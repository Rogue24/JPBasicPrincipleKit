//
//  JPMutexRecursiveDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/8.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * `pthread_mutex`
 * `mutex`叫做互斥锁，等待🔐的线程会处于休眠状态（不同于之前那种忙等，会一直占用着CPU资源）
 *
 * `PTHREAD_MUTEX_RECURSIVE` --- 递归🔐：允许【同一个线程】对同一把🔐进行【重复】加🔐
 */

// Low-leave Lock：低级🔐
// 特点：等不到🔐就会去休眠。
/**
 * 使用汇编跟踪等待中的线程的函数汇编代码：
 * --> `pthread_mutex_lock` --> `_pthread_mutex_lock_slow` --> `_pthread_mutex_lock_wait` --> `__psynch_mutexwait`
 * 最后会来到`__psynch_mutexwait`，里面调用了`syscall`，然后线程就休眠去了，可以看出这是个互斥🔐。
 * `syscall`：系统级别的函数调用
 */
@interface JPMutexRecursiveDemo : JPBaseDemo

@end
