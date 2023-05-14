//
//  ViewController.m
//  01-Runloop
//
//  Created by 周健平 on 2019/11/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

/*
 *【RunLoop与线程】
 * 每条线程都有唯一的一个与之对应的RunLoop对象
 * RunLoop 保存在全局的Dictionary，线程作为key，RunLoop作为value ==> 就像 NSDictionary<NSThread *, NSRunLoop *> *runLoops;
 * 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建（懒加载，主线程的RunLoop是在UIApplicationMain()里面获取过的）
 * RunLoop会在线程结束时销毁（一对一的关系，共生体）
 * 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop（除非子线程里面调用`[NSRunLoop currentRunLoop]`就会自动创建）

 *【获取RunLoop对象】
 * 获取当前线程的RunLoop：<<子线程的RunLoop第一次获取时才创建>>
    - OC：NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    - C：CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
 * 获取主线程的RunLoop：<<主线程的RunLoop在UIApplicationMain()已经获取/创建过了>>
    - OC：NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    - C：CFRunLoopRef runLoopRef = CFRunLoopGetMain();
 * <<NSRunLoop是对CFRunLoop的一层OC包装（跟NSOperationQueue类似）>>
 
 *【RunLoop对象的底层结构】
    struct __CFRunLoop {
//        CFRuntimeBase _base;
//        pthread_mutex_t _lock;
//        __CFPort _wakeUpPort;
//        Boolean _unused;
//        volatile _per_run_data *_perRunData;
        pthread_t _pthread;
//        uint32_t _winthread;
        CFMutableSetRef _commonModes;
        CFMutableSetRef _commonModeItems;
        CFRunLoopModeRef _currentMode;
        CFMutableSetRef _modes;
//        struct _block_item *_blocks_head;
//        struct _block_item *_blocks_tail;
//        CFAbsoluteTime _runTime;
//        CFAbsoluteTime _sleepTime;
//        CFTypeRef _counterpart;
    };
        ↓↓↓
      主要了解的
        ↓↓↓
    struct __CFRunLoop {
        pthread_t _pthread;
        CFMutableSetRef _commonModes;
        CFMutableSetRef _commonModeItems;
        CFRunLoopModeRef _currentMode; // 当前的mode，只能一个（是集合中的其中一个mode）
        CFMutableSetRef _modes; // 包含所有mode的一个集合（里面放的是CFRunLoopModeRef）
    };
 
 *【CFRunLoopModeRef的底层结构】
 * 简化过，以下这些是主要了解的：
     struct __CFRunLoopMode {
         CFStringRef _name;
         CFMutableSetRef _sources0;
         CFMutableSetRef _sources1;
         CFMutableArrayRef _observers;
         CFMutableArrayRef _timers;
     };
 
 *【RunLoop的应用范畴】
    1.定时器（Timers）、PerformSelector（Source0、Timers）
    2.GCD Async Main Queue（GCD，回到主队列 async/sync/after）
    3.事件响应、手势识别、界面刷新（Source1->Source0、Observers）
    4.网络请求
    5.AutoreleasePool（Observers）
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    CFRunLoopRef runLoopRef = CFRunLoopGetMain();
    
    NSLog(@"oc %p", runLoop); // 0x6080000bd820
    NSLog(@"c  %p", runLoopRef); // 0x6040001f5600
    
    NSLog(@"%@", runLoop); // <CFRunLoop 0x6040001f5600 ...>
    
    /*
     * 直接打印地址oc对象和c对象地址不同，直接打印oc对象，指向对象的地址却跟c对象一样
     * 打断点查看oc对象地址存放的内容：x/4xg 0x6080000bd820
        0x6080000bd820: 0x00000001016d7ff0 0x00006040001f5600 --> c对象地址
        0x6080000bd830: 0x00006080002539e0 0x0000608000253f20
     * 可以看到有存放着c对象的地址
     * 得出结论：NSRunLoop是对CFRunLoop的一层OC包装（跟NSOperationQueue类似）
     */
}

@end
