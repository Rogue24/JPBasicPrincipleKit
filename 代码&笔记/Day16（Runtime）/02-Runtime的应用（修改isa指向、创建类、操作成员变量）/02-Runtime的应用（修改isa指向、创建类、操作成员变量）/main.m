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

#pragma mark - 1. 修改Class的isa指向
void changedIsa(void) {
    JPPerson *per = [[JPPerson alloc] init];
    [per run];
    
    // 设置isa指向的Class
    object_setClass(per, JPCar.class);
    [per run];
}

#pragma mark - 2. 动态创建类
void allocateClassPair(void) {
    // 动态创建类（Pair，创建一对，也就是类对象和元类对象）
    Class JPDog = objc_allocateClassPair(NSObject.class, "JPDog", 0);
    // 最后一个参数是需要给这个类额外扩充多少内存空间，一般写0即可
    
    // 添加成员变量（只能在类注册之前添加）
    // 注意：成员变量只能在注册（objc_registerClassPair）之前添加，注册之后无法添加
    // 因为成员变量是存储在`class_ro_t`结构体里面，而`class_ro_t`是个【只读】表（ro：read-only）
    // 所以注册类之后这个表里面的数据（成员变量列表）就不可以再修改
    class_addIvar(JPDog, "_height", 4, 1, @encode(int));
    class_addIvar(JPDog, "_weight", 4, 1, @encode(int));
    // 参数依次为：添加到哪个类、成员变量名字、占用多少字节、内存对齐的最小字节（最好写1，不然会占很大内存）、类型编码
    
    // 注册类
    objc_registerClassPair(JPDog);
    
    // 添加方法（随时都可以添加）
    // 方法是存储在`method_array_t`结构体里面，这是个【可读可写】表，所以可以在类注册之后继续添加方法
    class_addMethod(JPDog, @selector(eat), (IMP)eat, "v@:");
    
    // 创建+注册后才能够使用新类
    id dog = [[JPDog alloc] init];
    NSLog(@"%@", dog);
    NSLog(@"InstanceSize: %zd", class_getInstanceSize(JPDog));
    NSLog(@"mallocSize: %zd", malloc_size((__bridge const void *)(dog)));

    [dog setValue:@30 forKey:@"_height"];
    [dog setValue:@50 forKey:@"_weight"];
    NSLog(@"_height: %@, _weight: %@", [dog valueForKey:@"_height"], [dog valueForKey:@"_weight"]);
    [dog performSelector:@selector(eat)];
    
    // 设置isa指向的Class
    JPPerson *per = [[JPPerson alloc] init];
    object_setClass(per, JPDog);
    [per performSelector:@selector(eat)];
    
    // 在不需要这个类时要释放掉
//    objc_disposeClassPair(JPDog);
}

#pragma mark - 3. 获取成员变量信息，设置和获取成员变量的值
void instanceVariableTest(void) {
    // 成员变量的信息存储在类对象中
    Class cls = [JPPerson class];
    
    //【1】class_getInstanceVariable 获取成员变量的信息
    Ivar ageIvar = class_getInstanceVariable(cls, "_age");
    
    //【2】ivar_getName 获取成员变量的名字
    const char *name = ivar_getName(ageIvar);
    NSLog(@"成员变量“_age”的名字：%s", name);
    
    //【3】ivar_getTypeEncoding 获取成员变量的类型编码
    const char *typeEncod = ivar_getTypeEncoding(ageIvar);
    NSLog(@"成员变量“_age”的类型编码：%s", typeEncod);
    
    // 成员变量的值存储在实例对象中
    JPPerson *per = [[JPPerson alloc] init];
    
    //【4】object_setIvar 设置成员变量的值
    object_setIvar(per, ageIvar, (__bridge id)(void *)27);
    // 设置基本数据类型的注意点：
    // runtime的底层函数不能使用`NSNumber`进行赋值，内部不会帮你自动转换，最终设置成乱码
    //【该是什么类型就得是什么类型】，也就是不能使用`@27`，得传入的是`指向这个数的指针`（id类型）
    // 基本数据类型不能直接转成id类型，得这样绕弯 ==> (__bridge id)(void *)27 ==> 数字转指针
    // 1.(void *)：将这个数转成一个指针
    //  - 为啥能转？因为指针变量就是存储地址值的，那就把这个数当作【地址值】存进去
    // 2.(__bridge id)：再将指针转id类型
    //  - `void *`和`id`可以互相转换
    //【KVC】之所以可以使用`NSNumber`进行赋值，那是因为内部会自动将`NSNumber`里面包装的值取出来 --> [@27 intValue]
    
    //【5】object_getIvar 获取成员变量的值
    int age = (int)object_getIvar(per, ageIvar);
    NSLog(@"成员变量“_age”的值：%d", age);
    
    Ivar nameIvar = class_getInstanceVariable(JPPerson.class, "_name");
    object_setIvar(per, nameIvar, @"shuaigeping");
    NSLog(@"成员变量“_name”的值：%@", object_getIvar(per, nameIvar));
}

#pragma mark - 4. 获取成员变量列表
void getIvarList(void) {
    unsigned int count; // 成员变量数量
    Ivar *ivars = class_copyIvarList(JPPerson.class, &count);
    for (NSInteger i = 0; i < count; i++) {
        Ivar ivar = ivars[i]; // ivars[i] 等价于 *(ivars+i)，指针挪位
        NSLog(@"%s --- %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    free(ivars); // runtime函数中，通过copy、create出来的东西都要free掉（需要手动内存管理）
}

#pragma mark - main
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSLog(@"============ 修改Class的isa指向 ============");
        changedIsa();
        
        NSLog(@"============ 动态创建类 ============");
        allocateClassPair();
        
        NSLog(@"============ 获取成员变量信息，设置和获取成员变量的值 ============");
        instanceVariableTest();
        
        NSLog(@"============ 获取成员变量列表 ============");
        getIvarList();
    }
    return 0;
}
