//
//  ViewController.m
//  03-class和meta-class的结构（深入了解）
//
//  Created by 周健平 on 2019/11/11.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPSon.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 这里证明一下performSelector也是走消息发送流程
    JPSon *son = [JPSon new];
    [son performSelector:@selector(test)];
    [son performSelector:@selector(test) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    [JPSon performSelector:@selector(test)];
}


@end
