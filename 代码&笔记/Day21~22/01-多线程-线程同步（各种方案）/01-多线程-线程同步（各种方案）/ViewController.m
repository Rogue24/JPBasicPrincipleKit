//
//  ViewController.m
//  06-多线程-线程同步
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
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

@property (nonatomic, strong) dispatch_queue_t viewQueue;
@property (nonatomic, strong) dispatch_semaphore_t viewSemaphore;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.demo = [[JPOSSpinLockDemo alloc] init];
    
    self.viewQueue = dispatch_queue_create("viewww", DISPATCH_QUEUE_SERIAL);
    self.viewSemaphore = dispatch_semaphore_create(0);
    
    return;
    
    NSObject *obj = [[NSObject alloc] init];
    NSLog(@"obj指向的地址：%p", obj);
    NSLog(@"obj地址：%p", &obj);
    
//    [self setupObj:&obj];
//    NSLog(@"obj指向的地址：%p", obj);
//    NSLog(@"obj地址：%p", &obj);
    
    [self setupObj2:obj];
    NSLog(@"obj指向的地址：%p", obj);
    NSLog(@"obj地址：%p", &obj);
}

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

- (IBAction)ticketTest:(id)sender {
    [self.demo ticketTest];
}

- (IBAction)moneyTest:(id)sender {
    [self.demo moneyTest];
}

- (IBAction)otherTest:(id)sender {
    [self.demo otherTest];
}
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

@end
