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

#warning 当前在MRC环境下！
// 关闭ARC：Targets --> Build Settings --> 搜索automatic reference --> 设置为NO

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
             *【ARC】编译器会自动将栈上的block复制到堆上（StackBlock ---> MallocBlock）
             *【MRC】编译器并不会将栈上的block复制到堆上（StackBlock）
             */
            
            // 2.block捕获了per这个auto变量（对象类型）：
            /**
             * StackBlock【栈空间的block】
             *  - 永远都不会对捕获的 auto 变量产生【强引用】！相当于只存储指向的地址值，并不会改变它的引用计数！
             *  <<毕竟自身随时被销毁，也就没必要强引用其他对象>>
             *  - 执行 StackBlock 时（在另一个作用域），捕获的 auto 变量有可能就已经被销毁了，就会造成坏内存访问的错误
             * 所以 StackBlock 存活期间【不会】保住 per 的命
             *
             * MallocBlock【堆空间的block】
             *  - 拷贝到堆上时，会自动对捕获的auto变量进行一次`retain`操作：`[per retain]`
             *  - 从堆上移除时，会自动对捕获的auto变量进行一次`release`操作：`[per release]`
             * 所以 MallocBlock 存活期间【会】保住 per 的命
             */
            
            jpblock = ^{
                NSLog(@"Hello, Block! %@ %d", per, per.age);
            };
            
            NSLog(@"00 retainCount %zd", [per retainCount]);
            
            //【MRC】StackBlock ---copy---> MallocBlock
            NSLog(@"jpblock before copy: %@", [jpblock class]);
            jpblock = [jpblock copy]; // per.retainCount += 1 拷贝到堆上，对per进行一次retain
            NSLog(@"jpblock after copy: %@", [jpblock class]);
            
            NSLog(@"11 retainCount %zd", [per retainCount]);
            
            //【MRC】
            [per release]; // per.retainCount -= 1 引用计数为0就会销毁
            
            NSLog(@"22 retainCount %zd", [per retainCount]);
            
//            jpblock = [jpblock copy];
//            NSLog(@"33 retainCount %zd", [per retainCount]);
//            jpblock = [jpblock copy];
//            NSLog(@"55 retainCount %zd", [per retainCount]);
//            [jpblock release];
//            NSLog(@"55 retainCount %zd", [per retainCount]);
//            [jpblock release];
//            NSLog(@"66 retainCount %zd", [per retainCount]);
//            [jpblock release];
//            NSLog(@"77 retainCount %zd", [per retainCount]);
            // 📢 注意：
            // `block`只有【拷贝到堆上时】，才会对捕获的auto变量进行一次`retain`操作，
            // 同理，也只有【从堆上移除时】，才会对捕获的auto变量进行一次`release`操作，
            // 只有这两种情况，其余时候`block`再怎么copy/release，都只会对`block`自己进行`retain/release`操作，并不会对捕获的auto变量进行`retain/release`操作。
            
            //【PS1】如果block没有在堆上，per就会在{}结束后就死了
            NSLog(@"over~");
        }
        
        // 如果上面{}中没有对jpblock进行copy操作，那么执行它就会崩溃！因为里面的per已经死了！
        jpblock();
        
        // 注意：对MallocBlock再进行一次copy操作，引用计数会+1
        jpblock = [jpblock copy];
        
        //【PS2】如果block在堆上，per会跟随block一起被销毁
        
        //【MRC】
        // copy了几次就得release几次，否则内存泄漏。
        [jpblock release];
        [jpblock release];
    }
    return 0;
}
