//
//  JPPerson.h
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

// KVO生成的子类会判断监听的属性有没有对应正确的set方法才会去重写
@interface JPPerson : NSObject
{
    @public
    int _height;
}
- (void)setHeight:(int)height;
- (void)setheight:(int)height; // 正确的set方法要用【驼峰法】，不然不会触发KVO（KVO生成的子类只会重写正确的set方法）

@property (nonatomic, assign) int money; // 如果监听的是属性的成员变量名字“_money”
//- (void)set_money:(int)money; // 那得有这样的set方法KVO生成的子类才会去重写

@property (nonatomic, assign) int age;

@property (nonatomic, assign) int weight;

@end
