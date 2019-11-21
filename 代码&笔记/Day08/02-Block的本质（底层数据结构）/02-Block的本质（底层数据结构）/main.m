//
//  main.m
//  01-Block
//
//  Created by 周健平 on 2019/10/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

// 底层代码：

struct __block_impl {
  void *isa; // block的类对象
  int Flags;
  int Reserved;
  void *FuncPtr; // block执行逻辑的函数地址
};

// block底层结构体
struct __main_block_impl_0 {
    struct __block_impl impl;  // 相当于 --> void *isa;
                               //           int Flags;
                               //           int Reserved;
                               //           void *FuncPtr;
    struct __main_block_desc_0* Desc;
    
    // 构造函数（类似OC的init方法），返回结构体对象
//  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
//    impl.isa = &_NSConcreteStackBlock;
//    impl.Flags = flags;
//    impl.FuncPtr = fp;
//    Desc = desc;
//  }
};

// block的描述信息
struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size; // block所占内存大小
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};


// 封装了block执行逻辑的函数
void __main_block_func_0(struct __main_block_impl_0 *__cself) {
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_d5_lk44v2y52fb93pytpn58wc800000gn_T_main_6c7893_mi_0);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        void (^jpBlock)(void) = ^{
            // 这些代码会被封装成__main_block_func_0函数
            NSLog(@"Hello, Block!");
        };
        /*
         * 定义block变量
         * __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0)
         
         void (*jpBlock)(void) =
                    &__main_block_impl_0(
                                         __main_block_func_0,
                                         &__main_block_desc_0_DATA
                                         );
         
         * __main_block_impl_0：block结构体的构造函数（类似OC的init方法），返回block结构体对象
            * __main_block_func_0：void *fp --> block执行逻辑的函数地址
            * __main_block_desc_0_DATA：__main_block_desc_0 *desc --> block的描述信息（占内存大小）
                * __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)}
                * 参数2计算了block结构体的总大小，保存到Block_size里面
         */
        
        jpBlock();
        /*
         * 执行block内部的代码
         
         ((void (*)(__block_impl *))((__block_impl *)jpBlock)->FuncPtr)((__block_impl *)jpBlock);
         ↓
         jpBlock->FuncPtr(jpBlock);  // 为啥jpBlock可以直接调用FuncPtr？
         
         * 因为jpBlock的impl是jpBlock结构体的第一个成员，所以impl的内存地址就是jpBlock的内存地址。
         * 所以jpBlock可以直接强制转换成impl --> ((__block_impl *)jpBlock)
         
         * 再使用impl调用FuncPtr：impl.FuncPtr(jpBlock) <==> jpBlock->FuncPtr(jpBlock)
         * FuncPtr的参数为block结构体：void __main_block_func_0(struct __main_block_impl_0 *__cself)
         */
        
    }
    return 0;
}
