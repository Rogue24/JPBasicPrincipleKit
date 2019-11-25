//
//  main.m
//  02-Runtime的应用
//
//  Created by 周健平 on 2019/11/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
#import "JPCar.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>

void eat(id self, SEL _cmd) {
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

/**
 * 1. 修改Class的isa指向
 */
void changedIsa() {
    JPPerson *per = [[JPPerson alloc] init];
    [per run];
    
    // 设置isa指向的Class
    object_setClass(per, JPCar.class);
    [per run];
}

/**
 * 2. 动态创建类
 */
void allocateClassPair() {
    // 动态创建类
    Class JPDog = objc_allocateClassPair(NSObject.class, "JPDog", 0);
    
    // 添加成员变量
    // 注意：成员变量只能在注册（objc_registerClassPair）之前添加，注册之后无法添加
    // 因为成员变量是存储在class_ro_t的结构体里面
    // class_ro_t结构体是只读的，创建（注册类）之后里面的数据都不可修改
    class_addIvar(JPDog, "_height", 4, 1, @encode(int));
    class_addIvar(JPDog, "_weight", 4, 1, @encode(int));
    
    // 注册类
    objc_registerClassPair(JPDog);
    
    // 添加方法
    // 方法是存储在method_array_t结构体里面，可读可写，所以可以在类注册之后继续添加方法
    class_addMethod(JPDog, @selector(eat), (IMP)eat, "v@:");
    
    id dog = [[JPDog alloc] init];
    NSLog(@"%@", dog);
    NSLog(@"%zd", class_getInstanceSize(JPDog));
    NSLog(@"%zd", malloc_size((__bridge const void *)(dog)));

    [dog setValue:@30 forKey:@"_height"];
    [dog setValue:@50 forKey:@"_weight"];
    NSLog(@"%@ %@", [dog valueForKey:@"_height"], [dog valueForKey:@"_weight"]);
    [dog performSelector:@selector(eat)];
    
    // 设置isa指向的Class
    JPPerson *per = [[JPPerson alloc] init];
    object_setClass(per, JPDog);
    [per performSelector:@selector(eat)];
    
    // 在不需要这个类时要释放掉
//    objc_disposeClassPair(JPDog);
}

/**
 * 3. 获取成员变量信息，设置和获取成员变量的值
 */
void instanceVariableTest() {
    // 获取成员变量信息（Ivar ==> InstanceVariable）
    // 成员变量的信息存储在类对象中
    Ivar ageIvar = class_getInstanceVariable(JPPerson.class, "_age");
    NSLog(@"_age 成员变量名字：%s，编码：%s", ivar_getName(ageIvar), ivar_getTypeEncoding(ageIvar));
    
    // 设置和获取成员变量的值
    // 成员变量的值存储在实例对象中
    JPPerson *per = [[JPPerson alloc] init];
    
    object_setIvar(per, ageIvar, (__bridge id)(void *)27);
    // (__bridge id)(void *)27 ==> 数字不能直接转成对象类型，得这样绕弯：
    // 1.(void *)：先将数字转指针类型，因为指针变量就是存储地址值，把这个数字当作地址值存进去
    // 2.(__bridge id)：再将指针转id类型
    NSLog(@"_age 成员变量的值：%d", object_getIvar(per, ageIvar));
    // object_getIvar取出啥就是啥，所以得用%d，不然报错
    
    Ivar nameIvar = class_getInstanceVariable(JPPerson.class, "_name");
    object_setIvar(per, nameIvar, @"shuaigeping");
    NSLog(@"_name 成员变量的值：%@", object_getIvar(per, nameIvar));
}

/**
 * 4. 获取成员变量列表
 */
void getIvarList() {
    unsigned int count; // 成员变量数量
    Ivar *ivars = class_copyIvarList(JPPerson.class, &count);
    for (NSInteger i = 0; i < count; i++) {
        Ivar ivar = ivars[i]; // ivars[i] 等价于 *(ivars+i)，指针挪位
        NSLog(@"%s --- %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    free(ivars); // copy、create出来的都要free掉
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        getIvarList();
    }
    return 0;
}


