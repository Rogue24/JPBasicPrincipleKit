//
//  JPGCDSemaphoreDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * semaphore叫做“信号量”
 * 信号量的初始值，可以用来控制线程并发访问的最大数量
 * 信号量的初始值为1，代表同时只允许1条线程访问资源，保证线程同步
 */

@interface JPGCDSemaphoreDemo : JPBaseDemo

@end
