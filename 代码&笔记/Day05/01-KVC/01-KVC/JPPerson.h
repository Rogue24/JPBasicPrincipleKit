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
    // 成员变量通过KVC赋值/查询的优先级
    // -------- 高 --------
    int _age;
    int _isAge;
    int age;
    int isAge;
    // -------- 低 --------
}
//@property (nonatomic, assign) int age;
@end
