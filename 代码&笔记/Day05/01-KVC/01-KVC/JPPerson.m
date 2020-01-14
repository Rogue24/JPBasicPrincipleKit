//
//  JPPerson.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

#pragma mark - KVC赋值：setter方法查询优先级
// -------------- 高 --------------
//- (void)setAge:(int)age {
//    _age = age;
//}
//- (void)_setAge:(int)age {
//    _age = age;
//}
// -------------- 低 --------------

#pragma mark - KVC取值：getter方法查询优先级
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

#pragma mark - 是否允许访问成员变量（默认为YES）
/*
 * KVC赋值/取值过程中对应的setter/getter方法都没找到时会来到这里
    - YES：按优先级_key、_isKey、key、isKey的顺序查找对应的成员变量
        - 找到：赋值/取值
        - 找不到：抛出NSUnknownKeyException异常
    - NO：抛出NSUnknownKeyException异常
 */
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}

#pragma mark - KVO相关（通过KVC赋值，不管有没有对应的setter方法都会触发KVO）

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
