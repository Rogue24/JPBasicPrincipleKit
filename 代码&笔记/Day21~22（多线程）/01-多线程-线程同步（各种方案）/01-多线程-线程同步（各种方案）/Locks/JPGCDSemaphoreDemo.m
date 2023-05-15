//
//  JPGCDSemaphoreDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPGCDSemaphoreDemo.h"

@interface JPGCDSemaphoreDemo ()
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_semaphore_t ticketSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t moneySemaphore;
@end

@implementation JPGCDSemaphoreDemo

- (instancetype)init {
    if (self = [super init]) {
        /**
         * `semaphore`叫做【信号量】
         * 信号量的初始值，可以用来控制线程并发访问的最大数量
         * 信号量的初始值为1，代表同时只允许1条线程访问资源，保证线程同步
         *
         * 其实就是用信号量的值来判定目前剩多少条线程可以用，当执行任务：
         * 任务开始：`dispatch_semaphore_wait`
            - 如果信号量大于0（`semaphore > 0`）==> 信号量减1（`semaphore - 1`），往下执行代码
            - 如果信号量小于等于0（`semaphore <= 0`）==> 让线程休眠等待，直到信号大于0 ==> 唤醒线程，信号量减1（`semaphore - 1`），接着执行后面的代码
         * 任务最后：`dispatch_semaphore_signal` ==> 信号量加1（`semaphore + 1`），告诉等待中的线程有信号量了！
         *
         * PS：`dispatch_semaphore_wait`和`dispatch_semaphore_signal`要配套使用，【缺一不可】。
         */
        
        // 最多可以5个线程同时执行
        self.semaphore = dispatch_semaphore_create(5);
        
        // 最多1个线程同时执行，保证线程同步
        self.ticketSemaphore = dispatch_semaphore_create(1);
        self.moneySemaphore = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - 其他：信号量为5的演示，即最多可以5个线程同时执行

- (void)otherTest {
    NSLog(@"----------here we go----------");
    for (NSInteger i = 0; i < 20; i++) {
        [[[NSThread alloc] initWithTarget:self selector:@selector(test:) object:@(i)] start];
    }
}

- (void)test:(NSNumber *)number {
    /*
     * dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
     * 如果信号量的值大于0，就让信号量减1，然后继续往下执行代码
     * 如果信号量的值小于等于0，就会让线程休眠等待，直到信号量的值大于0，就唤醒线程，再让信号量的值减1，继续往下执行代码
     * 伪代码：
         dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
                ↓↓↓
               类似于
                ↓↓↓
         if (self.semaphore <= 0) {
             // 线程在此休眠等待，直到这个信号量的值大于0（卡住这里不往下执行）
             sleep(n)
         }
     
         // 能来到这里，说明信号量至少为1，唤醒了这条线程，同时对信号量减1
         self.semaphore -= 1;
        
         // 减1后如果等于0，那么其他还在等这个信号量的线程只能继续等，而这条线程会继续往下执行。
     
     * 参数2的作用是【当信号量的值小于等于0时】线程会等多久：
        - DISPATCH_TIME_FOREVER：一直等待（休眠），直到这个信号量的值大于0
        - DISPATCH_TIME_NOW：不会等待，继续往下执行代码（这样就没法实现线程同步的效果）
     */
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    sleep(3);
    NSLog(@"test %@ --- %@", number, [NSThread currentThread]);
    
    /*
     * dispatch_semaphore_signal(self.semaphore);
     * 信号量加1，发送信号，唤醒等待靠前的线程
     * 伪代码：
         self.semaphore += 1;
     */
    dispatch_semaphore_signal(self.semaphore);
}

/*
 * 伪代码：
     // 初始化信号量，信号量为0
     self.semaphore = dispatch_semaphore_create(0); // self.semaphore = 0;
 
     - (void)test {
         //【1】开始执行任务1
 
         dispatch_async(dispatch_get_global_queue(0, 0), ^{
             //【4】开始执行任务2
             ......
             //【5】任务2结束，信号量加1，发送信号，唤醒等待靠前的线程
             dispatch_semaphore_signal(self.semaphore); // self.semaphore + 1 = 1;
         });
        
         //【2】任务1需要等待任务2执行完才继续，判断有无信号量
         dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); //【3】发现信号量为0，这里卡住（休眠）
         
         //【6】能来到这里，说明信号量至少为1，唤醒了这条线程，同时对信号量减1
         // self.semaphore -= 1;
         // 减1后如果等于0，那么其他还在等这个信号量的线程只能继续等，而这条线程会继续往下执行。
 
         //【7】任务1继续
         ......
     }
 */

#pragma mark - 卖票操作

- (void)__saleTicket {
    dispatch_semaphore_wait(self.ticketSemaphore, DISPATCH_TIME_FOREVER);
    
    [super __saleTicket];
    
    dispatch_semaphore_signal(self.ticketSemaphore);
}

#pragma mark - 存/取钱操作

- (void)__saveMoney {
    dispatch_semaphore_wait(self.moneySemaphore, DISPATCH_TIME_FOREVER);
    
    [super __saveMoney];
    
    dispatch_semaphore_signal(self.moneySemaphore);
}

- (void)__drawMoney {
    dispatch_semaphore_wait(self.moneySemaphore, DISPATCH_TIME_FOREVER);
    
    [super __drawMoney];
    
    dispatch_semaphore_signal(self.moneySemaphore);
}

@end
