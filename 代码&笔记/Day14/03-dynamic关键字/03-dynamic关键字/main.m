//
//  main.m
//  01-Runtime-消息转发
//
//  Created by 周健平 on 2019/11/17.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

// 调用方法：消息机制
// 1.当在自己的类对象的缓存和方法列表、以及所有父类的类对象的缓存和方法列表中统统都找不到xxx方法
// 2.也没有在自己类的+(BOOL)resolveXXXMethod里面动态添加方法
// 1 + 2 ==> 说明这个类没有能力去处理这个消息
// ==> 进入【消息转发】阶段：将消息转发给别人

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        per.age = 10;
        per.money = 20;
        per.height = 92;
        
        NSLog(@"per age is %d, money is %d, height is %d", per.age, per.money, per.height);
        
    }
    return 0;
}
