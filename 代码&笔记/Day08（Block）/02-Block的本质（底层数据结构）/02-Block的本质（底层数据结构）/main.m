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
    // impl是直接的一个结构体，而不是指针
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
// 也就是NSLog(@"Hello, Block!");
void __main_block_func_0(struct __main_block_impl_0 *__cself) {
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_d5_lk44v2y52fb93pytpn58wc800000gn_T_main_6c7893_mi_0);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        void (^jpBlock)(void) = ^{
            // 这些代码会被封装成`__main_block_func_0`函数
            NSLog(@"Hello, Block!");
        };
        /*
         * 定义block变量的底层代码实现：
         
         void (*jpBlock)(void) =
                    &__main_block_impl_0(
                                         __main_block_func_0,
                                         &__main_block_desc_0_DATA
                                         );
                              ↓↓↓
         __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0)
         * 这是block结构体的【构造函数】（类似OC的init方法），返回block结构体对象
            * 参数1：block执行逻辑的函数地址
                * void *fp = __main_block_func_0
            * 参数2：block的描述信息（占内存大小）
                * __main_block_desc_0 *desc = __main_block_desc_0_DATA
                                                        ↓↓↓
                    * __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)}
                                                                  ↓↓↓
                        * 参数2：计算了这个block结构体的总大小，然后保存到`__main_block_desc_0`这个结构体的`Block_size`成员里面
            * 参数3：不用管，已经有默认值了
                * int flags=0
         */
        
        jpBlock();
        /*
         * 执行block的底层代码实现：
         
         ((void (*)(__block_impl *))((__block_impl *)jpBlock)->FuncPtr)((__block_impl *)jpBlock);
         ↓↓↓
         去掉强制转换
         ↓↓↓
         jpBlock->FuncPtr(jpBlock);
         
         * 为啥`jpBlock`可以直接调用`FuncPtr`？
         * 那是经过了强制转换：__block_impl impl = ((__block_impl *)jpBlock);
           - 因为`jpBlock`的`impl`是`jpBlock`结构体的【第一个成员】，所以`impl`的内存地址就是`jpBlock`的内存地址，
           - 所以`jpBlock`可以直接强制转换成`__block_impl`这种类型，然后去调用它的`FuncPtr`。
         
         * impl.FuncPtr(jpBlock) <==相当于==> jpBlock->FuncPtr(jpBlock)
           - `impl.FuncPtr(jpBlock)`这句代码，无非就是从`impl`的地址往下搜索xx个字节找到`FuncPtr`的地址，然后执行它，
           - `jpBlock`的地址就是`impl`的地址，所以可以去执行同样的命令，毕竟都是一样的内存结构。
         
         * PS1：`FuncPtr`就是`__main_block_func_0`，也就是定义block时，把^{}里面的执行逻辑封装好的函数地址；
         * PS2：`FuncPtr`的参数就是【block结构体本身】==> void __main_block_func_0(struct __main_block_impl_0 *__cself)，所以是这样调用`jpBlock->FuncPtr(jpBlock)`。
         */
        
    }
    return 0;
}
