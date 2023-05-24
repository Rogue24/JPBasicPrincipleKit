//
//  ViewController.m
//  02-多线程-GCD（面试题01）
//
//  Created by 周健平 on 2019/12/5.
//  Copyright © 2019 周健平. All rights reserved.
//
//  结论：在等待过程中线程一旦退出（或者在线程退出后再等待）就会报错：目标线程在等待执行时退出。

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSThread *thread;
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
     * 错误原因：`target thread exited while waiting for the perform` --> 目标线程在等待执行时退出
     * 因为`waitUntilDone:YES`，当前线程会被【卡住】，要等`interviewTest`执行完才会继续
     * 调用`[thread start]`，`thread`肯定会先执行block的代码，但执行完`thread`就立马退出了（完全废了），所以根本不会去执行`interviewTest`
     * 也就是【根本等不到】`interviewTest`的结束，当前线程就会被【一直卡住】，所以崩溃了（错误原因就是说在等待一个已经退出的线程）
     *
     * 解决方法1：`waitUntilDone:NO`，不等，不用管`interviewTest`有没执行完，别卡住当前线程
     * ==> `thread`已经退出了，这样就类似于对空对象发消息（`[nil interviewTest]`）
     *
     * 解决方法2：启动子线程`thread`的`RunLoop`，暂时保住`thread`的命去执行`interviewTest`
     * ==> 可以看出`-performSelector:onThread:withObject:waitUntilDone:`这个方法的本质就是唤醒线程的`RunLoop`去处理事情（添加`Source0`）
     */
}

- (void)interviewTest {
    NSLog(@"2 --- %@", [NSThread currentThread]);
}

#pragma mark - 测试perform后再start会不会一样崩
// 结果：即便`perform`后再`start`也一样，`start`就立马执行`block`的代码，执行完`thread`就立马退出了，因此崩溃。
// 结论：在等待过程中线程一旦退出（或者在线程退出后再等待）就会报错：目标线程在等待执行时退出。
- (IBAction)interview2:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"begin --- %@", [NSThread currentThread]);
        
        self.thread = [[NSThread alloc] initWithBlock:^{
            NSLog(@"1 --- %@", [NSThread currentThread]);
        }];
        
        [self performSelector:@selector(interviewTest) onThread:self.thread withObject:nil waitUntilDone:YES];
        
        NSLog(@"end --- %@", [NSThread currentThread]);
    });
}
- (IBAction)interview2start:(id)sender {
    NSLog(@"thread start --- %@", [NSThread currentThread]);
    // 即便`perform`后再`start`也一样，
    [self.thread start]; // `start`就立马执行`block`的代码，执行完`thread`就退出了，
    // 再用这个已经废掉的`thread`去执行`waitUntilDone`为YES的任务肯定就会崩啦。
}

#pragma mark - 证明

#pragma mark 解决方法1：`waitUntilDone:NO`，不等，不用管`interviewTest`有没执行完，别卡住当前线程
- (IBAction)prove1:(id)sender {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
    }];
    
    [thread start];
    
    // 来到这里时`thread`已经退出了，这样就类似于对空对象发消息（`[nil interviewTest]`）
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:NO];
    
    // 打印：1，没有崩溃。
}

#pragma mark 解决方法2：启动子线程`thread`的`RunLoop`，暂时保住`thread`的命去执行`interviewTest`
- (IBAction)prove2:(id)sender {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1 --- %@", [NSThread currentThread]);
        
        // 启动子线程的RunLoop来等待下一个任务
        // 添加Port来接收`-performSelector:onThread:withObject:waitUntilDone:`的消息（唤醒RunLoop去处理）
        [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // 由于没有重复启动RunLoop（while循环），所以执行完一次任务后RunLoop就会自动退出
        NSLog(@"退出RunLoop --- %@", [NSThread currentThread]);
    }];
    
    [thread start];
    
    [self performSelector:@selector(interviewTest) onThread:thread withObject:nil waitUntilDone:YES];
    
    // 打印：1、2，也没有崩溃。
}

#pragma mark 测试：在【当前线程】等待是否会有问题
/**
 * 结果：没问题
 *
 * 个人猜测：
 * 调用`-performSelector:onThread:withObject:waitUntilDone:`，如果`onThread`为`【当前线程】`并且`waitUntilDone`为`YES`，
 * 相当于是在`【当前线程】`使用了`【递归🔐】`来执行SEL的方法。
 *
 * 相当于（伪代码）：
 
       @synchronized ([NSThread currentThread]) {
           [self test2];
       }
 
 */
- (IBAction)test:(id)sender {
    NSLog(@"111 --- %@", [NSThread currentThread]);
    [self performSelector:@selector(test2) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    NSLog(@"333 --- %@", [NSThread currentThread]);
    
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"111 --- %@", [NSThread currentThread]);
        [self performSelector:@selector(test2) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
        NSLog(@"333 --- %@", [NSThread currentThread]);
    }];
    [thread start];
}

- (void)test2 {
    NSLog(@"222 --- %@", [NSThread currentThread]);
    sleep(3);
}

@end
