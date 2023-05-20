//
//  JPNewsService.m
//  06-设计模式-分层设计
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPNewsService.h"
#import "JPHTTPTool.h"
#import "JPDBTool.h"

@implementation JPNewsService

+ (void)loadNews:(NSDictionary *)params success:(void(^)(NSArray *newsData))sucess failure:(void(^)(NSError *error))failure {
    
    // 先取出本地数据
    NSArray *newsData = [JPDBTool loadLocalData];
    if (newsData) {
        sucess(newsData);
        return;
    }
    
    // 如果没有本地数据，就加载网络数据
    [JPHTTPTool GET:@"123" params:@{} success:^(NSArray * _Nonnull newsData) {
        sucess(newsData);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

@end
