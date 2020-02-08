//
//  JPDog.m
//  01-内存管理-MRC
//
//  Created by 周健平 on 2019/12/15.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPDog.h"

@implementation JPDog

- (void)dealloc {
    NSLog(@"%s", __func__);
    [super dealloc];
}

- (void)run {
    NSLog(@"%s", __func__);
}

@end
