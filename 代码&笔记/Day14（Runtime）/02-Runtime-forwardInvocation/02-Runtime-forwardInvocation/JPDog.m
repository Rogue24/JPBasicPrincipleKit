//
//  JPDog.m
//  02-Runtime-forwardInvocation
//
//  Created by 周健平 on 2019/11/18.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPDog.h"

@implementation JPDog
- (int)test:(int)age {
    NSLog(@"%@ -test:%d", self, age);
    return age * 2;
}
+ (int)test:(int)age {
    NSLog(@"%@ +test:%d", self, age);
    return age * 4;
}
@end
