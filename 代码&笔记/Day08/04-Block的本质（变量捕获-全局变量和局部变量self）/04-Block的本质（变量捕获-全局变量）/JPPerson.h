//
//  JPPerson.h
//  04-Block的本质（变量捕获-全局变量）
//
//  Created by 周健平 on 2019/10/31.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPPerson : NSObject

@property (nonatomic, copy) NSString *name;

- (instancetype)initWithName:(NSString *)name;

- (void)test1;
- (void)test2;
- (void)test3;

@end

NS_ASSUME_NONNULL_END
