//
//  JPPerson.m
//  02-Category
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@interface JPPerson ()
- (void)haha;
@end

@implementation JPPerson

+ (void)load {
    NSLog(@"load --- JPPerson");
}

+ (void)initialize {
    NSLog(@"initialize --- JPPerson");
}

@end
