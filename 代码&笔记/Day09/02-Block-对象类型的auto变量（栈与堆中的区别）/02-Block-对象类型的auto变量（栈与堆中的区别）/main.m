//
//  main.m
//  01-Block的copy
//
//  Created by 周健平 on 2019/11/2.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

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

#warning 当前在MRC环境下！

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        void (^jpblock)(void);
        
        {
            JPPerson *per = [[JPPerson alloc] init];
            per.age = 19;
            NSLog(@"per %@", per);
            
            // 1.将block赋值给__strong指针时：
            /**
             *【ARC】编译器会自动将栈上的block复制到堆上（StackBlock --> MallocBlock）
             *【MRC】编译器并不会将栈上的block复制到堆上（StackBlock）
             */
            
            // 2.block捕获了per这个auto变量（对象类型的）：
            /**
             *【栈空间的block】
             * 不会对捕获的auto变量产生强引用，永远都是弱引用（毕竟自身随时被销毁，也就没必要强引用其他对象）
             * 执行block时，捕获的auto变量有可能就已经被销毁了，就会造成坏内存访问的错误
             * 所以block存活期间【不会】保住per的命
             *
             *【堆空间的block】
             * 拷贝到堆上时会自动对捕获的auto变量进行一次retain操作：[per retain];
             * 从堆上移除时自动对捕获的auto变量进行一次release操作：[per release];
             * 所以block存活期间【会】保住per的命
             */
            
            jpblock = ^{
                NSLog(@"Hello, Block! %@ %d", per, per.age);
            };
            
            //【MRC】StackBlock --> copy --> MallocBlock
            NSLog(@"jpblock before copy: %@", [jpblock class]);
            jpblock = [jpblock copy];
            NSLog(@"jpblock after copy: %@", [jpblock class]);
            
            //【MRC】
            [per release]; // 引用计数为0就会销毁，但有可能不是立马销毁的
            
            //【PS1】如果block没有在堆上，per就会在{}结束后就死了
            NSLog(@"over~");
        }
        
        jpblock();
        
        // 注意：对MallocBlock再进行一次copy操作，引用计数会+1
        jpblock = [jpblock copy];
        
        //【PS2】如果block在堆上，per跟随block一起被销毁
        
        //【MRC】
        [jpblock release];
        [jpblock release];
    }
    return 0;
}
