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
 * GlobalBlock：【没有访问任何auto变量】的block（只访问了static变量也是Global）
 * MallocBlock：对StackBlock调用了copy（StackBlock升级为MallocBlock）
 * StackBlock：访问了auto变量
 *
 * 每一种类型的Block调用copy后的结果：
 * GlobalBlock --copy--> GlobalBlock，啥事没有
 * MallocBlock --copy--> MallocBlock，还是在【堆】，引用计数+1，需要注意内存管理
 * StackBlock  --copy--> MallocBlock，内存从【栈】搬到【堆】，引用计数+1，需要注意内存管理
 */

typedef void (^JPBlock)(void);

JPBlock jpblock() {
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
        
        //【1】block作为函数返回值时
        JPBlock block1 = jpblock();
        NSLog(@"block1 作为函数返回值 %@", [block1 class]);
        
        //【2】将block赋值给__strong指针时（至少在作用域范围内不被销毁的指针）
        int b = 8;
        NSLog(@"block2 没赋值 %@", [^{
            NSLog(@"Hello, Block! %d", b);
        } class]);
        
        JPBlock block2 = ^{
            NSLog(@"Hello, Block! %d", b);
        };
        NSLog(@"block2 赋值了 %@", [block2 class]);
        
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
         * MRC下block属性的建议方法：
         * @property (nonatomic, copy) void (^blockName)(void);
         *
         * ARC下block属性的建议方法：
         * @property (nonatomic, copy) void (^blockName)(void);
         * @property (nonatomic, strong) void (^blockName)(void);
         */
    }
    return 0;
}
