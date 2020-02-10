//
//  JPPerson.m
//  01-Runtime-消息转发
//
//  Created by 周健平 on 2019/11/17.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"
#import <objc/runtime.h>
#import "JPDog.h"

@implementation JPPerson

- (void)fixTest {
    NSLog(@"fixTest %@ %@", self, NSStringFromSelector(_cmd));
}

#pragma mark - 第一次机会：resolveInstanceMethod（动态解析）
//【动态解析】：如果没有xxx方法的实现，runtime会在这里给机会去重新添加xxx方法
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(test)) {
//        Method method = class_getInstanceMethod(self, @selector(fixTest));
//        class_addMethod(self, sel, method_getImplementation(method), method_getTypeEncoding(method));
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}

#pragma mark - 第二次机会：forwardingTargetForSelector（消息转发）
//【消息转发】：将消息转发给别人
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    if (aSelector == @selector(test)) {
//        // 相当于：objc_msgSend(dog, aSelector)
//        return [[JPDog alloc] init];
//    }
//    return [super forwardingTargetForSelector:aSelector];
//}

#pragma mark - 第三次（最后）机会：methodSignatureForSelector+forwardInvocation（方法签名+方法调用）
//【NSMethodSignature】：方法签名，包含返回值类型、参数类型（TypeEncoding编码）的信息
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(test)) {
        // 如果返回nil就直接报错
        // 有返回就会执行forwardInvocation
        return [NSMethodSignature signatureWithObjCTypes:"v16@0:8"];
    }
    return [super methodSignatureForSelector:aSelector];
}

//【NSInvocation】：封装了一个方法调用，包括：方法调用者、方法名字、方法参数
// anInvocation.target ==> 方法调用者
// anInvocation.selector ==> 方法名字
// [anInvocation getArgument:NULL atIndex:0] ==> 获取方法参数
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    // 切换其他目标调用方法：
    // 方式1：
//    anInvocation.target = [[JPDog alloc] init];
//    [anInvocation invoke];
    // 方式2：
//    [anInvocation invokeWithTarget:[[JPDog alloc] init]];
    
    // 或者啥都不干
    NSLog(@"啥都不干");
}

@end
