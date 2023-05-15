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

/**
 * `@synchronized(obj)`内部会生成`obj`对应的递归锁，用于进行加锁、解锁操作
 *
 * 底层使用了哈希表的结构：用这个`obj`对象当作`key`去`StripedMap`中获取对应的`SyncData`对象，然后进行加锁、解锁操作
 *  - `StripedMap`是一个哈希表，作用类似于字典
 *  - `SyncData`是一个结构体，里面存放着🔐，而这个🔐是一个包装了`pthread_mutex`递归锁的C++类
 */

- (instancetype)init {
    if (self = [super init]) {
        /**
         * 如果全局对【同一块内存】进行操作，那就不能用`self`来当作`obj`了，因为每次`init`的`self`都是不同的。
         * 可以使用【类对象】这种全局唯一的对象，或者【全局变量】。
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
        // 底层会在任务开始时先执行：objc_sync_enter(obj)
        
        [super __saleTicket];
        
        // 底层会在任务结束前去执行：objc_sync_exit(obj)
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
    
    // 能来到这里就说明递归到头了，重置一下
    count = 0;
}

@end
