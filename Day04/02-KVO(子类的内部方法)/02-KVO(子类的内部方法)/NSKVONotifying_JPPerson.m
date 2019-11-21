//
//  NSKVONotifying_JPPerson.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "NSKVONotifying_JPPerson.h"

@implementation NSKVONotifying_JPPerson

#pragma mark - KVO的子类方法（使用runtime可以窥探）

// 重写监听的属性的setter方法
- (void)setAge:(int)age {
    _NSSetIntValueAndNotify();
}

// 重写Class返回父类
- (Class)class {
    return [JPPerson class];
}

// 重写dealloc进行收尾工作
- (void)dealloc {
    
}

- (BOOL)_isKVOA {
    return YES;
}

#pragma mark - _NSSetIntValueAndNotify的伪代码（大概是酱紫）

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
