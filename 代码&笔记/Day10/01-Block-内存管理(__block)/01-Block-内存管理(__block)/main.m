//
//  main.m
//  04-Block-__block
//
//  Created by 周健平 on 2019/11/3.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef void(^JPBlock)(void);

// C++编译的底层结构：

struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

struct __Block_byref_a_0 {
    void *__isa;
    struct __Block_byref_a_0 *__forwarding;
    int __flags;
    int __size;
    int a;
};

struct __Block_byref_obj_1 {
    void *__isa;
    struct __Block_byref_obj_1 *__forwarding;
    int __flags;
    int __size;
    void (*__Block_byref_id_object_copy)(void*, void*);
    void (*__Block_byref_id_object_dispose)(void*);
    NSObject *__strong obj;
};

struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    
    void (*copy)(void);
    void (*dispose)(void);
//    void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
//    void (*dispose)(struct __main_block_impl_0*);
}; // __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int b;
  NSObject *__strong obj2;
  NSObject *__weak weakObj;
  struct __Block_byref_a_0 *a; // by ref
  struct __Block_byref_obj_1 *obj; // by ref
    
//  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _b, NSObject *__strong _obj2, NSObject *__weak _weakObj, __Block_byref_a_0 *_a, __Block_byref_obj_1 *_obj, int flags=0) : b(_b), obj2(_obj2), weakObj(_weakObj), a(_a->__forwarding), obj(_obj->__forwarding) {
//    impl.isa = &_NSConcreteStackBlock;
//    impl.Flags = flags;
//    impl.FuncPtr = fp;
//    Desc = desc;
//  }
};

void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    // 对【对象类型的auto变量】进行类似retain操作形成对应的强、弱引用
    // 其他类型的auto变量不操作
//    _Block_object_assign((void*)&dst->a, (void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);
//    _Block_object_assign((void*)&dst->obj, (void*)src->obj, 8/*BLOCK_FIELD_IS_BYREF*/);
//    _Block_object_assign((void*)&dst->obj2, (void*)src->obj2, 3/*BLOCK_FIELD_IS_OBJECT*/);
//    _Block_object_assign((void*)&dst->weakObj, (void*)src->weakObj, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

void __main_block_dispose_0(struct __main_block_impl_0*src) {
    // 对【对象类型的auto变量】进行类似release操作
    // 其他类型的auto变量不操作
//    _Block_object_dispose((void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);
//    _Block_object_dispose((void*)src->obj, 8/*BLOCK_FIELD_IS_BYREF*/);
//    _Block_object_dispose((void*)src->obj2, 3/*BLOCK_FIELD_IS_OBJECT*/);
//    _Block_object_dispose((void*)src->weakObj, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

void __main_block_func_0(struct __main_block_impl_0 *__cself) {
//    __Block_byref_a_0 *a = __cself->a; // bound by ref
//    __Block_byref_obj_1 *obj = __cself->obj; // bound by ref
//    int b = __cself->b; // bound by copy
//    NSObject *__strong obj2 = __cself->obj2; // bound by copy
//    NSObject *__weak weakObj = __cself->weakObj; // bound by copy
//    (a->__forwarding->a) = 33;
//    (obj->__forwarding->obj) = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init"));
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_2d64f0_mi_6);
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_2d64f0_mi_7, (a->__forwarding->a), &(a->__forwarding->a));
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_2d64f0_mi_8, b, &b);
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_2d64f0_mi_9, (obj->__forwarding->obj), (obj->__forwarding->obj));
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_2d64f0_mi_10, obj2, obj2);
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_2d64f0_mi_11, weakObj, weakObj);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        __block int a = 29;
        int b = 12;
        
        __block NSObject *obj = [[NSObject alloc] init];
        /*
         struct __Block_byref_obj_1 {
            void *__isa;
            struct __Block_byref_obj_1 *__forwarding;
            int __flags;
            int __size;
            void (*__Block_byref_id_object_copy)(void*, void*);
            void (*__Block_byref_id_object_dispose)(void*);
            NSObject *__strong obj;
         };
         ↓初始化↓
         __Block_byref_obj_1 obj = {
            0,
            &obj,
            33554432,
            sizeof(__Block_byref_obj_1),
            __Block_byref_id_object_copy_131,
            __Block_byref_id_object_dispose_131,
            ((objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init")) // [[NSObject alloc] init]
         };
         */
        
        // 在ARC环境下，不带任何修饰符，【对象类型的auto变量】捕获到block中默认都是__strong
        NSObject *obj2 = [[NSObject alloc] init];
        
        NSObject *obj3 = [[NSObject alloc] init];
        __weak NSObject *weakObj = obj3;
        // __weak：只应用到OC对象，其他如int的基本数据类型不可用。
        
        NSLog(@"a is %d, address is %p", a, &a);
        NSLog(@"b is %d, address is %p", b, &b);
        NSLog(@"obj is %@", obj);
        NSLog(@"obj2 is %@", obj2);
        NSLog(@"weakObj is %@", weakObj);
        
        JPBlock block = ^{
            a = 33;
            obj = [[NSObject alloc] init];
            NSLog(@"Hello, JPBlock!");
            NSLog(@"a is %d, address is %p", a, &a);
            NSLog(@"b is %d, address is %p", b, &b);
            NSLog(@"obj is %@", obj);
            NSLog(@"obj2 is %@", obj2);
            NSLog(@"weakObj is %@", weakObj);
        };
        
