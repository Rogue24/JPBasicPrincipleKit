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
        
        /*
         * 循环引用的产生：
           self --强引用--> block
            ↑_____强引用_____↓
         *
         *【MRC】解决循环引用：
            self --强引用--> block
             ↑_____弱引用_____↓
         * 1.使用 __unsafe_unretained 来修饰变量
         * 2.使用 __block 来修饰变量
         */
        
        // *****【MRC】不支持__weak *****
        
        // ==================== __unsafe_unretained ====================
        JPPerson *per = [[JPPerson alloc] init];
        per.age = 11;
        
        __unsafe_unretained JPPerson *usurPer = per;
        per.block = [^{
            NSLog(@"使用__unsafe_unretained修饰 %d", usurPer.age);
        } copy];
        per.block();
        [per release];
        
        /*
         * __unsafe_unretained：不会产生强引用，指向的对象销毁时，不会自动将指针置为nil，存储的地址值不变
         * PS：不推荐使用__unsafe_unretained，虽然能解决循环引用问题，但【不安全】，会引发野指针问题 --> 坏内存访问
         */
        
        
        // ==================== __block ====================
        JPPerson *per2 = [[JPPerson alloc] init];
        per2.age = 31;
        
        __block JPPerson *blockPer = per2;
        per2.block = [^{
            NSLog(@"使用__block修饰 %d", blockPer.age);
        } copy];
        per2.block();
        [per2 release];
        
        /*
         * __block：对象被包装成__block变量结构体，不会对原有的对象进行retain操作，不会产生强引用（推荐）
         * PS：__block变量结构体的_Block_object_assign函数，在【ARC】环境下，会根据所指向对象的修饰符（__strong、__weak、__unsafe_unretained）做出相应的操作，形成强引用（retain）或者弱引用，而在【MRC】环境下是不会retain的
         */
        
        
        
//        NSLog(@"下面验证：使用__block修饰的那个对象，虽然不会造成循环引用，但释放之后再访问，会不会造成坏内存访问呢？");
//
//        __block JPPerson *blockPer2 = [[JPPerson alloc] init];
//        blockPer2.age = 0;
//
//        JPPerson *per3 = [[JPPerson alloc] init];
//        per3.block = [^{
//            blockPer2.age += 1;
//            NSLog(@"blockPer2 %@ %d", blockPer2, blockPer2.age);
//        } copy];
//        per3.block();
//
//        [blockPer2 release]; // 先释放。。。
//
//        // 再调用。。。
//
//        // PS：即使blockPer2的dealloc打印了信息，但blockPer2并不会立马死，所以这里弄个循环调用
//        // 如果没释放这100次都没事
//        // 如果有置nil也是没事
//        // 如果单纯没有retain，那么释放后再访问，肯定会崩溃嘛
//        for (NSInteger i = 0; i < 100; i++) {
//            per3.block();
//        }
//
//        // 结论：崩溃了！
//        // 也就是说，MRC的__block真的单纯不会retain而已，不会自动置nil。
//        // 那其实跟__unsafe_unretained差不多嘛！
//
//        [per3 release];
    }
    NSLog(@"---------finish---------");
    return 0;
}
