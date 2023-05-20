//
//  ViewController.m
//  02-设计模式-MVC(变种)
//
//  Created by 周健平 on 2019/12/29.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPAppViewModel.h"

@interface ViewController ()
@property (nonatomic, strong) JPAppViewModel *appVM;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // MVVM02：将业务逻辑（请求获取数据并创建Model等）放到ViewModel里面，并且根据Model数据进行二次处理；View监听ViewModel的属性变化随之刷新。
    
    self.appVM = [[JPAppViewModel alloc] initWithViewController:self];
    
    UIButton *btn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"refreshName" forState:UIControlStateNormal];
        [btn addTarget:self.appVM action:@selector(refreshName) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(100, 300, 100, 60);
        btn;
    });
    [self.view addSubview:btn];
}

@end
