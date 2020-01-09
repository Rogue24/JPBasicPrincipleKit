//
//  main.m
//  02-isa
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface JPPerson : NSObject <NSCopying>
{
    @public
    int _age;
}
@property (nonatomic, assign) int no;
- (void)personInstanceMethod;
+ (void)personClassMethod;
@end

@implementation JPPerson
- (void)personInstanceMethod {
    
}
+ (void)personClassMethod {
    
}
- (id)copyWithZone:(NSZone *)zone {
    return nil;
}
@end

@interface JPStudent : JPPerson <NSCoding>
{
    @public
    int _weight;
}
@property (nonatomic, assign) int height;
- (void)studentInstanceMethod;
+ (void)studentClassMethod;
@end

@implementation JPStudent
- (void)studentInstanceMethod {
    
}
+ (void)studentClassMethod {
    
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    return nil;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    
}
@end

struct jp_objc_class {
    Class isa;
    Class superclass;
};

//# if __arm64__        // 真机架构
//#   define ISA_MASK        0x0000000ffffffff8ULL
//# elif __x86_64__     // mac、模拟器架构
//#   define ISA_MASK        0x00007ffffffffff8ULL

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // 从64bitw开始，isa【需要】进行一次位运算，才能获得指向对象的真实地址
        // x86_64是mac系统架构，x86架构的64位处理器，ISA_MASK = 0x00007ffffffffff8
        
        //【1】验证实例对象的 isa & ISA_MASK 是否等于类对象的地址
        JPPerson *per = [[JPPerson alloc] init];
        Class perCls = [per class];
        // 打断点验证：per->isa & ISA_MASK = perCls
        // ↓↓↓
        // p/x per->isa：0x001d800100002441（实例对象的isa存放的地址）
        // p/x perCls：0x0000000100002440（类对象的地址）
        // 0x001d800100002441 & 0x00007ffffffffff8 = 0x0000000100002440
        
        //【2】验证类对象的 isa & ISA_MASK 是否等于元类对象的地址
        // PS：类对象无法直接获取isa，需要强制转型获取
        struct jp_objc_class *jp_perCls = (__bridge struct jp_objc_class *)perCls;
        Class perMCls = object_getClass(perCls);
        // 打断点验证：jp_perCls->isa & ISA_MASK = perMCls
        // ↓↓↓
        // p/x jp_perCls->isa：0x0000000100002418（类对象的isa存放的地址）
        // p/x perMCls：0x0000000100002418（元类对象的地址）
        // 0x0000000100002418 & 0x00007ffffffffff8 = 0x0000000100002418
        
        // 打印isa地址：p/x per->isa
        // 打印类对象地址：p/x perCls
        NSLog(@"JPPerson的实例对象 %p", per);
        NSLog(@"JPPerson的类对象 %p %p", perCls, jp_perCls);
        NSLog(@"JPPerson的元类对象 %p", perMCls);
        
        //【3】superclass指针【不需要】进行位运算，直接指向父类的类对象/元类对象
        /**
         * 如何查看类对象和元类对象的isa和superclass：
         * 因为类对象和元类对象都是struct objc_class，不能直接查看isa和superclass
         * 自定义一个差不多的struct，转换过来查看
         */
        struct jp_objc_class *jp_stuCls = (__bridge struct jp_objc_class *)([JPStudent class]);
        // ↓↓↓
        NSLog(@"JPStudent的superclass存放的地址 %p", jp_stuCls->superclass);
        NSLog(@"看看是不是跟JPPerson的类对象的地址一样？%p", perCls);
    }
    return 0;
}
