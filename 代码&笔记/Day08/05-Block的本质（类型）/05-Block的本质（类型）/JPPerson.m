//
//  JPPerson.m
//  04-Block的本质（变量捕获-全局变量）
//
//  Created by 周健平 on 2019/10/31.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

/**
 *【1】这个3个test方法里面的block里有没捕获变量？
 * --> 有，捕获的都是self这个局部变量
 *【2】self为局部变量？
 * --> 从下面的方法编译的C++代码可以看得出，OC的方法默认会隐式传两个参数过来：1. (id)self【方法调用者的指针】，2. (SEL)_cmd【方法选择器】
 * --> 所以self是一个参数，就是一个局部变量
 * --> 所以block捕获了self这个局部变量的指针，存储该地址值（JPPerson的实例对象）
 *【3】为啥test2和test3捕获的都是self？
 * --> 因为test2的 _name 相当于 self->_name，test3的 self.name 相当于 [self name]
 * --> 所以归根到底还是得捕获self，block内部才能通过self来获取这个属性值，毕竟属性值来自于实例对象
 *【4】终极结论：block怎样才会捕获？
 * --> 只要是局部变量（不管是auto或static类型）都会捕获！全局变量不会捕获！
 */

- (void)test1 {
    void (^jpBlock)(void) = ^{
        NSLog(@"Hello, I am %@", self);
    };
    jpBlock();
}
/*
 static void _I_JPPerson_test1(JPPerson * self, SEL _cmd) {
    ...
 }
 
 struct __JPPerson__test1_block_impl_0 {
   struct __block_impl impl;
   struct __JPPerson__test1_block_desc_0* Desc;
   JPPerson *self;
   ...
 };
 */

- (void)test2 {
    void (^jpBlock)(void) = ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-retain-self"
        NSLog(@"Hello, my name is %@", _name);
#pragma clang diagnostic pop
    };
    jpBlock();
}
/*
 static void _I_JPPerson_test2(JPPerson * self, SEL _cmd) {
    ...
 }
 
 struct __JPPerson__test2_block_impl_0 {
   struct __block_impl impl;
   struct __JPPerson__test2_block_desc_0* Desc;
   JPPerson *self;
   ...
 };
 */

- (void)test3 {
    void (^jpBlock)(void) = ^{
        NSLog(@"Hello, my name is %@", self.name);
    };
    jpBlock();
}
/*
 static void _I_JPPerson_test3(JPPerson * self, SEL _cmd) {
    ...
 }
 
 struct __JPPerson__test3_block_impl_0 {
   struct __block_impl impl;
   struct __JPPerson__test3_block_desc_0* Desc;
   JPPerson *self;
   ...
 };
 */

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}
/*
 static instancetype _Nonnull _I_JPPerson_initWithName_(JPPerson * self, SEL _cmd, NSString * _Nonnull name) {
     if (self = ((JPPerson *(*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("JPPerson"))}, sel_registerName("init"))) {
         ((void (*)(id, SEL, NSString * _Nonnull))(void *)objc_msgSend)((id)self, sel_registerName("setName:"), (NSString * _Nonnull)name);
     }
     return self;
 }
 */

@end
