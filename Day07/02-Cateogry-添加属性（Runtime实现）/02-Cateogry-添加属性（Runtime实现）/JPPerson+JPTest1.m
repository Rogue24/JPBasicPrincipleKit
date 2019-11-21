//
//  JPPerson+JPTest1.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson+JPTest1.h"

#import <AppKit/AppKit.h>
#import <objc/runtime.h>

@implementation JPPerson (JPTest1)

// 关联的key是指针类型（const void *），即需要传一个地址值
// void *：表示“任意类型的指针” 或 表示“该指针与一地址值相关，但是不清楚在此地址上的对象的类型”。

// 指针类型变量初始化存储的值为0x0（空地址的地址值）
// 如果直接使用那都是0x0了，避免重复可以保存自己的地址值，因为地址值是唯一的
// void *XXX --> 声明指针类型变量
const void *JPTestKey = &JPTestKey; // 保存自己的地址值（&XXX --> 获取变量地址）

// 【方式一】：新建一个常量
// 既然只需要地址值当作key，直接用自身地址即可，连赋值都不需要了，毕竟要的不是存储的值
// 使用char类型最好，因为最省内存：指针（void *）在64bit中占8个字节，int占4个字节，char只占1个字节
// 防止外部访问这些key就得加上static关键字，不加的话可以用extern访问到
static const char JPNameKey;
- (void)setName:(NSString *)name {
    NSLog(@"setName %p", &JPNameKey);
    objc_setAssociatedObject(self, &JPNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)name {
    NSLog(@"name %p", &JPNameKey);
    return objc_getAssociatedObject(self, &JPNameKey);
}

// 【方式二】：直接使用字符串
// 直接写出来字符串是放在常量区的，所以同样的字符串内存只占一份
- (void)setWeight:(int)weight {
    NSLog(@"setWeight %p", @"weight");
    objc_setAssociatedObject(self, @"weight", @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int)weight {
    NSLog(@"weight %p", @"weight");
    return [objc_getAssociatedObject(self, @"weight") intValue];
}

// 【方式三】：直接使用属性get方法的地址（也可以是set或其他方法的地址，使用get方法地址是因为可读性更高）
// 【推荐方式】：不需要维护额外的key、可读性高
- (void)setHeight:(int)height {
    NSLog(@"setHeight %p", @selector(height));
    objc_setAssociatedObject(self, @selector(height), @(height), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int)height {
    NSLog(@"height %p", _cmd);
    return [objc_getAssociatedObject(self, _cmd) intValue];
    
    // _cmd <==> @selector(height)
    // 隐式参数：OC的方法默认会隐式传两个参数过来
    // 1：(id)self 方法调用者的指针
    // 2：(SEL)_cmd 方法选择器
}

@end
