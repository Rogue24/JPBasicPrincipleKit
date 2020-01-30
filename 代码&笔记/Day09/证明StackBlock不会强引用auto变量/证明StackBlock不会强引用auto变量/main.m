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
                NSLog(@"%@", per);
            };
            
            block = [block copy];
            
            [per release];
        }
        
        block();
        [block release];
        
        NSLog(@"GoodBye, World!");
        
        /*
         block不调用copy的情况：
         2020-01-30 02:33:17.500656+0800 xxx[6016:272801] Hello, World!
         2020-01-30 02:33:17.501100+0800 xxx[6016:272801] -[JPPerson dealloc]
         2020-01-30 02:33:18.748698+0800 xxx[6016:272801] <JPPerson: 0x103201c10>
         2020-01-30 02:33:20.055453+0800 xxx[6016:272801] GoodBye, World!
         */
        
        /*
         block调用copy的情况：
         2020-01-30 02:33:40.887758+0800 xxx[6028:273017] Hello, World!
         2020-01-30 02:33:42.124598+0800 xxx[6028:273017] <JPPerson: 0x102405890>
         2020-01-30 02:33:42.124800+0800 xxx[6028:273017] -[JPPerson dealloc]
         2020-01-30 02:33:43.774439+0800 xxx[6028:273017] GoodBye, World!
         */
    }
    return 0;
}
