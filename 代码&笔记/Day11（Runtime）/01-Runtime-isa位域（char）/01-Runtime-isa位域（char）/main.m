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
        
        // !!：先转成布尔值，不过是反的，再取反获得正确的布尔值
        // 不然YES时，就是1、2、4之类的数字，而不是0和1的布尔值
        BOOL abc1 = 0b00000101 & 0b00000100;
        NSLog(@"%d", abc1);
        
        BOOL abc2 = !!(0b00000101 & 0b00000100);
        NSLog(@"%d", abc2);
        
    }
    return 0;
}
