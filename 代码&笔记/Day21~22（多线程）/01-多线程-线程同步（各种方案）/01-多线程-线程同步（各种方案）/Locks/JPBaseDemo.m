//
//  JPBaseDemo.m
//  07-多线程-线程同步（其他方案）
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

@interface JPBaseDemo ()
@property (nonatomic, assign) int money;
@property (nonatomic, assign) int ticketTotal;
@end

@implementation JPBaseDemo

#pragma mark - 卖票演示

- (void)ticketTest {
    self.ticketTotal = 15;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    dispatch_queue_t queue = dispatch_queue_create("123", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务1开始------");
        for (NSInteger i = 0; i < 5; i++) {
            [self __saleTicket];
        }
        NSLog(@"------任务1结束------");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务2开始------");
        for (NSInteger i = 0; i < 5; i++) {
            [self __saleTicket];
        }
        NSLog(@"------任务2结束------");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务3开始------");
        for (NSInteger i = 0; i < 5; i++) {
            [self __saleTicket];
        }
        NSLog(@"------任务3结束------");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"***************目标剩余0张，实际最后剩余%d张***************", self.ticketTotal);
    });
}

#pragma mark 卖一张
- (void)__saleTicket {
    int originCount = self.ticketTotal;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueCount = self.ticketTotal;
    int currentCount = originCount - 1;
    self.ticketTotal = currentCount;
    
    NSLog(@"卖之前%d张（实际上卖之前是%d张），现在还剩%d张 --- %@", originCount, trueCount, currentCount, [NSThread currentThread]);
}

#pragma mark - 存/取钱演示

- (void)moneyTest {
    self.money = 1000;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    dispatch_queue_t queue = dispatch_queue_create("123", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务1开始------");
        for (NSInteger i = 0; i < 10; i++) {
            [self __saveMoney];
        }
        NSLog(@"------任务1结束------");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务2开始------");
        for (NSInteger i = 0; i < 10; i++) {
            [self __drawMoney];
        }
        NSLog(@"------任务2结束------");
    });
    
    // 1000 + 10 * 100 - 10 * 50 = 1500
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"***************目标最后有1500块，实际最后有%d块***************", self.money);
    });
}

#pragma mark 存钱
- (void)__saveMoney {
    int originMoney = self.money;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueMoney = self.money;
    int currentMoney = originMoney + 100;
    self.money = currentMoney;
    
    NSLog(@"存100块 --- 存之前有%d块（实际上存之前有%d块），现在有%d块 --- %@", originMoney, trueMoney, currentMoney, [NSThread currentThread]);
}

#pragma mark 取钱
- (void)__drawMoney {
    int originMoney = self.money;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueMoney = self.money;
    int currentMoney = originMoney - 50;
    self.money = currentMoney;
    
    NSLog(@"取50块 --- 取之前有%d块（实际上取之前有%d块），现在剩%d块 --- %@", originMoney, trueMoney, currentMoney, [NSThread currentThread]);
}

#pragma mark - 其他演示

- (void)otherTest {}

@end
