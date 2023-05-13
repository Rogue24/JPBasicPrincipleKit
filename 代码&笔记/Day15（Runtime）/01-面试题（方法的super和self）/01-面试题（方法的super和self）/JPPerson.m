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
        /*
         * 如果是JPPerson的实例对象调用的就【不会】来到这里
            - 因为JPPerson没有这个方法的实现
            - respondsToSelector = no
         * 如果是JPStudent的实例对象【通过super调用的】会来到这里
            - 因为JPStudent本来有这个方法的实现，但是用的是super来调用
            - 然后在父类JPPerson的方法列表里面找不到这个方法，所以才会来到这里
            - respondsToSelector = yes
         */
        if (![self isMemberOfClass:JPPerson.class]) {
            NSLog(@"我是子类 %@", self); // JPStudent
        }
        
        /*
         * 延伸的另一个问题：这里的self是JPStudent，然后再通过super去调用这个方法，那么这里会不会再执行一次？
         * 答案：不会。
         *
         * [super methodSignatureForSelector:aSelector]的底层实现：
         * objc_msgSendSuper({self, class_getSuperclass(objc_getClass("JPPerson"))}, sel_registerName("methodSignatureForSelector:"), aSelector); ---- 对比之前多出来的这个aSelector就是这里的【参数】
         * 注意：这里的`objc_getClass("JPPerson")`中的"JPPerson"是直接“写死”的，并不是用self，所以class_getSuperclass拿到的是JPPerson的父类NSObject。
         * 可以看出，这是让self（JPStudent），去JPPerson的父类（NSObject）里面找methodSignatureForSelector方法调用，所以这里【不会】再执行一次。
         * 从而得出另一个结论：super并不是用self拿父类，而是拿【这个文件的这个类的父类】，self是不确定的。
         */
        return [super methodSignatureForSelector:aSelector];
    }
    
    //（可能通过performSelector调用的）其他没有实现的方法就走这个流程
    // 随便写个方法签名然后去forwardInvocation处理吧
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"JPPerson里面没有%s方法的实现", anInvocation.selector);
}

@end
