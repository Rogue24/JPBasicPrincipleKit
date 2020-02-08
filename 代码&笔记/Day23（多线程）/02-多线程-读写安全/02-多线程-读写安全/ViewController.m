//
//  ViewController.m
//  02-多线程-读写安全
//
//  Created by 周健平 on 2019/12/11.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()
@property (nonatomic, assign) pthread_rwlock_t lock;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@end

@implementation ViewController
{
    NSInteger _index;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    pthread_rwlock_init(&_lock, NULL);
    self.concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
}

- (void)dealloc {
    pthread_rwlock_destroy(&_lock);
}

- (void)write:(NSInteger)index threadMsg:(NSString *)threadMsg {
    sleep(1);
    index += 1;
    NSLog(@"-----------------------------------------");
    NSLog(@"正在 write %zd \n上一条线程：%@\n现在这条线程：%@", index, threadMsg, [NSThread currentThread]);
    NSLog(@"-----------------------------------------");
    _index = index;
}

- (void)read:(NSString *)threadMsg {
    sleep(1);
    NSLog(@"正在 read %zd \n上一条线程：%@\n现在这条线程：%@\n", _index, threadMsg, [NSThread currentThread]);
}

/*
 * 多读单写：经常用于文件等数据的读写操作
    1.同一时间，只能有1个线程进行写的操作
    2.同一时间，允许有多个线程进行读的操作
    3.同一时间，不允许既有写的操作，又有读的操作

 * 实现方案：
 * pthread_rwlock --- 读写🔐
    - 等待锁的线程会进入休眠
 * dispatch_barrier_async/dispatch_barrier_sync --- 栅栏+并发队列
    - 这个函数传入的并发队列【必须】是自己通过【dispatch_queue_cretate】创建的
    - 如果传入的是一个【串行队列】或【全局并发队列】，那这个函数便等同于【dispatch_async/dispatch_sync】函数的效果
 */

#pragma mark - pthread_rwlock
- (IBAction)pthreadRWLock:(id)sender {
    _index = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self pthread_write:i threadMsg:threadMsg];
        });
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self pthread_read:threadMsg];
        });
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self pthread_read:threadMsg];
        });
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self pthread_read:threadMsg];
        });
    }
}
- (void)pthread_write:(NSInteger)index threadMsg:(NSString *)threadMsg {
    pthread_rwlock_wrlock(&_lock);
    [self write:index threadMsg:threadMsg];
    pthread_rwlock_unlock(&_lock);
}
- (void)pthread_read:(NSString *)threadMsg {
    pthread_rwlock_rdlock(&_lock);
    [self read:threadMsg];
    pthread_rwlock_unlock(&_lock);
}

#pragma mark - dispatch_barrier_async
- (IBAction)barrierASYNC:(id)sender {
    _index = 0;
    for (NSInteger i = 0; i < 10; i++) {
        NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
        [self barrierASYNC_write:i threadMsg:threadMsg];
        [self barrierASYNC_read:threadMsg];
        [self barrierASYNC_read:threadMsg];
        [self barrierASYNC_read:threadMsg];
    }
}
- (void)barrierASYNC_write:(NSInteger)index threadMsg:(NSString *)threadMsg {
    dispatch_barrier_async(self.concurrentQueue, ^{
        [self write:index threadMsg:threadMsg];
    });
}
- (void)barrierASYNC_read:(NSString *)threadMsg {
    dispatch_async(self.concurrentQueue, ^{
        [self read:threadMsg];
    });
}

#pragma mark - dispatch_barrier_sync
- (IBAction)barrierSYNC:(id)sender {
    _index = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self barrierSYNC_write:i threadMsg:threadMsg];
        });
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self barrierSYNC_read:threadMsg];
        });
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self barrierSYNC_read:threadMsg];
        });
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self barrierSYNC_read:threadMsg];
        });
    }
}
- (void)barrierSYNC_write:(NSInteger)index threadMsg:(NSString *)threadMsg {
    dispatch_barrier_sync(self.concurrentQueue, ^{
        [self write:index threadMsg:threadMsg];
    });
}
- (void)barrierSYNC_read:(NSString *)threadMsg {
    dispatch_sync(self.concurrentQueue, ^{
        [self read:threadMsg];
    });
}

@end
