//
//  ViewController.m
//  03-内存管理-autorelease时机
//
//  Created by 周健平 on 2019/12/21.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPPerson.h"

#warning 当前在MRC环境下！

@interface ViewController ()

@end

@implementation ViewController

static BOOL isOver_ = NO;
static CFRunLoopObserverRef observer_;
+ (void)load {
    CFOptionFlags optionFlags = kCFRunLoopEntry | kCFRunLoopBeforeWaiting | kCFRunLoopExit;
    observer_ = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, optionFlags, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry:
            {
                NSLog(@"kCFRunLoopEntry");
                break;
            }
            case kCFRunLoopBeforeWaiting:
            {
                NSLog(@"kCFRunLoopBeforeWaiting");
                if (isOver_) {
                    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer_, kCFRunLoopCommonModes);
                    CFRelease(observer_);
                    observer_ = nil;
                }
                break;
            }
            case kCFRunLoopExit:
            {
                NSLog(@"kCFRunLoopExit");
                break;
            }
            default:
                break;
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer_, kCFRunLoopCommonModes);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad --- 1");
    
    // <1> 如果是自定义的autoreleasepool
    //【会在自动释放池的{}结束前一刻调用release】
    @autoreleasepool {
        JPPerson *per1 = [[[JPPerson alloc] init] autorelease];
        NSLog(@"per1 %@", per1);
    }
    // 所以per1会在{}的最后销毁
    
    NSLog(@"viewDidLoad --- 2");

    // <2> 如果不是在自定义的autoreleasepool，而是在main函数的autoreleasepool里面的
    //【什么时候释放是由RunLoop控制的】
    // 可能是在某次RunLoop循环中，在RunLoop休眠之前调用了release（kCFRunLoopBeforeWaiting）
    JPPerson *per2 = [[[JPPerson alloc] init] autorelease];
    NSLog(@"per2 %@", per2);
    
    // 例如在这里，viewDidLoad和viewWillAppear是处于同一次RunLoop循环中
    // viewDidAppear到来之前，RunLoop会进行一次休眠
    // 所以per2会等RunLoop这次循环的休眠之前，也就是在viewWillAppear之后，viewDidAppear之前才销毁
    
    /*
     * 如何知道viewDidLoad和viewWillAppear是处于同一次RunLoop循环中？
     *
     * 1.在viewDidLoad、viewWillAppear、viewDidAppear分别打个断点，再使用“bt”查看函数调用栈，
     * 会看到viewDidLoad和viewWillAppear都在source0中处理，而viewDidAppear不是
     *
     * 2.监听RunLoop的状态
     * 可以看到viewDidLoad和viewWillAppear都是在RunLoop同一次循环睡觉前执行，而viewDidAppear在另外一次
     */

    NSLog(@"viewDidLoad --- 3");
//    NSLog(@"%@", [NSRunLoop mainRunLoop]);
    
    //【MRC】环境下调用了autorelease的对象会在viewWillAppear之后销毁（RunLoop控制）
    //【ARC】环境下，LLVM会在方法的{}即将结束的时候，自动对里面的对象调用release方法
    // 所以如果是【ARC】环境下per2会在viewDidLoad结束前一刻、viewWillAppear之前就会被销毁
    
    JPPerson *per3 = [[JPPerson alloc] init];
    NSLog(@"per3 %@", per3);
    [per3 release]; // 没有使用autorelease的情况下，手动释放会立马销毁
    
    NSLog(@"viewDidLoad --- 4");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s", __func__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s", __func__);
    isOver_ = YES;
}

/*
 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
     kCFRunLoopEntry = (1UL << 0),              1   0x01
     kCFRunLoopBeforeTimers = (1UL << 1),       2   0x02
     kCFRunLoopBeforeSources = (1UL << 2),      4   0x04
     kCFRunLoopBeforeWaiting = (1UL << 5),      32  0x20
     kCFRunLoopAfterWaiting = (1UL << 6),       64  0x40
     kCFRunLoopExit = (1UL << 7),               128 0x80
     kCFRunLoopAllActivities = 0x0FFFFFFFU
 };
 
 * iOS在主线程的Runloop中注册了【2】个Observer，打印[NSRunLoop mainRunLoop]可以看到：
 * 都执行了_wrapRunLoopWithAutoreleasePoolHandler这个回调
 
 *【1】<CFRunLoopObserver 0x6000033005a0 [0x7fff80617cb0]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x7fff4808bf54), context = <CFArray 0x600000c4bab0 [0x7fff80617cb0]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7fe83a802048>\n)}}
 * 监听的状态：activities = 0x1 ==> 0b0001 ==>【kCFRunLoopEntry】
 * 监听到kCFRunLoopEntry事件，会调用objc_autoreleasePoolPush()
 
 *【2】<CFRunLoopObserver 0x600003300640 [0x7fff80617cb0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x7fff4808bf54), context = <CFArray 0x600000c4bab0 [0x7fff80617cb0]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7fe83a802048>\n)}}
 * 监听的状态：activities = 0xa0 ==> 0b10100000 ==>【kCFRunLoopBeforeWaiting | kCFRunLoopExit】
 * 监听到kCFRunLoopBeforeWaiting事件，会调用objc_autoreleasePoolPop()、objc_autoreleasePoolPush()
 * 监听到kCFRunLoopBeforeExit事件，会调用objc_autoreleasePoolPop()
 */

@end
