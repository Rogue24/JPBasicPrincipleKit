//
//  JPPerson+JPTest1.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson+JPTest1.h"

#import <AppKit/AppKit.h>


@implementation JPPerson (JPTest1)

+ (void)load {
    NSLog(@"load --- JPPerson+JPTest1");
}

+ (void)initialize {
    NSLog(@"initialize --- JPPerson+JPTest1");
}

- (void)xixi {
    NSLog(@"xixi --- JPPerson+JPTest1");
}

- (void)sleep {
    NSLog(@"I am sleepping --- JPPerson+JPTest1");
}

@end
