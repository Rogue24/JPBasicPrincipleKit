//
//  JPPerson.h
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPPerson : NSObject
{
    @public
    int _height;
}
- (void)setheight:(int)height; // set方法要用【驼峰法】，不然不会触发KVO。
- (void)setHeight:(int)height;

@property (nonatomic, assign) int age;

@property (nonatomic, assign) int weight;

@end
