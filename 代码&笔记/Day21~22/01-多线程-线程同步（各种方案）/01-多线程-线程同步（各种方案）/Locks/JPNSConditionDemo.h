//
//  JPNSConditionDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * NSCondition是对pthread_mutex普通锁（PTHREAD_MUTEX_DEFAULT）和cond的封装
 * 查看GNUstep的源码可以看到NSLock初始化的是PTHREAD_MUTEX_NORMAL的pthread_mutex，并且也初始化了条件_condition
 * PS：不是递归🔐
 */

// Low-leave Lock：低级🔐，等不到🔐就会去休眠
@interface JPNSConditionDemo : JPBaseDemo

@end

