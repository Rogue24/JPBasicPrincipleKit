//
//  JPAppViewModel.m
//  05-设计模式-MVVM02
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPAppViewModel.h"
#import "JPApp.h"

@implementation JPAppViewModel

- (void)loadApp {
    JPApp *app = [[JPApp alloc] init];
    app.name = @"QQ";
    app.imageName = @"QQ";
    
    self.name = [NSString stringWithFormat:@"my %@", app.name];
    self.imageName = app.imageName;
}

@end
