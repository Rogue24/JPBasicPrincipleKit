//
//  ViewController.m
//  01-Runloop
//
//  Created by 周健平 on 2019/11/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPViewController.h"

@interface ViewController ()

@end

@implementation ViewController

/**
 *【RunLoop与线程】
 * 每条线程都有唯一的一个与之对应的RunLoop对象
 * RunLoop 保存在全局的Dictionary，线程作为key，RunLoop作为value ==> @ {线程：RunLoop}
 * 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建（懒加载，主线程的RunLoop是在UIApplicationMain()里面获取过的）
 * RunLoop会在线程结束时销毁（一对一的关系，共生体）
 * 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop
 */

/**
 *【获取RunLoop对象】
 * 获取当前线程的RunLoop：<<子线程的RunLoop第一次获取时才创建>>
    - OC：NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    - C：CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
 * 获取主线程的RunLoop：<<主线程的RunLoop在UIApplicationMain()已经获取/创建过了>>
    - OC：NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    - C：CFRunLoopRef runLoopRef = CFRunLoopGetMain();
 */

/**
 * 源码获取RunLoop对象过程：
    __CFLock(&loopsLock);
    // 取出runLoop对象，从全局字典__CFRunLoops取出，线程pthreadPointer(t)为key
    CFRunLoopRef loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
    __CFUnlock(&loopsLock);
    if (!loop) {
        // runLoop对象为空，新建一个
        CFRunLoopRef newLoop = __CFRunLoopCreate(t);
        __CFLock(&loopsLock);
        // 再取一次确定此时还有没有
        loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
        if (!loop) {
            // 确定还没有，把新建的runLoop对象丢到全局字典__CFRunLoops中，线程pthreadPointer(t)为key
            CFDictionarySetValue(__CFRunLoops, pthreadPointer(t), newLoop);
            loop = newLoop;
        }
        // don't release run loops inside the loopsLock, because CFRunLoopDeallocate may end up taking it
        __CFUnlock(&loopsLock);
        CFRelease(newLoop);
    }
  */

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self presentViewController:[[JPViewController alloc] init] animated:YES completion:nil];
}

@end
