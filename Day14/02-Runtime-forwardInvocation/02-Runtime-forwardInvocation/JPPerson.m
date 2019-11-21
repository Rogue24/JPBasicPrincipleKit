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

//【第一次机会】resolveInstanceMethod
//【动态解析】：如果没有xxx方法的实现，runtime会在这里给机会去重新添加xxx方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(test:)) {
        // 啥都不干
        // 这里返回YES和NO都一样
        return NO;
    }
    return [super resolveInstanceMethod:sel];
}
+ (BOOL)resolveClassMethod:(SEL)sel {
    if (sel == @selector(test:)) {
        return NO;
    }
    return [super resolveClassMethod:sel];
}

//【第二次机会】forwardingTargetForSelector
//【消息转发】：将消息转发给别人
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (aSelector == @selector(test:)) {
        // 不转发给任何人就返回nil
        return nil;
    }
    return [super forwardingTargetForSelector:aSelector];
}
+ (id)forwardingTargetForSelector:(SEL)aSelector {
    if (aSelector == @selector(test:)) {
        // 只要方法签名一样，类方法也能发给实例对象去执行实例方法
        // ___forwarding___里面是叫这里返回的target去执行这里的SEL
        // 1.target是id类型，就是是谁都阔以
        // 2.SEL是方法名，只要target有个同名的方法就OJBK
        return [[JPDog alloc] init];
    }
    return [super forwardingTargetForSelector:aSelector];
}

//【第三次（最后）机会】methodSignatureForSelector+forwardInvocation
//【获取方法签名】：返回值类型、参数类型（TypeEncoding编码）
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(test:)) {
        // 如果返回nil就直接报错
        
        // 有返回就会执行forwardInvocation
//        return [NSMethodSignature signatureWithObjCTypes:"i20@0:8i16"];
        // 可以不传入数字
//        return [NSMethodSignature signatureWithObjCTypes:"i@:i"];
        // 可传入其他类同样类型的方法签名
        return [[[JPDog alloc] init] methodSignatureForSelector:aSelector];
    }
    return [super methodSignatureForSelector:aSelector];
}
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(test:)) {
        // 如果返回nil就直接报错
        return [JPDog methodSignatureForSelector:aSelector];
    }
    return [super methodSignatureForSelector:aSelector];
}

//【NSInvocation】：封装了一个方法调用，包括：方法调用者、方法名字、方法参数
// anInvocation.target ==> 方法调用者
// anInvocation.selector ==> 方法名字
// [anInvocation getArgument:NULL atIndex:0] ==> 获取方法参数
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    // 参数顺序：receiver(方法接收者)、selector(方法名字)、other arguments(其他参数)
    
    // 可以获取参数、修改参数、获取返回值、修改返回值
    // 这些返回值信息和参数信息都是由methodSignatureForSelector方法中返回的方法签名所决定的
    // 如果信息不对称会报错
    
    // 获取参数
    int age;
    [anInvocation getArgument:&age atIndex:2];
    NSLog(@"拿到age参数 %d * 3 = %d", age, age * 3);
    
    // 修改参数
    int newAge = 4;
    [anInvocation setArgument:&newAge atIndex:2];
    
    // 切换目标执行方法
    [anInvocation invokeWithTarget:[[JPDog alloc] init]];
    
    // 获取返回值
    int value;
    [anInvocation getReturnValue:&value];
    NSLog(@"返回值 %d", value);
    
    // 修改返回值
    int newValue = 777;
    [anInvocation setReturnValue:&newValue];
    NSLog(@"修改的返回值 %d", newValue);
    
    int newValue2;
    [anInvocation getReturnValue:&newValue2];
    NSLog(@"再看一次返回值 %d", newValue2);
    
}
+ (void)forwardInvocation:(NSInvocation *)anInvocation {
    // 修改参数
    int newAge = 2;
    [anInvocation setArgument:&newAge atIndex:2];
    
    // 切换目标执行方法
    [anInvocation invokeWithTarget:[JPDog class]];
    
    int value;
    [anInvocation getReturnValue:&value];
    NSLog(@"返回值 %d", value);
}
@end
