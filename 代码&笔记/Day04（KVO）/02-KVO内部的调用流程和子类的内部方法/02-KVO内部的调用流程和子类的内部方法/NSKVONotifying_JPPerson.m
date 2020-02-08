//
//  NSKVONotifying_JPPerson.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "NSKVONotifying_JPPerson.h"

@implementation NSKVONotifying_JPPerson

#pragma mark - KVO的子类方法的伪代码（方法列表使用runtime可以窥探）

// 重写Class返回父类，返回原本的类
// 重写的主要目的是让外界察觉不了这个类的存在（隐藏），从而屏蔽这个子类的内部实现。
- (Class)class {
    return [JPPerson class];
}

- (BOOL)_isKVOA {
    return YES;
}

// 重写dealloc进行收尾工作
- (void)dealloc {
    
}

#pragma mark KVO的属性监听实现

// 重写监听的属性的setter方法，里面其实调用_NSSetXXXAndNotify函数
- (void)setAge:(int)age {
    _NSSetIntValueAndNotify();
}

#pragma mark _NSSetIntValueAndNotify的伪代码（大概是酱紫）
// setXXX
// 内部 --> _NSSetIntValueAndNotify
// 内部 --> willChangeValueForKey --> setXXX(origin) --> didChangeValueForKey
/**
 * 触发KVO的条件（_NSSetIntValueAndNotify的内部实现）：
 * 1. 先调用willChangeValueForKey
 * 2. 这个属性原本的setter方法
 * 3. 再调用didChangeValueForKey（内部会调用observer的observeValueForKeyPath:ofObject:change:context:方法）
 * PS：如果前面没有先调用willChangeValueForKey，didChangeValueForKey内部就不会通知监听器
 */
void _NSSetIntValueAndNotify() {
    // 1.调用willChangeValueForKey:
    [self willChangeValueForKey:@"age"];
    
    // 2.调用原来的setter实现
    [super setAge:age];
    
    // 3.调用didChangeValueForKey:
    // 内部会调用observer的observeValueForKeyPath:ofObject:change:context:方法
    [self didChangeValueForKey:@"age"];
}

- (void)willChangeValueForKey:(NSString *)key {
    
}

- (void)didChangeValueForKey:(NSString *)key {
    // 通知监听器，XX属性值发送了改变
    [observer observeValueForKeyPath:key ofObject:self change:nil context:nil];
}

@end
