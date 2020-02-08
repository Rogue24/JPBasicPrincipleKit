//
//  JPPerson.m
//  01-内存管理-MRC
//
//  Created by 周健平 on 2019/12/15.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)dealloc {
//    [_dog release];
//    _dog = nil;
    self.dog = nil;
    
    NSLog(@"%s", __func__);
    [super dealloc];
}

- (void)setDog:(JPDog *)dog {
    if (_dog == dog) {
        return;
    }
    
    [_dog release];
    _dog = [dog retain];
}

- (JPDog *)dog {
    return _dog;
}

@end
