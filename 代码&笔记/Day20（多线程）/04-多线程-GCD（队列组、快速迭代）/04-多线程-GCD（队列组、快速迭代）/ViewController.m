//
//  ViewController.m
//  04-多线程-GCD（队列组）
//
//  Created by 周健平 on 2019/12/5.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) dispatch_group_t jp_group;
@property (nonatomic, assign) BOOL isCanEnter;
@property (nonatomic, assign) int index;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.jp_group = dispatch_group_create();
}

#pragma mark - 异步执行的注意点
- (IBAction)asyncPoint:(id)sender {
    NSLog(@"1 --- %@", [NSThread currentThread]);
    
    // dispatch_async：会晚一点点执行
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"2 --- %@", [NSThread currentThread]);
    });
    
    NSLog(@"3 --- %@", [NSThread currentThread]);
}

#pragma mark - 快速迭代
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

#pragma mark - 队列组
- (IBAction)group:(id)sender {
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    //【1】dispatch_group_async：添加任务到group中
    // 在{}开始时就相当于进组，在结束时就相当于出组，不能中途出组。
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue1, ^{
        // { 开头处相当于执行了 dispatch_group_enter(group);
        
        for (NSInteger i = 0; i < 5; i++) {
            
            // !!!不能在dispatch_group_async的{}中途手动出组，会崩!!!
            // 除非在这之前有对应执行过 dispatch_group_enter(group)
//            if (i == 2) {
//                dispatch_group_leave(group);
//                return;
//            }
            
            NSLog(@"任务1 --- %@", [NSThread currentThread]);
        }
        
        // } 结尾处相当于执行了 dispatch_group_leave(group);
    });
    
    // 尽管dispatch_group_async里面还有另一个gcd任务{}还没执行完，那也是另一个{}的事情，只要是自己的{}结束了就代表当前任务出组。
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue2, ^{
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"任务2 --- %@", [NSThread currentThread]);
        }
        
        dispatch_queue_t queue3 = dispatch_queue_create("queue3", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_async(group, queue3, ^{
            for (NSInteger i = 0; i < 5; i++) {
                NSLog(@"任务3 --- %@", [NSThread currentThread]);
            }
        });
    });
    
    //【2】dispatch_group_enter + dispatch_group_leave（不使用dispatch_group_async的情况也可以加入group）
    // dispatch_group_enter：标记一个任务追加到group，执行一次，相当于group中的任务数加1
    // dispatch_group_leave：标志一个任务离开了group，执行一次，相当于group中的任务数减1
    // - 两者要配对使用，有enter必有leave，得先enter后leave
    // - 这种方式可以自己控制在【不同方法、不同的线程】中随时进出组。
    dispatch_queue_t queue4 = dispatch_queue_create("queue4", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_enter(group); // 主线程加入group
    dispatch_async(queue4, ^{
        NSLog(@"任务4 begin --- %@", [NSThread currentThread]);
        sleep(3);
        NSLog(@"任务4 leave --- %@", [NSThread currentThread]);
        dispatch_group_leave(group); // 子线程离开group（可以中途离开group，去触发dispatch_group_notify和dispatch_group_wait）
        sleep(5);
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
    
    // dispatch_group_wait：阻塞当前线程（休眠），直到group里面的任务全部都完成，阻塞的线程才会继续往下执行
    NSLog(@"333 等组里任务执行完ing --- %@", [NSThread currentThread]);
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"333 组里任务都OJBK了 --- %@", [NSThread currentThread]);
}

#pragma mark - 先设置好notify而任务之后再添加的情况下，使用dispatch_group_enter防止notify在任务开始前就执行了
// 在一个{}里面先写了notify但任务是在另一个{}写的（且可能晚一点进组）这种情况下，先enter进组”卡住“notify，之后另一个{}的任务里面再leave就行了，不然当notify的{}结束时会发现group里面没任务了就会执行里面代码
- (IBAction)group_enter:(id)sender {
    // 要先enter，确保先有个任务
    NSLog(@"group_enter");
    dispatch_group_enter(self.jp_group);
    
    // 这时候添加notify，因为已经有任务了，就不会立即执行notify
    dispatch_group_notify(self.jp_group, dispatch_get_main_queue(), ^{
        NSLog(@"全部任务都完成了哦，执行notify");
        self.index = 0;
    });
    
    // 如果在这里才enter，那上面的notify在创建好的同时，会发现group当前没任务了，就立马执行里面的代码了
//    dispatch_group_enter(self.jp_group);
}

- (IBAction)group_leave:(id)sender {
    NSLog(@"group_leave");
    // 有几次enter代表能leave几次，超出就崩溃
    dispatch_group_leave(self.jp_group);
}

- (IBAction)group_async:(id)sender {
    self.index += 1;
    int index = self.index;
    dispatch_group_async(self.jp_group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"任务%d开始", index);
        int delay = 1 + arc4random() % 5;
        sleep(delay);
        NSLog(@"任务%d结束", index);
    });
}

@end
