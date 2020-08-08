//
//  main.m
//  01-KVC
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
#import "JPObserver.h"

/*
 * - (void)setValue:(nullable id)value forKey:(NSString *)key;
 * key只能写当前对象的成员变量（例如：@"age"）
 
 * - (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath;
 * keyPath可以写当前对象的成员变量，或成员变量的路径（例如：成员变量的成员变量 @"son.age"）
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        
        // 添加KVO监听
        JPObserver *observer = [[JPObserver alloc] init];
        [per addObserver:observer forKeyPath:@"age" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
        
        per->_age = 10;
        NSLog(@"成员变量直接赋值没有触发KVO ==> _age %d", per->_age);
        
#pragma mark KVC赋值
        // 通过KVC修改【属性/成员变量】的值
        [per setValue:@(20) forKey:@"age"];
        // 通过KVC修改的属性/成员变量，【不管有没有对应的setter方法，都会触发KVO】（KVO的子类应该通过-_isKVOA方法判定是否有监听器）
        // -setValue:forKey:的内部实现：
        // 1. [per willChangeValueForKey:@"age"];
        // 2. per->_age = 20;
        // 3. [per didChangeValueForKey:@"age"];
        NSLog(@"成员变量通过KVC赋值会触发KVO");
        
//        [per setValue:@(21) forKey:@"_age"];
//        [per setValue:@(22) forKey:@"_age"];
//        
//        [per setValue:@(23) forKey:@"_isAge"];
//        [per setValue:@(24) forKey:@"_isAge"];
//
//        [per setValue:@(25) forKey:@"isAge"];
//        [per setValue:@(26) forKey:@"isAge"];
        
        NSLog(@"_age %d", per->_age);
        NSLog(@"_isAge %d", per->_isAge);
        NSLog(@"age %d", per->age);
        NSLog(@"isAge %d", per->isAge);
        
        /*
         * -setValue:forKey: 的过程：
         * 1. 按照优先级为 -setKey: 、-_setKey: 的顺序查找方法
            - 1.1 找到：传递参数，调用方法
         * 2. 找不到，查看 +accessInstanceVariablesDirectly 方法是否为YES（是否允许访问成员变量，默认为YES）
            - 2.1 NO，不允许：抛出NSUnknownKeyException异常
         * 3. YES，允许，按照优先级为 _key、_isKey、key、isKey 的顺序查找成员变量
            - 3.1 找到：直接【赋值】
            - 3.2 找不到：抛出NSUnknownKeyException异常（崩溃）
         */
        
        // 如果key为@"_age"，那么查找成员变量的优先级为：__age、_is_age、_age、is_age，
        // 这里恰巧有_age这个成员变量，不然就会崩，所以别写错了。
        
        // 移除KVO监听
        [per removeObserver:observer forKeyPath:@"age"];
        
#pragma mark KVC取值
        per->_age = 100;
        per->_isAge = 200;
        per->age = 300;
        per->isAge = 400;
        
        id age = [per valueForKey:@"age"];
        NSLog(@"成员变量通过KVC取值 ==> age is %@", age);
        
        /*
         * -valueForKey: 的过程：
         * 1. 按照优先级为 -getKey 、-key、-isKey、-_key 的顺序查找方法
            - 1.1 找到：调用方法，取值
         * 2. 找不到，查看 +accessInstanceVariablesDirectly 方法是否为YES（是否允许访问成员变量，默认为YES）
            - 2.1 NO，不允许：抛出NSUnknownKeyException异常
         * 3. YES，允许，按照优先级为 _key、_isKey、key、isKey 的顺序查找成员变量
            - 3.1 找到：直接【取值】
            - 3.2 找不到：抛出NSUnknownKeyException异常（崩溃）
         */
    }
    return 0;
}
