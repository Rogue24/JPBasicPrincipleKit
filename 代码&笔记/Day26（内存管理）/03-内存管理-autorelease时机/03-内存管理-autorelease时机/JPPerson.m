//
//  JPPerson.m
//  03-内存管理-autorelease时机
//
//  Created by 周健平 on 2019/12/21.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)dealloc {
    NSLog(@"%@ %s", self, __func__);
    [super dealloc];
}

@end
