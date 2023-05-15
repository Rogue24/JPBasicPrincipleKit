//
//  JPMutexDefaultDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/7.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPMutexDefaultDemo.h"
#import <pthread.h>

@interface JPMutexDefaultDemo ()
@property (nonatomic, assign) pthread_mutex_t ticketMutex;
@property (nonatomic, assign) pthread_mutex_t moneyMutex;
@end

@implementation JPMutexDefaultDemo

- (void)__initMutex:(pthread_mutex_t *)mutex {
    // 初始化属性
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
    
    // 初始化🔐
    pthread_mutex_init(mutex, &attr); // 如果attr传NULL创建出来的就是PTHREAD_MUTEX_DEFAULT（普通🔐）
    
    // 销毁属性
    pthread_mutexattr_destroy(&attr);
}

- (instancetype)init {
    if (self = [super init]) {
        // 静态初始化
//        _ticketMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
//        _moneyMutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
        
        // 初始化🔐
        [self __initMutex:&_ticketMutex];
        [self __initMutex:&_moneyMutex];
    }
    return self;
}

- (void)dealloc {
    // 销毁🔐
    pthread_mutex_destroy(&_ticketMutex);
    pthread_mutex_destroy(&_moneyMutex);
}

#pragma mark - 卖票操作

- (void)__saleTicket {
    // 加🔐
    pthread_mutex_lock(&_ticketMutex);
    
    [super __saleTicket];
    
    // 解🔐
    pthread_mutex_unlock(&_ticketMutex);
}

#pragma mark - 存/取钱操作

- (void)__saveMoney {
    // 加🔐
    pthread_mutex_lock(&_moneyMutex);
    
    [super __saveMoney];
    
    // 解🔐
    pthread_mutex_unlock(&_moneyMutex);
}

- (void)__drawMoney {
    // 加🔐
    pthread_mutex_lock(&_moneyMutex);
    
    [super __drawMoney];
    
    // 解🔐
    pthread_mutex_unlock(&_moneyMutex);
}

@end
