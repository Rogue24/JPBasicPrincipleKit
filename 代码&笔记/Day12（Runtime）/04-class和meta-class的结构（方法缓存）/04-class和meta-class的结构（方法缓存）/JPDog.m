//
//  JPDog.m
//  04-class和meta-class的结构（方法缓存）
//
//  Created by 周健平 on 2020/2/8.
//  Copyright © 2020 周健平. All rights reserved.
//

#import "JPDog.h"

@implementation JPDog
- (NSString *)eat1 {
    return NSStringFromSelector(_cmd);
}
- (NSString *)eat2 {
    return NSStringFromSelector(_cmd);
}
- (NSString *)eat3 {
    return NSStringFromSelector(_cmd);
}
- (NSString *)eat4 {
    return NSStringFromSelector(_cmd);
}
- (NSString *)eat5 {
    return NSStringFromSelector(_cmd);
}

- (void)test1 {
    NSLog(@"%s", __func__);
}
- (void)test2 {
    NSLog(@"%s", __func__);
}
@end
