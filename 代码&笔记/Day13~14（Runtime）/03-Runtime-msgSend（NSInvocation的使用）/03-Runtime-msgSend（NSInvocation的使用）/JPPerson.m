//
//  JPPerson.m
//  01-Runtime-消息转发
//
//  Created by 周健平 on 2019/11/17.
//  Copyright © 2019 周健平. All rights reserved.
//
//  类方法也能消息转发：
//  +forwardingTargetForSelector:, +methodSignatureForSelector:, +forwardInvocationt:
//  这3个方法虽然敲的时候没提示出来，但只要有实现（能在methods里面找到），也是会调用的。
/*
 * ___forwarding___函数本质上只看消息接收者(receiver)和方法名(selector)：
 * 不管是实例方法还是类方法，只要类/元类对象的方法列表(methods)中有对应名字的方法，就会调用。
     // receiver是实例对象的话，receiverClass就是类对象
     // receiver是类对象的话，receiverClass就是元类对象
     // 只要有实现这些方法，就会调用喔
     if (class_respondsToSelector(receiverClass, @selector(xxx))) {
         [receiver xxx];
     }
 */

#import "JPPerson.h"
#import <objc/runtime.h>
#import "JPDog.h"

@implementation JPPerson

#pragma mark - 第一次机会：resolveInstanceMethod（动态解析）
//【动态解析】：如果没有xxx方法的实现，runtime会在这里给机会去重新添加xxx方法
+ (BOOL)resolveInstanceMethod:(SEL)sel { // 实例方法的
    if (sel == @selector(test:)) {
        // 啥都不干
        // 这里返回YES和NO都一样
        return NO;
    }
    BOOL resolve =[super resolveInstanceMethod:sel];
    // 默认返回NO
    return resolve;
}
+ (BOOL)resolveClassMethod:(SEL)sel { // 类方法的
    if (sel == @selector(test:)) {
        return NO;
    }
    return [super resolveClassMethod:sel];
}

// -resolveInstanceMethod: -> NO -> -forwardingTargetForSelector:

#pragma mark - 第二次机会：forwardingTargetForSelector（消息转发）
//【消息转发】：将消息转发给别人
- (id)forwardingTargetForSelector:(SEL)aSelector { // 实例方法的
    if (aSelector == @selector(test:)) {
        // 不转发给任何人就返回nil
        return nil;
    }
    id target = [super forwardingTargetForSelector:aSelector];
    // 默认返回nil
    return target;
}
+ (id)forwardingTargetForSelector:(SEL)aSelector { // 类方法的
    if (aSelector == @selector(test:)) {
        // 只要方法签名一样，【类方法】也能发给【实例对象】去执行【实例方法】
        // ___forwarding___ 里面是叫这里返回的`target`去执行这里的`SEL`
        // 1.`target`是id类型，就是是谁都阔以（是个对象都可以）
        // 2.`SEL`是方法名，只要`target`有个【同名的方法】就OJBK
        NSLog(@"找不到类方法，转发给实例对象找实例方法，它的刚好有一模一样的实例方法");
        return [[JPDog alloc] init]; // [JPDog class];
        // 相当于：objc_msgSend([[JPDog alloc] init], @selector(test:)); 给实例对象发消息
        //   ==> [[[JPDog alloc] init] test]; 也就是叫实例对象去执行它的实例方法
    }
    return [super forwardingTargetForSelector:aSelector];
}

// -forwardingTargetForSelector: -> return nil -> -methodSignatureForSelector:

