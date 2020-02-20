//
//  NSMutableDictionary+JPExtension.m
//  04-Runtime的应用（方法交换）
//
//  Created by 周健平 on 2019/11/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "NSMutableDictionary+JPExtension.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (JPExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 直接对NSMutableDictionary进行方法交换可能不起效
        // 因为想要交换的方法有可能并不是NSMutableDictionary这个类的方法
        // 使用NSMutableDictionary时实际上是【__NSDictionaryM】这个类（这个可以从崩溃信息里面看到）
        /**
         * 类簇：是Foundation framework框架下的一种设计模式，它管理了一组隐藏在公共接口下的私有类。
         * NSString、NSArray、NSDictonary... 真实类型是其他类型
         */
        // __NSDictionaryI 应该是 __NSDictionaryM 的父类
        // I：immutable（不可变），M：mutable（可变的）
        
        Class clsM = NSClassFromString(@"__NSDictionaryM");
        // 可变字典的存
        Method originSetMethod = class_getInstanceMethod(clsM, @selector(setObject:forKeyedSubscript:));
        Method exchangeSetMethod = class_getInstanceMethod(clsM, @selector(jp_setObject:forKeyedSubscript:));
        method_exchangeImplementations(originSetMethod, exchangeSetMethod);
        // 可变字典的取
        Method originGetMethod = class_getInstanceMethod(clsM, @selector(objectForKeyedSubscript:));
        Method exchangeGetMethod = class_getInstanceMethod(clsM, @selector(jp_objectForKeyedSubscript:));
        method_exchangeImplementations(originGetMethod, exchangeGetMethod);
        
        // __NSDictionaryI的方法列表也有objectForKeyedSubscript方法
        // 尝试交换__NSDictionaryI的objectForKeyedSubscript
        Class clsI = NSClassFromString(@"__NSDictionaryI");
        Method originGetMethodI = class_getInstanceMethod(clsI, @selector(objectForKeyedSubscript:));
        Method exchangeGetMethodI = class_getInstanceMethod(clsI, @selector(jp_objectForKeyedSubscript:));
        method_exchangeImplementations(originGetMethodI, exchangeGetMethodI);
        // 然而并没有拦截到，说明不可变字典的取值调用的是别的方法
        // 很有可能objectForKeyedSubscript方法是【专门给子类重写的】
    });
}

- (void)jp_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) {
        NSLog(@"JPExtension --- 请不要传入空的key");
        return;
    }
    [self jp_setObject:obj forKeyedSubscript:key];
}

- (id)jp_objectForKeyedSubscript:(id)key {
    if (!key) {
        NSLog(@"JPExtension --- key为空哦");
        return nil;
    }
    return [self jp_objectForKeyedSubscript:key];
}

@end
