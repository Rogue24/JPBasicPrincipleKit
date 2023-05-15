//
//  JPMutexCondDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/8.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPMutexCondDemo.h"
#import <pthread.h>

@interface JPMutexCondDemo ()
@property (nonatomic, assign) pthread_mutex_t mutex;
@property (nonatomic, assign) pthread_cond_t cond;
@property (nonatomic, strong) NSMutableArray *mArray;
@end

@implementation JPMutexCondDemo

- (void)__initMutex:(pthread_mutex_t *)mutex {
    // 初始化属性
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); // PTHREAD_MUTEX_RECURSIVE：递归🔐
    // 初始化🔐
    pthread_mutex_init(mutex, &attr);
    // 销毁属性
    pthread_mutexattr_destroy(&attr);
    
    // 初始化条件
    pthread_cond_init(&_cond, NULL);
    
    self.mArray = [NSMutableArray array];
}

- (instancetype)init {
    if (self = [super init]) {
        // 初始化🔐
        [self __initMutex:&_mutex];
    }
    return self;
}

- (void)dealloc {
    // 销毁🔐
    pthread_mutex_destroy(&_mutex);
    // 销毁条件
    pthread_cond_destroy(&_cond);
}

#pragma mark - 其他：条件🔐演示

- (void)otherTest {
    NSLog(@"-------------开始-------------");
    [[[NSThread alloc] initWithTarget:self selector:@selector(__removeObj) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(__hi) object:nil] start];
    sleep(1);
    [[[NSThread alloc] initWithTarget:self selector:@selector(__addObj) object:nil] start];
}

- (void)__removeObj {
    // 加🔐
    pthread_mutex_lock(&_mutex);
    
    NSLog(@"removeObj线程：打算删除元素");
    
    if (self.mArray.count == 0) {
        NSLog(@"removeObj线程：数组空的，条件不成立，让当前线程休眠，并且解🔐");
        pthread_cond_wait(&_cond, &_mutex); // 等待
        NSLog(@"removeObj线程：条件已经成立，唤醒当前线程，重新加🔐");
    }
    
    // `__removeObj线程`和`hi线程`是分别两条线程的等待，哪个会先被唤醒是不确定的
    [self.mArray removeLastObject];
    NSLog(@"removeObj线程：删除了元素");
    
    // 解🔐
    pthread_mutex_unlock(&_mutex);
}

- (void)__hi {
    // 加🔐
    pthread_mutex_lock(&_mutex);
    
    NSLog(@"hi线程：打算say个hi");
    
    if (self.mArray.count == 0) {
        NSLog(@"hi线程：数组空的，条件不成立，让当前线程休眠，并且解🔐");
        pthread_cond_wait(&_cond, &_mutex); // 等待
        NSLog(@"hi线程：条件已经成立，唤醒当前线程，重新加🔐");
    }
    
    // 📢 虽然条件已经成立，但不代表此时self.mArray不为空：
    // 因为`__removeObj线程`和`hi线程`是分别两条线程的等待，哪个会先被唤醒是不确定的，
    //【有可能】`__removeObj线程`比`hi线程`更早唤醒（这里大概率，毕竟先执行），会先执行`__removeObj线程`的代码，
    // 所以这里有可能为0，也有可能为1。
    NSLog(@"hi线程：hi，self.mArray.count: %zd", self.mArray.count);
    
    // 解🔐
    pthread_mutex_unlock(&_mutex);
}

- (void)__addObj {
    // 加🔐
    pthread_mutex_lock(&_mutex);
    
    NSLog(@"addObj线程：准备添加元素");
    sleep(3);
    
    [self.mArray addObject:@"baby"];
    NSLog(@"addObj线程：添加了元素");
    
    NSLog(@"addObj线程：发送信号/广播，告诉【使用着这个条件并等待着的线程】条件成立了，不过要先解了当前这个🔐");
    
    // 激活等待该条件的线程：
    // 1.信号（唤醒一条【使用着这个条件并等待着的线程】）
    // PS：如果有多条，只会唤醒排在最前等待的那一条线程，其他的线程会继续休眠，所以有多少条等待的线程就得唤醒多少次，或者直接广播
//    pthread_cond_signal(&_cond);
//    pthread_cond_signal(&_cond);
    // 2.广播（唤醒所有【使用着这个条件并等待着的线程】）
    pthread_cond_broadcast(&_cond);
    
    // 延迟一下再解锁
    NSLog(@"addObj线程：准备解🔐");
    sleep(3);
    
    // 解🔐
    pthread_mutex_unlock(&_mutex);
}

@end
