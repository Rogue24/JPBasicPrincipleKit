//
//  JPPerson.m
//  05-内存管理-autoreleasepool
//
//  Created by 周健平 on 2019/12/20.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)dealloc {
    NSLog(@"%@, %s", self, __func__);
    [super dealloc];
}

@end
