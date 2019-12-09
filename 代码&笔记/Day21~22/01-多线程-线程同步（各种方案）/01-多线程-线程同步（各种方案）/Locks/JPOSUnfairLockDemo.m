//
//  JPOSUnfairLockDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPOSUnfairLockDemo.h"
#import <os/lock.h>

@interface JPOSUnfairLockDemo ()
@property (nonatomic, assign) os_unfair_lock ticketLock;
@property (nonatomic, assign) os_unfair_lock moneyLock;
@end

@implementation JPOSUnfairLockDemo

- (instancetype)init {
    if (self = [super init]) {
        // 初始化🔐
        self.ticketLock = OS_UNFAIR_LOCK_INIT;
        self.moneyLock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

#pragma mark - 卖票操作

- (void)__saleTicket {
    // 加🔐
    /*
     * PS：void os_unfair_lock_lock(os_unfair_lock_t lock);
     * 传入的是【os_unfair_lock_t】类型
     *
     * 点进【os_unfair_lock】查看结构：
         typedef struct os_unfair_lock_s {
             uint32_t _os_unfair_lock_opaque;
         } os_unfair_lock, *os_unfair_lock_t;
     * 可以看到【os_unfair_lock_t】类型其实就是指向【os_unfair_lock】结构体的指针
     * 所以传入的是【os_unfair_lock】的地址。
     *
     * os_unfair_lock <==> *os_unfair_lock_t
       ↓↓↓
       &(os_unfair_lock) <==> os_unfair_lock_t
     *
     */
    os_unfair_lock_lock(&_ticketLock);
    
    [super __saleTicket];
    
    // 解🔐
    os_unfair_lock_unlock(&_ticketLock);
}

#pragma mark - 存/取钱操作

- (void)__saveMoney {
    // 加🔐
    os_unfair_lock_lock(&_moneyLock);
    
    [super __saveMoney];
    
    // 解🔐
    os_unfair_lock_unlock(&_moneyLock);
}

- (void)__drawMoney {
    // 加🔐
    os_unfair_lock_lock(&_moneyLock);
    
    [super __drawMoney];
    
    // 解🔐
    os_unfair_lock_unlock(&_moneyLock);
}

@end
