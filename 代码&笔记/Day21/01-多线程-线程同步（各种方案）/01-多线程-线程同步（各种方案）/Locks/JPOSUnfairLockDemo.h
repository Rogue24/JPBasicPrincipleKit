//
//  JPOSUnfairLockDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * os_unfair_lock
 * 用于取代不安全的OSSpinLock ，从<<iOS10>>开始才支持
 * 从底层调用看，等待os_unfair_lock锁的线程会处于休眠状态，并非忙等（忙等：不断while循环，一直占用CPU资源）
 * 使用汇编跟踪等待中的线程的函数汇编代码，最后会调用【syscall：系统的函数调用】，然后线程就休眠去了，可以看出这也是个互斥🔐
 */

// Low-leave Lock：低级🔐，等不到🔐就会去休眠
@interface JPOSUnfairLockDemo : JPBaseDemo

@end
