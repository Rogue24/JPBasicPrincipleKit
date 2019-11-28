//
//  NSObject+JPExtension.m
//  01-Runloop
//
//  Created by 周健平 on 2019/11/27.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "NSObject+JPExtension.h"
#import <objc/runtime.h>

@implementation NSObject (JPExtension)

+ (void)load {
    Method method1 = class_getInstanceMethod(self, @selector(forwardingTargetForSelector:));
    Method method2 = class_getInstanceMethod(self, @selector(jp_forwardingTargetForSelector:));
    method_exchangeImplementations(method1, method2);
}

- (id)jp_forwardingTargetForSelector:(SEL)aSelector {
    id forwardingTarget = self.jp_forwardingTargets[NSStringFromSelector(aSelector)];
    if (forwardingTarget) return forwardingTarget;
    return [self jp_forwardingTargetForSelector:aSelector];
}

- (void)setJp_forwardingTargets:(NSDictionary<NSString *,id> *)jp_forwardingTargets {
    objc_setAssociatedObject(self, @selector(jp_forwardingTargets), jp_forwardingTargets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary<NSString *,id> *)jp_forwardingTargets {
    return objc_getAssociatedObject(self, _cmd);
}

@end