#pragma mark - 第三次（最后）机会：methodSignatureForSelector+forwardInvocation（方法签名+方法调用）
//【NSMethodSignature】：方法签名，包含返回值类型、参数类型（TypeEncoding编码）的信息
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector { // 实例方法的
    if (aSelector == @selector(test:)) {
        // 如果返回nil就直接报错
        // 有返回就会执行forwardInvocation
        return [NSMethodSignature signatureWithObjCTypes:"i@:i"]; // i20@0:8i16，可以不写数字
        
        // 可以直接通过对象去找这个方法的方法签名（去它的类对象里面找）
        // 不过得这里要注意：不能通过【现在调用这个方法的对象】，会【死循环】：找不到才来的嘛，这样不得反复找
//        return [self methodSignatureForSelector:aSelector];
//        return [[[JPPerson alloc] init] methodSignatureForSelector:aSelector];
        // 要通过另一个有【相同方法并且有实现的对象】中去找：
//        return [[[JPDog alloc] init] methodSignatureForSelector:aSelector];
        
        // 如果只是为了不让程序崩溃，那随便返回一个TypeEncoding编码就好了（不是TypeEncoding编码的会崩）
        // 然后在forwardInvocation里面啥都不干就OJBK。
//        return [NSMethodSignature signatureWithObjCTypes:":"]; //"v16@0:8" ":"
    }
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    // 默认返回nil
    return methodSignature;
}
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector { // 类方法的
    if (aSelector == @selector(test:)) {
        // 如果返回nil就直接报错
        return [JPDog methodSignatureForSelector:aSelector];
    }
    return [super methodSignatureForSelector:aSelector];
}

// 上面返回一个方法签名后，将其封装到一个方法调用invocation中，接着调用-forwardInvocation:方法，给到我们使用。
// -methodSignatureForSelector: -> return methodSignature -> 创建invocation，调用-forwardInvocation:invocation
//             ↓
//         return nil
//             ↓
// unrecognized selector sent to instance（崩溃）

/*
 *【NSInvocation】：封装了一个方法调用，包括：方法调用者、方法名字、方法参数
 * anInvocation.target：方法调用者
 * anInvocation.selector：方法名字
 * [anInvocation getArgument:NULL atIndex:0]：获取方法参数
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation { // 实例方法的
    // 直接调用的后果：
    // 1.如果上面返回的`methodSignature`的方法签名跟原方法签名【对得上】，那么`anInvocation.target`则是【原消息调用者】
    //  - 直接调用：死循环
    // 2.如果上面返回的`methodSignature`的方法签名跟原方法签名【对不上】，那么`anInvocation.target`则指向一个【坏内存】
    //  - 直接调用：坏内存访问
//    NSLog(@"anInvocation.target %@", anInvocation.target);
//    [anInvocation invoke];
    
    // 使用anInvocation可以获取/修改参数、获取/修改返回值、切换方法调用者、调用方法。
    // 参数和返回值的信息都是由methodSignatureForSelector方法中返回的方法签名所决定的。
    /*
     * 参数的顺序/位置(index):
     * 0: receiver (方法接收者，id)
     * 1: selector (方法名字，_cmd)
     * 2 ~ xxx: other arguments (其他参数)
     */
    // 如果想正确使用anInvocation，那前面的方法签名不能瞎写，参数和返回值的信息不对称会报错
    // - 如果对不上，那参数的个数不就乱套了，直接导致index越界，崩溃！
    
    // 获取参数
    int age;
    [anInvocation getArgument:&age atIndex:2];
    NSLog(@"修改前的参数值 %d * 3 = %d", age, age * 3);
    
    // 修改参数
    int newAge = 4;
    [anInvocation setArgument:&newAge atIndex:2]; // 写
    int newAge2;
    [anInvocation getArgument:&newAge2 atIndex:2]; // 读
    NSLog(@"修改后的参数值 %d", newAge2);
    
    // 切换方法调用者并调用方法
    [anInvocation invokeWithTarget:[[JPDog alloc] init]];
    
    // 获取返回值（要先执行方法才有返回值）
    int value;
    [anInvocation getReturnValue:&value]; // 读
    NSLog(@"修改前的返回值 %d", value);
    
    // 修改返回值
    int newValue = 777;
    [anInvocation setReturnValue:&newValue]; // 写
    int newValue2;
    [anInvocation getReturnValue:&newValue2]; // 读
    NSLog(@"修改后的返回值 %d", newValue2);
}
+ (void)forwardInvocation:(NSInvocation *)anInvocation { // 类方法的
    // 修改参数
    int newAge = 2;
    [anInvocation setArgument:&newAge atIndex:2]; // 写
    
    // 切换方法调用者并调用方法
    [anInvocation invokeWithTarget:[JPDog class]];
    
    // 获取返回值（要先执行方法才有返回值）
    int value;
    [anInvocation getReturnValue:&value]; // 读
    NSLog(@"返回值 %d", value);
}

@end
