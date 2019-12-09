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
@property (nonatomic, assign) OSSpinLock lock;
@end

@implementation JPOSSpinLockDemo

- (instancetype)init {
    if (self = [super init]) {
        // 初始化🔐
        self.ticketLock = OS_SPINLOCK_INIT;
        self.moneyLock = OS_SPINLOCK_INIT;
        self.lock = OS_SPINLOCK_INIT;
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

#pragma mark - 其他：OSSpinLockTry 和 OSSpinLockLock 的区别

/**
 * OSSpinLockTry尝试加🔐，返回bool，true就是【已经】成功加🔐，false就是加🔐失败
 * 如果这个🔐已经有线程用着，那就是失败，返回false，【不会加🔐也不会等待】，代码往下继续
 */

- (void)otherTest {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self aaa];
    });
    
    sleep(1);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self bbb];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self ccc];
    });
}

- (void)aaa {
    if (OSSpinLockTry(&_lock)) {
        NSLog(@"aaa 尝试加锁成功");
        sleep(3);
        NSLog(@"aaa 解锁");
        OSSpinLockUnlock(&_lock);
    } else {
        NSLog(@"aaa 尝试加锁失败");
    }
}

- (void)bbb {
    if (OSSpinLockTry(&_lock)) {
        NSLog(@"bbb 尝试加锁成功");
        sleep(3);
        NSLog(@"bbb 解锁");
        OSSpinLockUnlock(&_lock);
    } else {
        NSLog(@"bbb 尝试加锁失败");
    }
}

- (void)ccc {
    OSSpinLockLock(&_lock);
    NSLog(@"ccc 加锁成功");
    sleep(3);
    NSLog(@"ccc 解锁");
    OSSpinLockUnlock(&_lock);
}

@end
