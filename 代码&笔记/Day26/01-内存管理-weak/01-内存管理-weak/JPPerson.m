//
//  JPPerson.m
//  04-内存管理-weak
//
//  Created by 周健平 on 2019/12/18.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
