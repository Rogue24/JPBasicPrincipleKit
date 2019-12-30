//
//  JPAppPresenter.m
//  03-设计模式-MVP
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPAppPresenter.h"
#import "JPApp.h"
#import "JPAppView.h"

@interface JPAppPresenter () <JPAppViewDelegate>
@property (nonatomic, weak) UIViewController *vc;
@end

@implementation JPAppPresenter

- (instancetype)initWithViewController:(UIViewController *)vc {
    if (self = [super init]) {
        self.vc = vc;
        
        JPAppView *appView = [[JPAppView alloc] initWithFrame:CGRectMake(100, 100, 100, 130)];
        appView.delegate = self;
        [self.vc.view addSubview:appView];
        
        JPApp *app = [[JPApp alloc] init];
        app.name = @"QQ";
        app.imageName = @"QQ";
        
        [appView setName:app.name andImage:app.imageName];
    }
    return self;
}

#pragma mark - <JPAppViewDelegate>

- (void)appViewDidClick:(JPAppView *)appView {
    NSLog(@"点击了%@", appView);
}

@end
