//
//  main.m
//  04-Block-__block
//
//  Created by 周健平 on 2019/11/3.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
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
    struct __Block_byref_a_0 *__forwarding; // 指向自身的指针
    int __flags;
    int __size;
    int a;
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
    struct __Block_byref_a_0 *a; // by ref
    
//  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_a_0 *_a, int flags=0) : a(_a->__forwarding) {
//    impl.isa = &_NSConcreteStackBlock;
//    impl.Flags = flags;
//    impl.FuncPtr = fp;
//    Desc = desc;
//  }
};

void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    _Block_object_assign((void*)&dst->a, (void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);
}

void __main_block_dispose_0(struct __main_block_impl_0*src) {
    _Block_object_dispose((void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);
}

void __main_block_func_0(struct __main_block_impl_0 *__cself) {
//    __Block_byref_a_0 *a = __cself->a; // bound by ref
//    (a->__forwarding->a) = 31;
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_x6_746b_l0s199ddqdvt8qclszr0000gn_T_main_d0b18b_mi_1, (a->__forwarding->a));
}


struct __main_block_desc_1 {
    size_t reserved;
    size_t Block_size;
};
struct __Block_byref_blockPer_1 {
    void *__isa;
    struct __Block_byref_blockPer_1 *__forwarding;
    int __flags;
    int __size;
    void *__copy; // --> 这是一个方法，换成指针代替着
    void *__dispose; // --> 这是一个方法，换成指针代替着
    JPPerson *blockPer;
};
struct __main_block_impl_1 {
    struct __block_impl impl;
    struct __main_block_desc_1* Desc;
    JPPerson *per2;
    struct __Block_byref_blockPer_1 *blockPer; // by ref
};

#warning 当前在MRC环境下！

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        /*
         * __block可以用于解决block内部无法修改auto变量值的问题
         * __block不能修饰全局变量、静态变量（static）
         */
        
        // 被__block修饰的变量，编译器会将其包装成一个对象（__Block_byref_a_0，里面有isa指针）
        __block int a = 29;
        /*
         __attribute__((__blocks__(byref))) __Block_byref_a_0 a = {(void*)0,(__Block_byref_a_0 *)&a, 0, sizeof(__Block_byref_a_0), 29};
         ↓
         __Block_byref_a_0 a = {0,
                                &a,
                                0,
                                sizeof(__Block_byref_a_0),
                                29};
        */
        
