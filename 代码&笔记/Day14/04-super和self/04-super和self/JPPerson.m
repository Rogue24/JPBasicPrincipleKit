//
//  JPPerson.m
//  04-super
//
//  Created by 周健平 on 2019/11/20.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)run {
    NSLog(@"%@ --- person run", self);
}

// 防止报【unrecognized selector sent to instance】错误的一种处理方式

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([self respondsToSelector:aSelector]) {
        return [super methodSignatureForSelector:aSelector];
    }
    
    // 能来到这里说明找不到方法的实现，随便写个方法签名去forwardInvocation处理吧
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"没有 %s 方法的实现", anInvocation.selector);
}

@end
