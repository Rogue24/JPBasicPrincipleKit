//
//  ViewController.m
//  02-RunLoop-线程保活的封装
//
//  Created by 周健平 on 2019/12/2.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPPermenantThread.h"

@interface ViewController ()
@property (nonatomic, strong) JPPermenantThread *perThread;
@end

@implementation ViewController

#pragma mark - 常量

#pragma mark - setter

#pragma mark - getter

#pragma mark - 创建方法

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.perThread = [[JPPermenantThread alloc] init];
    
    [self.perThread run];
    [self.perThread run];
    [self.perThread run];
    [self.perThread run];
    [self.perThread run];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

#pragma mark - 初始布局

#pragma mark - 通知方法

#pragma mark - 事件触发方法

- (IBAction)stopAction {
    [self.perThread stop];
}

#pragma mark - 重写父类方法

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.perThread executeTask:^{
        NSLog(@"执行任务 --- %@", [NSThread currentThread]);
    }];
}

#pragma mark - 系统方法

#pragma mark - 私有方法

#pragma mark - 公开方法

@end
