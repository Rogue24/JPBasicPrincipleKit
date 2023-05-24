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
 
 *【RunLoop的应用范畴】
    1.定时器（Timers）、PerformSelector（Source0、Timers）
    2.GCD Async Main Queue（GCD，回到主队列 async/sync/after）
    3.事件响应、手势识别、界面刷新（Source1->Source0、Observers）
    4.网络请求
    5.AutoreleasePool（Observers）
 */

void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    //【监听RunLoop各种状态的改变】
    CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"Entry 即将进入Loop --- %@", mode);
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"BeforeTimers 即将处理Times --- %@", mode);
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"BeforeSources 即将处理Sources --- %@", mode);
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"BeforeWaiting 即将进入休眠 --- %@", mode);
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"AfterWaiting 刚从休眠中唤醒 --- %@", mode);
            break;
        case kCFRunLoopExit:
            NSLog(@"Exit 即将退出Loop --- %@", mode);
            break;
        default:
            break;
    }
    CFRelease(mode); // Copy的记得最后要手动释放
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     * CFRunLoopModeRef的类型：
     * 1.kCFRunLoopDefaultMode/NSDefaultRunLoopMode：App的默认Mode，通常主线程是在这个Mode下运行
     * 2.UITrackingRunLoopMode：界面跟踪的Mode，用于ScrollView追踪触摸滑动，保证界面滑动时不受其他Mode影响
     * 3.kCFRunLoopCommonModes：包括 kCFRunLoopDefaultMode 和 UITrackingRunLoopMode 共用的Mode
        - PS：这并不是一个真的Mode，它只是一个标记。
     * 4.其他的都是系统的Mode无法使用
     */
    
    // 监听RunLoop的状态
    
    // 1.创建Observer
    
    //【方式一：通过回调函数监听】
//    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(
//        kCFAllocatorDefault,     // 参数1：allocator --> 分配器
//        kCFRunLoopAllActivities, // 参数2：activities --> 要监听的状态
//        YES,                     // 参数3：repeats --> 是否重复监听
//        0,                       // 参数4：order --> 是否考虑顺序（0：不需要考虑）
//        runLoopObserverCallBack, // 参数5：callout --> 回调函数的指针（地址）
//        NULL                     // 参数6：context --> 需要回调的信息，执行回调函数时经由里面的info回传
//    );
    
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
                CFRelease(mode); // Copy的记得最后要手动释放
                break;
            }
//            case kCFRunLoopBeforeWaiting:
//            {
//                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
//                NSLog(@"kCFRunLoopBeforeWaiting --- %@", mode);
//                CFRelease(mode); // Copy的记得最后要手动释放
//                break;
//            }
            case kCFRunLoopExit:
            {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopExit --- %@", mode);
                CFRelease(mode); // Copy的记得最后要手动释放
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
    // 默认模式下，一旦Runloop进入其他模式（例如滚动的mode），这个定时器就不会工作
    [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        // 定时器能唤醒线程，是在【kCFRunLoopAfterWaiting(刚从休眠中唤醒)】的状态下执行的
        NSLog(@"hello~");
    }];
}

// 定时器能唤醒线程，是在【kCFRunLoopAfterWaiting(刚从休眠中唤醒)】的状态下执行的
// 2023-05-18 04:00:51.174885+0800 [84960:32878653] BeforeWaiting 即将进入休眠 --- kCFRunLoopDefaultMode
// 2023-05-18 04:00:56.089082+0800 [84960:32878653] AfterWaiting 刚从休眠中唤醒 --- kCFRunLoopDefaultMode // 5秒后，被Timer唤醒
// 2023-05-18 04:00:56.089448+0800 [84960:32878653] hello~ // 处理Timer
// 2023-05-18 04:00:56.089757+0800 [84960:32878653] BeforeTimers 即将处理Times --- kCFRunLoopDefaultMode
// 2023-05-18 04:00:56.090007+0800 [84960:32878653] BeforeSources 即将处理Sources --- kCFRunLoopDefaultMode
// 2023-05-18 04:00:56.090229+0800 [84960:32878653] BeforeWaiting 即将进入休眠 --- kCFRunLoopDefaultMode

@end
