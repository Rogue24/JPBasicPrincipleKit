//
//  ViewController.m
//  06-多线程-线程同步
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import <libkern/OSAtomic.h>

@interface ViewController ()
@property (nonatomic, assign) int money;
@property (nonatomic, assign) int ticketTotal;

@property (nonatomic, assign) OSSpinLock moneyLock;
@property (nonatomic, assign) OSSpinLock ticketLock;
@end

@implementation ViewController

/**
 * OSSpinLock（自旋锁），使用while循环来实现加锁效果，一直占用CPU资源
 *【已经不再安全】可能会出现优先级反转问题
 * 例如：
 * thread1：优先级高
 * thread2：优先级低
 * 先执行thread2，加🔐
 * 然后再执行thread1，发现已经锁了，那就等着（不断地while循环）
 * 由于thread1的优先级高，CPU会不断地分配大量时间给thread1（一直无意义的while循环），从而没时间分配给thread2 --- 线程调度
 * 那么thread2就一直执行不完，那就一直解不了🔐，thread1和thread2不断地卡住，造成类似【死锁】的情况
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self moneyTest];
    [self ticketTest];
}

#pragma mark - 卖票演示

- (void)ticketTest {
    self.ticketTotal = 15;
    
    // 初始化🔐
    self.ticketLock = OS_SPINLOCK_INIT;
    
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
    // 不能每次都初始化🔐，不然每次操作都是不同的🔐
    // 这样会导致当加🔐时，这个🔐肯定是没锁上的，然后去执行，这样就有可能跟另一条线程的操作冲突了
    // self.lock = OS_SPINLOCK_INIT;
    
    // 加🔐
    OSSpinLockLock(&_ticketLock);
    /*
     * OSSpinLock的原理就是写了个while循环卡住线程，不断去判断这个🔐有没有被锁上（一直占用CPU资源）
       ==> while(是不是加了锁) {}
     */
    
    // OSSpinLockTry尝试加🔐，返回bool，true就是【已经】成功加🔐，false就是加🔐失败
//    if (!OSSpinLockTry(&_ticketLock)) return;
    
    int originCount = self.ticketTotal;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueCount = self.ticketTotal;
    int currentCount = originCount - 1;
    self.ticketTotal = currentCount;
    
    NSLog(@"刚刚%d张（实际上刚刚%d张），还剩%d张 --- %@", originCount, trueCount, currentCount, [NSThread currentThread]);
    
    // 解🔐
    OSSpinLockUnlock(&_ticketLock);
}

#pragma mark - 存/取钱演示

- (void)moneyTest {
    self.money = 1000;
    
    // 初始化🔐
    self.moneyLock = OS_SPINLOCK_INIT;
    
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
    // 加🔐
    OSSpinLockLock(&_moneyLock);
    
    int originMoney = self.money;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueMoney = self.money;
    int currentMoney = originMoney + 100;
    self.money = currentMoney;
    
    NSLog(@"存100块 --- 刚刚有%d块（实际上刚刚剩%d块），现在有%d块 --- %@", originMoney, trueMoney, currentMoney, [NSThread currentThread]);
    
    // 解🔐
    OSSpinLockUnlock(&_moneyLock);
}

// 取钱
- (void)drawMoney {
    // 加🔐
    OSSpinLockLock(&_moneyLock);
    
    int originMoney = self.money;
    
    // 延迟当前线程
    sleep(0.2);
    
    int trueMoney = self.money;
    int currentMoney = originMoney - 50;
    self.money = currentMoney;
    
    NSLog(@"取50块 --- 刚刚有%d块（实际上刚刚剩%d块），现在剩%d块 --- %@", originMoney, trueMoney, currentMoney, [NSThread currentThread]);
    
    // 解🔐
    OSSpinLockUnlock(&_moneyLock);
}

@end
