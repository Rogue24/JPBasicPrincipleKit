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

// 使用自身地址值为Key（毕竟唯一）
#define JPKey [NSString stringWithFormat:@"%p", self]

NSMutableDictionary *weights_;
NSMutableDictionary *names_;

+ (void)load {
    NSLog(@"load --- JPPerson+JPTest1");
    weights_ = [NSMutableDictionary dictionary];
    names_ = [NSMutableDictionary dictionary];
}

- (void)setWeight:(int)weight {
    weights_[JPKey] = @(weight);
}

- (int)weight {
    return [weights_[JPKey] intValue];
}

- (void)setName:(NSString *)name {
    names_[JPKey] = name;
}

- (NSString *)name {
    return names_[JPKey];
}

@end
