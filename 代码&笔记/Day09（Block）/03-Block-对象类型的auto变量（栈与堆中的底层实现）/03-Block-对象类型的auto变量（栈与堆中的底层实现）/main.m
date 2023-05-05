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

// 编译的C++底层代码：

struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    JPPerson *__strong per1;
    JPPerson *__weak weakPer2;
    
    // 构造函数
//  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, JPPerson *__strong _per1, JPPerson *__weak _weakPer2, int flags=0) : per1(_per1), weakPer2(_weakPer2) {
//    impl.isa = &_NSConcreteStackBlock;
//    impl.Flags = flags;
//    impl.FuncPtr = fp;
//    Desc = desc;
//  }
};

static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    // _Block_object_assign函数会根据auto变量的修饰符（__strong、__weak、__unsafe_unretained）做出相应的操作，类似于retain（形成强、弱引用）
    
    // 对外部的per1对象产生强引用
//    _Block_object_assign((void*)&dst->per1, (void*)src->per1, 3/*BLOCK_FIELD_IS_OBJECT*/);
    
    // 对外部的weakPer2对象产生弱引用
//    _Block_object_assign((void*)&dst->weakPer2, (void*)src->weakPer2, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {
    // _Block_object_dispose函数会自动释放引用的auto变量，类似于release
    
    // 释放per1
//    _Block_object_dispose((void*)src->per1, 3/*BLOCK_FIELD_IS_OBJECT*/);
    
    // 释放weakPer2
//    _Block_object_dispose((void*)src->weakPer2, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

static struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;

    // 当block内部访问了【对象类型】的auto变量，会多了这两个函数指针：
    //【1】__main_block_copy_0：
    void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
    //【2】__main_block_dispose_0：
    void (*dispose)(struct __main_block_impl_0*);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
#pragma clang diagnostic pop

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        void (^jpblock)(void);
        
        {
            JPPerson *per1 = [[JPPerson alloc] init];
            per1.age = 19;
            
            JPPerson *per2 = [[JPPerson alloc] init];
            per2.age = 22;
            
            NSLog(@"per1 %p", per1);
            NSLog(@"per2 %p", per2);
            
            __weak JPPerson *weakPer2 = per2;
            
            // 在ARC环境下，将Block赋值给__strong指针编译器会自动将栈上的block复制到堆上：
            // StackBlock --copy--> MallocBlock
            jpblock = ^{
                NSLog(@"per1.age is %d", per1.age);
                NSLog(@"weakPer2.age is %d", weakPer2.age);
            };
            /*
             编译的C++文件里面：
             jpblock = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, per1, weakPer2, 570425344));
             */
            
            NSLog(@"jpblock %@", [jpblock class]);
            
            // 在ARC环境下，只能这样创建StackBlock，超出作用域就会被系统自动回收了。
            NSLog(@"block1 %@", [^{
                NSLog(@"per1.age is %d", per1.age);
            } class]);
            NSLog(@"block2 %@", [^{
                NSLog(@"weakPer2.age is %d", weakPer2.age);
            } class]);
        }
        
        jpblock();
        NSLog(@"over~");
        
        /*
         * 总结：当block捕获了【对象类型】的auto变量：
         * Block结构体的`Desc`成员，它的结构体`__main_block_desc_0`里面会多出`copy`和`dispose`这两个函数指针，用于进行内存管理操作：
         * 在编译的C++文件里面分别是：__main_block_copy_0 和 __main_block_dispose_0
         *
         *
         * StackBlock【栈空间的block】
         *  - 永远都不会对`捕获的auto变量`产生【强引用】！相当于只存储指向的地址值，并不会改变它的引用计数！
         *  <<毕竟自身随时被销毁，也就没必要强引用其他对象>>
         *  - 执行 StackBlock 时（在另一个作用域），`捕获的auto变量`有可能就已经被销毁了，就会造成坏内存访问的错误
         * 所以 StackBlock 存活期间【不会】保住`捕获的auto变量`的命
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
         * 所以 MallocBlock 存活期间【会】保住`捕获的auto变量`的命
         *
         * 1. 拷贝到堆上时对捕获的auto变量：
         * 会调用copy函数，内部调用_Block_object_assign函数，类似retain操作
         * 该函数会根据auto变量的修饰符（__strong、__weak、__unsafe_unretained）做出相应的操作，形成强引用（retain）或者弱引用
         * <<看看per1和weakPer2的底层结构，确实是生成了对应的__strong和__weak引用>>
         *
         * 2. 从堆上移除时对捕获的auto变量：
         * 会调用dispose函数，内部调用_Block_object_dispose函数，类似release操作
         */
    }
    return 0;
}
