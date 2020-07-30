//
//  ViewController.m
//  02-设计模式-MVC(变种)
//
//  Created by 周健平 on 2019/12/29.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPAppView.h"
#import "JPAppViewModel.h"

@interface ViewController () <JPAppViewDelegate>
@property (nonatomic, strong) JPAppViewModel *appVM;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // MVVM02：将业务逻辑（请求获取数据并创建Model等）放到ViewModel里面，并且根据Model数据进行二次处理
    
    self.appVM = [[JPAppViewModel alloc] init];
    [self.appVM loadApp];
    
    JPAppView *appView = [[JPAppView alloc] initWithFrame:CGRectMake(100, 100, 100, 130)];
    appView.delegate = self;
    [self.view addSubview:appView];
    
    appView.iconView.image = [UIImage imageNamed:self.appVM.imageName];
    appView.nameLabel.text = self.appVM.name;
}

#pragma mark - <JPAppViewDelegate>

- (void)appViewDidClick:(JPAppView *)appView {
    NSLog(@"点击了%@", appView);
}

@end
