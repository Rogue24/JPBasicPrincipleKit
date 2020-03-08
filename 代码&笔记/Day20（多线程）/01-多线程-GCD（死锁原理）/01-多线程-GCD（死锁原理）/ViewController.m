//
//  ViewController.m
//  01-多线程-GCD
//
//  Created by 周健平 on 2019/12/3.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

/*
 *【同步】和【异步】主要影响：能不能开启新的线程（任务在哪执行）
 * dispatch_sync：在【当前】线程中执行任务，【不具备】开启新线程的能力
 * dispatch_async：在【新的】线程中执行任务，【具备】开启新线程的能力
    - 不一定会开启，例如在【主队列】中只用主线程，又或者当前线程没被销毁且空闲着就继续用着不去开启新的线程了
    - 由于新开线程或找空闲线程（线程调度）都需要一个过程，是要花一点时间的，所以【dispatch_async + 并发】的任务一般都会慢一丢丢才开始执行
 
 * 队列：是用来存放任务，GCD会自动将队列中的任务取出，放到对应的线程中执行，
 * <<任务的取出遵循队列的FIFO（First In First Out）原则：先进先出，后进后出>>
 *【并发】和【串行】主要影响：任务的执行方式（任务怎么执行）
    - DISPATCH_QUEUE_CONCURRENT（并发）：多个任务并发（同时）开始执行，不用等上一个任务执行完才开始
    - DISPATCH_QUEUE_SERIAL（串行）：一个任务执行完毕后，再执行下一个任务
    - 主队列：是一个特殊的串行队列，主队列的任务只会在【主线程】中执行（异步执行也不会开启新线程）
 
 * 在queue中执行任务1，任务1中往queue添加任务2：
 *【串行和并发队列、同步和异步执行的区别】
    dispatch_async(queue, ^{
        // 执行任务1
                 
        // 同步dispatch_sync：任务放入队列中会【立马取出来】放在【当前线程】中同步执行
        // ***不会开启新的线程，也就是说会卡住当前线程去执行***
        // 串行队列：任务2要等任务1执行完才能执行，而任务1因为dispatch_sync也要等任务2执行完才能继续，因此会造成死锁
        // 并发队列：不用等任务1执行完，立马取出任务2去执行，两个任务在同一线程内，任务2执行完再继续任务1后面的代码
        dispatch_sync(queue, ^{
            // 执行任务2
        });
        
        // 异步dispatch_async：任务放入队列中【不会立马取出来】执行，<<由队列类型决定什么时候取>>
        // ***会开启新的线程去执行，除非在主队列、或者有刚执行完任务没退出的子线程，就不会开启新的线程***
        // 串行队列：任务2要等任务1执行完才会从队列中取出来去执行，任务1不用等任务2，不会造成死锁
        // 并发队列：不用等任务1执行完，立马取出任务2去执行，两个任务在各自不同的线程内，互不影响，任务1会继续后面的代码
        dispatch_async(queue, ^{
            // 执行任务2
        });
    });
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self deadlock1];
    
//    [self deadlock2];
    
//    [self deadlock3];
    
//    [self deadlock4];
    
//    [self asyncMainQueue];
    
//    [self syncOtherSerialQueue];
    
//    [self serialAndOtherSerialQueue];
    
    [self asyncSerialQueue];
    
//    [self concurrentQueue];
    
//    for (NSInteger i = 0; i < 10; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"doing --- %@", [NSThread currentThread]);
//        });
//    }
    
    NSLog(@"hi");
    
//    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//
//        NSLog(@"doing1 --- %@", [NSThread currentThread]);
//
//        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"doing2 --- %@", [NSThread currentThread]);
//        });
//    });
}

#pragma mark - 死锁的各种情况（这里都在主队列的viewDidLoad任务内执行）
/**
 * 造成死锁的原因：
 *【1】dispatch_sync（同步执行）：立马在当前线程同步执行任务，执行完毕才能继续往下执行
 *【2】serial dispatch queue（串行队列）：必须等上一个任务执行完毕后才去执行下一个任务
 *【1+2】==> 串行队同步列添加任务1，会在当前线程内去执行任务1，途中同步添加任务2， 这时由于【同步执行】的性质，任务1必须要等任务2执行完才能继续，而任务2由于【串行队列】的性质，也必须等任务1执行完才会执行，由此造成死锁。
 */
#pragma mark 在主队列的线程(主线程) + 往主队列 + 同步执行
- (void)deadlock1 {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    // deadlock1{}还没执行完，死锁！
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"doing --- %@", [NSThread currentThread]);
    });
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

#pragma mark 在主队列的线程(主线程) + 往串行队列 + 同步执行 + 往主队列 + 同步执行
- (void)deadlock2 {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    dispatch_queue_t serialQueue = dispatch_queue_create("hi", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        NSLog(@"doing1 --- %@", [NSThread currentThread]);
        
        // 回去主队列执行任务，但是！deadlock2{}还没执行完，死锁！
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"doing2 --- %@", [NSThread currentThread]);
        });
    });
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

#pragma mark 往串行队列 + 同步执行 + 往串行队列(同一个) + 同步执行
- (void)deadlock3 {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    dispatch_queue_t serialQueue = dispatch_queue_create("hi", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        NSLog(@"doing1 --- %@", [NSThread currentThread]);
        
        // doing1{}还没执行完，死锁！
        dispatch_sync(serialQueue, ^{
            NSLog(@"doing2 --- %@", [NSThread currentThread]);
        });
    });
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

