//
//  JPViewController.m
//  01-Runloop
//
//  Created by 周健平 on 2019/11/27.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPViewController.h"
#import "JPPerson.h"
#import "NSObject+JPExtension.h"

@interface JPViewController ()
@property (nonatomic, strong) JPPerson *per;
@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.greenColor;
    
    self.per = [[JPPerson alloc] init];
    self.per.jp_forwardingTargets = @{NSStringFromSelector(@selector(run)): self};
    
    [self.per performSelector:@selector(run)];
}

- (void)run {
    NSLog(@"%s", __func__);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
