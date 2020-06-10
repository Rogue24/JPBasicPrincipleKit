//
//  JPNSConditionLockDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * NSConditionLock是对NSCondition的进一步封装，可以自定义条件值（可以控制线程的调用顺序）
 * PS：不是递归🔐
 */

// Low-leave Lock：低级🔐
// 特点：等不到🔐就会去休眠。
/**
 * 使用汇编跟踪等待中的线程的函数汇编代码：
 * 最后会调用syscall，然后线程就休眠去了，可以看出这是个互斥🔐。
 *【syscall：系统级别的函数调用】
 */
@interface JPNSConditionLockDemo : JPBaseDemo

@end
