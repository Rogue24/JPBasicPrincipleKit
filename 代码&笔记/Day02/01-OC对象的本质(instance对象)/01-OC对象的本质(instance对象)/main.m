//
//  main.m
//  02-OC对象的本质
//
//  Created by 周健平 on 2019/10/21.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

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
        
        // instance对象存储的信息包括：
        // 1.isa指针（存放着这个对象的内存地址，始终都排在第一个，其实就是这个对象的内存地址）
        // 2.其他成员变量（isa其实也是成员变量）
        // 只存储成员变量（具体的值），不会存储方法等其他东西
    }
    return 0;
}
