//
//  main.m
//  01-Runtime-isa位域
//
//  Created by 周健平 on 2019/11/7.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        
        NSLog(@"per isTall? %d", per.isTall);
        NSLog(@"per isRich? %d", per.isRich);
        NSLog(@"per isHandsome? %d", per.isHandsome);
        
        per.tall = YES;
        per.rich = YES;
        per.handsome = YES;
        NSLog(@"per isTall? %d", per.isTall);
        NSLog(@"per isRich? %d", per.isRich);
        NSLog(@"per isHandsome? %d", per.isHandsome);
        
        // !!
        // 第一个`!`会自动变成布尔类型的值（0或1），不过是反的；
        // 第二个`!`再取反就能获得正确的布尔值
        BOOL abc1 = !!(0b00000101 & 0b00000100);
        NSLog(@"abc1 = %d", abc1); // 1
        
        // 不使用`!!`的话，为YES时，可能是2、4、8之类的数值，而不是布尔类型的值（0或1）
        BOOL abc2 = 0b00000101 & 0b00000100;
        NSLog(@"abc2 = %d", abc2); // 4
    }
    return 0;
}
