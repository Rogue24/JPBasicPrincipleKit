//
//  main.m
//  证明StackBlock不会强引用auto变量
//
//  Created by 周健平 on 2020/1/30.
//  Copyright © 2020 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        void (^block)(void);
        
        {
            JPPerson *per = [[JPPerson alloc] init];
            
            block = ^{
                NSLog(@"hi, %@", per);
            };
            block = [block copy];
            
            [per release];
        }
        
        NSLog(@"%@", [block class]);
        
        block();
        [block release];
        
        NSLog(@"GoodBye, World!");
        
        /*
         block不调用copy的情况：
         2023-05-02 02:25:23.967466+0800 xxx[56526:15380258] Hello, World!
         2023-05-02 02:25:23.968630+0800 xxx[56526:15380258] -[JPPerson dealloc]
         2023-05-02 02:25:23.968706+0800 xxx[56526:15380258] __NSStackBlock__
         Thread 1: EXC_BAD_ACCESS (code=1, address=0x3eaddeac0018)
         */
        
        /*
         block调用了copy的情况：
         2023-05-02 02:26:20.693644+0800 xxx[56553:15382056] Hello, World!
         2023-05-02 02:26:20.694615+0800 xxx[56553:15382056] __NSMallocBlock__
         2023-05-02 02:26:20.694811+0800 xxx[56553:15382056] hi, <JPPerson: 0x600000018000>
         2023-05-02 02:26:20.694857+0800 xxx[56553:15382056] -[JPPerson dealloc]
         2023-05-02 02:26:20.694884+0800 xxx[56553:15382056] GoodBye, World!
         */
    }
    return 0;
}
