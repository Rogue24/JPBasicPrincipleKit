//
//  JPPerson+JPTest1.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//
//  使用字典的弊端：
//  1.有多少个属性就得用多少个全局字典来管理
//  2.因为是全局字典，所以内存会一直占用着，得手动管理，麻烦
//  3.线程安全问题

#import "JPPerson+JPTest1.h"

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
