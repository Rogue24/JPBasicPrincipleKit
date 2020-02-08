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
 * NSTimer不准时：
 * 因为NSTimer依赖于RunLoop，RunLoop每跑一圈就会累积这一圈的时间，然后在循环的开头查看累积的时间是否达到NSTimer要触发的时间
 * 但是RunLoop每一圈所花费的时间是不固定的（RunLoop的任务过于繁重的话就会长一点），所以可能会导致NSTimer不准时
 * 例：timer设置为每隔1s触发任务，RunLoop第1圈0.2s，第2圈0.3s，第3圈0.3s，差0.2s，但第4圈却0.4s，加起来0.2+0.3+0.3+0.4=1.2 > 1.0
 */

/**
 * GCD定时器会更加准时：
 * 因为GCD定时器是直接跟系统内核挂钩的，而且不依赖RunLoop。
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad~");
    
//    [self timerTest];
    
    NSLog(@"开始计时");
    self.timerKey = [JPGCDTool execTask:self action:@selector(gcdTimerHandle) start:3 interval:2 repeats:YES async:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *timerKey = [JPGCDTool execTask:self action:@selector(gcdTimerHandle) start:3 interval:2 repeats:YES async:YES];
    
    [JPGCDTool cancelTask:self.timerKey];
    self.timerKey = timerKey;
}

- (void)gcdTimerHandle {
    NSLog(@"hello~ %@", [NSThread currentThread]);
}

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
