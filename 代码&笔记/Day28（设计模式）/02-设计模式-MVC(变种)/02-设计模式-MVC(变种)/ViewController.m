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
    
    // 优点：View的显示实现在内部实现，只需要给View传入Model，减轻Controller的负担
    // 缺点：View依赖Model，一对一，无法重复使用
    // 特定：将View的实现内部封装起来，屏蔽外界，仅暴露Model接口
    
    appView.app = app;
}

#pragma mark - <JPAppViewDelegate>

- (void)appViewDidClick:(JPAppView *)appView {
    NSLog(@"点击了 --- %@", appView);
}

@end
