//
//  ViewController.m
//  02-RunLoop（NSTimer）
//
//  Created by 周健平 on 2019/11/28.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    static int count = 0;
    
    // scheduledTimerWithTimeInterval创建的定时器默认添加在默认模式（NSDefaultRunLoopMode）
    // 一旦Runloop进入其他模式（例如滚动的mode），这个定时器就不会工作
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        // 定时器能唤醒线程，是在kCFRunLoopAfterWaiting(刚从休眠中唤醒)的状态下执行的
//        CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
//        NSLog(@"%@ --- %d", mode, ++count);
//    }];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
        NSLog(@"%@ --- %d", mode, ++count);
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    NSLog(@"Show Time!");
    
    /*
     *【RunLoop对象的底层结构】
     * 简化过，以下这些是主要了解的：
        struct __CFRunLoop {
            pthread_t _pthread;
            CFMutableSetRef _commonModes; // 如果timer使用NSRunLoopCommonModes时会放入kCFRunLoopDefaultMode和UITrackingRunLoopMode
            CFMutableSetRef _commonModeItems; // 如果timer使用NSRunLoopCommonModes时会放入timer
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
             CFMutableArrayRef _timers; // 如果timer使用kCFRunLoopDefaultMode或UITrackingRunLoopMode时会添加到这里
         };
     
     *【CFRunLoopModeRef的类型】
     * kCFRunLoopDefaultMode/NSDefaultRunLoopMode：App的默认Mode，通常主线程是在这个Mode下运行
     * UITrackingRunLoopMode：界面跟踪的Mode，用于ScrollView追踪触摸滑动，保证界面滑动时不受其他Mode影响
     * kCFRunLoopCommonModes/NSRunLoopCommonModes：包括 kCFRunLoopDefaultMode 和 UITrackingRunLoopMode 共用的Mode
     *
     * 其他的都是系统的Mode无法使用
     *
     * kCFRunLoopDefaultMode 和 UITrackingRunLoopMode 才是真正存在的模式
     * kCFRunLoopCommonModes 并不是一个真的Mode，它只是一个标记。
     
     *【RunLoop在不同模式下添加Timer的情况】
     *
     * 1.kCFRunLoopDefaultMode 或 UITrackingRunLoopMode 其中的一种模式：
     * 那么 Timer 只能在选定的那一种模式下运行（例：使用Default模式，滚动时就不运行）
     * Timer 会被放到 RunLoop对象的_modes集合 里面对应的那个 CFRunLoopModeRef的_timers数组 中
     * runLoop._modes[x]._timers = [timer];
     *
     * 2.NSRunLoopCommonModes，这不是真的模式，只是一个标记，用来告诉RunLoop对象要这样做：
     * 将 kCFRunLoopDefaultMode 和 UITrackingRunLoopMode 放入到 _commonModes集合 中（这两个模式本来也存放在_modes中）
     * 将 Timer 放入到 _commonModeItems集合 中
     * runLoop._commonModes = [kCFRunLoopDefaultMode, UITrackingRunLoopMode];
     * runLoop._commonModeItems = [timer];
     * 那么 _commonModeItems集合 里面的 timer 可以在 _commonModes集合 里面存放的所有模式下运行
     * 所以无论有无滚动，Timer都能运行
     * PS：RunLoop真正切换的还是kCFRunLoopDefaultMode和UITrackingRunLoopMode这两种模式
     */
}

@end
