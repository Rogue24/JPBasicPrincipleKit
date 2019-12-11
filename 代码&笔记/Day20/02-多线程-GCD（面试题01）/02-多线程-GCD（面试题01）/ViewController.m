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
    // Do any additional setup after loading the view.
}

#pragma mark - 问题

- (IBAction)interview {
    /**
     * 以下打印结果是？
     * ==> 只打印1和3，没有打印2
     */
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
        [self performSelector:@selector(interviewTest) withObject:nil afterDelay:.0];
        NSLog(@"3 --- %@", [NSThread currentThread]);
    });
    
    /**
     * why？
     * 因为<< -performSelector:withObject:afterDelay: >>方法底层是通过NSTimer实现的
     * ==> 也就是说，本质就是往RunLoop中添加定时器，然而【子线程默认没有开启RunLoop】
     * ==> 没有RunLoop就不会处理定时器和其他中途新增的任务、触摸事件等，当前任务执行完线程就会销毁
     */
}

- (void)interviewTest {
    NSLog(@"2 --- %@", [NSThread currentThread]);
}

#pragma mark - 证明

- (IBAction)onMainThread {
    // 主线程本来就开启了RunLoop不需要手动启动
    NSLog(@"1 --- %@", [NSThread currentThread]);
    
    [self performSelector:@selector(interviewTest) withObject:nil afterDelay:.0];
    
    // 能延迟个4秒左右
    NSInteger xxx = 0;
    for (NSInteger i = 0; i < (999999999 * 2); i++) {
        xxx += 1;
    }
    
    NSLog(@"3 --- %@", [NSThread currentThread]);
    
    // 打印：1、3、2
    // 执行timer的任务，即使afterDelay为0也会有一丁点延时
    // 那是因为RunLoop要先处理完当前的任务，处理完会去休眠，接着再由timer唤醒线程去处理timer
}

- (IBAction)openSubThreadAndRunLoop {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"1 --- %@", [NSThread currentThread]);
        [self performSelector:@selector(interviewTest) withObject:nil afterDelay:.0];
        NSLog(@"3 --- %@", [NSThread currentThread]);
        
        // 启动子线程的RunLoop来等待下一个任务（处理timer）
        // 调用<<-performSelector:withObject:afterDelay:>>方法就是往RunLoop添加了定时器，所以这里不用自己添加Port
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // PS1：当前Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出
        // PS2：timer的任务处理完RunLoop就会退出，如果像之前那样通过while无限循环去启动就真的会一直循环着，线程并没有休眠
        // ==> 因为timer被销毁了，不像添加Port会被RunLoop一直持有着
        
        NSLog(@"退出RunLoop --- %@", [NSThread currentThread]);
        
        // 打印：1、3、2
        // 执行timer的任务，即使afterDelay为0也会有一丁点延时，毕竟RunLoop正在处理着当前的任务，处理完休眠再唤醒再处理timer
    });
}

- (IBAction)notAfterDelay:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"1 --- %@", [NSThread currentThread]);
        [self performSelector:@selector(interviewTest)];
        NSLog(@"3 --- %@", [NSThread currentThread]);
        
        // 打印：1、2、3
        // <<-performSelector:>>方法底层是通过【objc_msgSend】消息机制执行的方法
        // 相当于[self interviewTest]，直接在当前线程执行
    });
}

@end
