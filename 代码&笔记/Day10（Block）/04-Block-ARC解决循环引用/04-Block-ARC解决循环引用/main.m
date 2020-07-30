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
        
        /*
         * 循环引用的产生：
            self --强引用--> block
             ↑_____强引用_____↓
         */
        
        // ==================== 解决循环引用【1】====================
        JPPerson *per = [[JPPerson alloc] init];
        per.age = 11;
        __weak JPPerson *weakPer = per;
        per.block = ^{
            NSLog(@"（外部）使用__weak修饰 %d", weakPer.age);
        };
        per.block();
        [per test];
        
        JPPerson *per1 = [[JPPerson alloc] init];
        per1.age = 32;
        __unsafe_unretained JPPerson *usurPer = per1;
        per1.block = ^{
            NSLog(@"使用__unsafe_unretained修饰 %d", usurPer.age);
        };
        per1.block();
        
        /*
         * 解决循环引用【1】：
            self --强引用--> block
             ↑_____弱引用_____↓
         * 使用 __weak 或 __unsafe_unretained 修饰变量
         * __weak：不会产生强引用，指向的对象销毁时，会自动将指针置为nil（推荐）
         * __unsafe_unretained：不会产生强引用，指向的对象销毁时，不会自动将指针置为nil，存储的地址值不变，还是那个地址
         * PS：不推荐使用__unsafe_unretained，虽然能解决循环引用问题，但【不安全】，会引发野指针问题 --> 坏内存访问
         */
        
        
        // ==================== 解决循环引用【2】====================
        JPPerson *per2 = [[JPPerson alloc] init];
        per2.age = 75;
        __block JPPerson *blockPer = per2; // 包装成__block变量结构体
        // 结构体里面强引用这个blockPer2指针：JPPerson *__strong blockPer2;
        per2.block = ^{
            if (blockPer) {
                NSLog(@"blockPer.age is %d", blockPer.age);
                blockPer = nil;
                // (blockPer->__forwarding->blockPer2) = __null; --> 将真正指向blockPer2的指针置nil
            } else {
                NSLog(@"blockPer is nil");
            }
        };
        per2.block();
        per2.block();
        
        /*
         * 解决循环引用【2】：
            self --强引用--> block
                              ↓
            nil <--强引用-------
         * 使用__block修饰变量来解决循环引用，首先【必须】得在block内部逻辑的最后【对其置为nil】，并且【必须要调用】block
         * 因为，在__block变量结构体里面的对象，是被__strong引用着
         * 所以，如果一直不执行这个block，就会一直循环引用
         * 另外，如果执行了这个block之后再执行一次这个block，里面的这个变量则为nil，因为上一次执行的最后已经置nil
         */
        
        NSLog(@"调用block之后，per2 is %@", per2);
        NSLog(@"调用block之后，blockPer is %@", blockPer);
        /*
         * blockPer是另一种对象（__block变量结构体，里面强引用着per2）
         * 对blockPer置nil不会影响per2，只是用来打破引用循环
         */
    }
    NSLog(@"---------finish---------");
    return 0;
}
