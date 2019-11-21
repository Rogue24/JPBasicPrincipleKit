//
//  main.m
//  03-Block-循环引用
//
//  Created by 周健平 on 2019/11/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

#warning 当前在MRC环境下！

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // *****【MRC】不支持__weak *****
        
        //【1】
        JPPerson *per = [[JPPerson alloc] init];
        per.age = 11;
        
        __unsafe_unretained JPPerson *weakPer = per;
        per.block = [^{
            NSLog(@"~ %d", weakPer.age);
        } copy];
        per.block();
        
        JPPerson *per2 = [[JPPerson alloc] init];
        per2.age = 31;
        
        __block JPPerson *weakPer2 = per2;
        per2.block = [^{
            NSLog(@"~ %d", weakPer2.age);
        } copy];
        per2.block();
        
        [per release];
        [per2 release];
        
        /*
         * 循环引用的产生：
            self --强引用--> block
             ↑_____强引用_____↓
         *
         * 解决循环引用：
            self --强引用--> block
             ↑_____弱引用_____↓
         * 使用 __unsafe_unretained 或 __block 修饰变量
         * __unsafe_unretained：不会产生强引用，指向的对象销毁时，不会自动将指针置为nil，存储的地址值不变（不推荐，虽然能解决循环引用问题，但不安全，会引发野指针问题 --- 坏内存访问）
         * __block：对象被包装成__block变量结构体，不会对原有的对象进行retain操作，不会产生强引用（推荐）
         * PS：在【ARC】环境下，__block变量结构体里面的对象是被__strong引用着，block调用_Block_object_assign函数时会对结构体里面的对象进行retain操作，而【MRC】环境下是不会的，类似弱引用
         */
        
    }
    NSLog(@"---------finish---------");
    return 0;
}
