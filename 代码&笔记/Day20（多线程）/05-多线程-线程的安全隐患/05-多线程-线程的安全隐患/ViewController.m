//
//  ViewController.m
//  05-多线程-线程安全
//
//  Created by 周健平 on 2019/12/5.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) int ticketTotal;
@property (nonatomic, assign) int money;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self ticketTest];
    [self moneyTest];
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
            [self saveMoney];
        }
        NSLog(@"------任务1结束------");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务2开始------");
        for (NSInteger i = 0; i < 10; i++) {
            [self drawMoney];
        }
        NSLog(@"------任务2结束------");
    });
    
    // 1000 + 10 * 100 - 10 * 50 = 1500
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"目标最后有1500块，实际最后有%d块 --- %@", self.money, [NSThread currentThread]);
    });
}

// 存钱
- (void)saveMoney {
    int originMoney = self.money;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueMoney = self.money;
    
    int currentMoney = originMoney + 100;
    self.money = currentMoney;
    
    NSLog(@"存100块 --- 刚刚有%d块（实际上刚刚剩%d块），现在有%d块 --- %@", originMoney, trueMoney, currentMoney, [NSThread currentThread]);
}

// 取钱
- (void)drawMoney {
    int originMoney = self.money;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueMoney = self.money;
    
    int currentMoney = originMoney - 50;
    self.money = currentMoney;
    
    NSLog(@"取50块 --- 刚刚有%d块（实际上刚刚剩%d块），现在剩%d块 --- %@", originMoney, trueMoney, currentMoney, [NSThread currentThread]);
}

#pragma mark - 卖票演示

- (void)ticketTest {
    self.ticketTotal = 15;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    dispatch_queue_t queue = dispatch_queue_create("123", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务1开始------");
        for (NSInteger i = 0; i < 5; i++) {
            [self saleTicket];
        }
        NSLog(@"------任务1结束------");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务2开始------");
        for (NSInteger i = 0; i < 5; i++) {
            [self saleTicket];
        }
        NSLog(@"------任务2结束------");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"------任务3开始------");
        for (NSInteger i = 0; i < 5; i++) {
            [self saleTicket];
        }
        NSLog(@"------任务3结束------");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"目标剩余0张，实际最后剩余%d张 --- %@", self.ticketTotal, [NSThread currentThread]);
    });
}

// 卖一张
- (void)saleTicket {
    int originCount = self.ticketTotal;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueCount = self.ticketTotal;
    
    int currentCount = originCount - 1;
    self.ticketTotal = currentCount;
    
    NSLog(@"刚刚%d张（实际上刚刚%d张），还剩%d张 --- %@", originCount, trueCount, currentCount, [NSThread currentThread]);
}

@end
