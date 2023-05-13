//
//  JPPerson.m
//  01-class和meta-class的结构（查看缓存）
//
//  Created by 周健平 on 2019/11/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"
#import <objc/runtime.h>

@implementation JPPerson

// 模拟一个跟源码一样的method_t结构体
struct method_t {
    SEL name;
    const char *types;
    IMP imp; // 指向函数的指针（函数地址）
};

#pragma mark - 动态方法解析（实例方法的）

// 当在自己的类对象的缓存和方法列表、以及所有父类的类对象的缓存和方法列表中统统都找不到xxx方法时，就会来到这里
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"没有%@方法的实现", NSStringFromSelector(sel));
    
    /*
     *【动态方法解析】
     * 不提供xxx方法的实现，runtime在【消息发送阶段】肯定找不到xxx方法，
     * 然后就会来到这里，在这里runtime会给我们机会去【重新添加】xxx方法。
     *
     * 使用runtime【动态添加】xxx方法的实现：
     * class_addMethod(Class cls, SEL name, IMP imp, char *types)
        - cls：从哪个类添加
        - name：要添加哪个方法
        - imp：添加的方法地址
        - types：添加的方法编码（返回值类型、参数信息，编码含义去查看TypeEncoding对应表）
     */
    
    //【1】添加Method
    if (sel == @selector(personTest111)) {
        
        // typedef struct objc_method *Method;
        Method method = class_getInstanceMethod(self, @selector(fixPersonTest111));
        
        //【1.1】转成`method_t`来获取`imp`和`types`
        // `Method`其实是指向结构体`objc_method`的指针（struct objc_method *）
        // 而`struct objc_method`的结构跟`struct method_t`基本是一样的，
        // 所以可以强制转换：
//        struct method_t *method_t = (struct method_t *)method;
//        class_addMethod(self,
//                        sel,
//                        method_t->imp,
//                        method_t->types);
        // 但毕竟这是自己模拟的`method_t`结构体，还是不太靠谱。
        
        //【1.2】使用runtime的函数来获取`imp`和`types`
        class_addMethod(self,
                        sel,
                        method_getImplementation(method),
                        method_getTypeEncoding(method));
        
        // 返回YES代表告诉系统已经动态添加了方法
        return YES;
    }
    
    //【2】添加C语言函数
    if (sel == @selector(personTest222)) {
        class_addMethod(self,
                        sel,
                        (IMP)fixPersonTest222,
                        "v16@0:8");
        
        // 返回YES代表告诉系统已经动态添加了方法
        return YES;
    }
    
    return [super resolveInstanceMethod:sel];
}

- (void)fixPersonTest111 {
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
}

void fixPersonTest222(id self, SEL _cmd) {
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
}

#pragma mark - 动态方法解析（类方法的）

// 当在自己的元类对象的缓存和方法列表、以及所有父类的元类对象的缓存和方法列表中统统都找不到xxx方法时，就会来到这里
+ (BOOL)resolveClassMethod:(SEL)sel {
    if (sel == @selector(personTest333)) {
        Method method = class_getInstanceMethod(self, @selector(fixPersonTest333));
    
        // 不管添加的是[类方法]还是[实例方法]，【只要是方法】都可以添加
        class_addMethod(object_getClass(self), // 注意：类方法是添加到【元类对象】里面，可不是类对象
                        sel,
                        method_getImplementation(method),
                        method_getTypeEncoding(method));
        // PS:【类方法】的调用者只会是类对象
        
        return YES;
    }
    return [super resolveClassMethod:sel];
}

- (void)fixPersonTest333 {
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
}

@end
