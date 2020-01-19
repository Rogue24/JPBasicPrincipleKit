//
//  main.m
//  01-Block
//
//  Created by 周健平 on 2019/10/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

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
    
    // 因为可以直接获取，所以没必要去捕获a_、b_
    
    // 构造函数（类似OC的init方法），返回结构体对象
//    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
//      impl.isa = &_NSConcreteStackBlock;
//      impl.Flags = flags;
//      impl.FuncPtr = fp;
//      Desc = desc;
//    }
};

// block的描述信息
struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size; // block所占内存大小
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};


// 封装了block执行逻辑的函数
void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    
    // 这里直接去获取全局变量a_、b_
    // 既然可以直接获取，所以block没必要去捕获a_、b_
    
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_d5_lk44v2y52fb93pytpn58wc800000gn_T_main_4dcbcb_mi_0, a_, b_);
}


int a_ = 10;
static int b_ = 20;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        void (^jpBlock)(void) = ^{
            NSLog(@"Hello, Block! a is %d, b is %d", a_, b_);
        };
        
        a_ = 30;
        b_ = 40;
        
        jpBlock();
        
        /**
         * 局部变量 --> 需要捕获 --> 因为跨函数访问，本体超出作用域就无法再访问，所以要捕获进去
         * 全局变量 --> 不用捕获 --> 全部函数都可以直接访问
         */
        
        JPPerson *per = [[JPPerson alloc] initWithName:@"shuaigeping"];
        [per test1];
        [per test2];
        [per test3];
    }
    return 0;
}