//        NSMutableArray *arr = [NSMutableArray array];
        JPBlock stackBlock = ^{
            // 这是使用这个变量，所以不需要__block修饰
//            [arr addObject:@"1"];
            
            // 这是修改这个变量，所以需要__block修饰
            a = 31;
            /*
             * Block的内部实现：
                __Block_byref_a_0 *a = __cself->a; // bound by ref
                (a->__forwarding->a) = 31;
             * 并不是直接赋值，而是由包装好的对象通过forwarding(指向自身的指针)再找到这个a来进行赋值
             * a->__forwarding->a = 31;
             */
            
            NSLog(@"Hello, JPBlock! %d", a);
        };
        /*
         JPBlock block = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_a_0 *)&a, 570425344));
         ↓
         JPBlock block = &__main_block_impl_0(__main_block_func_0,
                                              &__main_block_desc_0_DATA,
                                              &a,
                                              570425344);
         */
        
        struct __main_block_impl_0 *stackBlockImpl = (__bridge struct __main_block_impl_0 *)stackBlock;
        /*
         * 打印可以查看：
         * po &a 或 po &(blockImpl->a->a) ：0x0000000100710b18 ==> 这是a的地址值
         * po blockImpl->a ：0x0000000100710b00 ==> 这是将a包装在里面的那个对象的地址值
         * a的地址值跟这个对象的地址值刚好相差24个字节，证明a的确包装在这个对象里面的。
         * 就是这个结构体：
            struct __Block_byref_a_0 {
                void *__isa; // 从 0x0000000100710b00 开始，占8字节
                struct __Block_byref_a_0 *__forwarding;    // 占8字节
                int __flags;                               // 占4字节
                int __size;                                // 占4字节
                int a; // 这里就是：0x0000000100710b00 + 0x18 = 0x0000000100710b18
            };
         *
         * block里面的a不是真的a，是__block变量结构体，真的a在这个结构体里面
         * 对a的【赋值】看上去是直接赋值，实际上是：a->__forwarding->a = 31
         * 对a的【取值】看上去是直接取值，实际上是：a.__forwarding->a
         * 所以打印a的地址并不是包装a的结构体的地址，而真的是a的地址值
         * 苹果表面上对其进行了隐蔽的效果，不公开内部实现，让开发者觉得就只是对a进行了操作
         * 实际上是包装到一个对象里面再通过这个对象进行操作，类似于KVO
         */
        NSLog(@"block class is %@", [stackBlock class]); // __NSStackBlock__
        NSLog(@"a address is %p", &a); // 0x7ffeefbff448
        NSLog(@"blockImpl->a->a address is %p", &(stackBlockImpl->a->a)); // 0x7ffeefbff448
        NSLog(@"blockImpl->a address is %p", stackBlockImpl->a); // 0x7ffeefbff430
        NSLog(@"a is %d", a); // 29
        NSLog(@"------ before copy ------");
        /*
         * 在这打个断点在控制台打印日志查看：
         * 输入：x/4xg 0x7ffeefbff430，查看【栈上】__block变量结构体（stackBlockImpl->a）的内容
         * ==> 0x7ffeefbff430: 0x0000000000000000 0x00007ffeefbff430
               0x7ffeefbff440: 0x0000002020000000 0x000000000000001d
         * 可以看到__forwarding指向的是自己的__block变量结构体，自己的a是29
         */
        
        JPBlock mallocBlock = [stackBlock copy];
        struct __main_block_impl_0 *mallocBlockImpl = (__bridge struct __main_block_impl_0 *)mallocBlock;
        
        stackBlock();
        
        NSLog(@"block class is %@", [mallocBlock class]);
        NSLog(@"a address is %p", &a);
        NSLog(@"blockImpl->a->a address is %p", &(mallocBlockImpl->a->a));
        NSLog(@"blockImpl->a address is %p", mallocBlockImpl->a);
        NSLog(@"a is %d", a);
        NSLog(@"------ after copy ------");
        /*
         * 在这打个断点在控制台打印日志查看：
         * 输入：x/4xg 0x7ffeefbff430，查看【栈上】__block变量结构体（stackBlockImpl->a）的内容
         * ==> 0x7ffeefbff430: 0x0000000000000000 0x0000000100576d00
               0x7ffeefbff440: 0x0000002020000000 0x000000000000001d
         * 可以看到此时的__forwarding指向的是【堆上】__block变量结构体，自己的a还是29
         */
        
        /*
         * 结论：__forwarding在Block从栈上拷贝到堆上后的指向
         *【栈上】的__block变量结构体的__forwarding会指向【堆上】的__block变量结构体，
         * 而堆上的__block变量结构体的__forwarding还是指向自己。
         * 由于修改变量都是通过a->__forwarding->a这样的形式进行操作，
         * 所以这样的做法就可以在Block从栈上拷贝到堆上后，
         * 即使是修改栈上的__block变量结构体的变量，实际上修改的是堆上的__block变量结构体的变量，
         * 因为__forwarding都指着堆上的，因此栈上的__block变量结构体里面的变量还是原来的值，
         * 毕竟栈上的__block变量结构体在{}后就被回收，再修改栈上的已经没意义了。
         */
        
        /*
         * 总结：__block的本质
         *
         *【修饰】
         * 被__block修饰的变量，编译器会将其包装成一个结构体（就是一个对象，里面有isa指针）
         * OC代码：__block int a = 29;
         * C++代码：
            struct __Block_byref_a_0 {
                void *__isa;
                struct __Block_byref_a_0 *__forwarding; // 指向自身的指针
                int __flags;
                int __size;
                int a; // 修饰的那个变量
            };
         * block会保存这个结构体的指针
         * 同时Block的结构体的Desc结构体里面，会多了copy和dispose这两个函数指针：
         * 在编译的C++文件里面分别是：__main_block_copy_0 和 __main_block_dispose_0
         * 为什么呢？因为这个包装了a的结构体是一个对象，这两个函数是用于进行内存管理操作的
         *
         *【赋值】
         * 当对这个变量赋值时，blokc会通过这个指针找到这个结构体
         * 再通过结构体里面那个指向自身的指针(__forwarding)找到结构体的内存
         * 最后找到这个变量，进行赋值。
         * OC代码：a = 31 ==> C++代码：a->__forwarding->a = 31;
         *
         *【取值】
         * 当取出这个变量时，blokc会通过这个指针找到这个结构体
         * 再通过结构体里面那个指向自身的指针(__forwarding)找到结构体的内存
         * 最后找到这个变量，取值。
         * OC代码：a ==> C++代码：a.__forwarding->a;
         */
        
        
        [stackBlock release];
        [mallocBlock release];
        
        
        NSLog(@"验证：__block变量结构体里面的isa究竟指向啥？");
        NSLog(@"追加验证：被__block修饰的实例对象，__block变量结构体里面的isa是不是指向对象的class？");
        
