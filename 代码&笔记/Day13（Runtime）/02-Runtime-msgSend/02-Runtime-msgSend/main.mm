//
//  main.m
//  01-class和meta-class的结构（查看缓存）
//
//  Created by 周健平 on 2019/11/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
#import "JPStudent.h"
#import "MJClassInfo_New.h"
#import <objc/runtime.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // sel_registerName：传入一个C语言字符串返回一个SEL
        // 所有名字一样的选择器(SEL)的地址都是同一个，不同类中相同名字的方法，所对应的方法选择器(SEL)是相同的
//        NSLog(@"%p %p %p", @selector(personTest), @selector(personTest), sel_registerName("personTest"));
        
        /*
         * objc_msgSend(per, sel_registerName("personTest");
         * OC的方法调用：消息机制，给方法调用者发送消息
         * 消息接收者（receiver）：per
         * 消息名称：personTest
         *
         * objc_msgSend如果找不到合适的方法进行调用，就会报错：
            - unrecognized selector sent to instance
         */
        
        JPStudent *stu = [[JPStudent alloc] init];
        [stu personTest111];
        [stu personTest222];
        
        JPPerson *per = [[JPPerson alloc] init];
        [per personTest111];
        [per personTest222];
        
        [JPPerson personTest333];
    }
    return 0;
}
