//
//  JPPerson+JPTest2.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson+JPTest2.h"

#import <AppKit/AppKit.h>


@implementation JPPerson (JPTest2)

+ (void)load {
    NSLog(@"load --- JPPerson+JPTest2");
}

+ (void)initialize {
    NSLog(@"initialize --- JPPerson+JPTest2");
}

- (void)xixi {
    NSLog(@"xixi --- JPPerson+JPTest2");
}

@end
