//
//  ViewController.m
//  06-设计模式-分层设计
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPNewsService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 界面层告诉业务层执行什么业务，然后显示什么，业务具体怎么执行交给业务层处理
    [JPNewsService loadNews:@{} success:^(NSArray *newsData) {
        
    } failure:^(NSError *error) {
        
    }];
}


@end
