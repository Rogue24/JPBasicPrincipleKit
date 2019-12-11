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
}

- (IBAction)asyncPoint:(id)sender {
    NSLog(@"1 --- %@", [NSThread currentThread]);
    
    // dispatch_async：会晚一点点执行
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"2 --- %@", [NSThread currentThread]);
    });
    
    NSLog(@"3 --- %@", [NSThread currentThread]);
}

- (IBAction)apply:(id)sender {
    // 快速迭代：要使用【并发队列】才能实现所有遍历同时进行（充分利用设备的多核）
    // PS：如果使用【串行队列】就跟普通for循环一样按顺序遍历了。
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSLog(@"快速迭代 begin");
    dispatch_apply(array.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
        NSLog(@"%zu: %@ %@", index, array[index], [NSThread currentThread]);
        sleep(3);
    });
    // 会阻塞当前线程（休眠），直到dispatch_apply里面的任务全部都完成（全部都遍历好了），线程才继续往下执行
    NSLog(@"快速迭代 end");
}

- (IBAction)group:(id)sender {
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    // dispatch_group_async：添加任务到group中
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
        dispatch_queue_t queue3 = dispatch_queue_create("queue3", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_async(group, queue3, ^{
            for (NSInteger i = 0; i < 10; i++) {
                NSLog(@"任务3 --- %@", [NSThread currentThread]);
            }
        });
    });
    
    // dispatch_group_enter：标记一个任务追加到group，执行一次，相当于group中的任务数加1
    // dispatch_group_leave：标志一个任务离开了group，执行一次，相当于group中的任务数减1
    // 两者要配对使用，这样不使用dispatch_group_async的情况也可以加入group
    dispatch_queue_t queue4 = dispatch_queue_create("queue4", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_enter(group); // 加入group
    dispatch_async(queue4, ^{
        NSLog(@"任务4 begin --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"任务4 leave");
        dispatch_group_leave(group); // 提前离开group，触发dispatch_group_notify和dispatch_group_wait
        sleep(3);
        NSLog(@"任务4 end --- %@", [NSThread currentThread]);
    });
    
    // dispatch_group_notify：当group里面的任务全部都完成就会执行block里面的代码
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
    
    // dispatch_group_wait：阻塞当前线程（休眠），直到group里面的任务全部都完成，线程才继续往下执行
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"333 都OJBK了 --- %@", [NSThread currentThread]);
}

@end
