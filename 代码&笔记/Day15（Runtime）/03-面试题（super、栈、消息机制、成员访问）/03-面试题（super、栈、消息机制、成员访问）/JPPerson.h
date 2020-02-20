//
//  JPPerson.h
//  02-面试题（print）
//
//  Created by 周健平 on 2019/11/23.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPPerson : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *littlename;
@property (nonatomic, copy) NSString *othername;
- (void)print1;
- (void)print2;
- (void)print3;
- (void)print4;
@end

NS_ASSUME_NONNULL_END
