//
//  JPNewsViewModel.m
//  04-设计模式-MVVM
//
//  Created by 周健平 on 2019/12/30.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPNewsViewModel.h"

@implementation JPNewsViewModel

- (void)loadNewData:(void (^)(NSArray *newsData))completion {
    if (!completion) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *newsData = [NSMutableArray array];
        for (NSInteger i = 0; i < 20; i++) {
            JPNews *news = [[JPNews alloc] init];
            news.title = [NSString stringWithFormat:@"news-title-%zd", i];
            news.content = [NSString stringWithFormat:@"news-content-%zd", i];
            [newsData addObject:news];
        }
        NSLog(@"假装在请求数据...");
        sleep(3);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"请求成功！");
            completion(newsData);
        });
    });
}

@end
