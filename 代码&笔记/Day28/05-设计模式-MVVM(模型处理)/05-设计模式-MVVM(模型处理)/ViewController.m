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
