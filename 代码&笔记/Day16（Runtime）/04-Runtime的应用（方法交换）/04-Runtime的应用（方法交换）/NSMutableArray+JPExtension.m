//
//  NSMutableArray+JPExtension.m
//  04-Runtime的应用（方法交换）
//
//  Created by 周健平 on 2019/11/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "NSMutableArray+JPExtension.h"
#import <objc/runtime.h>

@implementation NSMutableArray (JPExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 直接对NSMutableArray进行方法交换可能不起效
        // 因为想要交换的方法有可能并不是NSMutableArray这个类的方法
        // 使用NSMutableArray时实际上是【__NSArrayM】这个类（这个可以从崩溃信息里面看到）
        /**
         * 类簇：是Foundation framework框架下的一种设计模式，它管理了一组隐藏在公共接口下的私有类。
         * NSString、NSArray、NSDictonary... 真实类型是其他类型
         */
        // __NSArrayI 应该是 __NSArrayM 的父类
        // I：immutable（不可变），M：mutable（可变的）
        
        Class cls = NSClassFromString(@"__NSArrayM");
        Method originMethod = class_getInstanceMethod(cls, @selector(insertObject:atIndex:));
        Method exchangeMethod = class_getInstanceMethod(cls, @selector(jp_insertObject:atIndex:));
        method_exchangeImplementations(originMethod, exchangeMethod);
    });
}

- (void)jp_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {
        NSLog(@"JPExtension ---- 请不要传入空元素");
        return;
    }
    [self jp_insertObject:anObject atIndex:index];
}

@end
