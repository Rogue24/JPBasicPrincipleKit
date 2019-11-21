//
//  JPPerson.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)setAge:(int)age {
    _age = age;
    NSLog(@"setAge");
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    NSLog(@"willChangeValueForKey --- %@", key);
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"begin didChangeValueForKey");
    [super didChangeValueForKey:key];
    NSLog(@"end didChangeValueForKey --- %@", key);
}

- (void)setHeight:(int)height {
    NSLog(@"setHeight");
}

- (int)height {
    return 111;
}

@end
