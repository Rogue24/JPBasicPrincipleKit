//
//  JPPerson.h
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

// KVO生成的子类会判断监听的属性有没有对应正确的set方法才会去【重写】
// 必须是`-setXxx:`这样的set方法，或者是`-_setXxx:`（名字前多一个下划线），必须要用驼峰法，返回值类型必须要为void（KVC那套判定）
@interface JPPerson : NSObject
{
    @public
    int isHeight; // 优先级：_height、_isHeight、height、isHeight
    int douer;
}

- (void)_setHeight:(int)height;
// 如果名字前多两个下划线呢？
//- (void)__setHeight:(int)height;
// NO，这种方法KVO不会去重写（调用不会触发KVO）。

- (void)setMoney:(int)money;
- (NSString *)money;

@property (nonatomic, assign) int age;

@property (nonatomic, assign) int weight;

@end
