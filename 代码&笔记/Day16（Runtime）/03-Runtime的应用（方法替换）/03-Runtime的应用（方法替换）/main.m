//
//  main.m
//  03-Runtime的应用（方法交换）
//
//  Created by 周健平 on 2019/11/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
#import <objc/runtime.h>

void myRun(void) {
    NSLog(@"runing man");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        [per run];
        
        // 动态替换方法（传入方法）
        // myRun是个C语言函数，里面没有self和_cmd这两个隐式参数，所以类型编码只需要写"v"
        class_replaceMethod(JPPerson.class, @selector(run), (IMP)myRun, "v");
        [per run];
        
        // 动态替换方法（用block作为方法实现）
        class_replaceMethod(JPPerson.class, @selector(run), imp_implementationWithBlock(^{
            NSLog(@"runing block");
        }), "v");
        [per run];
    }
    return 0;
}
