//
//  ViewController.m
//  02-多线程-GCD（面试题01）
//
//  Created by 周健平 on 2019/12/5.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) NSThread *thread;
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
     * ==> 打印1，然后崩溃！
     */
    
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
    }];
    
    [thread start];
    
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:YES];
    
    /**
     * why？
     * [thread start] 执行完block的代码，thread就退出了（销毁）
     * 接着再往这个线程添加任务，又因为waitUntilDone:YES，当前线程会被卡住，要等任务执行完才会继续
     * 但是这时线程都没了，根本无法执行任务，根本等不到任务结束，当前线程就会被一直卡死，所以崩溃了
     *
     * 解决方法1：waitUntilDone:NO，别卡住当前线程，相当于对空对象发消息 --- [nil interviewTest]
     * 解决方法2：启动子线程的RunLoop
     * ==> 可以看出<<-performSelector:onThread:withObject:waitUntilDone:>>这个方法的本质就是唤醒线程的RunLoop去处理事情
     */
}

- (void)interviewTest {
    NSLog(@"2 --- %@", [NSThread currentThread]);
}

#pragma mark - 证明

- (IBAction)prove1:(id)sender {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
    }];
    
    [thread start];
    
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:NO];
    
    // 打印：1，没有崩溃。
}

- (IBAction)prove2:(id)sender {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
        
        // 启动子线程的RunLoop来等待下一个任务
        // 添加Port来接收<<-performSelector:onThread:withObject:waitUntilDone:>>的消息（然后唤醒RunLoop）
        [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        NSLog(@"退出RunLoop --- %@", [NSThread currentThread]);
    }];
    
    [thread start];
    
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:YES];
    
    // 打印：1、2，也没有崩溃。
}

@end
