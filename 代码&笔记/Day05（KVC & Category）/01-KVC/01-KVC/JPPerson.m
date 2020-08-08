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

#pragma mark - 是否允许访问成员变量（默认就返回YES）
/*
 * 添加KVO和使用KVC都会【各自】调用这里最多二次，setter和getter各来一次，之后重复访问这个成员变量就不会再来了
 * KVC赋值/取值过程中对应的setter或getter方法没找到时会来到这里（setter和getter各来一次，有的话就不会来，没有的话要去找成员变量，得通过这里的同意）
    - YES：按优先级_key、_isKey、key、isKey的顺序查找对应的成员变量
        - 找到：赋值/取值
        - 找不到：抛出NSUnknownKeyException异常
    - NO：抛出NSUnknownKeyException异常
 * KVO添加时对应的setter或getter方法没找到时也会来到这里（setter和getter各来一次，有的话就不会来，没有的话要去找成员变量，得通过这里的同意）
 */
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}

//- (void)setAge:(int)age {
//
//}
//- (int)age {
//    return 1;
//}

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
