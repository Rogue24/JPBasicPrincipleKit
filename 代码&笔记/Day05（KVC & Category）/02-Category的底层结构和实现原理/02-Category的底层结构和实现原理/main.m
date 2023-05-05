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
        
        [JPPerson hi];
        
        JPPerson *per = [[JPPerson alloc] init];
        [per run];
        [per eat];
        [per fuck];
        [per sleep];
        
        // Category的方法是通过【runtime】动态合并到`class对象`和`meta-class对象`中
        // - 是在【程序运行过程】中合并的，而不是【编译过程】中合并的
        // 并不是跟KVO那样生成一个子类再通过isa指向这个类去找这些方法
        
        // Category的处理过程：
        // 1.`JPPerson+JPExtension` --编译--> 生成`struct _category_t`
        //  - 此时分类的信息还没有合并到`class对象`和`meta-class对象`中，直到程序开始运行才进行合并。
        // 2.`struct _category_t` --runtime--> 把信息写进`class对象`和`meta-class对象`中
        //  - 核心过程在【JPPerson+JPExtension.m】文件里面有写到。
        
        per.name = @"zhoujianping";
        NSLog(@"%@", per.name);
    }
    return 0;
}
