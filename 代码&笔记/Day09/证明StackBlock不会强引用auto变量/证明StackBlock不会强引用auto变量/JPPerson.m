//
//  JPPerson.m
//  证明StackBlock不会强引用auto变量
//
//  Created by 周健平 on 2020/1/30.
//  Copyright © 2020 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson
- (void)dealloc {
    NSLog(@"%s", __func__);
    [super dealloc];
}
@end
