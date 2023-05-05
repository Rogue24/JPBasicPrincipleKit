//
//  JPPerson.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

// KVO底层是按照KVC的流程走，先找方法，找到就重写，找不到就来这里看看是否能访问成员变量
// 添加KVO和使用KVC都会【各自】调用这里最多二次，setter和getter各来一次，之后重复访问这个成员变量就不会再来了
/*
 例如这里的height，只有setter方法，没有getter方法：
    1.当添加KVO时，找不到getter方法，会来一次这里
    2.当KVO【第一次】监听到属性被修改时，又或者手动【第一次】使用了KVC（valueForKey:）
        - 被KVO监听的属性被修改时会先执行willChangeValueForKey，这里面其实是使用KVC（valueForKey:）获取旧值，同样也是找不到getter方法，所以会再来一次这里，之后执行didChangeValueForKey也会使用KVC，不过前面已经来过这里获取过权限了，所以后面就不会再来了（没获取的话就已经崩溃了）
 */
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}

- (void)_setHeight:(int)height {
    isHeight = height;
    NSLog(@"setHeight");
}

- (void)setMoney:(int)money {
    NSLog(@"setMoney");
}
- (NSString *)money {
    return @"no money";
}

- (void)setAge:(int)age {
    _age = age;
    NSLog(@"setAge");
}

- (void)setWeight:(int)weight {
    _weight = weight;
    NSLog(@"setWeight");
}

// 注意：最好别乱写get方法，因为KVO的回调是从get方法这里取值的！
- (void)douer {
    NSLog(@"模拟douer的get方法");
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    NSLog(@"willChangeValueForKey: %@", key);
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"didChangeValueForKey: %@ --- begin", key);
    [super didChangeValueForKey:key];
    NSLog(@"didChangeValueForKey: %@ --- ended", key);
    NSLog(@"==============================================");
}

@end
