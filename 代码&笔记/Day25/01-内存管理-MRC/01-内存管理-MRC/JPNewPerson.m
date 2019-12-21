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
//
//- (void)setAge:(int)age {
//    _age = age;
//}
//
//- (int)age {
//    return _age;
//}

@end
