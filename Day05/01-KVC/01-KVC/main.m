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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        
        JPObserver *observer = [[JPObserver alloc] init];
        [per addObserver:observer forKeyPath:@"age" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
        
        // 通过KVC修改 属性/成员变量 的值
        // 通过KVC修改，不管有没有对应的setter方法，都会触发KVO（通过-_isKVOA方法判定是否有监听器）
        [per setValue:@(20) forKey:@"age"];
        // 内部实现：
        // 1. [per willChangeValueForKey:@"age"];
        // 2. per->_age = 20;
        // 3. [per didChangeValueForKey:@"age"];
        
        NSLog(@"_age %d", per->_age);
        NSLog(@"_isAge %d", per->_isAge);
        NSLog(@"age %d", per->age);
        NSLog(@"isAge %d", per->isAge);
        
        /**
         * -setValue:forKey: 的过程：
         * 1. 按照优先级为 -setKey: 、-_setKey: 的顺序查找方法
         * 1.1 找到：传递参数，调用方法
         * 2. 找不到，查看 +accessInstanceVariablesDirectly 方法是否为YES（是否允许访问成员变量，默认为YES）
         * 2.1 NO，不允许：抛出NSUnknownKeyException异常
         * 3. YES，允许，按照优先级为 _key、_isKey、key、isKey 的顺序查找成员变量
         * 3.1 找到：直接赋值
         * 3.2 找不到：抛出NSUnknownKeyException异常
         */
        
        [per removeObserver:observer forKeyPath:@"age"];
        
        
        per->_age = 100;
        per->_isAge = 200;
        per->age = 300;
        per->isAge = 400;
        
        id age = [per valueForKey:@"age"];
        NSLog(@"age is %@", age);
        
        /**
         * -valueForKey: 的过程：
         * 1. 按照优先级为 -getKey 、-key、-isKey、-_key 的顺序查找方法
         * 1.1 找到：调用方法，取值
         * 2. 找不到，查看 +accessInstanceVariablesDirectly 方法是否为YES（是否允许访问成员变量，默认为YES）
         * 2.1 NO，不允许：抛出NSUnknownKeyException异常
         * 3. YES，允许，按照优先级为 _key、_isKey、key、isKey 的顺序查找成员变量
         * 3.1 找到：直接取值
         * 3.2 找不到：抛出NSUnknownKeyException异常
         */
    }
    return 0;
}
