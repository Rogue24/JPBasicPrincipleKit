//
//  JPPerson+JPExtension.h
//  02-Category
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPPerson (JPExtension)

- (void)fuck;

- (void)sleep;

@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
