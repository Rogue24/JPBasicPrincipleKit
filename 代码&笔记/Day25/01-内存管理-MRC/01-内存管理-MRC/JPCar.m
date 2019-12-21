//
//  JPCar.m
//  01-内存管理-MRC
//
//  Created by 周健平 on 2019/12/16.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPCar.h"

@implementation JPCar
- (void)dealloc {
    NSLog(@"%s", __func__);
    [super dealloc];
}
@end
