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

void (^jpBlockX)(void);

void createStackBlock(void) {
    int x = 99;
    jpBlockX = ^{
        NSLog(@"Hello, StackBlock! x is %d", x);
    };
    jpBlockX();
}

void createMallocBlock(void) {
    int x = 123;
    jpBlockX = [^{
        NSLog(@"Hello, MallocBlock! x is %d", x);
    } copy];
    jpBlockX();
}

#warning 当前在MRC环境下！
// 关闭ARC：Targets --> Build Settings --> 搜索automatic reference --> 设置为NO

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSString *str = @"123";
        int f = 7;
        
        NSLog(@"常量 %p", str); // 0x100004130
        NSLog(@"元类对象 %p", object_getClass([JPPerson class])); // 0x100008220
        NSLog(@"类对象 %p", [JPPerson class]); // 0x1000081f8
        NSLog(@"全局变量 %p %p", &a_, &b_); // 0x100008260 0x100008264
        NSLog(@"实例对象 %p", [JPPerson new]); // 0x600000004010
        NSLog(@"局部变量 %p", &f); // 0x7ff7bfefead4
        /*
         * 应用程序的内存分配
          【低地址】
            - 代码段（函数）__TEXT
            - 数据段（常量、全局变量、类/元类对象）__DATA
                - 常量区
                - 静态区/全局区
                -【GlobalBlock】
            - 堆（对象）heap
                - 动态分配内存，需要程序员自己去申请内存(malloc)、管理内存(release)
                -【MallocBlock】
            - 栈（局部变量）stack
                - 系统自动分配、销毁内存
                -【StackBlock】
          【高地址】
         */
        
        /**
         * 局部变量 --> 需要捕获 --> 因为跨函数访问，本体超出作用域就无法再访问，所以要捕获进去
         * 全局变量 --> 不用捕获 --> 全部函数都可以直接访问
         */
        static int x = 22;
        void (^jpBlock1)(void) = ^{
            NSLog(@"Hello, Block! a is %d, b is %d, x is %d", a_, b_, x);
            int a = 0;
            for (int i = 0; i < 9999999; i++) {
                a += 1;
            }
            NSLog(@"over");
        };
        a_ = 30;
        b_ = 40;
        x = 33;
        jpBlock1();
        NSLog(@"go on");
        a_ = 80;
        b_ = 100;
        x = 44;
        
        // block的类型
        NSLog(@"jpBlock1 %@", [jpBlock1 class]); // __NSGlobalBlock__
