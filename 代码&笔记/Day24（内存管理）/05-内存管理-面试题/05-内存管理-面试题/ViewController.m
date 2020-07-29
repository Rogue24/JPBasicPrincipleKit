//
//  ViewController.m
//  05-内存管理-面试题
//
//  Created by 周健平 on 2019/12/15.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import <malloc/malloc.h>

/*
 * OC源码中的定义：
 * 判断是否TaggedPointed的掩码 _OBJC_TAG_MASK
 * 决定这个掩码的条件 OBJC_MSB_TAGGED_POINTERS
 
 * OBJC_MSB_TAGGED_POINTERS的定义：
    #if (TARGET_OS_OSX || TARGET_OS_IOSMAC) && __x86_64__
    #   define OBJC_MSB_TAGGED_POINTERS 0 ==> Mac平台，条件是0
    #else
    #   define OBJC_MSB_TAGGED_POINTERS 1 ==> 非Mac平台（iOS、iPadOS、watchOS），条件是1
    #endif
 
 * _OBJC_TAG_MASK的定义：
    #if OBJC_MSB_TAGGED_POINTERS
    #   define _OBJC_TAG_MASK (1UL<<63) ==> 条件是1，则为iOS平台，判断的是最高有效位（第64位）
    #else
    #   define _OBJC_TAG_MASK 1UL ==> 条件是0，则为Mac平台，判断的是最低有效位（第1位）
    #endif
 
 * iOS平台的判定位为最高有效位（第64位）
 * Mac平台的判定位为最低有效位（第1位）
 */

@interface ViewController ()
@property (nonatomic, copy) NSString *name;
@end

@implementation ViewController

#warning 当前为【iOS平台】

BOOL isTaggedPointer(id pointer) {
    return (long)(__bridge void *)pointer & (long)(1UL<<63); // iOS平台是最高有效位（第64位）
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *str1 = [NSString stringWithFormat:@"zhoujianping"];
    NSString *str2 = [NSString stringWithFormat:@"zjp"];
    
    NSLog(@"PS1：OC对象的地址的最低有效位肯定是0，那是因为OC对象是以16做为倍数来进行内存对齐，所以最低位肯定是0");
    NSLog(@"PS2：iOS平台的判定位为最高有效位（第64位），Mac平台的判定位为最低有效位（第1位）");
    
    NSLog(@"查看内存地址");
    NSLog(@"str1 --- %p", str1);
    NSLog(@"str2 --- %p", str2);
    NSLog(@"str1是OC对象，所以地址的判定位是%d", isTaggedPointer(str1));
    NSLog(@"str2是TaggedPointer指针，所以地址的判定位是%d", isTaggedPointer(str2));
    
    NSLog(@"查看ASCII码");
    NSLog(@"z --- %d", 'z');
    NSLog(@"j --- %d", 'j');
    NSLog(@"p --- %d", 'p');
    NSLog(@"查看对应的十六进制");
    NSLog(@"0x7a --- %d", 0x7a);
    NSLog(@"0x6a --- %d", 0x6a);
    NSLog(@"0x70 --- %d", 0x70);
    
    /*
     * 按照以前版本（iOS12前）str2应该是：0xa00000000706a7a1（开头a和结尾1是随便写的）
     * 现在最新版本（iOS12起）str2变成是：0xa1d6857eff10bb4f
     * 新版本应该是加了个掩码，这里按【以前版本】来解释：
     * 0xa00000000706a7a1
        a ---- 1010，可以看到最高有效位是1，说明这是Tagged Poinnter
        7a --- z
        6a --- j
        70 --- p
     */
    
    NSLog(@"查看分配的内存大小");
    NSLog(@"str1 --- %zd", malloc_size((__bridge const void *)(str1))); // 32
    NSLog(@"str2 --- %zd", malloc_size((__bridge const void *)(str2))); // 0
    NSLog(@"可以看出str2根本不是个对象，没有分配新的内存空间来存储，而是利用str2自身这个指针的地址来存值");
    NSLog(@"因为str1的内容在64位的存储空间（指针的最大取值范围）不够用，所以要使用动态分配内存的方式来存储数据");
    
    NSLog(@"直接查看类型，一切明了");
    NSLog(@"str1 --- %@", str1.class); // __NSCFString
    NSLog(@"str2 --- %@", str2.class); // NSTaggedPointerString
    
    NSLog(@"hello~");
}

// 会崩溃
- (IBAction)action1:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            self.name = [NSString stringWithFormat:@"zhoujianping"];
        });
    }
}

/*
 * why崩溃？
 * 属性name的setter方法在MRC环境下（<<ARC环境下编译后也会转成MRC模式下的代码>>）是酱紫：
     - (void)setName:(NSString *)name {
         if (_name != name) {
             [_name release];
             _name = [name copy];
         }
     }
 * 由于上面方法是【同时】开启【多个线程】去进行setter操作
 * 会极大几率导致其中一条线程release操作刚执行完，都还没进行赋值，另一条线程这时又执行了release操作，所以崩溃。
 * 原因就是【连续执行release操作】造成的【坏内存访问】。
 */

/*
 * 解决方案：
 * 1：nonatomic改成atomic，其实就是在setter内部加解🔐
 * 2：在setter外部加解🔐
     加🔐
     self.name = [NSString stringWithFormat:@"zhoujianping"];
     解🔐
 */

// 不会崩溃
- (IBAction)action2:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            self.name = [NSString stringWithFormat:@"zjp"];
        });
    }
}

/*
 * why不崩溃？
 * 因为 [NSString stringWithFormat:@"zjp"] 这不是一个OC对象，而是一个TaggedPointer
 * 意味着这里的赋值不会像OC对象的setter方法那样会先release后retain或copy再赋值，而是将TaggedPointer这个指针变量的地址值【直接】赋值给"_name"这个成员变量，修改地址值而已，【完全没有内存相关的操作】，因此不会出现连续执行release操作造成的坏内存访问（崩溃）。
 */

@end
