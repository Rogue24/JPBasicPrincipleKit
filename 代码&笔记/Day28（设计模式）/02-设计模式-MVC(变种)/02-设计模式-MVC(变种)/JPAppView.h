//
//  JPAppView.h
//  02-设计模式-MVC(变种)
//
//  Created by 周健平 on 2019/12/29.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPApp, JPAppView;

@protocol JPAppViewDelegate <NSObject> // 同时也遵守<NSObject>协议，这样才能调用respondsToSelector方法
@optional
- (void)appViewDidClick:(JPAppView *)appView;
@end

@interface JPAppView : UIView
@property (nonatomic, strong) JPApp *app;
@property (nonatomic, weak) id<JPAppViewDelegate> delegate;
@end

