//
//  ViewController.m
//  02-多线程-GCD（面试题01）
//
//  Created by 周健平 on 2019/12/5.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(log1) withObject:nil afterDelay:.0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"hi");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self log2];
        });
    });
    
    [self performSelector:@selector(log3) withObject:nil];
}

- (void)log1 {
    NSLog(@"1");
}

- (void)log2 {
    NSLog(@"2");
}

- (void)log3 {
    NSLog(@"3");
}

#pragma mark - 问题

- (IBAction)interview {
    /**
     * 以下打印结果是？
     * ==> 只打印1和3，没有打印2
     */
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"1 interview --- %@", [NSThread currentThread]);
        [self performSelector:@selector(interviewTest) withObject:nil afterDelay:.0];
        NSLog(@"3 interview --- %@", [NSThread currentThread]);
    });
    
    /*
     * why？
     * 因为 -performSelector:withObject:afterDelay: 方法底层是通过【NSTimer】实现的（参考GNUstep）
        ==> 也就是说，本质就是往当前RunLoop中添加定时器，然而【子线程默认没有开启RunLoop】
        ==> 没有RunLoop就不会处理定时器和其他中途新增的任务、触摸事件等，当前任务执行完线程就会销毁
     */
}

- (void)interviewTest {
    NSLog(@"2 interviewTest --- %@", [NSThread currentThread]);
}

#pragma mark - 证明

#pragma mark 主线程证明
- (IBAction)onMainThread {
    // 主线程本来就开启了RunLoop不需要手动启动
    NSLog(@"1 onMainThread --- %@", [NSThread currentThread]);
    
    [self performSelector:@selector(interviewTest) withObject:nil afterDelay:.0];
    
    // 能延迟个4秒左右
    NSInteger xxx = 0;
    for (NSInteger i = 0; i < (999999999 * 2); i++) {
        xxx += 1;
    }
    
    NSLog(@"3 onMainThread --- %@", [NSThread currentThread]);
    
    // 打印：1、3、2
    // 执行timer的任务，即使afterDelay为0也会有一丁点延时
    // 那是因为RunLoop要先处理完当前的任务，处理完（这一次循环）会去休眠，接着再由timer唤醒去处理timer（下一次循环）
}

#pragma mark 子线程证明
- (IBAction)openSubThreadAndRunLoop {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"1 openSubThreadAndRunLoop --- %@", [NSThread currentThread]);
        [self performSelector:@selector(interviewTest) withObject:nil afterDelay:.0];
        NSLog(@"3 openSubThreadAndRunLoop --- %@", [NSThread currentThread]);
        
        // 启动子线程的RunLoop来等待下一个任务（处理timer）
        // 调用<<-performSelector:withObject:afterDelay:>>方法就是往RunLoop添加了定时器，所以这里不用自己添加Port
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // 当处理完这个timer后：
        // PS1：RunLoop就会立马退出，因为当前Mode里没有其他任何Source0/Source1/Timer/Observer
        // PS2：如果像之前那样在这里用while循环去启动，就真的会一直循环着，线程并不会休眠
        // ==> 因为这个timer会自动销毁，不像添加Port会被RunLoop一直持有着
        // ==> 每次循环都会发现当前Mode里没有任何Source0/Source1/Timer/Observer，RunLoop退出接着启动这样一直循环下去
        
        NSLog(@"退出RunLoop openSubThreadAndRunLoop --- %@", [NSThread currentThread]);
        
        // 打印：1、3、2
        // 执行timer的任务，即使afterDelay为0也会有一丁点延时，
        // 毕竟RunLoop正在处理着当前的任务，处理完这些（这一次循环）去休眠，接着被timer唤醒再去处理timer（下一次循环）
    });
}

#pragma mark 不延时的做法
- (IBAction)notAfterDelay:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"1 notAfterDelay --- %@", [NSThread currentThread]);
        [self performSelector:@selector(interviewTest)];
        NSLog(@"3 notAfterDelay --- %@", [NSThread currentThread]);
        
        // 打印：1、2、3
        // <<-performSelector:>>方法底层是通过【objc_msgSend】消息机制执行的方法（在源码的NSObject.mm文件里面有实现）
        // 等价于 [self interviewTest] ，直接在当前线程执行的
    });
}

@end
