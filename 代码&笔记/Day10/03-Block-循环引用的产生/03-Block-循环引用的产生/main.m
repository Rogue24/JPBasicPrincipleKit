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
        
        [per test];
        
        /*
         * 循环引用的产生：
            self --强引用--> block
             ↑_____强引用_____↓
         */
        
        // 即便没有调用过这个block，循环引用还是会发生
        // 因为当【创建】这个block时，block就已经捕获并强引用了self，然后self又强引用block
//        per.block();
        
    }
    NSLog(@"---------finish---------");
    
    NSLog(@"程序执行完，per都没有打印dealloc的信息，说明产生了循环引用！");
    
    return 0;
}
