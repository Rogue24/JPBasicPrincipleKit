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
        
        
        NSLog(@"a moment later...");
        per.tall = YES;
        per.rich = YES;
        per.handsome = YES;
        
        NSLog(@"per isTall? %d", per.isTall);
        NSLog(@"per isRich? %d", per.isRich);
        NSLog(@"per isHandsome? %d", per.isHandsome);
    }
    return 0;
}
