//
//  NSObject+Test.m
//  01-isa和superclass
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "NSObject+Test.h"

#import <AppKit/AppKit.h>


@implementation NSObject (Test)

//+ (void)test {
//    NSLog(@"+[NSObject test] ---- %p", self);
//}

- (void)test {
    NSLog(@"-[NSObject test] ---- %p", self);
}

@end
