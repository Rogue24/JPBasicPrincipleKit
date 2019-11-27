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
 
 * CFRunLoopModeRef结构（简化过，这些是主要了解的）：
     struct __CFRunLoopMode {
         CFStringRef _name;
         CFMutableSetRef _sources0;
         CFMutableSetRef _sources1;
         CFMutableArrayRef _observers;
         CFMutableArrayRef _timers;
     };
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    CFRunLoopRef runLoopRef = CFRunLoopGetMain();
    
    NSLog(@"oc %p", runLoop); // 0x6080000bd820
    NSLog(@"c  %p", runLoopRef); // 0x6040001f5600
    
    NSLog(@"%@", runLoop); // <CFRunLoop 0x6040001f5600 ...>
    
    
    /**
     * 直接打印地址oc对象和c对象地址不同，直接打印oc对象，地址跟c对象一样
     * 打断点查看oc对象地址存放的内容：x/4xg 0x6080000bd820
        0x6080000bd820: 0x00000001016d7ff0 0x00006040001f5600 --> c对象地址
        0x6080000bd830: 0x00006080002539e0 0x0000608000253f20
     * 可以看到有存放着c对象的地址
     * 得出结论：NSRunLoop是对CFRunLoop的一层包装（跟NSOperationQueue类似）
     */
}

@end
