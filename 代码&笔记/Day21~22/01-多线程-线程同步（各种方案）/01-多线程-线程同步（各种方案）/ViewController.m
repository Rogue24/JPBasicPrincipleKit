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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.demo = [[JPOSSpinLockDemo alloc] init];
    
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

@end
