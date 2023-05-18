//
//  main.m
//  04-内存管理-Tagged Pointer
//
//  Created by 周健平 on 2019/12/14.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * OC源码中的定义：
 * 判断是否TaggedPointed的掩码 _OBJC_TAG_MASK
 * 决定这个掩码的条件 OBJC_MSB_TAGGED_POINTERS

 * OBJC_MSB_TAGGED_POINTERS的定义：
    #if (TARGET_OS_OSX || TARGET_OS_IOSMAC) && __x86_64__
    #   define OBJC_MSB_TAGGED_POINTERS 0 ==> Mac平台，条件是【0】
    #else
    #   define OBJC_MSB_TAGGED_POINTERS 1 ==> 非Mac平台（iOS、iPadOS、watchOS），条件是【1】
    #endif

 * _OBJC_TAG_MASK的定义：
    #if OBJC_MSB_TAGGED_POINTERS ==> 判断 OBJC_MSB_TAGGED_POINTERS 的值
    #   define _OBJC_TAG_MASK (1UL<<63) ==> 是1，为iOS平台，判断的是最高有效位（第64位）
    #else
    #   define _OBJC_TAG_MASK 1UL ==> 是0，为Mac平台，判断的是最低有效位（第1位）
    #endif

 * iOS平台的判定位为【最高】有效位（第64位）
 * Mac平台的判定位为【最低】有效位（第1位）
 */

/*
 *【OC实例对象的十六进制内存地址的最低有效位肯定是0】
 * 因为在Mac、iOS中的malloc函数分配的内存大小总是【16】的倍数（内存对齐）
 * 16 = 0x10 = 0b00010000，所以对象的十六进制内存地址的最低有效位（第1位）肯定是【0】
 */

/*
 * 当NSNumber、NSDate、NSString存值很小的情况下
 * 在没有使用TaggedPointer之前：
    - NSNumber等对象需要动态分配内存、维护引用计数等，NSNumber指针存储的是堆中NSNumber对象的地址值（需要创建OC对象）
 * 使用TaggedPointer之后：
    - NSNumber指针里面存储的数据变成了：Tag + Data，也就是将数据直接存储在了指针中（不需要创建OC对象）
 
 * 当存值很大，指针不够存储数据时（超过64位），才会使用动态分配内存的方式来存储数据（创建OC对象）
 
 * objc_msgSend 能识别TaggedPointer，比如NSNumber的intValue方法，直接从指针提取数据，节省了以前的调用开销（而且这不是真的OC对象，根本就没有通过isa去找方法的操作）
 
 * 怎么识别？判定位是【1】就是TaggedPointer，否则就是OC对象。
    - iOS平台：判定位是最高有效位（第64位）
    - Mac平台：判定位是最低有效位（第1位）
    指针地址：
        0xde9733d5df1e1473
          ↓              ↓
        1101            0011
        ↓                  ↓
    最高有效位（第64位）  最低有效位（第1位）
        ↓                  ↓
    iOS平台判断这一位     Mac平台判断这一位
  
 */

#warning 当前为【Mac平台】

/*
 0b1110001
&0b0000001
----------
   0000001
*/
BOOL isTaggedPointer(id pointer) {
    return (long)(__bridge void *)pointer & (1UL << 0); // Mac平台是最低有效位（第1位）
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSNumber *num1 = @3;
        NSNumber *num2 = @4;
        NSNumber *num3 = @5;
        NSNumber *num4 = @(0xFFFFFFFFFFFFFFFF); // 数值太大，64位不够放，得alloc生成个对象来保存
        
        // 小数值的NSNumber对象，并不是alloc出来放在堆中的对象，只是一个单纯的指针，目标值是存放在指针的地址值中
        NSLog(@"%p %p %p %p", num1, num2, num3, num4); // 0x327 0x427 0x527 0x103210340
        
        // Tagged Pointer的NSNumber指针里面存储的数据变成了：Tag + Data，也就是将数据直接存储在了指针中
        // 例如：0x327 ==> 0x3(Data)27(Tag) // 0x27可能代表是NSNumber类型
        
        /*
         * PS：例如`@3`
         * 在以前版本的地址是0x327（第3位就是存值3，0x27是标识）
         * 现在版本（macOS 10.15.4）地址却是0x429707dbd8281ae5，一堆乱码似的，应该是底层多&了一层掩码（加密了？）
         */
        
        // 如何判断指针是否TaggedPointer：将指针地址&判定用的掩码，查看判定位是什么（Mac是第1位，iOS是第64位）
        // 判定位是【0】，这是分配到堆中的OC对象的内存地址（OC对象在内存中以16对齐，因此有效位肯定是0）
        // 判定位是【1】，这是Tagged Pointer
        NSLog(@"%d %d %d %d",
              isTaggedPointer(num1),
              isTaggedPointer(num2),
              isTaggedPointer(num3),
              isTaggedPointer(num4));
        // 1 1 1 0
        
        /*
         * 例如：num4 => 0x10054b580，num3 => 0x527（0x27 ==> 0b00100111）
                                   ↖第1位是0                           ↖第1位是1
         * 可以看出num4是堆中的OC对象，num3是TaggedPointer
         */
        
        // 底层直接通过位运算从指针中把目标值取出来
        NSLog(@"%d", num1.intValue);
        
        /*
         * TaggedPointer技术的好处：
         * 1.存值：直接把值存到指针中，不需要再新建一个OC对象来保存（额外多分配至少16个字节）--- 省内存
         * 2.取值：直接从指针中把目标值抽取出来，不需要像以前那样还得通过消息机制先找到intValue方法再调用才能获取那么麻烦 --- 性能好、效率高
         */
        
    }
    return 0;
}
