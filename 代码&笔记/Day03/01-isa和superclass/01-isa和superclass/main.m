//
//  main.m
//  01-isa和superclass
//
//  Created by 周健平 on 2019/10/23.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "NSObject+Test.h"

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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        /**
         * 方法调用 -> 消息机制：
         * 本质上就是给对象发送了方法的消息
         * C++代码：objc_msgSend(perIns, sel_registerName("personInstanceMethod"));
         */
        
        JPPerson *perIns = [[JPPerson alloc] init];
        [perIns personInstanceMethod];
        // instance(JPPerson) --isa--> class(JPPerson) ==> -personInstanceMethod
        
        Class perCls = [JPPerson class];
        [perCls personClassMethod];
        // class(JPPerson) --isa--> meta-class(JPPerson) ==> +personClassMethod
        
        JPStudent *stu = [[JPStudent alloc] init];
        [stu personInstanceMethod];
        // instance(JPPerson) --isa--> class(JPStudent) --superclass--> class(JPPerson) ==> -personInstanceMethod
        
        Class stuCls = [JPStudent class];
        [stuCls personClassMethod];
        // class(JPStudent) --isa--> meta-class(JPStudent) --superclass--> meta-class(JPPerson) ==> +personClassMethod
        
        // isa指针：instance对象指向class对象，class对象指向meta-class对象，（所有）meta-class对象指向基类的meta-class对象（包括基类自己的meta-class对象也是指向自己本身）
        
        // superclass指针：instance对象没有superclass指针，class对象指向父类的class对象，meta-class对象指向父类的meta-class对象，基类的class对象指向空，基类的meta-class对象指向基类的class对象
        
        NSLog(@"JPStudent --- %p", [JPStudent class]);
        [JPStudent test];
        // class(JPStudent) --isa--> meta-class(JPStudent) --superclass--> meta-class(JPPerson) --superclass--> meta-class(NSObject) --superclass--> class(NSObject) ==> -test
        
        NSLog(@"JPPerson --- %p", [JPPerson class]);
        [JPPerson test];
        // class(JPPerson) --isa--> meta-class(JPPerson) --superclass--> meta-class(NSObject) --superclass--> class(NSObject) ==> -test
        
        NSLog(@"NSObject --- %p", [NSObject class]);
        [NSObject test];
        // class(NSObject) --isa--> meta-class(NSObject) --superclass--> class(NSObject) ==> -test
        
        /**
         * 类对象调用实例方法的解释：
         * 基类的meta-class对象的superclass指针指向的是基类的class对象
         * 当最终来到【基类的元类对象】里面发现没有对应的【类方法】，【基类的元类对象】就会通过【superclass指针】去到【基类的类对象】里面，查询有没有相同名字的【实例方法】，找到就调用，找不到就会报unrecognized selector的错误。
         * 同时验证了OC的方法调用本质就是发消息，代码是objc_msgSend(xxx, sel_registerName("xxxx"))，可以看到代码里面的方法写的只是方法名字，并没有带+、-号，是用名字找方法，不会区分这是实例方法还是类方法。
         */
    }
    return 0;
}
