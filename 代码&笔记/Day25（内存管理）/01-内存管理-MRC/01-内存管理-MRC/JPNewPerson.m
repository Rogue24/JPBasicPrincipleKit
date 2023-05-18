//
//  JPNewPerson.m
//  01-内存管理-MRC
//
//  Created by 周健平 on 2019/12/16.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPNewPerson.h"

@implementation JPNewPerson

- (void)dealloc {
    self.car = nil;
    
    NSLog(@"%s", __func__);
    [super dealloc];
}

#pragma mark - 使用【retain】修饰自动生成的setter和getter的实现
//- (void)setCar:(JPCar *)car {
//    if (_car == car) {
//        return;
//    }
//
//    [_car release];
//    _car = [_car retain];
//}
//
//- (JPCar *)car {
//    return _car;
//}

#pragma mark - 使用【assign】修饰自动生成的setter和getter的实现
//- (void)setAge:(int)age {
//    _age = age;
//}
//
//- (int)age {
//    return _age;
//}

@end
