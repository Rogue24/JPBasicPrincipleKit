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

static Class targetCls_;

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if (self.target) {
        return [self.target methodSignatureForSelector:sel];
    }
    return [NSMethodSignature signatureWithObjCTypes:"v"];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (self.target) {
        [invocation invokeWithTarget:self.target];
    } else {
        NSLog(@"没有target");
    }
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if (targetCls_) {
        return [targetCls_ methodSignatureForSelector:sel];
    }
    return [NSMethodSignature signatureWithObjCTypes:"v"];
}

+ (void)forwardInvocation:(NSInvocation *)invocation {
    if (targetCls_) {
        [invocation invokeWithTarget:targetCls_];
    } else {
        NSLog(@"没有target");
    }
}

@end

@implementation JPProxy

+ (instancetype)proxyWithTarget:(id)target {
    JPProxy *proxy = [self alloc]; // NSProxy没有init方法
    proxy.target = target;
    targetCls_ = [target class];
    return proxy;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
