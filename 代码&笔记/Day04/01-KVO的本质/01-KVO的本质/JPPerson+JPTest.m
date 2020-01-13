//
//  JPPerson+JPTest.m
//  01-KVO
//
//  Created by 周健平 on 2019/11/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson+JPTest.h"

@implementation JPPerson (JPTest)

- (void)setMoney:(int)money {
    NSLog(@"setMoney");
}

- (int)money {
    return 999;
}

@end
