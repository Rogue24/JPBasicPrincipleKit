//
//  main.m
//  05-内存管理-autoreleasepool
//
//  Created by 周健平 on 2019/12/20.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

#warning 当前在MRC环境下！
// 关闭ARC：Targets --> Build Settings --> 搜索automatic reference --> 设置为NO

/**
 * `extern`：声明外部全局变量（可以用来访问全局的没有被`static`修饰的私有函数、私有变量）
 * 表示变量或者函数的定义可能在别的文件中，提示编译器遇到此变量或者函数时，在别的文件里寻找其定义。
 * 工作原理：先会在当前文件下查找有没有对应全局变量，如果没有，才去其他文件查找
 * 注意：`extern`只能用于声明，不能用于定义
 */

// 查看自动释放池的情况的函数
extern void _objc_autoreleasePoolPrint(void); // 系统私有的函数，存在但不公开的。

int main(int argc, const char * argv[]) {
    // main函数的 @autoreleasepool 的 Push()、Pop() 是【监听了 RunLoop 的状态去调用的】，毕竟整个App存活期间都不会结束，不然一直都不会有 Pop()
    // 在 RunLoop 进入时会 Push() 一次，在 RunLoop 退出时会 Pop() 一次，而在 RunLoop 循环期间，会在休眠之前先 Pop() 一次接着 Push() 一次，才去休眠，达到完美闭合。
    
    @autoreleasepool { //【1】Push() = boundary1 --> 放入 POOL_BOUNDARY
        // atautoreleasepoolobj = objc_autoreleasePoolPush();
        /**
         * 这个`atautoreleasepoolobj`就是`POOL_BOUNDARY`。
         * 是在`objc_autoreleasePoolPush`内部创建好并丢进`AutoreleasePoolPage`中：
         *  - 如果当前没有`autoreleasePoolPage`对象，或者当前页已经满了，就新建一个再把`POOL_BOUNDARY`丢进去。
         * 这里返回`POOL_BOUNDARY`是用于`@autoreleasepool{}`结束时给到`objc_autoreleasePoolPop`函数使用：
         *  - 从栈顶开始逐个pop，如果跟`POOL_BOUNDARY`相等就意味着已经到达边界了，
         *  - 代表已经对当前`@autoreleasepool{}`内生成的全部对象都进行了`release`操作，停止pop。
         */
        
        // 调用了autorelease的对象才会丢到自动释放池中进行内存管理（{}结束后自动进行release操作）
        JPPerson *per1 = [[[JPPerson alloc] init] autorelease];
        NSLog(@"per1 %@", per1);
        /*
         * 对象的`autorelease`方法的底层调用：
             AutoreleasePoolPage *page = hotPage(); // 获取当前`autoreleasePoolPage`对象
             if (page && !page->full()) {
                 return page->add(obj); ==> 已经有`autoreleasePoolPage`对象，并且没满，直接把obj丢进去
             } else if (page) {
                 return autoreleaseFullPage(obj, page); ==> 已经满了，创建下一页的`autoreleasePoolPage`对象再把obj丢进去
             } else {
                 return autoreleaseNoPage(obj); ==> 当前没有autoreleasePoolPage对象，新建一个，接着先放入`POOL_BOUNDARY`，然后再放入obj
             }
         * PS：放入的是对象的内存地址。
         */
        
        /**
         * 📢 使用`@autoreleasepool`并不是新建一个`AutoreleasePoolPage`对象！！！
         * `@autoreleasepool`会在{}的一开始生成一个自己的`POOL_BOUNDARY`，然后判断当前页满不满：
         *  - 1. 还没满的话就直接把自己的`POOL_BOUNDARY`放进当前页
         *  - 2. 满了就【自动】新建一个`AutoreleasePoolPage`对象，再把自己的`POOL_BOUNDARY`放进去
         * PS：
         *  - `POOL_BOUNDARY`是在`@autoreleasepool`的{}开头调用了`objc_autoreleasePoolPush()`函数生成的。
         *  - `AutoreleasePoolPage`对象会【自动】创建的（没有当前页或者当前页满了），不用咱们管。
         */
        @autoreleasepool { //【2】Push() = boundary2 --> 放入 POOL_BOUNDARY
            JPPerson *per2 = [[[JPPerson alloc] init] autorelease];
            NSLog(@"per2 %@", per2);
            
            @autoreleasepool { //【3】Push() = boundary3 --> 放入 POOL_BOUNDARY
                JPPerson *per3 = [[[JPPerson alloc] init] autorelease];
                NSLog(@"per3 %@", per3);
                
                _objc_autoreleasePoolPrint();
                
                /*
                 * _objc_autoreleasePoolPrint()的打印如下：
                 
                     objc[73784]: ##############
                     objc[73784]: AUTORELEASE POOLS for thread 0x1000d2dc0
                     objc[73784]: 6 releases pending.
                     objc[73784]: [0x104805000]  ................  PAGE  (hot) (cold)
                     objc[73784]: [0x104805038]  ################  POOL 0x104805038
                     objc[73784]: [0x104805040]       0x102802cd0  JPPerson // ==> per1
                     objc[73784]: [0x104805048]  ################  POOL 0x104805048
                     objc[73784]: [0x104805050]       0x102802d20  JPPerson // ==> per2
                     objc[73784]: [0x104805058]  ################  POOL 0x104805058
                     objc[73784]: [0x104805060]       0x102802d30  JPPerson // ==> per3
                     objc[73784]: ##############
                 
                 * ################  POOL 0x104805058
                    ==> 这种就是 POOL_BOUNDARY，是当前 autoreleasePool 的初始边界（标识）
                 * (hot)：当前正在使用的那一页
                 * (cold)：不是当前页
                 * (full)：这一页满了
                 */
                
            } //【3】Pop(boundary3)
            
        } //【2】Pop(boundary2)
        
        // objc_autoreleasePoolPop(atautoreleasepoolobj); ==> Pop()
        // 从栈顶开始对里面的对象逐个release，直到遇到`POOL_BOUNDARY`为止（stop）
        // PS：是数据结构的栈，不是内存分布的栈
    } //【1】Pop(boundary1)
    
    return 0;
}

