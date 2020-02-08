//
//  JPPerson.m
//  02-Block-对象类型的auto变量
//
//  Created by 周健平 on 2019/11/2.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)dealloc {
    NSLog(@"俺死了 --- %p", self);
}

@end
