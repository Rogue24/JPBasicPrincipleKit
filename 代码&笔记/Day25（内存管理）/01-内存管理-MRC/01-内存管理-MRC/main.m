//
//  main.m
//  01-内存管理-MRC
//
//  Created by 周健平 on 2019/12/15.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
#import "JPNewPerson.h"

#warning 当前在MRC环境下！

void autoreleaseTest() {
    /*
     * autorelease方法：
     * 调用了autorelease的对象，会在一个【恰当】的时刻（不再使用对象时）自动去执行一次release操作
     * 这里是在main函数的@autoreleasepool的{}结束后，对【在{}里面调用过autorelease的对象】自动调用一次release
     */
    JPPerson *per = [[[JPPerson alloc] init] autorelease];
    NSLog(@"retainCount -- %zd", per.retainCount);
}

// 在JPPerson的setter方法给dog添加retain操作
// 在dealloc方法给dog添加release操作
void setterTest1() {
    /** 人在狗在 */
    
    JPDog *dog = [[JPDog alloc] init]; // dog.retainCount = 1
    
    JPPerson *per1 = [[JPPerson alloc] init]; // per1.retainCount = 1
    JPPerson *per2 = [[JPPerson alloc] init]; // per2.retainCount = 1
    
    per1.dog = dog; // dog.retainCount = 2
    per2.dog = dog; // dog.retainCount = 3
    
    [dog release]; // dog.retainCount = 2
    
    // release操作后并不是立马就销毁，虽然已经执行了dealloc，但这是一个过程，会慢一点才彻底销毁
    // 有时候CPU的执行的速度比销毁的速度快，就不会崩，所以为了验证问题，弄个循环呗
    for (NSInteger i = 0; i < 5; i++) {
        [per1.dog run];
    }
    
    [per1 release]; // dog.retainCount = 1, per1.retainCount = 0
    
    for (NSInteger i = 0; i < 5; i++) {
        [per2.dog run];
    }
    
    [per2 release]; // dog.retainCount = 0, per2.retainCount = 0
}

// 在JPPerson的setter方法给旧的dog添加release操作
void setterTest2() {
    /** 人在旧狗不在 */
    
    JPDog *dog1 = [[JPDog alloc] init]; // dog1.retainCount = 1
    JPDog *dog2 = [[JPDog alloc] init]; // dog2.retainCount = 1
    
    JPPerson *per = [[JPPerson alloc] init]; // per.retainCount = 1
    
    per.dog = dog1; // dog1.retainCount = 2
    
    for (NSInteger i = 0; i < 5; i++) {
        [per.dog run];
    }
    
    per.dog = dog2; // dog1.retainCount = 1, dog2.retainCount = 2
    
    for (NSInteger i = 0; i < 5; i++) {
        [per.dog run];
    }
    
    [dog1 release]; // dog1.retainCount = 0
    [dog2 release]; // dog2.retainCount = 1
    [per release]; // dog2.retainCount = 0, per.retainCount = 0
}

// 在JPPerson的setter方法加个判断新的dog是不是旧的dog
// 如果是一样的dog并且引用计数是1，就不能执行release后接着执行retain，这样会坏内存访问
// 顺便在dealloc改成self.dog = nil来销毁
// PS：想验证问题就去开启Xcode的【僵尸】模式吧
void setterTest3() {
    /** 人在旧狗不在 */
    
    JPDog *dog = [[JPDog alloc] init]; // dog.retainCount = 1
    
    JPPerson *per = [[JPPerson alloc] init]; // per.retainCount = 1
    per.dog = dog; // dog.retainCount = 2
    
    [dog release]; // dog.retainCount = 1
    
    per.dog = dog; // dog.retainCount = 1
    per.dog = dog; // dog.retainCount = 1
    per.dog = dog; // dog.retainCount = 1
    per.dog = dog; // dog.retainCount = 1
    
    [per release]; // dog.retainCount = 0, per.retainCount = 0
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPNewPerson *per = [[JPNewPerson alloc] init];
        
//        JPCar *car = [[JPCar alloc] init];
//
//        per.car = car;
        
        per.car = [[JPCar alloc] init];
        
        NSLog(@"%zd", per.car.retainCount);
        
//        [car release];
        [per release]; 
    }
    return 0;
}
