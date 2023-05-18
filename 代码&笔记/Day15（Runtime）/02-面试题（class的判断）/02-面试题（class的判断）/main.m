//
//  main.m
//  01-class
//
//  Created by 周健平 on 2019/11/21.
//  Copyright © 2019 周健平. All rights reserved.
//
//  isMemberOfClass和isKindOfClass：
//  1.实例对象调用，会用【类对象】去跟<传进来的Class对象>对比
//  2.类对象调用，会用【元类对象】去跟<传进来的Class对象>对比

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "JPPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        /**
         * `isMemberOfClass`：对比是不是等同于【此类】
         * `isKindOfClass`：对比是不是等同于【此类或其子类】
         *
         * 实例对象调用：
         * `isMemberOfClass`：直接通过`[self class]`获取自己的【类对象】去对比传进来的Class
         * `isKindOfClass`：通过`superclass`进行for循环 ，每次通过`[self class]`获取自己的【类对象】去对比传进来的Class
         *
         * 类对象调用：
         * `isMemberOfClass`：直接通过`object_getClass(self)`获取自己的【元类对象】去对比传进来的Class
         * `isKindOfClass`：通过`superclass`进行for循环 ，每次通过`object_getClass(self)`获取自己的【元类对象】去对比传进来的Class
         *
         * 特殊情况：`[JPPerson isKindOfClass:[NSObject class]]`、`[NSObject isKindOfClass:[NSObject class]]` ==> YES
         * 为啥用【元类对象】跟【类对象】对比会是YES？
         * 因为`superclass`通过for循环最后会来到根类（`NSObject`）的元类对象，
         * 而根类的元类对象的`superclass`就是指向根类的类对象（`[NSObject class]`），所以相等（YES）。
         *
         * 可以这么说：所有【元类对象】都属于【NSObject的类对象】的子类
         * ==> `[任意对象 isKindOfClass:[NSObject class]]` ==> `YES`
         */
        
        JPPerson *per = [[JPPerson alloc] init];
        
        NSLog(@"%d", [per isMemberOfClass:per.class]); // 1
        NSLog(@"%d", [per.class isMemberOfClass:per.class]); // 0
        NSLog(@"%d", [per isKindOfClass:per.class]); // 1
        NSLog(@"%d", [per.class isKindOfClass:per.class]); // 0
        
        NSLog(@"==========实例方法==========");
        NSLog(@"%d", [per isMemberOfClass:[JPPerson class]]); // 1
        NSLog(@"%d", [per isMemberOfClass:[NSObject class]]); // 0
        NSLog(@"--------------------------");
        NSLog(@"%d", [per isKindOfClass:[JPPerson class]]); // 1
        NSLog(@"%d", [per isKindOfClass:[NSObject class]]); // 1
        
        NSLog(@"==========类方法==========");
        NSLog(@"%d", [JPPerson isMemberOfClass:[JPPerson class]]); // 0
        NSLog(@"%d", [JPPerson isMemberOfClass:[NSObject class]]); // 0
        NSLog(@"--------------------------");
        NSLog(@"%d", [JPPerson isKindOfClass:object_getClass([JPPerson class])]); // 1
        NSLog(@"%d", [JPPerson isKindOfClass:object_getClass([NSObject class])]); // 1
        
        NSLog(@"==========特殊情况==========");
        NSLog(@"%d", [JPPerson isKindOfClass:[NSObject class]]); // 1
        NSLog(@"%d", [NSObject isKindOfClass:[NSObject class]]); // 1
        NSLog(@"%d", [object_getClass([JPPerson class]) isMemberOfClass:object_getClass([JPPerson class])]); // 0
        NSLog(@"%d", [object_getClass([JPPerson class]) isMemberOfClass:object_getClass([NSObject class])]); // 1
        NSLog(@"%d", [object_getClass([JPPerson class]) isKindOfClass:[NSObject class]]); // 1
        NSLog(@"%d", [object_getClass([NSObject class]) isMemberOfClass:[NSObject class]]); // 0
        
        NSLog(@"==========面试题==========");
        NSLog(@"%d", [NSObject isKindOfClass:[NSObject class]]); // 1
        NSLog(@"%d", [NSObject isMemberOfClass:[NSObject class]]); // 0
        NSLog(@"%d", [JPPerson isKindOfClass:[JPPerson class]]); // 0
        NSLog(@"%d", [JPPerson isMemberOfClass:[JPPerson class]]); // 0
    }
    return 0;
}

#pragma mark - NSObject的源码
//@implementation NSObject
//+ (BOOL)isMemberOfClass:(Class)cls {
//    return object_getClass((id)self) == cls;
//}
//
//- (BOOL)isMemberOfClass:(Class)cls {
//    return [self class] == cls;
//}
//
//+ (BOOL)isKindOfClass:(Class)cls {
//    for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
//        if (tcls == cls) return YES;
//    }
//    return NO;
//}
//
//- (BOOL)isKindOfClass:(Class)cls {
//    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
//        if (tcls == cls) return YES;
//    }
//    return NO;
//}
//@end
