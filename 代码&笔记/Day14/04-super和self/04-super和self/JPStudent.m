//
//  JPStudent.m
//  04-super
//
//  Created by 周健平 on 2019/11/20.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPStudent.h"
#import <objc/runtime.h>

@implementation JPStudent

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"[self class] %@", [self class]); // JPStudent
        NSLog(@"[self superclass] %@", [self superclass]); // JPPerson
        NSLog(@"--------------------");
        NSLog(@"[super class] %@", [super class]); // JPStudent
        NSLog(@"[super superclass] %@", [super superclass]); // JPPerson
    }
    return self;
}

- (void)run {
    [super run];
}

/*
 * struct __rw_objc_super ==这个结构体在OC源码中为==> struct objc_super
    struct objc_super {
        // 消息接收者
        __unsafe_unretained _Nonnull id receiver;
        // 消息接收者的父类（OBJC2之后用super_class，旧的版本用的是class）
        __unsafe_unretained _Nonnull Class super_class;
    };
 
 * [super run]编译的C++的代码：
    static void _I_JPStudent_run(JPStudent * self, SEL _cmd) {
        ((void (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("JPStudent"))}, sel_registerName("run"));
            ↓↓↓
        struct objc_super arg = {
            self,
            class_getSuperclass(objc_getClass("JPStudent")) // 拿到JPStudent的父类
        };
        objc_msgSendSuper(arg, @selector(run));
            ↓↓↓
        objc_msgSendSuper({self, [JPPersion class]}, @selector(run)});
 
        // super关键字是将self和父类的类对象包装成objc_super结构体去执行objc_msgSendSuper函数
    
        // objc_msgSendSuper：self直接去到arg的super_class里查找run方法并执行
        // 也就是子类对象直接去到父类的方法列表里查找方法，不需要先通过isa找到父类
        // 并不是父类对象去执行父类方法
        // PS：父类已经在struct objc_super的super_class给到
        // 所以是使用arg的self去调用父类方法，这时候父类方法里的self并不是父类的对象，而是消息接收者自身
    }
 
 * [super run] ==> 使用super调用方法的本质：
    · objc_msgSendSuper({self, [JPPersion class]}, @selector(run)})
    · self（子类对象自身、方法调用者、消息接收者）绕过第一个isa直接去到父类的方法列表开始查询方法并执行
    · 所以这个super其实就是self，只是执行的是父类的方法
 */

@end

/*
 * 综合上述所知：
    [self class] ========> JPStudent
    [super class] =======> JPStudent
    [self superclass] ===> JPPerson
    [super superclass] ==> JPPerson
        ↓↓↓
 所以为什么打印结果一样
        ↓↓↓
 那是因为class和superclass返回的对象类型取决于消息接收者
        ↓↓↓
 而使用self或super调用方法，消息接收者始终都是子类对象本身，所以结果都一样
        ↓↓↓
 class和superclass明显都是根类NSObject的方法
        ↓↓↓
 由此可以推导出NSObject这两个方法的实现
        ↓↓↓
 @implementation NSObject
 - (Class)class {
    // 谁调用就返回谁的Class
    return object_getClass(self);
 }
 - (Class)superclass {
    // 谁调用就返回谁的superclass
    return class_getSuperclass(object_getClass(self));
 }
 @end
 */
