//
//  main.m
//  01-Block
//
//  Created by 周健平 on 2019/10/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
#import <objc/runtime.h>

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

void (^jpBlockX)(void);

void createStackBlock() {
    int x = 99;
    jpBlockX = ^{
        NSLog(@"Hello, StackBlock! x is %d", x);
    };
    jpBlockX();
}

void createMallocBlock() {
    int x = 123;
    jpBlockX = [^{
        NSLog(@"Hello, MallocBlock! x is %d", x);
    } copy];
    jpBlockX();
}

#warning 当前在MRC环境下！

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        int f = 7;
        NSLog(@"全局变量 %p %p", &a_, &b_);
        NSLog(@"元类对象 %p", object_getClass([JPPerson class]));
        NSLog(@"类对象 %p", [JPPerson class]);
        NSLog(@"实例对象 %p", [JPPerson new]);
        NSLog(@"局部变量 %p", &f);
        // 应用程序的内存分配
        // 低地址
        // 【1】程序区域/代码段/代码区（函数、常量）
        // 【2】数据区域/数据段/全局区（全局变量、类/元类对象）
        // 【3】堆（对象）：动态分配内存，需要程序员自己去申请内存(malloc)、管理内存(release)
        // 【4】栈（局部变量）：系统自动分配、销毁内存
        // 高地址
        
        /**
         * 局部变量 --> 需要捕获 --> 超出作用域就无法访问（跨函数访问）
         * 全局变量 --> 不用捕获 --> 全部函数都可以直接访问
         */
        void (^jpBlock1)(void) = ^{
            NSLog(@"Hello, Block! a is %d, b is %d", a_, b_);
            int a = 0;
            for (int i = 0; i < 9999999; i++) {
                a += 1;
            }
            NSLog(@"over");
        };
        a_ = 30;
        b_ = 40;
        jpBlock1();
        NSLog(@"go on");
        a_ = 80;
        b_ = 100;
        
        // block的类型
        NSLog(@"jpBlock1 %@", [jpBlock1 class]); // __NSGlobalBlock__
        NSLog(@"jpBlock1 %@", [[jpBlock1 class] superclass]); // __NSGlobalBlock
        NSLog(@"jpBlock1 %@", [[[jpBlock1 class] superclass] superclass]); // NSBlock
        NSLog(@"jpBlock1 %@", [[[[jpBlock1 class] superclass] superclass] superclass]); // NSObject
        
        int c = 99;
        void (^jpBlock2)(void) = ^{
            NSLog(@"Hello, Block! c is %d", c);
        };
        NSLog(@"jpBlock2 %@", [jpBlock2 class]);  // ARC：__NSMallocBlock__，MRC：__NSStackBlock__
        NSLog(@"jpBlock2 %@", [[jpBlock2 class] superclass]); // ARC：__NSMallocBlock，MRC：__NSStackBlock
        
        int d = 101;
        NSLog(@"jpBlock3 %@", [^{
            NSLog(@"Hello, Block! d is %d", d);
        } class]);  // __NSStackBlock__
        NSLog(@"jpBlock3 %@", [[^{
            NSLog(@"Hello, Block! d is %d", d);
        } class] superclass]); // __NSStackBlock
        
        // 编译的C++文件的block的isa都赋值为_NSConcreteStackBlock
        // 不一定都正确，一切以打印（运行时）为准
        // _NSConcreteGlobalBlock, _NSConcreteMallocBlock, _NSConcreteStackBlock
        // __NSGlobalBlock__,      __NSMallocBlock__,      __NSStackBlock__ // 打印的
        //        ↓                       ↓                       ↓
        // __NSGlobalBlock,        __NSMallocBlock,        __NSStackBlock
        // ↓↓↓
        // NSBlock
        // ↓
        // NSObject
        
        // 低地址
        // 【1】程序区域
        // 【2】数据区域  <-- GlobalBlock
        // 【3】堆       <-- MallocBlock
        // 【4】栈       <-- StackBlock
        // 高地址
        
        /**
         * GlobalBlock：【没有访问任何auto变量】的block（只访问了static变量也是Global）
         * MallocBlock：对StackBlock调用了copy（升级）
         * StackBlock：访问了auto变量
         *
         * PS：为啥jpBlock2是访问了auto变量，但打印的是MallocBlock类型？
         * 因为现在是在ARC环境下运行的，ARC背后做了很多事情
         * 关闭ARC：去到 Targets --> Build Settings --> 搜索automatic reference --> 设置为NO
         */
        
        createStackBlock(); // --> 里面设置了jpBlockX，定义为StackBlock（访问了auto变量）
        jpBlockX(); // 调用完函数再调用block --> 调用结果中的auto变量为乱码
        /**
         * 因为这是StackBlock类型的block，【是在栈上分配的内存，jpBlockX这个全局变量只是引用这个地址】
         * StackBlock类型的block里面的impl、Desc、其他捕获的变量是存在栈上的
         * 当test调用完，即离开了作用域，系统就会自动回收这些成员变量
         * 所以在test函数执行完之后，block内的成员变量全部被销毁了，都变成了垃圾数据
         */
        
        // 防止这种情况出现：将栈上的block搬到堆上（copy）
        createMallocBlock(); // --> 对StackBlock调用了copy --> 将block的内存搬到堆空间里面
        jpBlockX(); // 调用完函数再调用block，auto变量不再为乱码，因为这次没有被系统回收
        [jpBlockX release]; // 需要释放防止内存泄漏
        
        /**
         * 三种block类型进行copy操作：
         * GlobalBlock --copy--> 啥事没有
         * MallocBlock --copy--> 还是在【堆】，引用计数+1，需要注意内存管理
         * StackBlock  --copy--> 内存从【栈】搬到【堆】，需要注意内存管理
         */
        NSLog(@"jpBlock2 %@ after copy %@", [jpBlock2 class], [[jpBlock2 copy] class]);
    }
    return 0;
}
