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

void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    // 【监听RunLoop各种状态的改变】
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"即将进入Loop");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"即将处理Times");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"即将处理Source");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"即将进入休眠");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"刚从休眠中唤醒");
            break;
        case kCFRunLoopExit:
            NSLog(@"即将退出Loop");
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * CFRunLoopModeRef的类型
     * kCFRunLoopDefaultMode/NSDefaultRunLoopMode：App的默认Mode，通常主线程是在这个Mode下运行
     * UITrackingRunLoopMode：界面跟踪的Mode，用于ScrollView追踪触摸滑动，保证界面滑动时不受其他Mode影响
     * kCFRunLoopCommonModes：包括 kCFRunLoopDefaultMode 和 UITrackingRunLoopMode 共用的Mode
        * PS：这并不是一个真的Mode，它只是一个标记。
     * 其他的都是系统的Mode无法使用
     */
    
    // 监听RunLoop的状态
    
    // 1.创建Observer
    
    //【方式一：通过回调函数监听】
    // 参数1：分配器
    // 参数2：监听状态
    // 参数3：是否重复监听
    // 参数4：是否考虑顺序（0：不需要考虑）
    // 参数5：回调的函数指针（地址）
    // 参数6：需要回调的信息，执行回调函数时经由里面的info回传
//    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, runLoopObserverCallBack, NULL);
    
    //【方式二：通过block监听】
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        //【监听RunLoop模式的切换】
        // 切换Mode，会退出当前Loop，再重新选择一个Mode进入
        // 所以这里只需要监听这两种状态
        switch (activity) {
            case kCFRunLoopEntry:
            {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopEntry --- %@", mode);
                CFRelease(mode);
                break;
            }
            case kCFRunLoopExit:
            {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopExit --- %@", mode);
                CFRelease(mode);
                break;
            }
            default:
                break;
        }
    });
    
    // 2.添加Observer到RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);

    // 3.释放Observer（添加到RunLoop中，RunLoop就会引用Observer，这里就不需要继续引用了）
    CFRelease(observer);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __func__);
    
    // scheduledTimerWithTimeInterval创建的定时器默认添加在默认模式（NSDefaultRunLoopMode）
    // 一旦Runloop进入其他模式（例如滚动的mode），这个定时器就不会工作
    [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        // 定时器能唤醒线程，是在kCFRunLoopAfterWaiting(刚从休眠中唤醒)的状态下执行的
        NSLog(@"hello~");
    }];
}

@end
