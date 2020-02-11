//
//  JPDog.h
//  02-Runtime-forwardInvocation
//
//  Created by 周健平 on 2019/11/18.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPDog : NSObject
- (int)test:(int)age;
+ (int)test:(int)age;
@end

NS_ASSUME_NONNULL_END
