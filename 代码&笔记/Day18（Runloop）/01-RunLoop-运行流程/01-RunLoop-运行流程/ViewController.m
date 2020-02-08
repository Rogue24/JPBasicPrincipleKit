//
//  ViewController.m
//  01-RunLoop流程
//
//  Created by 周健平 on 2019/11/28.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

/**
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
 
 *【RunLoop处理各种事件的底层调用】
 * 去调用外部的具体操作：xxx_CALLING_OUT_TO_xxx
 * 通知Observers：
    __CFRunLoopDoObservers --> __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__
 * 处理Source0：
    __CFRunLoopDoSources0 --> __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__
 * 处理Source1：
    __CFRunLoopDoSource1 --> __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__
 * 处理Blocks：
    __CFRunLoopDoBlocks --> __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__
 * 处理Timers：
    __CFRunLoopDoTimers --> __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__
 * 处理GCD：
    __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // GCD需要用到RunLoop的地方：
            NSLog(@"这是RunLoop调用了__CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__才来到这里");
        });
    });
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"这是RunLoop调用了__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__才来到这里");
}


@end