#pragma mark 往串行队列 + 异步执行 + 往串行队列(同一个) + 同步执行
- (void)deadlock4 {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    dispatch_queue_t serialQueue = dispatch_queue_create("hi", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serialQueue, ^{
        NSLog(@"doing1 --- %@", [NSThread currentThread]);
        
        // doing1{}还没执行完，死锁！
        dispatch_sync(serialQueue, ^{
            NSLog(@"doing2 --- %@", [NSThread currentThread]);
        });
    });
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

#pragma mark - 反死锁（这里都在主队列的viewDidLoad任务内执行）

#pragma mark dispatch_async（异步执行）：不要求立马在当前线程同步执行任务
- (void)asyncMainQueue {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    // doing{}排在asyncMainQueue{}后面执行，主队列异步执行->主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"doing --- %@", [NSThread currentThread]);
    });
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

#pragma mark 自定义的串行队列同步执行任务，跟主队列不冲突
- (void)syncOtherSerialQueue {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    dispatch_queue_t serialQueue = dispatch_queue_create("123", DISPATCH_QUEUE_SERIAL);
    
    // doing1{}先加入队列，先执行doing1{}，异步执行->新线程
    dispatch_async(serialQueue, ^{
        NSLog(@"doing1 --- %@", [NSThread currentThread]);
        // 能延迟个4秒左右
        NSInteger xxx = 0;
        for (NSInteger i = 0; i < (999999999 * 2); i++) {
            xxx += 1;
        }
    });
    
    // doing2{}排在doing1{}后面执行，同步执行->主线程
    // 会卡住当前线程，等这个串行队列上一个任务执行完
    // 当前线程是主线程，所在队列是主队列，而这是另一台串行队列，不冲突哦
    dispatch_sync(serialQueue, ^{
        NSLog(@"doing2 --- %@", [NSThread currentThread]);
    });
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

#pragma mark 两条不同的串行队列，不冲突
- (void)serialAndOtherSerialQueue {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    dispatch_queue_t serialQueue = dispatch_queue_create("hi", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t serialQueue2 = dispatch_queue_create("hi2", DISPATCH_QUEUE_SERIAL);
    
    // doing1{}同步执行->主线程
    dispatch_sync(serialQueue, ^{
        NSLog(@"doing1 --- %@", [NSThread currentThread]);
        
        // doing2{}跟doing1{}同一线程，doing2{}结束再继续doing1{}，同步执行->主线程
        dispatch_sync(serialQueue2, ^{
            NSLog(@"doing2 --- %@", [NSThread currentThread]);
        });
    });
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

#pragma mark 另开线程，不冲突
- (void)asyncSerialQueue {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    dispatch_queue_t serialQueue = dispatch_queue_create("hi", DISPATCH_QUEUE_SERIAL);
    
    // doing1{}先加入队列，异步执行->新线程
    dispatch_async(serialQueue, ^{
        
        // doing2{}后加入队列，跟在doing1{}后面再执行，异步执行->新线程
        dispatch_async(serialQueue, ^{
            NSLog(@"doing2 --- %@", [NSThread currentThread]);
        });
        
        NSInteger c = 0;
        for (NSInteger i = 0; i < 999999999; i++) {
            c += 1;
        }
        
        NSLog(@"doing1 --- %@", [NSThread currentThread]);
        
        // doing3{}跟在doing2{}后面再执行，异步执行->新线程
        dispatch_async(serialQueue, ^{
            NSLog(@"doing3 --- %@", [NSThread currentThread]);
        });
    });
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

#pragma mark 并发队列，不用等上一个任务执行完才执行，立马执行
- (void)concurrentQueue {
    NSLog(@"to do some thing --- %@", [NSThread currentThread]);
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("hi", DISPATCH_QUEUE_CONCURRENT);
    
    // doing1{}异步执行->新线程
    dispatch_async(concurrentQueue, ^{
        NSLog(@"doing1 --- %@", [NSThread currentThread]);
        
        // doing2{}异步执行->新线程
        dispatch_async(concurrentQueue, ^{
            NSLog(@"doing2 --- %@", [NSThread currentThread]);
        });
        
        // doing3{}跟doing1{}同一线程，doing3{}执行完继续doing1{}，同步执行->doing1{}线程
        dispatch_sync(concurrentQueue, ^{
            NSLog(@"doing3 --- %@", [NSThread currentThread]);
        });
        
        NSInteger c = 0;
        for (NSInteger i = 0; i < 999999999; i++) {
            c += 1;
        }
        
        // doing4{}异步执行->新线程
        dispatch_async(concurrentQueue, ^{
            NSLog(@"doing4 --- %@", [NSThread currentThread]);
        });
        
        // doing5{}跟doing1{}同一线程，doing3{}执行完再执行doing5{}再继续doing1{}，同步执行->doing1{}线程
        dispatch_sync(concurrentQueue, ^{
            NSLog(@"doing5 --- %@", [NSThread currentThread]);
        });
    });
    
//    NSInteger c = 0;
//    for (NSInteger i = 0; i < 999999999; i++) {
//        c += 1;
//    }
    
    NSLog(@"done! --- %@", [NSThread currentThread]);
}

@end
