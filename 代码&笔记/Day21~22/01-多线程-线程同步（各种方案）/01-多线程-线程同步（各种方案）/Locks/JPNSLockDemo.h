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

// Low-leave Lock：低级🔐，等不到🔐就会去休眠
@interface JPNSLockDemo : JPBaseDemo

@end
