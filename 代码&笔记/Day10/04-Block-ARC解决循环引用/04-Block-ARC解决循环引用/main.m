//
//  main.m
//  03-Block-循环引用
//
//  Created by 周健平 on 2019/11/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        //【1】
        JPPerson *per = [[JPPerson alloc] init];
        per.age = 11;
        __weak JPPerson *weakPer = per;
        per.block = ^{
            NSLog(@"~ %d", weakPer.age);
        };
        per.block();
        [per test];
        
        JPPerson *per1 = [[JPPerson alloc] init];
        per1.age = 32;
        __unsafe_unretained JPPerson *weakPer1 = per1;
        per1.block = ^{
            NSLog(@"~ %d", weakPer1.age);
        };
        per1.block();
        
        //【2】
        JPPerson *per2 = [[JPPerson alloc] init];
        per2.age = 75;
        __block JPPerson *blockPer2 = per2; // 包装成__block变量结构体
        // 结构体里面强引用这个blockPer2指针：JPPerson *__strong blockPer2;
        per2.block = ^{
            if (blockPer2) {
                NSLog(@"blockPer2 age is %d", blockPer2.age);
                blockPer2 = nil;
                // (blockPer2->__forwarding->blockPer2) = __null; --> 将真正指向blockPer2的指针置nil
            } else {
                NSLog(@"blockPer2 is nil");
            }
        };
        per2.block();
        per2.block();
        
        /*
         * 循环引用的产生：
            self --强引用--> block
             ↑_____强引用_____↓
         *
         * 解决循环引用【1】：
            self --强引用--> block
             ↑_____弱引用_____↓
         * 使用 __weak 或 __unsafe_unretained 修饰变量
         * __weak：不会产生强引用，指向的对象销毁时，会自动将指针置为nil（推荐）
         * __unsafe_unretained：不会产生强引用，指向的对象销毁时，不会自动将指针置为nil，存储的地址值不变（不推荐，虽然能解决循环引用问题，但不安全，会引发野指针问题 --- 坏内存访问）
         *
         * 解决循环引用【2】：
            self --强引用--> block
             ↑__×__强引用__×__↓
         * 使用 __block 修饰变量，并且在调用block的最后置nil，所以【必须】调用block
         * 在__block变量结构体里面的对象，是被__strong引用着
         * 如果一直不执行这个block，就会一直循环引用
         * 如果执行了这个block之后再执行，里面的这个变量则为nil
         * 被__block修饰的变量是另一种对象（__block变量结构体，里面强引用着原本对象），对这个对象置nil不会影响原对象，只是打破了引用循环
         */
        
    }
    NSLog(@"---------finish---------");
    return 0;
}
