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
    // 虽然看上去能行，但是目标方法里面的self，就不再是target了，是me（内存地址不一样）
    // 这样timer持有的不是target而是me了
    // 而且还无法释放
    // 暂时不知道why，按道理来说应该会调用两次target的dealloc，第一次是target调用，接着销毁timer后，轮到me第二次去调用，然而第二次没发生
//    object_setClass(proxy, [target class]); // 所以不好，不建议
    
    return proxy;
}

// 方案2：利用消息转发机制（it work）
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target; // 让target去执行，相当于objc_msgSend(self.target, aSelector);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
