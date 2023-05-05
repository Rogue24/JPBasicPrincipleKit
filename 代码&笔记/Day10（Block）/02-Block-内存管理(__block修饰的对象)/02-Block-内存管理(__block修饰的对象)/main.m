//
//  main.m
//  04-Block-__block
//
//  Created by 周健平 on 2019/11/3.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "JPPerson.h"

typedef void(^JPBlock)(void);

// C++编译的底层结构：

struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    
    void (*copy)(void); // 参数有警告，所以换成void，原本长这样：void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
    void (*dispose)(void); // 参数有警告，所以换成void，原本长这样：void (*dispose)(struct __main_block_impl_0*);
    
}; // __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

void __Block_byref_id_object_copy_131(void *dst, void *src) {
    _Block_object_assign((char*)dst + 40, *(void * *) ((char*)src + 40), 131);
}
void __Block_byref_id_object_dispose_131(void *src) {
    _Block_object_dispose(*(void * *) ((char*)src + 40), 131);
}
/*
 * 为啥要加40？因为实际的对象地址在这个__block变量结构体的首地址后40个字节的位置：
   void *__isa;                                        --> + 8
   struct __Block_byref_block_per1_0 *__forwarding;    --> + 8
   int __flags;                                        --> + 4
   int __size;                                         --> + 4
   void (*__Block_byref_id_object_copy)(void*, void*); --> + 8
   void (*__Block_byref_id_object_dispose)(void*);     --> + 8
   JPPerson *__weak block_per1;            对象指针的地址 = struct的首地址 + 40（0x28）
 */

struct __Block_byref_block_per1_0 {
    void *__isa;
    struct __Block_byref_block_per1_0 *__forwarding;
    int __flags;
    int __size;
    // __Block_byref_id_object_dispose_131
    void (*__Block_byref_id_object_copy)(void*, void*);
    // __Block_byref_id_object_dispose_131
    void (*__Block_byref_id_object_dispose)(void*);
    JPPerson *__weak block_per1;
};
struct __Block_byref_block_per2_1 {
    void *__isa;
    struct __Block_byref_block_per2_1 *__forwarding;
    int __flags;
    int __size;
    // __Block_byref_id_object_dispose_131
    void (*__Block_byref_id_object_copy)(void*, void*);
    // __Block_byref_id_object_dispose_131
    void (*__Block_byref_id_object_dispose)(void*);
    JPPerson *__weak block_per2;
};
struct __Block_byref_per3_2 {
    void *__isa;
    struct __Block_byref_per3_2 *__forwarding;
    int __flags;
    int __size;
    // __Block_byref_id_object_dispose_131
    void (*__Block_byref_id_object_copy)(void*, void*);
    // __Block_byref_id_object_dispose_131
    void (*__Block_byref_id_object_dispose)(void*);
    JPPerson *__strong per3;
};

struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    JPPerson *__strong per4;
    struct __Block_byref_block_per1_0 *block_per1; // by ref
    struct __Block_byref_block_per2_1 *block_per2; // by ref
    struct __Block_byref_per3_2 *per3; // by ref
    
//  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, JPPerson *__strong _per4, __Block_byref_block_per1_0 *_block_per1, __Block_byref_block_per2_1 *_block_per2, __Block_byref_per3_2 *_per3, int flags=0) : per4(_per4), block_per1(_block_per1->__forwarding), block_per2(_block_per2->__forwarding), per3(_per3->__forwarding) {
//    impl.isa = &_NSConcreteStackBlock;
//    impl.Flags = flags;
//    impl.FuncPtr = fp;
//    Desc = desc;
//  }
};

void __main_block_func_0(struct __main_block_impl_0 *__cself) {
//  struct __Block_byref_block_per1_0 *block_per1 = __cself->block_per1; // bound by ref
//  struct __Block_byref_block_per2_1 *block_per2 = __cself->block_per2; // bound by ref
//  struct __Block_byref_per3_2 *per3 = __cself->per3; // bound by ref
//  JPPerson *__strong per4 = __cself->per4; // bound by copy
    
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_a19f48_mi_5, (block_per1->__forwarding->block_per1));
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_a19f48_mi_6, (block_per2->__forwarding->block_per2));
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_a19f48_mi_7, (per3->__forwarding->per3));
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_a19f48_mi_8, per4);
}

