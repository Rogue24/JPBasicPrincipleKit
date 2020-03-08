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

/**
 * extern：声明外部全局变量（可以用来访问全局的没有被static修饰的私有函数、私有变量）
 * 表示变量或者函数的定义可能在别的文件中，提示编译器遇到此变量或者函数时，在别的文件里寻找其定义。
 * 工作原理：先会去当前文件下查找有没有对应全局变量，如果没有，才回去其他文件查找
 * 注意：extern只能用于声明，不能用于定义
 */

// 查看自动释放池的情况的函数
extern void _objc_autoreleasePoolPrint(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool { //【1】Push()
        // atautoreleasepoolobj = objc_autoreleasePoolPush();
        // 如果本来就有autoreleasePoolPage对象，就加进去，没有就新建
        
        // 调用了autorelease的对象才会丢到自动释放池中进行内存管理（{}结束后自动进行release操作）
        JPPerson *per1 = [[[JPPerson alloc] init] autorelease];
        NSLog(@"per1 %@", per1);
        
        /*
         * 对象的autorelease方法的底层调用：
             AutoreleasePoolPage *page = hotPage();
             if (page && !page->full()) {
                 return page->add(obj); ==> 已经有autoreleasePoolPage对象，并且没满，直接丢进去
             } else if (page) {
                 return autoreleaseFullPage(obj, page); ==> 已经满了，创建下一页autoreleasePoolPage对象再丢进去
             } else {
                 return autoreleaseNoPage(obj); ==> 没有autoreleasePoolPage对象，新建一个
             }
         */
        
        @autoreleasepool { //【2】Push()
            JPPerson *per2 = [[[JPPerson alloc] init] autorelease];
            NSLog(@"per2 %@", per2);
            
            @autoreleasepool { //【3】Push()
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
                     objc[73784]: [0x104805040]       0x102802cd0  JPPerson
                     objc[73784]: [0x104805048]  ################  POOL 0x104805048
                     objc[73784]: [0x104805050]       0x102802d20  JPPerson
                     objc[73784]: [0x104805058]  ################  POOL 0x104805058
                     objc[73784]: [0x104805060]       0x102802d30  JPPerson
                     objc[73784]: ##############
                 
                 * ################  POOL 0x104805058 ==> 这种是POOL_BOUNDARY
                 * 是autoreleasePoolPage的初始边界（标识）
                 */
                
            } //【3】Pop()
            
        } //【2】Pop()
        
        // objc_autoreleasePoolPop(atautoreleasepoolobj);
        // 从栈顶开始对里面的对象逐个release，直到遇到POOL_BOUNDARY为止（stop）
        // PS：是数据结构的栈，不是内存分布的栈
    } //【1】Pop()
    
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
 
 * 在@autoreleasepool{}里面有个 __AtAutoreleasePool 类型的结构体变量，结构如下：
 
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
        // 在autoreleasepool的开头，会创建这么一个变量
        atautoreleasepoolobj = objc_autoreleasePoolPush();
 
        JPPerson *per = [[[JPPerson alloc] init] autorelease];
 
        // 在autoreleasepool即将结束时，会调用这个函数
        objc_autoreleasePoolPop(atautoreleasepoolobj);
    }
    return 0;
 }

*/
