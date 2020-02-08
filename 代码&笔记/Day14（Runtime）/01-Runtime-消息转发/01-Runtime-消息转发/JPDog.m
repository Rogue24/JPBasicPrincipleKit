//
//  JPDog.m
//  01-Runtime-消息转发
//
//  Created by 周健平 on 2019/11/17.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPDog.h"

@implementation JPDog

- (void)test {
    NSLog(@"test %@ %@", self, NSStringFromSelector(_cmd));
}

@end
