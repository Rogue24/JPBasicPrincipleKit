//
//  JPHTTPTool.h
//  06-设计模式-分层设计
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPHTTPTool : NSObject
+ (void)GET:(NSString *)URL params:(NSDictionary *)params success:(void(^)(NSArray *newsData))sucess failure:(void(^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
