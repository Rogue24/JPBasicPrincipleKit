//
//  ViewController.m
//  02-设计模式-MVC(变种)
//
//  Created by 周健平 on 2019/12/29.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPApp.h"
#import "JPAppView.h"

@interface ViewController () <JPAppViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JPAppView *appView = [[JPAppView alloc] initWithFrame:CGRectMake(100, 100, 100, 130)];
    appView.delegate = self;
    [self.view addSubview:appView];
    
    JPApp *app = [[JPApp alloc] init];
    app.name = @"QQ";
    app.imageName = @"QQ";
    
    appView.app = app;
}

#pragma mark - <JPAppViewDelegate>

- (void)appViewDidClick:(JPAppView *)appView {
    NSLog(@"点击了%@", appView);
}

@end
