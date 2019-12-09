//
//  JPMutexRecursiveDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/8.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPMutexRecursiveDemo.h"
#import <pthread.h>

@interface JPMutexRecursiveDemo ()
@property (nonatomic, assign) pthread_mutex_t mutex;
@end

@implementation JPMutexRecursiveDemo

- (void)__initMutex:(pthread_mutex_t *)mutex {
    // 初始化属性
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); // PTHREAD_MUTEX_RECURSIVE：递归🔐
    // 初始化🔐
    pthread_mutex_init(mutex, &attr);
    // 销毁属性
    pthread_mutexattr_destroy(&attr);
}

- (instancetype)init {
    if (self = [super init]) {
        // 初始化🔐
        [self __initMutex:&_mutex];
    }
    return self;
}

- (void)dealloc {
    // 销毁🔐
    pthread_mutex_destroy(&_mutex);
}

#pragma mark - 其他：递归演示

/**
 * 递归🔐：允许【同一个线程】对一把🔐进行【重复】加🔐
 * 属性设置为PTHREAD_MUTEX_RECURSIVE
 * How to work？
    线程1：
        otherTest（加🔐）--- 1
            otherTest（加🔐）--- 2
                otherTest（加🔐）--- 3
                otherTest（解🔐）--- 3
            otherTest（解🔐）--- 2
        otherTest（解🔐）--- 1
    线程2：
        otherTest（先休眠，等线程1的🔐全部解开才工作）--- 1
 */
- (void)otherTest {
    // 加🔐
    pthread_mutex_lock(&_mutex);
    
    static int count = 0;
    int currentCount = count;
    
    NSLog(@"%s --- %d", __func__, currentCount);
    
    if (currentCount < 10) {
        count += 1;
        [self otherTest];
    }
    
    NSLog(@"----%d----", currentCount);
    
    // 解🔐
    pthread_mutex_unlock(&_mutex);
}

@end
