//
//  main.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "JPPerson.h"
#import "JPPerson+JPTest1.h"
#import "JPPerson+JPTest2.h"
#import "JPStudent.h"
#import "JPStudent+JPTest1.h"
#import "JPStudent+JPTest2.h"
#import "NSObject+JPExtension.h"
#import "JPBoy.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /**
         * initialize方法会在类【第一次接收到消息】时调用，load方法是初始化Runtime时直接拿到方法地址去调用
         * 如果整个程序都没有使用过这个类，就不会调用initialize
         */
        
        // insert code here...
        NSLog(@"Hello, World!");
        
        // 🌰1_子类有实现initialize：
        // 如果父类没调用过initialize，会先调用父类的initialize，再调用子类的initialize。
        [JPStudent alloc];
        
        // 🌰2_子类没实现initialize：
        // 如果子类的initialize没有实现，父类调用完initialize后，会【再次】调用父类（JPPerson）的initialize。
        // 不信就把上面那句“[JPStudent alloc]”注释了再运行看看，父类的initialize会被连续调用两次。
        [JPBoy alloc];
        
        /*
         * initialize是通过消息机制调用，所以【分类的initialize方法优先级更高】
         * 调用顺序：
            1. objc_msgSend(JPPerson.class, @selector(initialize));
            2. objc_msgSend(JPStudent.class, @selector(initialize));
         * 先调用父类的initialize，再调用子类的initialize
         * 如果子类的initialize没有实现，会再次调用父类的initialize，所以【父类的initialize可能会被调用多次】
         *
         * 大概酱紫的逻辑（伪代码）：
            // 调用某个方法前，先检查自己有没有初始化
            if (!self.isInitialized) {
                // -------- 自己没有初始化 --------
         
                // ---- 先检查父类有没有初始化 ----
                if (!super.isInitialized) {
                    // 父类没有初始化，调用父类的initialize
                    objc_msgSend(super.class, @selector(initialize));
                    // 📌 标记<父类>已经初始化
                    super.isInitialized = YES;
                }
         
                if (@selector(initialize)) {
                    // 如果自己有initialize方法，就调用【自己的】
                    objc_msgSend(self.class, @selector(initialize));
                } else {
                    // 如果自己没有initialize方法，就调用【父类的】
                    objc_msgSend(super.class, @selector(initialize));
                }
         
                // 📌 标记<自己>已经初始化
                self.isInitialized = YES;
            }
            // 检查完了，继续去调用某个方法吧
         *
         */
        
        // 到这里已经接收过消息了（已经标记初始化），所以不会再调用initialize方法了。
        [JPStudent alloc];
        [JPBoy alloc];
        NSLog(@"Goodbye, World!");
    }
    return 0;
}

/*
 
 // objc_msgSend：调用某个方法，就是通过 isa -> 类/元类对象 -> 寻找方法 -> 调用
 最新源码中寻找方法列表的操作：
 class_getClassMethod
 ↓
 class_getInstanceMethod
 ↓
 lookUpImpOrNil
 ↓
 lookUpImpOrForward
 ↓
 if (initialize && !cls->isInitialized()) {
     cls = initializeAndLeaveLocked(cls, inst, runtimeLock);
 }
 ↓
 initializeAndMaybeRelock
 ↓
 // 判断是否已经调用过initialize
 if (cls->isInitialized()) {
     if (!leaveLocked) lock.unlock();
     return cls;
 }
 →→→ YES，【确保了已经调用过initialize方法，继续去寻找要去调用的方法】
 ↓
 NO，没有则继续往下
 ↓
 initializeNonMetaClass
 ↓↑ 递归（确保是从第一任父类开始依次调用，保证先执行完所有父类的initialize方法）
 initializeNonMetaClass(supercls);
 ↓
 callInitialize
 ↓
 ((void(*)(Class, SEL))objc_msgSend)(cls, SEL_initialize); // 发送initialize方法消息
 // 由于这是通过objc_msgSend去调用，所以如果子类的initialize方法没有实现，就会【再次】调用父类的initialize方法
 ↓
 // 至此，【确保了已经调用过initialize方法】，继续去寻找要去调用的方法。
 
*/
