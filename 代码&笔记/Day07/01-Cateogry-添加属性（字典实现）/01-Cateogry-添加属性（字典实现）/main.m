//
//  main.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "JPPerson.h"
#import "JPPerson+JPTest1.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per1 = [[JPPerson alloc] init];
        per1.age = 27;
        per1.weight = 160;
        per1.name = @"shuaigepinng";
        
        JPPerson *per2 = [[JPPerson alloc] init];
        per2.age = 25;
        per2.weight = 105;
        per2.name = @"shadou";
        
        NSLog(@"per1 %d, %d, %@", per1.age, per1.weight, per1.name);
        NSLog(@"per2 %d, %d, %@", per2.age, per2.weight, per2.name);
        
    }
}
