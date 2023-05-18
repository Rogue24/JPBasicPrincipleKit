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
// 关闭ARC：Targets --> Build Settings --> 搜索automatic reference --> 设置为NO

@interface ViewController ()

@end

/*
 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry = (1UL << 0),            1  0x01  0b00000001
    kCFRunLoopBeforeTimers = (1UL << 1),     2  0x02  0b00000010
    kCFRunLoopBeforeSources = (1UL << 2),    4  0x04  0b00000100
    kCFRunLoopBeforeWaiting = (1UL << 5),   32  0x20  0b00100000
    kCFRunLoopAfterWaiting = (1UL << 6),    64  0x40  0b01000000
    kCFRunLoopExit = (1UL << 7),           128  0x80  0b10000000
    kCFRunLoopAllActivities = 0x0FFFFFFFU
 };

 * iOS系统在主线程的`Runloop`中注册了【2】个Observer，这两个Observer的回调函数都是`_wrapRunLoopWithAutoreleasePoolHandler`，
 * 明显就是用来处理`AutoreleasePool`相关的事情，打印`[NSRunLoop mainRunLoop]`可以看到：
 
 *【1】<CFRunLoopObserver 0x6000033005a0 [0x7fff80617cb0]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x7fff4808bf54), context = <CFArray 0x600000c4bab0 [0x7fff80617cb0]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7fe83a802048>\n)}}
 * 👂🏻 监听的状态：
 *  - activities = 0x1 --> 0b0001 --> kCFRunLoopEntry
 * 🤖 执行的行动：
 *  - 监听到【kCFRunLoopEntry】状态，调用`objc_autoreleasePoolPush()`
 
 *【2】<CFRunLoopObserver 0x600003300640 [0x7fff80617cb0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x7fff4808bf54), context = <CFArray 0x600000c4bab0 [0x7fff80617cb0]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7fe83a802048>\n)}}
 * 👂🏻 监听的状态：
 *  - activities = 0xa0 --> 0b10100000 --> (kCFRunLoopBeforeWaiting | kCFRunLoopExit)
 * 🤖 执行的行动：
 *  - 监听到【kCFRunLoopBeforeWaiting】状态，先调用`objc_autoreleasePoolPop()`，再调用`objc_autoreleasePoolPush()`
 *  - 监听到【kCFRunLoopExit】状态，调用`objc_autoreleasePoolPop()`
 
 * 整个App的运行过程中保持`push`和`pop`的成对执行：
 *  - 进入`Runloop`时执行一次`push` --- 启动App或切换Mode
 *  - 循环过程中【在休眠前】先`pop`再`push`
 *  - 退出`Runloop`时执行一次`pop` --- 退出App或切换Mode
 * 实现完美闭合。
 */

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
    
    // 查看系统在主线程的`Runloop`中注册的`Observer`
//    NSLog(@"%@", [NSRunLoop mainRunLoop]);
    
    NSLog(@"viewDidLoad --- 1");
    
    // <1> 如果是自定义的`autoreleasepool`
    // - 会在自动释放池的{}结束前一刻调用`release`
    @autoreleasepool {
        JPPerson *per1 = [[[JPPerson alloc] init] autorelease];
        NSLog(@"per1 %@", per1);
    }
    // 所以per1会在{}的最后销毁
    
    NSLog(@"viewDidLoad --- 2");

    // <2> 如果不是在自定义的`autoreleasepool`，而是在【main函数】的`autoreleasepool`里面的
    // - 什么时候释放是由`RunLoop`控制的
    // - 可能在某次`RunLoop`循环中，`RunLoop`休眠之前（kCFRunLoopBeforeWaiting）调用了`release`
    JPPerson *per2 = [[[JPPerson alloc] init] autorelease];
    NSLog(@"per2 %@", per2);
    
    // 例如在这里，`viewDidLoad`和viewWillAppear是处于同一次RunLoop循环中
    // `viewDidAppear`到来之前，`RunLoop`会进行一次休眠，
    // 所以`per2`会等`RunLoop`这次循环的休眠之前，也就是在【`viewWillAppear`之后、`viewDidAppear`之前】才销毁。
    
    /**
     * 如何知道`viewDidLoad`和`viewWillAppear`是处于同一次`RunLoop`循环中？
     *
     * 1. 在`viewDidLoad`、`viewWillAppear`、`viewDidAppear`分别打个断点，再使用`bt`查看函数调用栈
     *  - 可以看到`viewDidLoad`和`viewWillAppear`都是在`source0`中处理，而`viewDidAppear`不是
     *
     * 2. 监听`RunLoop`的状态
     *  - 可以看到`viewDidLoad`和`viewWillAppear`都是在`RunLoop`同一次循环休眠前执行，而`viewDidAppear`在另外一次
     */
    
    //【MRC】环境下调用了`autorelease`的对象会在【`viewWillAppear`之后、`viewDidAppear`之前】销毁（RunLoop控制）
    //【ARC】环境下，LLVM会在方法的{}即将结束的时候，自动对里面的对象调用`release`方法
    // 所以如果是【ARC】环境下`per2`会在【`viewDidLoad`结束前一刻、`viewWillAppear`之前】就被销毁（LLVM调用）。

    NSLog(@"viewDidLoad --- 3");
    
    JPPerson *per3 = [[JPPerson alloc] init];
    NSLog(@"per3 %@", per3);
    [per3 release]; // 没有使用autorelease的情况下，手动释放会立马销毁
    
    NSLog(@"viewDidLoad --- 4");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s", __func__); // 打个断点使用“bt”查看函数调用栈
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s", __func__); // 打个断点使用“bt”查看函数调用栈
    isOver_ = YES;
}

@end
