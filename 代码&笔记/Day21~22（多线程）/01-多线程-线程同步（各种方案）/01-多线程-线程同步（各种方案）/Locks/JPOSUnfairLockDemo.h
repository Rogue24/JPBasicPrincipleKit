//
//  JPOSUnfairLockDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * `os_unfair_lock`
 * 用于取代不安全的`OSSpinLock`，从 iOS10 开始才支持
 * 从底层调用看，等待`os_unfair_lock`锁的线程会处于休眠状态，并非忙等（忙等：不断while循环，一直占用CPU资源）
 */

// Low-leave Lock：低级🔐
// 特点：等不到🔐就会去休眠。
/**
 * 使用汇编跟踪等待中的线程的函数汇编代码：
 * --> `os_unfair_lock_lock` --> `_os_unfair_lock_lock_slow` --> `__ulock_wait`
 * 最后会来到`__ulock_wait`，里面调用了`syscall`，然后线程就休眠去了，可以看出这是个互斥🔐。
 * `syscall`：系统级别的函数调用
 */
@interface JPOSUnfairLockDemo : JPBaseDemo

@end
