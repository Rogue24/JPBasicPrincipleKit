//
//  JPNSLockDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPNSLockDemo.h"

@interface JPNSLockDemo ()
@property (nonatomic, strong) NSLock *ticketLock;
@property (nonatomic, strong) NSLock *moneyLock;
@property (nonatomic, strong) NSRecursiveLock *recursiveLock;
@end

@implementation JPNSLockDemo

- (instancetype)init {
    if (self = [super init]) {
        // 初始化🔐
        self.ticketLock = [[NSLock alloc] init];
        self.moneyLock = [[NSLock alloc] init];
        self.recursiveLock = [[NSRecursiveLock alloc] init];
        
        /**
         * - (BOOL)tryLock;
         * 尝试加🔐，返回BOOL，YES就是【已经】成功加🔐，NO就是加🔐失败
         * 如果这个🔐已经有线程用着，那就是失败，返回NO，不会加🔐也不会等待，代码往下继续
         *
         * - (BOOL)lockBeforeDate:(NSDate *)limit;
         * 如果这个🔐已经有线程用着，当前线程会在给到的日期limit到来之前一直等待（阻塞、休眠）
         * 在limit到来之前，这个🔐可以使用了，那就加🔐，返回YES，代码往下继续
         * 当超过了limit，当前线程就不再等待，返回NO，不会加🔐也不会等待，代码往下继续
         */
    }
    return self;
}

#pragma mark - 卖票操作

- (void)__saleTicket {
    // 加🔐
    [self.ticketLock lock];
    
    [super __saleTicket];
    
    // 解🔐
    [self.ticketLock unlock];
}

#pragma mark - 存/取钱操作

- (void)__saveMoney {
    // 加🔐
    [self.moneyLock lock];
    
    [super __saveMoney];
    
    // 解🔐
    [self.moneyLock unlock];
}

- (void)__drawMoney {
    // 加🔐
    [self.moneyLock lock];
    
    [super __drawMoney];
    
    // 解🔐
    [self.moneyLock unlock];
}

#pragma mark - 其他

/**
 * 递归🔐：允许【同一个线程】对一把🔐进行【重复】加🔐
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
    [self.recursiveLock lock];
    
    static int count = 0;
    int currentCount = count;
    
    NSLog(@"%s --- %d", __func__, currentCount);
    
    if (currentCount < 10) {
        count += 1;
        [self otherTest];
    }
    
    NSLog(@"----%d----", currentCount);
    
    // 解🔐
    [self.recursiveLock unlock];
}


@end
