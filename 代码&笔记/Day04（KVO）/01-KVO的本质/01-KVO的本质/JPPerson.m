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
    // 保存旧值，【标识】等会调用`didChangeValueForKey`（调用setter方法之后）
    NSLog(@"willChangeValueForKey --- %@", key);
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"begin didChangeValueForKey");
    [super didChangeValueForKey:key]; // 通知监听器，XX属性值发送了改变：在这里执行的KVO代理方法
    NSLog(@"ended didChangeValueForKey --- %@", key);
    NSLog(@"==============================================");
}

- (void)setHeight:(int)height {
    NSLog(@"setHeight");
}

- (int)height {
    return 111;
}

@end
