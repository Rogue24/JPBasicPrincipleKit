//
//  JPOSSpinLockDemo.h
//  07-多线程-线程同步（其他方案）
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * OSSpinLock（自旋锁），使用while循环来实现加锁效果，一直占用CPU资源
 *【已经不再安全】可能会出现优先级反转问题
 * 例如：
 * thread1：优先级高
 * thread2：优先级低
 * 先执行thread2，加🔐
 * 然后再执行thread1，发现已经锁了，那就等着（不断地while循环）
 * 由于thread1的优先级高，CPU会不断地分配大量时间给thread1（一直无意义的while循环），从而没时间分配给thread2 --- 线程调度
 * 那么thread2就一直执行不完，那就一直解不了🔐，thread1和thread2不断地卡住，造成类似【死锁】的情况（永远拿不到🔐）
 */

// High-leave Lock：高级🔐，等不到🔐就一直等，不会去休眠
@interface JPOSSpinLockDemo : JPBaseDemo

@end
