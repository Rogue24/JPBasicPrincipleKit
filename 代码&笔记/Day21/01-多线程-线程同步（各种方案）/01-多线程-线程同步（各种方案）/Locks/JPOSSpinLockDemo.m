//
//  JPOSSpinLockDemo.m
//  07-多线程-线程同步（其他方案）
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPOSSpinLockDemo.h"
#import <libkern/OSAtomic.h>

@interface JPOSSpinLockDemo ()
@property (nonatomic, assign) OSSpinLock ticketLock;
@property (nonatomic, assign) OSSpinLock moneyLock;
@end

@implementation JPOSSpinLockDemo

- (instancetype)init {
    if (self = [super init]) {
        // 初始化🔐
        self.ticketLock = OS_SPINLOCK_INIT;
        self.moneyLock = OS_SPINLOCK_INIT;
    }
    return self;
}

#pragma mark - 卖票操作

- (void)__saleTicket {
    // 加🔐
    OSSpinLockLock(&_ticketLock);
    
    [super __saleTicket];
    
    // 解🔐
    OSSpinLockUnlock(&_ticketLock);
}

#pragma mark - 存/取钱操作

- (void)__saveMoney {
    // 加🔐
    OSSpinLockLock(&_moneyLock);
    
    [super __saveMoney];
    
    // 解🔐
    OSSpinLockUnlock(&_moneyLock);
}

- (void)__drawMoney {
    // 加🔐
    OSSpinLockLock(&_moneyLock);
    
    [super __drawMoney];
    
    // 解🔐
    OSSpinLockUnlock(&_moneyLock);
}

@end
