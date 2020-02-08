//
//  main.m
//  01-Block
//
//  Created by 周健平 on 2019/10/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

// 底层代码：

// Block的描述信息Desc：
struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size; // Block所占内存的大小
};

// impl：
struct __block_impl {
  void *isa; // --> 有isa指针证明Block本质就是个OC对象
  int Flags;
  int Reserved;
  void *FuncPtr; // 函数的地址
};

// Block在底层的结构体：
struct __main_block_impl_0 {
  // Block是封装了函数调用（impl.FuncPtr）以及函数调用环境（money，函数需要的参数）的OC对象（impl.isa）
  // impl是直接的一个结构体，而不是指针
  struct __block_impl impl;  // 相当于 --> void *isa;
                             //           int Flags;
                             //           int Reserved;
                             //           void *FuncPtr;
  struct __main_block_desc_0* Desc;
  int money; // 外部参数
    
    // 创建block的函数：
    // void *fp：就是__main_block_impl_0的地址，即将来block要调用的函数的地址
//  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _money, int flags=0) : money(_money) {
//    impl.isa = &_NSConcreteStackBlock;
//    impl.Flags = flags;
//    impl.FuncPtr = fp; --> 将函数的地址保存到impl的FuncPtr里面
//    Desc = desc;
//  }
};


/*

// 创建block
// __main_block_impl_0：将要执行的代码封装好的函数
void (*jpBlock)(int, int) = ((void (*)(int, int))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, money));

// 调用block
((void (*)(__block_impl *, int, int))((__block_impl *)jpBlock)->FuncPtr)((__block_impl *)jpBlock, 100, 200);

*/

/*
// 将执行的代码封装成这个函数
static void __main_block_func_0(struct __main_block_impl_0 *__cself, int a, int b) {
    int money = __cself->money; // bound by copy
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_d5_lk44v2y52fb93pytpn58wc800000gn_T_main_51a537_mi_0, a);
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_d5_lk44v2y52fb93pytpn58wc800000gn_T_main_51a537_mi_1, b);
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_d5_lk44v2y52fb93pytpn58wc800000gn_T_main_51a537_mi_2, money);
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_d5_lk44v2y52fb93pytpn58wc800000gn_T_main_51a537_mi_3);
}
*/

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        int money = 150;
        
        // *【验证函数地址存放在block里面的impl.FuncPtr】*
        
        void (^jpBlock)(int, int) = ^(int a, int b) {
            // *【2】可以在这里打个断点 *
            // 通过Debug->Debug Workflow->Always Show Disassembly查看汇编代码
            // 可以看到这个函数的初始地址为0x0000000100000ea0
            NSLog(@"a is %d", a);
            NSLog(@"b is %d", b);
            NSLog(@"money is %d", money);
            NSLog(@"Hello, Block!");
        };
        
        struct __main_block_impl_0 *blockStruct = (__bridge struct __main_block_impl_0 *)jpBlock;
        // *【1】可以在这里打个断点 *
        // 在控制台通过打印”p blockStruct->impl.FuncPtr“lldb指令
        // 查看到impl.FuncPtr的地址为0x0000000100000ea0
        
        jpBlock(100, 200);
        
        // *【1】跟【2】的地址是一致，证明了函数地址的确是存放在block里面的impl.FuncPtr。*
    }
    return 0;
}
