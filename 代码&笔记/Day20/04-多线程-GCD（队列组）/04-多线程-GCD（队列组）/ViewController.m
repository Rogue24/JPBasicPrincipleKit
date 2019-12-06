//
//  ViewController.m
//  04-多线程-GCD（队列组）
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
    
    NSLog(@"1 --- %@", [NSThread currentThread]);
    
    // dispatch_async：会晚一点点执行
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"2 --- %@", [NSThread currentThread]);
    });
    
    NSLog(@"3 --- %@", [NSThread currentThread]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue1, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"任务1 --- %@", [NSThread currentThread]);
        }
    });
    
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue2, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"任务2 --- %@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等group里面的【所有队列的所有任务】都执行完毕后，才会执行这里的代码
        NSLog(@"000 都OJBK了 --- %@", [NSThread currentThread]);
    });
    
    dispatch_group_notify(group, queue1, ^{
        // 等group里面的【所有队列的所有任务】都执行完毕后，才会执行这里的代码
        NSLog(@"111 都OJBK了 --- %@", [NSThread currentThread]);
    });
    
    dispatch_group_notify(group, queue2, ^{
        // 等group里面的【所有队列的所有任务】都执行完毕后，才会执行这里的代码
        NSLog(@"222 都OJBK了 --- %@", [NSThread currentThread]);
    });
}

@end