//        struct __main_block_impl_0 *blockImpl = (__bridge struct __main_block_impl_0 *)block;
        
        block();
        
        /*
         * 总结1：__block的本质
         *
         *【修饰】
         * 被__block修饰的变量，编译器会将其包装成一个结构体（就是一个对象，里面有isa指针）
         * PS：不管这个变量是什么类型，都会被包装成这种结构体
         *
         * OC代码：__block int a = 29;
         *        __block NSObject *obj = [[NSObject alloc] init];
         * C++代码：
            struct __Block_byref_a_0 {
                void *__isa;
                struct __Block_byref_a_0 *__forwarding; // 指向自身的指针
                int __flags;
                int __size;
                int a; // 修饰的那个变量
            };
            struct __Block_byref_obj_1 {
                void *__isa;
                struct __Block_byref_obj_1 *__forwarding;
                int __flags;
                int __size;
                void (*__Block_byref_id_object_copy)(void*, void*);
                void (*__Block_byref_id_object_dispose)(void*);
                NSObject *__strong obj;
            };
         * block会保存这些结构体的指针
         *
         * 不管这个变量是什么类型，只要被__block修饰都会被包装成__Block_byref_xxx_x这种结构体
         * 这种结构体其实就是对象，因为里面有isa指针
         * 所以被__block修饰的auto变量，被block捕获进去的是因__block生成的那种对象，并不是自身
         *
         * 只要block捕获的变量是【对象类型的auto变量】
         * Block的结构体的Desc结构体里面就会多了copy和dispose这两个函数指针，用于进行内存管理操作的
         * 在编译的C++文件里面分别是：__main_block_copy_0 和 __main_block_dispose_0
         *
         *
         * 总结2：block的内存管理
         *
         *【栈空间的block】
         * 不会对捕获的auto变量产生强引用，【永远都是弱引用】
         * <<毕竟自身随时被销毁，也就没必要强引用其他对象>>
         * PS1：执行block时，捕获的auto变量有可能就已经被销毁了，就会造成坏内存访问的错误
         * PS2：要后续执行block只能赋值给__strong指针，
         * 不过在ARC环境下会自动进行copy操作升级为MallocBlock，因此block会保住auto变量的命，
         * 所以，想证明执行block时捕获的auto变量会不会已经被销毁了就只能在MRC环境下进行。
         *
         * 当block从【栈空间】copy到【堆空间】，同时也会将捕获的对象拷贝过去：
         * 1.拷贝到堆上时：
         * block会调用Desc的copy函数，内部调用_Block_object_assign函数
         * 对【对象类型的auto变量】进行类似retain操作形成对应的强、弱引用
         * PS1：只要是因__block生成的那种对象，都是strong引用；
         * PS2：如果是仅__weak修饰的对象，weak引用，其他一般都是strong引用
         *
         * 2.从堆上移除时：
         * block会调用Desc的dispose函数，内部调用_Block_object_dispose函数
         * 对【对象类型的auto变量】进行类似release操作
         * PS：引用计数为0时则销毁
         */
    }
    return 0;
}
