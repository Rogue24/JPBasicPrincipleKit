//
//  JPProxyObject.m
//  03-内存管理-定时器
//
//  Created by 周健平 on 2019/12/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPProxyObject.h"
#import <objc/runtime.h>

@implementation JPProxyObject

+ (instancetype)proxyWithTarget:(id)target {
    JPProxyObject *proxy = [[self alloc] init];
    proxy.target = target;
    
    // 方案1：使用runtime修改Class的isa指向
    // 虽然能行，但是【不安全】，不建议。
//    object_setClass(proxy, [target class]);
    /*
     * 例如这里重写了dealloc，target的dealloc里面对定时器进行关闭操作：[self.timer invalidate];
     * 然后轮到proxy执行dealloc，但执行的是target的dealloc，此时的self是proxy，
     * 用proxy的地址去获取timer的地址，然而proxy根本没有timer，所以拿到的是个野指针，导致【坏内存访问】！
     * 所以不建议，用proxy去执行target的方法很不安全的。
     */
    
    return proxy;
}

// 方案2：利用消息转发机制（推荐）
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target; // 让target去执行，相当于objc_msgSend(self.target, aSelector);
}

- (void)dealloc {
    NSLog(@"%s %@", __func__, self);
}

@end
