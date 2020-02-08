//
//  JPProxy.m
//  03-内存管理-定时器
//
//  Created by 周健平 on 2019/12/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPProxy.h"
#import <objc/runtime.h>

@implementation JPProxy2

+ (instancetype)proxyWithTarget:(id)target {
    JPProxy2 *proxy = [self alloc]; // NSProxy没有init方法
    proxy.target = target;
    return proxy;
}

@end

@implementation JPProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
