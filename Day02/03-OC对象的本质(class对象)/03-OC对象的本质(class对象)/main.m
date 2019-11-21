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
        Class cls1 = NSObject.class;
        Class cls2 = [NSObject new].class;
        Class cls3 = object_getClass([NSObject new]);
        NSLog(@"%p, %p, %p", cls1, cls2, cls3);
        
        // 每个类在内存中有且只有一个class对象
        
        // class对象存储的信息包括：
        // isa指针
        // superclass指针
        // 类的属性信息（@property）
        // 类的对象方法信息（instance method，带减号那种）
        // 类的协议信息（protocol）
        // 类的成员变量信息（ivar，类型、名称等）
        // ......（其他）
    }
    return 0;
}
