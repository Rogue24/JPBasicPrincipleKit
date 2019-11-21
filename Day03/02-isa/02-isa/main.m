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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        Class perCls = [per class];
        Class perMCls = object_getClass(perCls);
        
        NSLog(@"%p %p %p", per, perCls, perMCls);
        // 打印isa地址：p/x per->isa
        // 打印类对象地址：p/x perCls
        
        // JPPerson的实例对象isa指向地址：0x001d800100002439
        // JPPerson的类对象地址：        0x0000000100002438
        
        // 【从64bitw开始，isa需要进行一次位运算，才能计算出真实地址】
        // 所以：per->isa & ISA_MASK = perCls
        // 0x001d800100002439 & 0x00007ffffffffff8 = 0x0000000100002438
        // x86_64是mac系统架构，x86架构的64位处理器，ISA_MASK为0x00007ffffffffff8
        
        // superclass指针不需要进行位运算，直接指向父类的类对象/元类对象
        /**
         * 如何查看类对象和元类对象的isa和superclass：
         * 因为类对象和元类对象都是struct objc_class，不能直接查看isa和superclass
         * 自定义一个差不多的struct，转换过来查看
         */
        struct jp_objc_class *jp_stuCls = (__bridge struct jp_objc_class *)([JPStudent class]);
        NSLog(@"%p %p", perCls, jp_stuCls->superclass);
    }
    return 0;
}

//# if __arm64__        // 真机架构
//#   define ISA_MASK        0x0000000ffffffff8ULL
//# elif __x86_64__     // mac、模拟器架构
//#   define ISA_MASK        0x00007ffffffffff8ULL
