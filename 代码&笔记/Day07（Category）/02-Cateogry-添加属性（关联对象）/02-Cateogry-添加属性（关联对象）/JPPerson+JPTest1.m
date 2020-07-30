//
//  JPPerson+JPTest1.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson+JPTest1.h"
#import <objc/runtime.h>

@implementation JPPerson (JPTest1)

// 关联的key是指针类型（const void *），即需要传一个地址值
// void *：表示“任意类型的指针” 或 表示“该指针与一地址值相关，但是不清楚在此地址上的对象的类型”，类似于id。

// 指针类型变量初始化【存储的值】为NULL（即0x0，空地址的地址值）
// 如果直接使用那都是0x0了，避免重复可以保存自己的地址值，因为地址值是唯一的
// void *XXX --> 声明指针类型变量
// PS：用extern访问到这个全局变量
const void *JPTestKey = &JPTestKey; // 保存自己的地址值（&XXX --> 获取变量地址）

//【方式一】：新建一个常量
// 因为是全局的，所以会一直存在，并且内存地址是唯一的。
// 既然内存地址是唯一的，那直接用【自身地址】当作key即可，连赋值都不需要了（要的只是地址而不是内容，不需要赋值）。
// 既然不用赋值，那就用【最省内存】的数据类型，所以char类型最好。
// PS1：指针（void *）在64bit中占8个字节，int占4个字节，char只占1个字节
// PS2：加上static关键字可以防止外部通过extern访问到这个全局变量，只能本文件内可以访问
static const char JPNameKey;
- (void)setName:(NSString *)name {
    NSLog(@"setName %p", &JPNameKey);
    objc_setAssociatedObject(self, &JPNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)name {
    NSLog(@"name %p", &JPNameKey);
    return objc_getAssociatedObject(self, &JPNameKey);
}

//【方式二】：直接使用字符串
// 直接写出来字符串是放在常量区（代码区）的，所以内存地址是唯一的，同样的字符串内存只占一份
- (void)setWeight:(int)weight {
    NSLog(@"setWeight %p", @"weight");
    objc_setAssociatedObject(self, @"weight", @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int)weight {
    NSLog(@"weight %p", @"weight");
    return [objc_getAssociatedObject(self, @"weight") intValue];
}

//【方式三】：直接使用属性get方法的地址（也可以是set或其他方法的地址，使用get方法地址是因为可读性更高）
// 方法的地址也是放在常量区（代码区）的，所以内存地址是唯一的
//【!推荐!】：不需要维护额外的key、可读性高
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
