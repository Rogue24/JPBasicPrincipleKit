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
    int isHeight; // 优先级：_height、_isHeight、height、isHeight
}
- (void)setHeight:(int)height;

- (void)setMoney:(int)money;
- (NSString *)money;

@property (nonatomic, assign) int age;

@property (nonatomic, assign) int weight;

@end
