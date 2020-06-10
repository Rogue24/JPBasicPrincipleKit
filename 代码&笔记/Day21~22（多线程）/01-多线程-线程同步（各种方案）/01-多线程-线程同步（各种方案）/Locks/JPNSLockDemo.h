//
//  JPNSLockDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * NSLock是对pthread_mutex普通锁（PTHREAD_MUTEX_DEFAULT）的封装
 * 查看GNUstep的源码可以看到NSLock初始化的是PTHREAD_MUTEX_NORMAL的pthread_mutex
 *
 * NSRecursiveLock是对pthread_mutex递归锁的封装
 * 查看GNUstep的源码可以看到NSRecursiveLock初始化的是PTHREAD_MUTEX_RECURSIVE的pthread_mutex
 */

// Low-leave Lock：低级🔐
// 特点：等不到🔐就会去休眠。
/**
 * 使用汇编跟踪等待中的线程的函数汇编代码：
 * 最后会调用syscall，然后线程就休眠去了，可以看出这是个互斥🔐。
 *【syscall：系统级别的函数调用】
 */
@interface JPNSLockDemo : JPBaseDemo

@end
