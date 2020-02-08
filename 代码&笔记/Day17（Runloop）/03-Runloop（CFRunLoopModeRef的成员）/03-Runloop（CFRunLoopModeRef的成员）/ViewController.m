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
 * RunLoop 保存在全局的Dictionary，线程作为key，RunLoop作为value ==> @ {线程：RunLoop}
 * 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建（懒加载，主线程的RunLoop是在UIApplicationMain()里面获取过的）
 * RunLoop会在线程结束时销毁（一对一的关系，共生体）
 * 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop
 
 *【获取RunLoop对象】
 * 获取当前线程的RunLoop：<<子线程的RunLoop第一次获取时才创建>>
    - OC：NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    - C：CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
 * 获取主线程的RunLoop：<<主线程的RunLoop在UIApplicationMain()已经获取/创建过了>>
    - OC：NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    - C：CFRunLoopRef runLoopRef = CFRunLoopGetMain();
 * <<NSRunLoop是对CFRunLoop的一层OC包装（跟NSOperationQueue类似）>>
 
 *【RunLoop对象的底层结构】
 * 简化过，以下这些是主要了解的：
    struct __CFRunLoop {
        pthread_t _pthread;
        CFMutableSetRef _commonModes;
        CFMutableSetRef _commonModeItems;
        CFRunLoopModeRef _currentMode; // 当前的mode，只能一个（是集合中的其中一个mode）
        CFMutableSetRef _modes; // 包含所有mode的一个集合（里面放的是CFRunLoopModeRef）
    };
 
 *【CFRunLoopModeRef】
 * CFRunLoopModeRef代表RunLoop的运行模式
 * 一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer
 * RunLoop启动时只能选择其中一个Mode，作为currentMode
 * 如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入
 * 不同组的Source0/Source1/Timer/Observer能分隔开来，互不影响
 * 如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出
 
 *【CFRunLoopModeRef的底层结构】
 * 简化过，以下这些是主要了解的：
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
