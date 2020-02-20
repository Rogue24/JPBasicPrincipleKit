//
//  JPStudent.m
//  04-super
//
//  Created by 周健平 on 2019/11/20.
//  Copyright © 2019 周健平. All rights reserved.
//
//  注意：super并不是用self拿父类，而是拿【这个文件的这个类的父类】，self是不确定的。

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

- (void)eat {
    [super eat];
    NSLog(@"student eat");
}

- (void)run {
    [super run];
    
    /*
     * [super run]的底层调用：
        struct objc_super arg = {
            self,
            class_getSuperclass(objc_getClass("JPStudent")) // 拿到JPStudent的父类
        };
        objc_msgSendSuper(arg, @selector(run));
     */
}

/*
 * struct __rw_objc_super ==这个结构体在OC源码中为==> struct objc_super
    struct objc_super {
        // 消息接收者
        __unsafe_unretained _Nonnull id receiver;
        // 消息接收者的父类（OBJC2之后用super_class，旧的版本用的是class）
        __unsafe_unretained _Nonnull Class super_class;
    };
 
 * objc_msgSendSuper函数：
    objc_msgSendSuper(struct objc_super * _Nonnull super, SEL _Nonnull op, ...)
                                ↓↓↓                            ↓↓↓         ↓↓↓
                    【struct objc_super】结构体                 方法名      方法参数（多数，以“,”分隔）
                                ↓↓↓
          存放着消息接收者(receiver)和消息接收者的父类(super_class)
 
 * [super run]编译的C++的代码：
 
    static void _I_JPStudent_run(JPStudent * self, SEL _cmd) {
        ((void (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("JPStudent"))}, sel_registerName("run"));
            ↓↓↓
        objc_msgSendSuper((__rw_objc_super){self,
                                            class_getSuperclass(objc_getClass("JPStudent"))},
                           sel_registerName("run"));
            ↓↓↓
        << __rw_objc_super ==这个结构体在OC源码中为==> objc_super >>
            ↓↓↓
        struct objc_super arg = {
            self,
            class_getSuperclass(objc_getClass("JPStudent")) // 拿到JPStudent的父类
        };
        objc_msgSendSuper(arg, @selector(run));
            ↓↓↓
        objc_msgSendSuper({self, [JPPersion class]}, @selector(run)});
 
        //【super关键字】实际上做了：
        // 先将self和父类的类对象包装成objc_super结构体，然后作为参数去执行objc_msgSendSuper函数
            ↓↓↓
        // objc_msgSendSuper({self, [JPPersion class]}, @selector(run)});
        // 这个函数的意思是：self【直接】先去[JPPersion class]的方法列表中查找run方法并执行
        // 也就是子类对象直接去到父类的方法列表里查找方法，其目的就是要调用父类的方法而不是自己的
        // 不然会直接执行自己的方法造成【死循环】
 
        // PS1：父类的类对象已经放在struct objc_super的super_class，通过这个直接去到父类的方法列表找方法
        // PS2：通过self去调用父类的方法，所以这时候父类方法里的self并不是父类的对象，而是消息接收者自身（子类）
    }
 
 * 结论：
 * [super run] ==> 使用super调用方法的本质：
    · objc_msgSendSuper({self, [JPPersion class]}, @selector(run)})；
    · self（子类对象自身、方法调用者、消息接收者）绕过第一个isa直接从父类的方法列表开始查询方法并执行；
    · 所以这个super其实就是self，只是执行的是父类的方法；
    · 目的就是为了直接去调用父类的方法，而不是调用自己的方法。
 
 * PS：super调用，实际上底层会转换为objc_msgSendSuper2函数的调用，在后面会讲到。
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
 class和superclass的源码实现：是通过【self】调用的函数，通过super调用其实也就是self调用
    @implementation NSObject
    // 谁调用就返回谁的Class
    + (Class)class {
        return self;
    }
    - (Class)class {
        return object_getClass(self);
    }
    // 谁调用就返回谁的superclass
    + (Class)superclass {
        return class_getSuperclass(self);
    }
    - (Class)superclass {
        return class_getSuperclass(object_getClass(self));
    }
    @end
 */
