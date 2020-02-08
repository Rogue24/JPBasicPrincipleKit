//
//  main.m
//  02-Category
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
#import "JPPerson+JPExtension.h"
#import "JPPerson+JPOther.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        [per run];
        [per eat];
        [per fuck];
        [per sleep];
        
        // 分类的方法是通过runtime动态合并到class对象和meta-class对象中
        // 并不是跟KVO那样生成一个子类再通过isa指向这个类去找这些方法
        
        per.name = @"zhoujianping";
        NSLog(@"%@", per.name);
    }
    return 0;
}
