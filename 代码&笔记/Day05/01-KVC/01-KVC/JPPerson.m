//
//  JPPerson.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

#pragma mark - setter方法查询优先级
// -------------- 高 --------------
//- (void)setAge:(int)age {
//    _age = age;
//}
//- (void)_setAge:(int)age {
//    _age = age;
//}
// -------------- 低 --------------

#pragma mark - getter方法查询优先级
// -------------- 高 --------------
//- (int)getAge {
//    return _age;
//}
//- (int)age {
//    return _age;
//}
//- (int)isAge {
//    return _age;
//}
//- (int)_age {
//    return _age;
//}
// -------------- 低 --------------

// 是否允许访问成员变量，默认为YES
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
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
