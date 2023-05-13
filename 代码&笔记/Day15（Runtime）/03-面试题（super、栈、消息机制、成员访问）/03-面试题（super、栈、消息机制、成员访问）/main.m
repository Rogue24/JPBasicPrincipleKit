//
//  main.m
//  02-面试题（print）
//
//  Created by 周健平 on 2019/11/23.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

void test(void) {
    long long a = 1; // 0x7ffedfd3eaa8
    long long b = 2; // 0x7ffedfd3eaa0
    long long c = 3; // 0x7ffedfd3ea98
    long long d = 4; // 0x7ffedfd3ea90
    NSLog(@"局部变量分配在栈空间，地址是从高地址到低地址分配：%p, %p, %p, %p", &a, &b, &c, &d);
}

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        
        test();
        
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
