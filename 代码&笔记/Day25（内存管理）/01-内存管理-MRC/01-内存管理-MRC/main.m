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
// 关闭ARC：Targets --> Build Settings --> 搜索automatic reference --> 设置为NO

#pragma mark - autorelease
void autoreleaseTest(void) {
    /*
     * autorelease方法：
     * 调用了autorelease的对象，会在一个【恰当】的时刻（不再使用对象时）自动去执行一次release操作
     * 这里是在main函数的`@autoreleasepool`的{}结束后，对【在{}里面调用过autorelease的对象】自动调用一次release
     */
    JPPerson *per = [[[JPPerson alloc] init] autorelease];
    NSLog(@"retainCount -- %zd", per.retainCount);
}

// 在JPPerson的setter方法给dog添加retain操作
// 在dealloc方法给dog添加release操作
void setterTest1(void) {
    /** 人在狗在 */
    
    JPDog *dog = [[JPDog alloc] init]; // dog.retainCount = 1
    
    JPPerson *per1 = [[JPPerson alloc] init]; // per1.retainCount = 1
    JPPerson *per2 = [[JPPerson alloc] init]; // per2.retainCount = 1
    
    per1.dog = dog; // dog.retainCount = 2
    per2.dog = dog; // dog.retainCount = 3
    
    [dog release]; // dog.retainCount = 2
    
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
void setterTest2(void) {
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
// 如果是一样的dog并且引用计数是1，就不能先执行release接着执行retain，这样会坏内存访问（dog已经被释放了还执行retain）
// 顺便得在dealloc改成self.dog = nil来销毁
// PS：想验证问题就去开启Xcode的【僵尸】模式和注释setter方法的判断吧（僵尸对象：对已经死掉的对象继续拿来使用）
void setterTest3(void) {
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
        
        setterTest3();
        
        JPPerson *per0 = [[[JPPerson alloc] init] autorelease];
        NSLog(@"per0.retainCount --- %zd", per0.retainCount);
        [per0 release]; // 使用了autorelease的对象就不要过多调用release，这样会提前释放
        // 📢 使用了autorelease的对象，会自动在某个时机去执行一次release操作，
        // 如果在这里提前释放该对象的话，就会在{}结束的时候报错（尝试去释放一个已经释放掉的对象）。
        
        JPNewPerson *per = [[JPNewPerson alloc] init];
        
//        JPCar *car = [[JPCar alloc] init];
//
//        per.car = car;
        
        // per的car属性使用了retain修饰符
        per.car = [[JPCar alloc] init];
        
        NSLog(@"per.car.retainCount --- %zd", per.car.retainCount);
        
        [per.car release];
        
        NSLog(@"per.car.retainCount --- %zd", per.car.retainCount);
        
        [per release];
//        [per retain]; // 来到这里时，per已经被释放掉了，retain会报错
        
        NSLog(@"睡一会先");
        sleep(5);
        NSLog(@"Goodbye, World!");
    }
    NSLog(@"end");
    return 0;
}
