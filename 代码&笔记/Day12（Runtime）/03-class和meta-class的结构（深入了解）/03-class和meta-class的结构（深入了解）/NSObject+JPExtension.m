//
//  NSObject+JPExtension.m
//  03-class和meta-class的结构（深入了解）
//
//  Created by 周健平 on 2020/8/5.
//  Copyright © 2020 周健平. All rights reserved.
//

#import "NSObject+JPExtension.h"

@implementation NSObject (JPExtension)
- (void)test {
    NSLog(@"%@ %s", self, __func__);
}
@end
