//
//  main.m
//  01-Block的copy
//
//  Created by 周健平 on 2019/11/2.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Block的类型及其由来：
 * GlobalBlock：【没有访问任何auto变量】的block
 * MallocBlock：对StackBlock调用了copy（StackBlock升级为MallocBlock）
 * StackBlock：【只要有访问了auto变量】的block
 *
 * PS：static变量不是auto变量，跟全局变量一样，都是一直存在内存中
 *
 * 每一种类型的Block调用copy后的结果：
 * GlobalBlock --copy--> GlobalBlock，啥事没有
 * MallocBlock --copy--> MallocBlock，还是在【堆】，并不会再产生一块新的内存，而是引用计数+1，需要注意内存管理
 * StackBlock  --copy--> MallocBlock，内存从【栈】搬到【堆】，引用计数+1，需要注意内存管理
 */

typedef void (^JPBlock)(void);
JPBlock jpblock(void) {
    int a = 9;
    return ^{
        NSLog(@"Hello, Block! %d", a);
    };
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // 在ARC环境下，编译器会根据情况自动将栈上的block复制到堆上：
        // StackBlock --> MallocBlock
        
        //【有以下几种情况会自动copy】
        
        //【1】block作为函数返回值时
        NSLog(@"【1】block作为函数返回值时 %@", [jpblock() class]);
        
        //【2】将block赋值给__strong指针时（至少在作用域范围内不被销毁的指针）
        int b = 8;
        JPBlock strongBlock = ^{
            NSLog(@"Hello, Block! %d", b);
        };
        NSLog(@"【2】将block赋值给__strong指针 %@", [strongBlock class]);
        
        // ARC环境下还会存在StackBlock的情况1：
        NSLog(@"【2.1】没有赋值给__strong指针 %@", [^{
            NSLog(@"Hello, Block! %d", b);
        } class]);
        
        // ARC环境下还会存在StackBlock的情况2：
        __weak JPBlock weakBlock = ^{
            NSLog(@"Hello, Block! %d", b);
        }; // 将block赋值给__weak指针时还是StackBlock类型
        JPBlock copyWeakBlock = [weakBlock copy]; // StackBlock  --copy--> MallocBlock
        NSLog(@"【2.2】将block赋值给__weak指针 %@ %@", weakBlock, [weakBlock class]);
        NSLog(@"【2.2】对StackBlock使用copy后 %@ %@", copyWeakBlock, [copyWeakBlock class]);
        
        //【3】block作为Cocoa API中方法名含有“usingBlock”的方法参数时
        [[NSArray new] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // ...
        }];
        
        //【4】block作为GCD API的方法参数时
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // ...
        });
        
        /**
         *【MRC环境】下 block 属性的建议：用`copy`修饰
         * @property (nonatomic, copy) void (^blockName)(void);
         *
         *【ARC环境】下 block 属性的建议：用`copy` or `strong`修饰
         * @property (nonatomic, copy) void (^blockName)(void);
         * @property (nonatomic, strong) void (^blockName)(void);
         */
    }
    return 0;
}
