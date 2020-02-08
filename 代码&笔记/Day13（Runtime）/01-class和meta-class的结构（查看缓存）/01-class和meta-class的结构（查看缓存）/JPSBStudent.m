//
//  JPSBStudent.m
//  01-class和meta-class的结构（查看缓存）
//
//  Created by 周健平 on 2019/11/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPSBStudent.h"

@implementation JPSBStudent
- (void)sbStudentTest {
    NSLog(@"%@ %s", NSStringFromClass(self.class), __func__);
}
@end