//        struct __main_block_desc_1 {
//            size_t reserved;
//            size_t Block_size;
//        };
//
//        struct __Block_byref_blockPer_1 {
//            void *__isa;
//            struct __Block_byref_blockPer_1 *__forwarding;
//            int __flags;
//            int __size;
//            void *__copy; // --> 这是一个方法，换成指针代替着
//            void *__dispose; // --> 这是一个方法，换成指针代替着
//            JPPerson *blockPer;
//        };
//
//        struct __main_block_impl_1 {
//          struct __block_impl impl;
//          struct __main_block_desc_1* Desc;
//          struct __Block_byref_blockPer_1 *blockPer; // by ref
//        };
        JPPerson *per = [[JPPerson alloc] init];
        __block JPPerson *blockPer = per;
        
        JPPerson *per2 = [[JPPerson alloc] init];
        
        JPBlock perBlock = ^{
            NSLog(@"Hello, per2 %@", per2);
            NSLog(@"Hello, blockPer %@", blockPer);
        };
        perBlock();
        
        struct __main_block_impl_1 *perBlockImpl = (__bridge struct __main_block_impl_1 *)perBlock;
        NSLog(@"per2 --- %p", per2);
        NSLog(@"blockPer --- %p", blockPer);
        NSLog(@"perBlockImpl->per2 --- %p", perBlockImpl->per2);
        NSLog(@"perBlockImpl->blockPer --- %p", perBlockImpl->blockPer);
        NSLog(@"perBlockImpl->blockPer->blockPer --- %p", perBlockImpl->blockPer->blockPer);
        
        NSLog(@"-------先验证结构对不对-------");
        
        Class perCls = [JPPerson class];
        NSLog(@"JPPerson的class %p", perCls);
        Class perMetaCls = object_getClass(perCls);
        NSLog(@"JPPerson的metaClass %p", perMetaCls);
        
        NSLog(@"perBlockImpl->blockPer->__isa --- %p", perBlockImpl->blockPer->__isa);
        NSLog(@"不是指向对象的class");
        
        // 从编译C++代码可以看出：
        /*
         __Block_byref_a_0 a =
            {
                0,
                &a,
                0,
                sizeof(__Block_byref_a_0),
                29
            };
         
         __Block_byref_blockPer_1 blockPer =
            {
                0, ---> isa被赋值为0
                &blockPer,
                33554432,
                sizeof(__Block_byref_blockPer_1),
                __Block_byref_id_object_copy_131,
                __Block_byref_id_object_dispose_131,
                per
            };
         */
        
        NSLog(@"结论：凡是被__block修饰的变量，__block变量结构体里面的isa都指向0x0，啥都不是");
        
        [perBlock release];
    }
    return 0;
}
