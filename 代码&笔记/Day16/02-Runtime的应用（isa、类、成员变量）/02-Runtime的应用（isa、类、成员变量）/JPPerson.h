//
//  JPPerson.h
//  02-Runtime的应用
//
//  Created by 周健平 on 2019/11/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPPerson : NSObject
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString *name;
- (void)run;
@end

NS_ASSUME_NONNULL_END
