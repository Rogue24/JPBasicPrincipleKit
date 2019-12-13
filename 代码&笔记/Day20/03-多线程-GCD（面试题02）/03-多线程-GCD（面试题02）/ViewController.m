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
     * ==> 打印1，然后崩溃！
     */
    
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
    }];
    
    [thread start];
    
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:YES];
    
    /**
     * why？
     * 因为waitUntilDone:YES，当前线程会被卡住，【要等interviewTest执行完才会继续】
     * [thread start]，thread肯定会先执行block的代码，但执行完thread就退出了（完全废了），所以根本不会去执行interviewTest
     * 也就是根本等不到interviewTest的结束，当前线程就会被一直卡住，所以崩溃了（错误原因写的就是目标线程已经退出）
     *
     * 解决方法1：waitUntilDone:NO，不等，别卡住当前线程
     * ==> 不用管interviewTest有没执行完，再加上thread已经退出，这样就类似于对空对象发消息 --- [nil interviewTest]
     * 解决方法2：启动子线程的RunLoop
     * ==> 可以看出<<-performSelector:onThread:withObject:waitUntilDone:>>这个方法的本质就是唤醒线程的RunLoop去处理事情
     */
}

- (void)interviewTest {
    NSLog(@"2 --- %@", [NSThread currentThread]);
}

#pragma mark - 证明

// 解决方法1：waitUntilDone:NO，不等，别卡住当前线程
// 不用管interviewTest有没执行完，再加上thread已经退出，这样就类似于对空对象发消息 --- [nil interviewTest]
- (IBAction)prove1:(id)sender {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
    }];
    
    [thread start];
    
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:NO];
    
    // 打印：1，没有崩溃。
}

// 解决方法2：启动子线程的RunLoop
- (IBAction)prove2:(id)sender {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
        
        // 启动子线程的RunLoop来等待下一个任务
        // 添加Port来接收<<-performSelector:onThread:withObject:waitUntilDone:>>的消息（然后唤醒RunLoop）
        [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // 由于没有重复启动RunLoop（while循环），所以执行完一次任务后RunLoop就会自动退出
        NSLog(@"退出RunLoop --- %@", [NSThread currentThread]);
    }];
    
    [thread start];
    
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:YES];
    
    // 打印：1、2，也没有崩溃。
}

@end
