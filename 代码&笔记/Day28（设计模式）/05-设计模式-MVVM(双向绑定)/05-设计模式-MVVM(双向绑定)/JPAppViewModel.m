//
//  JPAppViewModel.m
//  05-设计模式-MVVM02
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPAppViewModel.h"
#import "JPApp.h"
#import "JPAppView.h"

@interface JPAppViewModel () <JPAppViewDelegate>
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, strong) JPApp *app;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageName;
@end

@implementation JPAppViewModel

- (instancetype)initWithViewController:(UIViewController *)vc {
    if (self = [super init]) {
        self.vc = vc;
        
        // 创建View
        JPAppView *appView = [[JPAppView alloc] initWithFrame:CGRectMake(100, 120, 100, 130)];
        appView.delegate = self;
        appView.appVM = self;
        [vc.view addSubview:appView];
        
        // 加载模型数据
        JPApp *app = [[JPApp alloc] init];
        app.name = @"QQ";
        app.imageName = @"QQ";
        self.app = app;
        
        // 设置数据
        self.name = app.name;
        self.imageName = app.imageName;
    }
    return self;
}

- (void)refreshName {
    self.name = [NSString stringWithFormat:@"%@_%d", self.app.name, arc4random_uniform(99)];
}

#pragma mark - <JPAppViewDelegate>

- (void)appViewDidClick:(JPAppView *)appView {
    NSLog(@"点击了 --- %@", appView);
}

@end
