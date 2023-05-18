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
    NSLog(@"------------------[write %zd begin]-------------------", index);
    NSLog(@"\n【writing: %zd】\n在这条线程调用：%@\n在这条线程执行：%@", index, threadMsg, [NSThread currentThread]);
    NSLog(@"-------------------[write %zd end]--------------------", index);
}

- (void)read:(NSInteger)index threadMsg:(NSString *)threadMsg {
    sleep(1);
    NSLog(@"------------------[read %zd begin]-------------------", index);
    NSLog(@"\n【reading: %zd】\n在这条线程调用：%@\n在这条线程执行：%@", index, threadMsg, [NSThread currentThread]);
    NSLog(@"-------------------[read %zd end]--------------------", index);
}

/*
 * 多读单写：经常用于文件等数据的读写操作
    1.同一时间，只能有1个线程进行写的操作
    2.同一时间，允许有多个线程进行读的操作
    3.同一时间，不允许既有写的操作，又有读的操作

 * 实现方案：
 * pthread_rwlock --- 读写🔐
    - 等待锁的线程会进入休眠
 * dispatch_barrier_async/dispatch_barrier_sync --- 栅栏+并发队列 ==> 用于写操作
    - 这个函数传入的【并发队列】【必须】是自己通过【dispatch_queue_cretate】创建的
    - 如果传入的是一个【串行队列】或【全局并发队列】，那么 dispatch_barrier_async/dispatch_barrier_sync 便等同于 dispatch_async/dispatch_sync 的效果，那就没意义了
    - 至于为什么不能使用【全局并发队列】，个人认为是系统不希望我们阻断全局并发队列的并发效率，毕竟这是一条为全局服务的队列，不可能只处理这里的任务，可不能中途插入一些超级耗时的操作卡住其他并发任务吧。
 
 * 从打印结果看到：
    - write：始终保持着【一个完整的begin和end闭合】的打印
    - read：都是【多个同时】穿插交替的打印
 * 可以看出这两种方案都可以做到：在同一时间内只会进行1次write操作，在同一时间内可以同时进行多个read操作，不会同时一起进行write和read操作。
 */

#pragma mark - pthread_rwlock【同步：在哪条线程调用，就在哪条线程操作】
- (IBAction)pthreadRWLock:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __pthread_write:i threadMsg:threadMsg];
        });
        NSInteger readIndex = i * 3;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __pthread_read:readIndex threadMsg:threadMsg];
        });
        readIndex += 1;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __pthread_read:readIndex threadMsg:threadMsg];
        });
        readIndex += 1;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __pthread_read:readIndex threadMsg:threadMsg];
        });
    }
}
- (void)__pthread_write:(NSInteger)index threadMsg:(NSString *)threadMsg {
    pthread_rwlock_wrlock(&_lock);
    [self write:index threadMsg:threadMsg];
    pthread_rwlock_unlock(&_lock);
}
- (void)__pthread_read:(NSInteger)index threadMsg:(NSString *)threadMsg {
    pthread_rwlock_rdlock(&_lock);
    [self read:index threadMsg:threadMsg];
    pthread_rwlock_unlock(&_lock);
}

#pragma mark - dispatch_barrier_async【异步：会开启新的线程去操作】
- (IBAction)barrierASYNC:(id)sender {
//    for (NSInteger i = 0; i < 10; i++) {
//        NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
//        [self __barrierASYNC_write:i threadMsg:threadMsg];
//        NSInteger readIndex = i * 3;
//        [self __barrierASYNC_read:readIndex threadMsg:threadMsg];
//        readIndex += 1;
//        [self __barrierASYNC_read:readIndex threadMsg:threadMsg];
//        readIndex += 1;
//        [self __barrierASYNC_read:readIndex threadMsg:threadMsg];
//    }
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __barrierASYNC_write:i threadMsg:threadMsg];
        });
        NSInteger readIndex = i * 3;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __barrierASYNC_read:readIndex threadMsg:threadMsg];
        });
        readIndex += 1;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __barrierASYNC_read:readIndex threadMsg:threadMsg];
        });
        readIndex += 1;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __barrierASYNC_read:readIndex threadMsg:threadMsg];
        });
    }
}
- (void)__barrierASYNC_write:(NSInteger)index threadMsg:(NSString *)threadMsg {
    dispatch_barrier_async(self.concurrentQueue, ^{
        [self write:index threadMsg:threadMsg];
    });
}
- (void)__barrierASYNC_read:(NSInteger)index threadMsg:(NSString *)threadMsg {
    dispatch_async(self.concurrentQueue, ^{
        [self read:index threadMsg:threadMsg];
    });
}

#pragma mark - dispatch_barrier_sync【同步：在哪条线程调用，就在哪条线程操作】
- (IBAction)barrierSYNC:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __barrierSYNC_write:i threadMsg:threadMsg];
        });
        NSInteger readIndex = i * 3;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __barrierSYNC_read:readIndex threadMsg:threadMsg];
        });
        readIndex += 1;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __barrierSYNC_read:readIndex threadMsg:threadMsg];
        });
        readIndex += 1;
        dispatch_async(queue, ^{
            NSString *threadMsg = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
            [self __barrierSYNC_read:readIndex threadMsg:threadMsg];
        });
    }
}
- (void)__barrierSYNC_write:(NSInteger)index threadMsg:(NSString *)threadMsg {
    dispatch_barrier_sync(self.concurrentQueue, ^{
        [self write:index threadMsg:threadMsg];
    });
}
- (void)__barrierSYNC_read:(NSInteger)index threadMsg:(NSString *)threadMsg {
    dispatch_sync(self.concurrentQueue, ^{
        [self read:index threadMsg:threadMsg];
    });
}

@end