void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    _Block_object_assign((void*)&dst->block_per1, (void*)src->block_per1, 8/*BLOCK_FIELD_IS_BYREF*/);
    _Block_object_assign((void*)&dst->block_per2, (void*)src->block_per2, 8/*BLOCK_FIELD_IS_BYREF*/);
    _Block_object_assign((void*)&dst->per3, (void*)src->per3, 8/*BLOCK_FIELD_IS_BYREF*/);
    _Block_object_assign((void*)&dst->per4, (__bridge void*)src->per4, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

void __main_block_dispose_0(struct __main_block_impl_0*src) {
    _Block_object_dispose((void*)src->block_per1, 8/*BLOCK_FIELD_IS_BYREF*/);
    _Block_object_dispose((void*)src->block_per2, 8/*BLOCK_FIELD_IS_BYREF*/);
    _Block_object_dispose((void*)src->per3, 8/*BLOCK_FIELD_IS_BYREF*/);
    _Block_object_dispose((__bridge void*)src->per4, 3/*BLOCK_FIELD_IS_OBJECT*/);
}



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPBlock block;
        
        {
            //【ARC】
            /*
             * __block：编译器会将其包装成<<__block变量结构体>>，会被block【强】引用
             * PS：其实就是一个对象，里面有isa指针
             *
             * 被__block修饰的对象会被编译器会将其包装成__block变量结构体：
                struct __Block_byref_block_per2_1 {
                    void *__isa;
                    struct __Block_byref_block_per2_1 *__forwarding;
                    int __flags;
                    int __size;
                    void (*__Block_byref_id_object_copy)(void*, void*);
                    void (*__Block_byref_id_object_dispose)(void*);
                    JPPerson *__weak block_per1; // 真正指向对象地址的指针，引用类型取决于对象定义时的引用类型，默认是__strong
                };
             * 包装对象的__block变量结构体内部比包装基本数据类型多出了两个函数，用于内存管理：
             * copy函数：当结构体被拷贝到堆上时内部会调用这个函数
             * dispose函数：当结构体从堆上移除时内部会调用这个函数
             *
             *【当block从栈上拷贝到堆上时】：
             * ↓
             * 调用block的Desc结构体的copy函数
             * ↓
             * __main_block_copy_0 -> _Block_object_assign
             * ↓
             * 把__block变量结构体拷贝到堆上，对__block变量结构体产生【强】引用
             * ↓
             * 调用__block变量结构体的__Block_byref_id_object_copy函数
             * ↓
             * __Block_byref_id_object_copy_131 -> _Block_object_assign（8）
             * ↓
             * 根据对象的引用修饰符做相应操作：
             *【ARC】环境下：__strong就强引用（retain），__weak就弱引用（不会retain）
             *【MRC】环境下：不管是什么引用修饰符，都不会强引用，即不会进行retain操作
             * PS：由于MRC环境没有weak指针，所以在MRC环境下是用__block来解决循环引用的问题
             * ↓↓
             * 注意的是，这仅仅只是解决了循环引用，一旦对象销毁后，block内部引用的这个对象并不会自动置nil，
             * 接着再调用block的话，block内部就会访问到这个已被销毁的地址，坏内存访问导致崩溃（MRC环境）。
             *
             *【当block从堆上移除时】：
             * ↓
             * 调用block的Desc结构体的dispose函数
             * ↓
             * __main_block_dispose_0 -> _Block_object_dispose
             * ↓
             * 释放__block变量结构体，把__block变量结构体从堆上移除
             * ↓
             * 调用__block变量结构体的__Block_byref_id_object_dispose
             * ↓
             * __Block_byref_id_object_dispose_131 -> _Block_object_dispose（8）
             * ↓
             * 删除__block变量结构体指向对象的指针（release）
             */
            
            JPPerson *per1 = [[JPPerson alloc] init];
            JPPerson *per2 = [[JPPerson alloc] init];
            /*
             * __weak：弱引用，只能修饰【OC对象】，不能作用于【__block变量结构体】，
             * 所以`MallocBlock`对【__block变量结构体】只有强引用。
             * 因此这两种修饰方式是一样的：
             * 1. __weak __block JPPerson *block_per1 = per1;
             * 2. __block __weak JPPerson *block_per2 = per2;
             * 最终都是包装成【__block变量结构体】，其内部__weak引用本体。
             */
            __weak __block JPPerson *block_per1 = per1;
            __block __weak JPPerson *block_per2 = per2;
            
            __block JPPerson *per3 = [[JPPerson alloc] init];
            
            JPPerson *per4 = [[JPPerson alloc] init];
            
            //【ARC】
            NSLog(@"per1 %p", per1);
            NSLog(@"per2 %p", per2);
            
            NSLog(@"per3 %p", per3);
            NSLog(@"per4 %p", per4);
            
            block = ^{
                //【ARC】
                NSLog(@"block_per1 %@", block_per1);
                NSLog(@"block_per2 %@", block_per2);
                
                NSLog(@"block_per3 %@", per3);
                NSLog(@"block_per4 %@", per4);
            };
            
            //【MRC】
//            block = [block copy];
//            [per3 release];
//            [per4 release];
        }
        
        block();
        
        //【MRC】
//        NSLog(@"block release");
//        [block release];
        
        
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
         
            // __block int a，基本数据类型的__block变量
            struct __Block_byref_a_0 {
                void *__isa;
                struct __Block_byref_a_0 *__forwarding; // 指向自身的指针
                int __flags;
                int __size;
                int a; // 修饰的那个变量
            };
         
            // __block NSObject *obj，对象类型的__block变量
            struct __Block_byref_obj_1 {
                void *__isa;
                struct __Block_byref_obj_1 *__forwarding;
                int __flags;
                int __size;
                void (*__Block_byref_id_object_copy)(void*, void*);
                void (*__Block_byref_id_object_dispose)(void*);
                NSObject *__strong obj;
            };
            // 对比基本数据类型的多了copy和dispose这两个函数，这是用来对结构体里面的对象进行内存管理的
         
         * block会保存这些结构体的指针
         *
         * 不管这个变量是什么类型，只要被__block修饰都会被包装成__Block_byref_xxx_x这种结构体
         * 这种结构体其实就是对象，因为里面有isa指针
         * 所以被__block修饰的auto变量，被block捕获进去的是因__block生成的那种对象，并不是自身
         *
         * 只要block捕获的变量是【对象类型的auto变量】
         * Block的结构体的Desc结构体里面就会多了copy和dispose这两个函数指针，用于进行内存管理操作的
         * 在编译的C++文件里面分别是：__main_block_copy_0 和 __main_block_dispose_0
         */
        
        /*
         * 总结2：block的内存管理
         *
         * StackBlock【栈空间的block】
         *  - 永远都不会对`捕获的auto变量`产生【强引用】！相当于只存储指向的地址值，并不会改变它的引用计数！
         *  <<毕竟自身随时被销毁，也就没必要强引用其他对象>>
         *  - 执行 StackBlock 时（在另一个作用域），`捕获的auto变量`有可能就已经被销毁了，就会造成坏内存访问的错误
         * 所以 StackBlock 存活期间【不会】保住`对象类型的auto变量`的命
         *
         * 证明：在另一个作用域执行 StackBlock 时，`捕获的auto变量`会不会已经被销毁？
         *  - 只能在MRC环境下证明，因为想在另一个作用域执行block，只能赋值给__strong指针，
         *  - 但在ARC环境下这操作会自动升级为MallocBlock，这样block就会保住auto变量的命。
         * ==> 已证明：在另一个作用域执行 StackBlock 时，`捕获的auto变量`已经被销毁了，
         * ==> 说明 StackBlock 存活期间【不会】保住`auto变量`的命。
         *
         *
         * MallocBlock【堆空间的block】
         *  - 拷贝到堆上时，会自动根据`捕获的auto变量`的修饰符形成【强引用】或者【弱引用】
         *  - 从堆上移除时，会自动释放`捕获的auto变量`
         *
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
         *
         * 所以 MallocBlock 存活期间【会】保住`对象类型的auto变量`的命
         */
    }
    return 0;
}
