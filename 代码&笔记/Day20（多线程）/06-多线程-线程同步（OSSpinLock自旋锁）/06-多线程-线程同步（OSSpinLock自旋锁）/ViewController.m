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
 *【已经不再安全】，可能会出现【优先级反转问题】。
 * 例如：
 * thread1：优先级高
 * thread2：优先级低
 * 1. 先执行 thread2，加🔐
 * 2. 接着执行 thread1，发现已经加🔐了，那就等 thread2 解🔐
    - 由于 OSSpinLock 使用的是通过while循环实现的加锁效果，因此等待中的 thread1 是一直活跃着；
    - 又因为【线程调度】，而 thread1 的优先级高，所以CPU就会不断地分配大量时间给 thread1（一直无意义的循环），从而没时间分配给 thread2；
    - 那么 thread2 就没有资源的分配，一直执行不完，导致 thread2 一直解不了🔐， thread1 一直干等着，造成类似【死锁】的情况。
 * 解决：
 * 使用通过【休眠】的方式实现加锁功能的🔐，这样即便 thread1 优先级高，等待的过程中也不会占用CPU资源，CPU也就能分配时间给 thread2 继续执行。
 */

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - OSSpinLockTry 和 OSSpinLockLock 的区别

/**
 * OSSpinLockTry尝试加🔐，返回bool，true就是【已经】成功加🔐，false就是加🔐失败
 * 如果这个🔐已经有线程用着，那就是失败，返回false，【不会加🔐也不会等待】，代码往下继续
 */
- (IBAction)lockTryTest {
    self.ticketLock = OS_SPINLOCK_INIT;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (OSSpinLockTry(&(self->_ticketLock))) {
            NSLog(@"111 尝试加锁成功 --- %@", [NSThread currentThread]);
            sleep(3);
            NSLog(@"111 解锁 --- %@", [NSThread currentThread]);
            OSSpinLockUnlock(&(self->_ticketLock));
        } else {
            NSLog(@"111 尝试加锁失败 --- %@", [NSThread currentThread]);
        }
    });
    
    sleep(1);
    
    // 尝试加🔐，没有🔐就不等也不执行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (OSSpinLockTry(&(self->_ticketLock))) {
            NSLog(@"222 尝试加锁成功 --- %@", [NSThread currentThread]);
            sleep(3);
            NSLog(@"222 解锁 --- %@", [NSThread currentThread]);
            OSSpinLockUnlock(&(self->_ticketLock));
        } else {
            NSLog(@"222 尝试加锁失败 --- %@", [NSThread currentThread]);
        }
    });
    
    // 不尝试，直接加🔐，没有🔐就一直等到有🔐
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"333 等着加锁 --- %@", [NSThread currentThread]);
        OSSpinLockLock(&(self->_ticketLock));
        NSLog(@"333 加锁成功 --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"333 解锁 --- %@", [NSThread currentThread]);
        OSSpinLockUnlock(&(self->_ticketLock));
    });
}

#pragma mark - 卖票演示

- (IBAction)ticketTest {
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
    // 这样会导致每次要加🔐时，这个🔐都是新建的，新的锁肯定是没锁上的，接着会去执行后面代码，这样等于没锁，就有可能跟另一条线程的操作冲突了
    // self.lock = OS_SPINLOCK_INIT;
    
    // 加🔐
    OSSpinLockLock(&_ticketLock);
    /*
     * OSSpinLock的原理就是写了个while循环卡住线程，不断去判断这个🔐有没有被锁上（一直占用CPU资源）
       ==> while(是不是加了锁) {}
     */
    
    // OSSpinLockTry尝试加🔐，返回bool，true就是【已经】成功加🔐，false就是加🔐失败
    // 如果这个🔐已经有线程用着，那就是失败，返回false，【不会加🔐也不会等待】，代码往下继续
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

- (IBAction)moneyTest {
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