/*
 * 编译的C++文件：

     int main(int argc, const char * argv[]) {
        { __AtAutoreleasePool __autoreleasepool;
            JPPerson *per = ((JPPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((JPPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((JPPerson *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("JPPerson"), sel_registerName("alloc")), sel_registerName("init")), sel_registerName("autorelease"));
        }
        return 0;
     }
     
                 ↓↓↓↓↓↓
                 简化一下
                 ↓↓↓↓↓↓
     
     int main(int argc, const char * argv[]) {
        {
            __AtAutoreleasePool __autoreleasepool;
            JPPerson *per = [[[JPPerson alloc] init] autorelease];
        }
        return 0;
     }
 
 * 在`@autoreleasepool{}`里面有个 __AtAutoreleasePool 类型的结构体变量，结构如下：
 
     struct __AtAutoreleasePool {
     
        // 构造函数，在创建结构体的时候调用
        __AtAutoreleasePool() {
            atautoreleasepoolobj = objc_autoreleasePoolPush();
        }
     
        // 析构函数，在结构体销毁的时候调用
        ~__AtAutoreleasePool() {
            objc_autoreleasePoolPop(atautoreleasepoolobj);
        }
     
        void * atautoreleasepoolobj;
     };

                 ↓↓↓↓↓
                 相当于
                 ↓↓↓↓↓

     int main(int argc, const char * argv[]) {
        {
            // 在autoreleasepool的开头，会创建这么一个变量，返回的是POOL_BOUNDARY
            atautoreleasepoolobj = objc_autoreleasePoolPush();
     
            JPPerson *per = [[[JPPerson alloc] init] autorelease];
     
            // 在autoreleasepool即将结束时，会调用这个函数，传入的是POOL_BOUNDARY
            objc_autoreleasePoolPop(atautoreleasepoolobj);
        }
        return 0;
     }

*/
