//
//  JPPerson.h
//  03-Block-循环引用
//
//  Created by 周健平 on 2019/11/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JPBlock)(void);

@interface JPPerson : NSObject
@property (nonatomic, assign) int age;
@property (nonatomic, copy) JPBlock block;
- (void)test;
@end
