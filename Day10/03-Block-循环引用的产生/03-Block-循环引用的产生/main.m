//
//  main.m
//  03-Block-循环引用
//
//  Created by 周健平 on 2019/11/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        per.age = 11;
        
//        per.block = ^{
//            NSLog(@"~ %d", per.age);
//        };
//        per.block();
        
        [per test];
        
        /*
         * 循环引用的产生：
            self --强引用--> block
             ↑_____强引用_____↓
         */
        
    }
    NSLog(@"---------finish---------");
    return 0;
}
