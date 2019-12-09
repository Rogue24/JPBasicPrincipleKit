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

@interface ViewController ()
@property (nonatomic, strong) JPBaseDemo *baseDemo;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseDemo = [[JPNSConditionDemo alloc] init];
    
    return;
    
    NSObject *obj = [[NSObject alloc] init];
    NSLog(@"obj指向的地址：%p", obj);
    NSLog(@"obj地址：%p", &obj);
    
    [self setupObj:&obj];
    NSLog(@"obj指向的地址：%p", obj);
    NSLog(@"obj地址：%p", &obj);
    
//    [self setupObj2:obj];
//    NSLog(@"obj指向的地址：%p", obj);
//    NSLog(@"obj地址：%p", &obj);
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.baseDemo ticketTest];
//    [self.baseDemo moneyTest];
    [self.baseDemo otherTest];
}

@end
