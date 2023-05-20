//
//  JPAppViewModel.h
//  05-设计模式-MVVM02
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPAppViewModel : NSObject
- (instancetype)initWithViewController:(UIViewController *)vc;
- (void)refreshName;
@end
