//
//  NSMutableDictionary+JPExtension.m
//  04-Runtime的应用（方法交换）
//
//  Created by 周健平 on 2019/11/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "NSMutableDictionary+JPExtension.h"
#import <objc/runtime.h>

/**
 * 类簇：是`Foundation framework`框架下的一种设计模式，它管理了一组隐藏在公共接口下的【私有类】
 * 🌰 ：`NSString`、`NSArray`、`NSDictonary`...  它们的真实类型是其他类型
 */

@implementation NSMutableDictionary (JPExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 直接对`NSMutableDictionary`进行方法交换可能不起效，
        // 因为想要交换的方法有可能并不是`NSMutableDictionary`这个类的方法。
        
        // 使用`NSMutableDictionary`时实际上是【__NSDictionaryM】这个类（这个可以从崩溃信息里面看到）
        Class clsM = NSClassFromString(@"__NSDictionaryM");
        
        // 可变字典的存
        Method originSetMethod = class_getInstanceMethod(clsM, @selector(setObject:forKeyedSubscript:));
        Method exchangeSetMethod = class_getInstanceMethod(clsM, @selector(jp_setObject:forKeyedSubscript:));
        method_exchangeImplementations(originSetMethod, exchangeSetMethod);
        
        // 可变字典的取
        Method originGetMethod = class_getInstanceMethod(clsM, @selector(objectForKeyedSubscript:));
        Method exchangeGetMethod = class_getInstanceMethod(clsM, @selector(jp_objectForKeyedSubscript:));
        method_exchangeImplementations(originGetMethod, exchangeGetMethod);
        
        // __NSDictionaryI 应该是 __NSDictionaryM 的父类
        // I：immutable（不可变），M：mutable（可变的）
        
        // `__NSDictionaryI`的方法列表也有`objectForKeyedSubscript`方法
        // 尝试交换`__NSDictionaryI`的`objectForKeyedSubscript`
        Class clsI = NSClassFromString(@"__NSDictionaryI");
        // 不可变字典的取
        Method originGetMethodI = class_getInstanceMethod(clsI, @selector(objectForKeyedSubscript:));
        Method exchangeGetMethodI = class_getInstanceMethod(clsI, @selector(jp_objectForKeyedSubscript:));
        method_exchangeImplementations(originGetMethodI, exchangeGetMethodI);
        // 然而经过实测，`__NSDictionaryI`的`objectForKeyedSubscript`并没有拦截到，
        // 说明【不可变字典的取值】调用的是【别的方法】。
        // 有可能`objectForKeyedSubscript`方法是【专门】给`__NSDictionaryI`的子类重写的。
    });
}

// 存值 --- 属于可变的
- (void)jp_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) {
        NSLog(@"JPExtension --- 请不要传入空的key");
        return;
    }
    [self jp_setObject:obj forKeyedSubscript:key];
}

// 取值 --- 属于不可变的
- (id)jp_objectForKeyedSubscript:(id)key {
    if (!key) {
        NSLog(@"JPExtension --- key为空哦");
        return nil;
    }
    return [self jp_objectForKeyedSubscript:key];
}

@end
