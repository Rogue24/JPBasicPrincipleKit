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
struct __test_block_impl_0 {
    // impl是直接的一个结构体，而不是指针
    struct __block_impl impl;  // 相当于 --> void *isa;
                               //           int Flags;
                               //           int Reserved;
                               //           void *FuncPtr;
    struct __test_block_desc_0* Desc;
    
    int money;  // 值传递
    int *car;   // 指针传递
    
    // 构造函数（类似OC的init方法），返回结构体对象
//    __test_block_impl_0(void *fp, struct __test_block_desc_0 *desc, int _money, int *_car, int flags=0) : money(_money), car(_car) {
//      impl.isa = &_NSConcreteStackBlock;
//      impl.Flags = flags;
//      impl.FuncPtr = fp;
//      Desc = desc;
//    }
    // money(_money)、car(_car)：C++语法，想当于自动将_xxx这个值赋值给xxx这个成员 ==> xxx = _xxx;
    // int money --> 值传递
    // int *car --> 指针传递
};

// block的描述信息
struct __test_block_desc_0 {
  size_t reserved;
  size_t Block_size; // block所占内存大小
} __main_block_desc_0_DATA = { 0, sizeof(struct __test_block_impl_0)};


// 封装了block执行逻辑的函数
void __test_block_func_0(struct __test_block_impl_0 *__cself) {
//    int money = __cself->money; // bound by copy
//    int *car = __cself->car; // bound by copy
//    NSLog((NSString *)&__NSConstantStringImpl__var_folders_d5_lk44v2y52fb93pytpn58wc800000gn_T_main_581fee_mi_0, money, (*car));
}

void (^jpBlock)(void);

void test() {
    
    // 局部变量默认就自动定义为auto，所以不用自己加上auto关键字
    // auto：自动变量，离开作用域就销毁
    int money = 30; // -> auto int money = 30;
    
    // static：静态局部变量，会一直保存在内存中
    static int car = 100;
    
    jpBlock = ^{
        /*
         * 只要是局部变量，block要访问这个局部变量，都会将之捕获进来
         * block将money的值捕获进来（capture）--> 值传递
            - money是自动变量（auto），离开作用域就销毁，之后就无法访问（不然就会坏内存访问，即野指针），所以auto进行的是值传递，捕获【当前值】
         * block将car的指针捕获进来（capture）--> 指针传递
            - car是静态变量（static），会一直保存在内存中，有地址就能一直访问（不然就只能在作用域内访问），所以static进行的是指针传递，捕获地址随时去访问【最新值】
         */
        NSLog(@"Hello, Block! %d, car %d", money, car);
    };
    
    money = 50;
    car = 200;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        test(); // 这里之后money就会销毁，car还在内存中
        jpBlock();
    }
    return 0;
}
