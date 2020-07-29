//
//  main.m
//  01-多线程-atomic
//
//  Created by 周健平 on 2019/12/10.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        
        // 只有这两句是保证线程安全（setterg和getter）
        per.mArray = [NSMutableArray array];
        NSMutableArray *mArray = per.mArray;
        
        // 属性的其他使用方法（addObject）不能保证是线程安全的
        [mArray addObject:@"1"];
        [mArray addObject:@"2"];
        [mArray addObject:@"3"];
        
    }
    return 0;
}
