//
//  main.m
//  02-OC对象的本质
//
//  Created by 周健平 on 2019/10/21.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/*
 * OC对象分3种：
    1.instance对象（实例对象）
    2.class对象（类对象）
    3.meta-class对象（元类对象）
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // 获取类对象
        Class cls = [NSObject class];
        NSLog(@"cls %p", cls);
        
        // 获取元类对象
        // 将类对象当作参数传入可获取元类对象
        Class cls1 = object_getClass(cls); // 如果传入的是实例对象，则获取的是类对象
        NSLog(@"cls1 %p", cls1);
        NSLog(@"cls1 %@", NSStringFromClass(cls1));
        
        // 对【类对象】使用`class`方法可以获取【元类对象】吗？
        // 答：不可以，无论用多少次返回的都是同一个类对象（自己）
        Class cls2 = [cls class];
        NSLog(@"cls2 %p", cls2);
        
        // 每个类在内存中有且只有一个meta-class对象
        
        // meta-class对象和class对象的【内存结构】是一样的，但用途不一样。
        
        // meta-class对象存储的信息包括：
        // isa指针
        // superclass指针
        // 类的类方法信息（class method，带加号那种）
        // ......（其他为空）
        
        // 判断是否为元类对象
        NSLog(@"cls1 %d, cls2 %d", class_isMetaClass(cls1), class_isMetaClass(cls2));
        
        //【object_getClass】函数：return obj->getIsa();
        // 也就是说返回isa指向的内存地址：
        // - 如果传的是instance对象，返回class对象
        // - 如果传的是class对象，返回meta-class对象
        // - 如果传的是meta-class对象，返回NSObject（基类）的meta-class对象
        
        //【objc_getClass】函数：
        // 传入类名字符串，返回对应的Class对象，【不会是meta-class对象】
        
        //【class】函数：
        // 返回对应的Class对象，【不会是meta-class对象】
    }
    return 0;
}
