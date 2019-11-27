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
 * RunLoop对象的底层结构：
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
 
 * CFRunLoopModeRef代表RunLoop的运行模式
 * 一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer
 * RunLoop启动时只能选择其中一个Mode，作为currentMode
 * 如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入
 * 不同组的Source0/Source1/Timer/Observer能分隔开来，互不影响
 * 如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出
 
 * CFRunLoopModeRef结构（简化过，以下这些是主要了解的）：
 
     struct __CFRunLoopMode {
         CFStringRef _name;
 
         CFMutableSetRef _sources0;
            - 触摸事件处理
            - performSelector:onThread:
 
         CFMutableSetRef _sources1;
            - 基于Port的线程间通信
            - 系统事件捕捉（例：触摸事件是靠这个Source1来捕获，然后再分发给Source0来了处理）
 
         CFMutableArrayRef _observers;
            - 用于监听RunLoop的状态
            - UI刷新（BeforeWaiting）
            - Autorelease pool（BeforeWaiting）
 
         CFMutableArrayRef _timers;
            - NSTimer
            - performSelector:withObject:afterDelay:（底层其实用NSTimer）
     };
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
//    CFRunLoopRef runLoopRef = CFRunLoopGetMain();
    
//    NSLog(@"oc %p", runLoop); // 0x6080000bd820
//    NSLog(@"c  %p", runLoopRef); // 0x6040001f5600
//
//    NSLog(@"%@", runLoop); // <CFRunLoop 0x6040001f5600 ...>
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __func__);
    /*
     * 打个断点，去控制台打印lldb指令【bt】：查看完整的函数调用栈
     * 从函数调用栈中可以看到：
     * 通过 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__
     * 触发了 __handleEventQueueInternal 去处理点击事件，最后执行到这里
     * 看得出【Source0】是用来进行触摸事件处理
     */
}

@end
