//
//  ViewController.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2020/4/19.
//  Copyright © 2020 周健平. All rights reserved.
//

#import "ViewController.h"

#import "JPOSSpinLockDemo.h"
#import "JPOSUnfairLockDemo.h"
#import "JPMutexDefaultDemo.h"
#import "JPMutexRecursiveDemo.h"
#import "JPMutexCondDemo.h"
#import "JPNSLockDemo.h"
#import "JPNSConditionDemo.h"
#import "JPNSConditionLockDemo.h"
#import "JPGCDSerialQueueDemo.h"
#import "JPGCDSemaphoreDemo.h"
#import "JPSynchronizedDemo.h"

#define JPSemaphoreWait \
static dispatch_semaphore_t jp_semaphore; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
    jp_semaphore = dispatch_semaphore_create(1); \
}); \
dispatch_semaphore_wait(jp_semaphore, DISPATCH_TIME_FOREVER);

#define JPSemaphoreSignal dispatch_semaphore_signal(jp_semaphore);

@interface ViewController ()
@property (nonatomic, strong) JPBaseDemo *demo;
@property (weak, nonatomic) IBOutlet UILabel *lockNameLabel;

@property (nonatomic, strong) dispatch_queue_t viewQueue;
@property (nonatomic, strong) dispatch_semaphore_t viewSemaphore;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;

@property (nonatomic, assign) NSInteger testTotal;
@property (nonatomic, assign) NSInteger testCount;
@property (nonatomic, strong) dispatch_semaphore_t testSemaphore;
@end

@implementation ViewController

- (void)setupObj:(NSObject **)obj {
    NSLog(@"赋值前-----");
    NSLog(@"传入的obj地址：%p", obj);
    *obj = nil;
    NSLog(@"赋值后-----");
}

- (void)setupObj2:(NSObject *)obj {
    NSLog(@"赋值前-----");
    NSLog(@"传入的obj地址：%p", &obj);
    obj = nil;
    NSLog(@"赋值后-----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.demo = [[JPMutexRecursiveDemo alloc] init];
    NSString *className = NSStringFromClass(self.demo.class);
    self.lockNameLabel.text = [className substringWithRange:NSMakeRange(2, className.length - 6)];
    [self.lockNameLabel sizeToFit];
    
    
    self.viewQueue = dispatch_queue_create("viewww", DISPATCH_QUEUE_SERIAL);
    self.viewSemaphore = dispatch_semaphore_create(0);
    
    self.testSemaphore = dispatch_semaphore_create(0);
    
    
//    NSObject *obj = [[NSObject alloc] init];
//    NSLog(@"obj指向的地址：%p", obj);
//    NSLog(@"obj地址：%p", &obj);
//
////    [self setupObj:&obj];
////    NSLog(@"obj指向的地址：%p", obj);
////    NSLog(@"obj地址：%p", &obj);
//
//    [self setupObj2:obj];
//    NSLog(@"obj指向的地址：%p", obj);
//    NSLog(@"obj地址：%p", &obj);
}

#pragma mark - 各种线程同步方案

#pragma mark 卖票演示
- (IBAction)ticketTest:(id)sender {
    [self.demo ticketTest];
}

#pragma mark 存/取钱演示
- (IBAction)moneyTest:(id)sender {
    [self.demo moneyTest];
}

#pragma mark 给子类继承的用于其他操作的演示
- (IBAction)otherTest:(id)sender {
    [self.demo otherTest];
}

#pragma mark - 信号量测试

#pragma mark 1.使用信号量让子线程先等待其他线程（如主线程）执行完一些任务后再继续
- (IBAction)testtest {
    
    self.view1.alpha = 0;
    self.view2.alpha = 0;
    self.view3.alpha = 0;
    
    __block UIView *view;
    for (NSInteger i = 0; i < 3; i++) {
        dispatch_async(self.viewQueue, ^{
            NSLog(@"----------------第%zd次开始----------------", i + 1);
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1 animations:^{
                    view.alpha = 0;
                } completion:^(BOOL finished) {
                    switch (i) {
                        case 0:
                            view = self.view1;
                            break;
                        case 1:
                            view = self.view2;
                            break;
                        case 2:
                            view = self.view3;
                            break;
                        default:
                            break;
                    }
                    [UIView animateWithDuration:1 animations:^{
                        view.alpha = 1;
                    } completion:^(BOOL finished) {
                        NSLog(@"拿到view(%p)了 --- %@", view, [NSThread currentThread]);
                        dispatch_semaphore_signal(self.viewSemaphore);
                    }];
                }];
            });
            
            NSLog(@"暂停等主线程拿到view再继续 --- %@", [NSThread currentThread]);
            dispatch_semaphore_wait(self.viewSemaphore, DISPATCH_TIME_FOREVER);
            
            NSLog(@"拿这个view(%p)的属性去做一些耗时的事 --- %@", view, [NSThread currentThread]);
            sleep(3);
            NSLog(@"----------------第%zd次结束----------------", i + 1);
        });
    }
    
    dispatch_async(self.viewQueue, ^{
        NSLog(@"over~");
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1 animations:^{
                self.view1.alpha = 1;
                self.view2.alpha = 1;
                self.view3.alpha = 1;
            }];
        });
    });
}

#pragma mark 2.1 开启10个信号量加锁的子线程任务
- (IBAction)xinnhaotest21:(id)sender {
    self.testTotal += 10;
    
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSLog(@"%zd --- 信号量剩几个？%zd", i, self.testCount);
            
            // 信号量小于1时，就休眠该线程等待信号量大于0为止
            dispatch_semaphore_wait(self.testSemaphore, DISPATCH_TIME_FOREVER);
            // 信号量大于0时才会继续往下走，然后信号量会减1
            
            self.testTotal -= 1;
            self.testCount -= 1;
            NSLog(@"%zd --- 来信号了，-1后信号量剩%zd个，总共剩%zd个任务", i, self.testCount, self.testTotal);
        });
    }
}
#pragma mark 2.2 手动添加信号量数量
- (IBAction)xinnhaotest22:(id)sender {
    // 信号量加1，激活休眠的线程
    self.testCount += 1;
    NSLog(@"信号量%zd个", self.testCount);
    dispatch_semaphore_signal(self.testSemaphore);
}

@end
