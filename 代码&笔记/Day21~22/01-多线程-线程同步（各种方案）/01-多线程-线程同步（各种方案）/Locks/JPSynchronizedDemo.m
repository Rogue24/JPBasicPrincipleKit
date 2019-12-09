//
//  JPSynchronizedDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPSynchronizedDemo.h"

@implementation JPSynchronizedDemo

static NSObject *lock_;
static NSObject *ticketLock_;
static NSObject *moneyLock_;

- (instancetype)init {
    if (self = [super init]) {
        /**
         * @synchronized(obj)内部会生成obj对应的递归锁，然后进行加锁、解锁操作
         * 底层中是用这个obj当作key去StripedMap（是一个哈希表，作用类似于字典）来获取对应的SyncData对象（🔐放在这个对象里面）
         * 如果全局对同一块内存进行操作，在这里面就不能用self来当作obj了，因为每次init的self都不同
            - 可以使用类对象这种全局唯一的对象，或者全局变量
         */
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            lock_ = [[NSObject alloc] init];
            ticketLock_ = [[NSObject alloc] init];
            moneyLock_ = [[NSObject alloc] init];
        });
    }
    return self;
}

#pragma mark - 卖票操作

- (void)__saleTicket {
    @synchronized (ticketLock_) {
        // 底层会在任务开始时先执行：objc_sync_enter
        
        [super __saleTicket];
        
        // 底层会在任务结束前去执行：objc_sync_exit
    }
}

#pragma mark - 存/取钱操作

- (void)__saveMoney {
    @synchronized (moneyLock_) {
        [super __saveMoney];
    }
}

- (void)__drawMoney {
    @synchronized (moneyLock_) {
        [super __drawMoney];
    }
}

#pragma mark - 其他：递归演示

- (void)otherTest {
    // 里面封装的是递归🔐
    
    static int count = 0;
    int currentCount = count;
    
    @synchronized (lock_) {
        NSLog(@"%s --- %d", __func__, currentCount);
        
        if (currentCount < 10) {
            count += 1;
            [self otherTest];
        }
        
        NSLog(@"----%d----", currentCount);
    }
}

@end
