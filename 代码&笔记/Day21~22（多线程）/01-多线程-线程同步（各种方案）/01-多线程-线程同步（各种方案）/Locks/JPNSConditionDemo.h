//
//  JPNSConditionDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * `NSCondition`是对`pthread_mutex`普通锁（`PTHREAD_MUTEX_DEFAULT`）和`pthread_cond`的封装
 * 查看`GNUstep`的源码可以看到`NSCondition`初始化的是`PTHREAD_MUTEX_NORMAL`的`pthread_mutex`，并且也初始化了条件`_condition`
 * PS：不是递归🔐
 */

// Low-leave Lock：低级🔐
// 特点：等不到🔐就会去休眠。
/**
 * 使用汇编跟踪等待中的线程的函数汇编代码：
 * 最后会调用`syscall`，然后线程就休眠去了，可以看出这是个互斥🔐。
 * `syscall`：系统级别的函数调用
 */
@interface JPNSConditionDemo : JPBaseDemo

@end