//        NSLog(@"jpBlock1 %@", [[jpBlock1 class] superclass]); // __NSGlobalBlock
//        NSLog(@"jpBlock1 %@", [[[jpBlock1 class] superclass] superclass]); // NSBlock
//        NSLog(@"jpBlock1 %@", [[[[jpBlock1 class] superclass] superclass] superclass]); // NSObject
        // 📢 最新版iOS已经不存在`__NSXXXBlock`这种类型了，`__NSXXXBlock__`直接继承自`NSBlock`
        NSLog(@"jpBlock1 %@", [[jpBlock1 class] superclass]); // NSBlock
        NSLog(@"jpBlock1 %@", [[[jpBlock1 class] superclass] superclass]); // NSObject
        
        /**
         * `block`最终继承于`NSObject`，所以`block`本质上就是一个【OC对象】。
         */
        
        int c = 99;
        void (^jpBlock2)(void) = ^{
            NSLog(@"Hello, Block! c is %d", c);
        };
        // ARC：__NSMallocBlock__，MRC：__NSStackBlock__
        NSLog(@"jpBlock2 %@", [jpBlock2 class]);
        // 📢 最新版iOS已经不存在`__NSXXXBlock`这种类型了，`__NSXXXBlock__`直接继承自`NSBlock`
        // ARC：__NSMallocBlock，MRC：__NSStackBlock ❌
        // NSBlock ✅
        NSLog(@"jpBlock2 %@", [[jpBlock2 class] superclass]);
        
        int d = 101;
        // __NSStackBlock__
        NSLog(@"jpBlock3 %@", [^{
            NSLog(@"Hello, Block! d is %d", d);
        } class]);
        // 📢 最新版iOS已经不存在`__NSXXXBlock`这种类型了，`__NSXXXBlock__`直接继承自`NSBlock`
        // __NSStackBlock ❌
        // NSBlock ✅
        NSLog(@"jpBlock3 %@", [[^{
            NSLog(@"Hello, Block! d is %d", d);
        } class] superclass]);
        
        // 通过`clang`编译的C++代码中的`block`的isa都赋值为`_NSConcreteStackBlock`，
        // 这些代码不一定就是OC实际转成的C++代码，例如类型可能不一样，但总体来说差别不大，可以作为【参考】。
        // 一切以【运行时的结果】为准！！！（打印出来的就是运行时的结果）
        //
        // `clang`编译后的的block类型：
        // _NSConcreteGlobalBlock, _NSConcreteMallocBlock, _NSConcreteStackBlock  ---- 这一行仅供参考
        //        ↓                       ↓                       ↓
        // 运行时打印的block类型才是真正的类型：
        // __NSGlobalBlock__,      __NSMallocBlock__,      __NSStackBlock__  ---- ✅
        //        ↓                       ↓                       ↓
        // 📢 最新版iOS已经不存在`__NSXXXBlock`这种类型了，`__NSXXXBlock__`直接继承自`NSBlock`
        // __NSGlobalBlock,        __NSMallocBlock,        __NSStackBlock  ---- ❌忽略这一行
        // ↓↓↓
        // NSBlock
        // ↓
        // NSObject
        
        // 低地址
        //【1】代码段
        //【2】数据段 <--- GlobalBlock
        //【3】堆 <------ MallocBlock
        //【4】栈 <------ StackBlock
        // 高地址
        
        /**
         * `GlobalBlock`：【没有访问任何`auto`变量】的block
         *  - 记住：`static`变量不是`auto`变量，跟全局变量一样，都是一直存在内存中。
         * `StackBlock`：【只要有访问了`auto`变量】的block
         * `MallocBlock`：对`StackBlock`调用了copy（升级）
         *
         * 问题：为啥`jpBlock2`访问了`auto`变量，但打印的是`MallocBlock`类型？
         * 因为现在是在【ARC环境】下运行的，ARC背后做了很多事情：
         * ARC环境下，`StackBlock`赋值给【强指针】时会自动调用`copy`，`copy`后升级变成`MallocBlock`。
         */
        
        // --------------------------- StackBlock的问题 begin ---------------------------
        // 😱演示问题
        createStackBlock(); // --> 这个函数里面设置了jpBlockX，类型为StackBlock（访问了auto变量）
        jpBlockX(); // 调用完函数再调用block
        // ==> 调用结果中的auto变量为【乱码】（本来是99，但这里是-272632968，变成了垃圾数据）
        
        // 🤔分析问题
        /**
         * 因为这是`StackBlock`类型的 block，是在【栈】上分配的内存，而`jpBlockX`只是个全局变量的指针，引用着这个内存地址。
         *  - `StackBlock`类型的 block 里面的`impl`、`Desc`、`捕获的auto变量`这些成员是存在【栈】上的，而它的函数是在【代码段】
         *
         * 当`createStackBlock`函数调用完（即离开了函数的作用域），系统就会自动回收 {} 里面的临时变量（包括 block 内的成员变量），也就是回收当初在【栈】上开辟给这个函数使用的那块内存，
         * 接着执行`jpBlockX()`，这时候去访问 block 内的成员变量，由于成员已经被销毁了，都变成了垃圾数据，所以得到的是一堆乱码。
         */
        
        // 😁解决问题
        // 防止这种情况出现：将栈上的block搬到堆上（copy）
        // 只要放在堆上，系统就不会自动回收这个block了。
        createMallocBlock(); // --> 对`StackBlock`调用了copy --> 将block的内存搬到堆空间里面
        jpBlockX(); // 调用完函数再调用block，auto变量不再为乱码，因为这次没有被系统回收
        
        // 这时候的block是在堆上，MRC环境下需要手动释放，防止内存泄漏
        [jpBlockX release];
        // --------------------------- StackBlock的问题 ended ---------------------------
        
        /**
         * 三种 block 类型进行`copy`操作后的结果：
         * `GlobalBlock` ==copy==>  啥事没有
         * `MallocBlock` ==copy==>  还是在【堆】，并不会再产生一块新的内存，而是引用计数+1，需要注意内存管理
         * `StackBlock`   ==copy==>  内存从【栈】搬到【堆】，需要注意内存管理
         */
        NSLog(@"jpBlock2 origin is %@", [jpBlock2 class]);
        jpBlock2 = [jpBlock2 copy];
        NSLog(@"jpBlock2 after copy is %@", [jpBlock2 class]);
        [jpBlock2 release]; // 已经在堆上，需要销毁
    }
    return 0;
}
