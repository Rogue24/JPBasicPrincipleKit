//
//  JPOSSpinLockDemo.h
//  07-多线程-线程同步（其他方案）
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * `OSSpinLock`（自旋锁），使用while循环来实现加锁效果，一直占用CPU资源
 *【已经不再安全】，可能会出现【优先级反转问题】。
 * 例如：
 * thread1：优先级高
 * thread2：优先级低
 * 1. 先执行 thread2，加🔐
 * 2. 接着执行 thread1，发现已经加🔐了，那就等 thread2 解🔐
    - 由于 `OSSpinLock`使用的是通过while循环实现的加锁效果，因此等待中的 thread1 是一直活跃着；
    - 又因为【线程调度】，而 thread1 的优先级高，所以CPU就会不断地分配大量时间给 thread1（一直无意义的循环），从而没时间分配给 thread2；
    - 那么 thread2 就没有资源的分配，一直执行不完，导致 thread2 一直解不了🔐， thread1 一直干等着，造成类似【死锁】的情况。
 * 解决：
 * 使用通过【休眠】的方式实现加锁功能的🔐，这样即便 thread1 优先级高，等待的过程中也不会占用CPU资源，CPU也就能分配时间给 thread2 继续执行。
 */

// High-leave Lock：高级🔐
// 特点：等不到🔐就一直等，不会去休眠。
@interface JPOSSpinLockDemo : JPBaseDemo

@end
