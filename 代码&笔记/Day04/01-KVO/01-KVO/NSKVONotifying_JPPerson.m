//
//  NSKVONotifying_JPPerson.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "NSKVONotifying_JPPerson.h"

@implementation NSKVONotifying_JPPerson

// 重写父类被观察的属性的set方法
- (void)setAge:(int)age {
    _NSSetIntValueAndNotify();
}

#pragma mark - 伪代码（大概是酱紫）

void _NSSetIntValueAndNotify() {
    [self willChangeValueForKey:@"age"];
    [super setAge:age];
    [self didChangeValueForKey:@"age"];
}

- (void)willChangeValueForKey:(NSString *)key {
    
}

- (void)didChangeValueForKey:(NSString *)key {
    // 通知监听器，XX属性值发送了改变
    [observer observeValueForKeyPath:key ofObject:self change:nil context:nil];
}

@end
