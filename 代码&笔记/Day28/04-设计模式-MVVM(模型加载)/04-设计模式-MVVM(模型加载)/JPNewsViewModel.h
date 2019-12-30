//
//  JPNewsViewModel.h
//  04-设计模式-MVVM
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPNews.h"

@interface JPNewsViewModel : NSObject

- (void)loadNewData:(void(^)(NSArray *newsData))completion;

@end
