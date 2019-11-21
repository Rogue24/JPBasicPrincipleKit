//
//  JPPerson+JPTest1.h
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <AppKit/AppKit.h>


#import "JPPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPPerson (JPTest1)
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int weight;
@property (nonatomic, assign) int height;
@end

NS_ASSUME_NONNULL_END
