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
#import "JPBitch.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        /**
         * initialize方法会在类第一次【接收到消息】时调用，load方法是直接拿到方法地址去调用
         * 如果整个程序都没有使用过这个类，就不会调用initialize
         */
        
        // insert code here...
        NSLog(@"Hello, World!");
        
        // 如果父类没调用过initialize，会先调用父类的initialize，再调用子类的initialize
        [JPStudent alloc];
        // 如果子类的initialize没有实现，会再次调用父类（JPPerson）的initialize
        [JPBitch alloc];
        
        /**
         * initialize是通过消息机制调用，所以分类的initialize方法优先级更高
         * 调用顺序：会先调用父类的initialize，再调用子类的initialize
         * 1. objc_msgSend(JPPerson.class, @selector(initialize));
         * 2. objc_msgSend(JPStudent.class, @selector(initialize));
         * 如果子类的initialize没有实现，会再次调用父类的initialize，所以父类的initialize可能会被调用多次。
         * 大概酱紫的逻辑：
            if (!self.isInitialized) {
                if (!super.isInitialized) {
                    objc_msgSend(super.class, @selector(initialize));
                    super.isInitialized = YES;
                }
                if (@selector(initialize)) {
                    objc_msgSend(self.class, @selector(initialize));
                } else {
                    objc_msgSend(super.class, @selector(initialize));
                }
                self.isInitialized = YES;
            }
         */
        
        
    }
    return 0;
}


/*
 
 // 调用某个方法，就是通过 isa -> 类/元类对象 -> 寻找方法 -> 调用
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
 // YES，【确保了已经调用过initialize方法，继续去寻找要去调用的方法】
 →
 // NO，没有则继续往下
 ↓
 initializeNonMetaClass
 ↓↑
 initializeNonMetaClass(supercls); // 递归依次寻找父类
 ↓
 callInitialize
 ↓
 ((void(*)(Class, SEL))objc_msgSend)(cls, SEL_initialize); // 发送initialize方法消息（调用）
 ↓
 // 至此，【确保了已经调用过initialize方法，继续去寻找要去调用的方法】
 
*/
