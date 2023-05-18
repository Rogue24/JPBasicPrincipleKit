//
//  ViewController.m
//  02-内存管理-GCD定时器
//
//  Created by 周健平 on 2019/12/13.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPGCDTool.h"

@interface ViewController ()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, copy) NSString *timerKey;
@end

@implementation ViewController

/**
 * `NSTimer`不准时：
 * 因为`NSTimer`依赖于`RunLoop`，`RunLoop`每跑一圈就会累积这一圈的时间，然后在循环的开头查看累积的时间是否达到`NSTimer`要触发的时间。
 * 但是`RunLoop`每一圈所花费的时间是不固定的（`RunLoop`的任务过于繁重的话就会长一点），所以可能会导致`NSTimer`不准时。
 * 例：`timer`设置为每隔1s触发任务，`RunLoop`第1圈0.2s，第2圈0.3s，第3圈0.3s，差0.2s，但第4圈却用了0.4s，加起来`0.2 + 0.3 + 0.3 + 0.4 = 1.2 > 1.0`，超时！
 */

/**
 * `GCD定时器`会更加准时：
 * 因为`GCD定时器`是直接跟【系统内核】挂钩的，而且不依赖`RunLoop`。
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad~");
//    [self timerTest];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSString *timerKey = [JPGCDTool execTask:self action:@selector(gcdTimerHandle) start:3 interval:2 repeats:YES async:YES];
//
//    [JPGCDTool cancelTask:self.timerKey];
//    self.timerKey = timerKey;
//}

- (IBAction)begin:(id)sender {
    if (self.timerKey) {
        NSLog(@"继续");
        [JPGCDTool resumeTask:self.timerKey];
    } else {
        NSLog(@"开始计时");
        self.timerKey = [JPGCDTool execTask:self action:@selector(gcdTimerHandle) start:1 interval:2 repeats:YES async:YES];
    }
}

- (IBAction)suspend:(id)sender {
    NSLog(@"暂停");
    [JPGCDTool suspendTask:self.timerKey];
}

- (IBAction)cancel:(id)sender {
    NSLog(@"取消");
    [JPGCDTool cancelTask:self.timerKey];
    self.timerKey = nil;
}

- (void)gcdTimerHandle {
    NSLog(@"hello~ %@", [NSThread currentThread]);
}

#pragma mark - 创建GCD定时器
- (void)timerTest {
    
    // 设置回调在哪个队列执行
    // 使用【主队列】，就会将任务丢到【主线程】执行
//    dispatch_queue_t queue = dispatch_get_main_queue();
    // 使用【非主队列】，就会将任务丢到【子线程】执行
    dispatch_queue_t queue = [JPGCDTool createSerialQueue:"baby"];
    
    // 创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.timer = timer;
    
    // 设置时间
    // dispatch_source_set_timer(timer, 几秒后开始, 隔几秒执行一次, 误差几秒) --- 是的，连误差都可以设置
    NSTimeInterval start = 1;
    NSTimeInterval interval = 3;
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC),
                              interval * NSEC_PER_SEC,
                              0);
    
    // 设置回调
    // 1.使用block回调
//    dispatch_source_set_event_handler(timer, ^{
//        NSLog(@"hello~ %@", [NSThread currentThread]);
//    });
    // 2.使用(C)函数回调
    dispatch_source_set_event_handler_f(timer, timerHandle);
    
    // 启动定时器
    dispatch_resume(timer);
}

void timerHandle(void *param) {
    NSLog(@"hello~ %@", [NSThread currentThread]);
}

@end
