//
//  ViewController.m
//  06-多线程-线程同步
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPBaseDemo.h"
#import "JPOSSpinLockDemo.h"
#import "JPOSUnfairLockDemo.h"

@interface ViewController ()
@property (nonatomic, strong) JPBaseDemo *baseDemo;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseDemo = [[JPOSSpinLockDemo alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.baseDemo ticketTest];
    [self.baseDemo moneyTest];
}

@end
