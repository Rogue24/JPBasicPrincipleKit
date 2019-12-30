//
//  JPNewsService.h
//  06-设计模式-分层设计
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPNewsService : NSObject
+ (void)loadNews:(NSDictionary *)params success:(void(^)(NSArray *newsData))sucess failure:(void(^)(NSError *error))failure;
@end
