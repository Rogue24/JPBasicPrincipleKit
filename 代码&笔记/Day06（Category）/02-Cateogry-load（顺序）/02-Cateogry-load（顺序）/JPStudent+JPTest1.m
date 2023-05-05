//
//  JPStudent+JPTest1.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPStudent+JPTest1.h"

#import <AppKit/AppKit.h>


@implementation JPStudent (JPTest1)

+ (void)load {
    NSLog(@"load --- JPStudent+JPTest1");
}

+ (void)test {
    [super help];
}

@end
