//
//  JPPerson.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)setHeight:(int)height {
    _height = height;
    NSLog(@"setHeight");
}

- (void)setAge:(int)age {
    _age = age;
    NSLog(@"setAge");
}

- (void)setWeight:(int)weight {
    _weight = weight;
    NSLog(@"setWeight");
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    NSLog(@"willChangeValueForKey:%@", key);
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"didChangeValueForKey:%@ --- begin", key);
    [super didChangeValueForKey:key];
    NSLog(@"didChangeValueForKey:%@ --- end", key);
}

@end
