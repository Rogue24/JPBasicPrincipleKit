//
//  main.m
//  01-super补充
//
//  Created by 周健平 on 2019/11/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        [per run];
    }
    return 0;
}
