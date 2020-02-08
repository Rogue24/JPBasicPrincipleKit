//
//  JPMutexRecursiveDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/8.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * pthread_mutex
 * mutex叫做互斥锁，等待🔐的线程会处于休眠状态（不同于之前那种忙等，会一直占用着CPU资源）
 * 使用汇编跟踪等待中的线程的函数汇编代码，最后会调用【syscall：系统的函数调用】，然后线程就休眠去了
 * PTHREAD_MUTEX_RECURSIVE --- 递归🔐：允许【同一个线程】对一把🔐进行【重复】加🔐
 */

// Low-leave Lock：低级🔐，等不到🔐就会去休眠
@interface JPMutexRecursiveDemo : JPBaseDemo

@end
