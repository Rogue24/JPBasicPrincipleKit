//
//  JPGCDSerialQueueDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPGCDSerialQueueDemo.h"

@interface JPGCDSerialQueueDemo ()
@property (nonatomic, strong) dispatch_queue_t ticketQueue;
@property (nonatomic, strong) dispatch_queue_t moneyQueue;
@end

@implementation JPGCDSerialQueueDemo

- (instancetype)init {
    if (self = [super init]) {
        // 初始化🔐
        self.ticketQueue = dispatch_queue_create("ticketQueue", DISPATCH_QUEUE_SERIAL);
        self.moneyQueue = dispatch_queue_create("moneyQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

/**
 * dispatch_sync + serialQueue：同步执行+串行队列
 * serialQueue：串行队列，里面的任务是排队、按顺序执行，一个任务执行完毕后，再执行下一个任务
 * dispatch_sync：同步执行，在【当前】线程中执行任务，不会开启新线程
 * 不要在自己的串行队列的任务里面再同步执行新任务，会造成死锁，例：
    dispatch_sync(serialQueue, ^{
        任务1
        dispatch_sync(serialQueue, ^{
            任务2
        });
    });
 *
 * 为什么要使用【同步执行+串行队列】的方式就可以实现加🔐的效果？
 * 由于这里的任务都是全局并发队列异步执行的任务（async + globalQueue）：
 * 1. serialQueue：因为每个任务可能分别在不同的子线程，并且是并发执行的，所以放到串行队列可以让多个任务排队去执行
 * 2. dispatch_sync：让串行队列的任务在当前线程执行，因为任务本来就是在子线程执行的，所以没必要再开启新线程
 */

#pragma mark - 卖票操作

- (void)__saleTicket {
    dispatch_sync(self.ticketQueue, ^{
        [super __saleTicket];
    });
}

#pragma mark - 存/取钱操作

- (void)__saveMoney {
    dispatch_sync(self.moneyQueue, ^{
        [super __saveMoney];
    });
}

- (void)__drawMoney {
    dispatch_sync(self.moneyQueue, ^{
        [super __drawMoney];
    });
}

@end
