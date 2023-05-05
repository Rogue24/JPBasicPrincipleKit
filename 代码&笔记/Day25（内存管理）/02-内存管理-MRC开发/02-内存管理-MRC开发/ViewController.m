//
//  ViewController.m
//  02-内存管理-MRC开发
//
//  Created by 周健平 on 2019/12/16.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

#warning 当前在MRC环境下！

@interface Dog: NSObject
@end
@implementation Dog
- (void)dealloc {
    NSLog(@"死求");
}
@end

@interface Person: NSObject
@property (atomic, retain) Dog *dog;
@end
@implementation Person
@end

@interface ViewController ()
@property (nonatomic, retain) NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Test~
//    Person *p1 = [[Person alloc] init];
//    Person *p2 = [[Person alloc] init];
//
//    Dog *d = [[Dog alloc] init];
//    NSLog(@"count:%ld", d.retainCount);
//
//    p1.dog = d;
//    NSLog(@"count:%ld", d.retainCount);
//    
//    p2.dog = p1.dog;
//    NSLog(@"count:%ld", d.retainCount);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"count:%ld", d.retainCount);
//        [d release];
//    });
//
//    [p1.dog release];
//    p1.dog = nil;
//    NSLog(@"count:%ld", d.retainCount);
//
//    [p2.dog release];
//    p2.dog = nil;
//    NSLog(@"count:%ld", d.retainCount);
//
//    [p1 release];
//    [p2 release];
    
    
    /*
     * [NSMutableArray array] 内部相当于 [[[NSMutableArray alloc] init] autorelease]
     * 不是通过alloc、new、copy、mutableCopy创建，而是通过系统自带的类方法（工厂方法）创建的对象，一般都是调用过【autorelease】，所以不需要对这种方式创建出来的对象进行release操作
     * 调用了autorelease的对象，会在一个【恰当】的时刻（不再使用对象时）自动去执行一次release操作
     */
    NSMutableArray *dataArray = [NSMutableArray array];
    NSLog(@"%zd", dataArray.retainCount);
    
    self.dataArray = dataArray;
    NSLog(@"%zd", self.dataArray.retainCount);
    
//    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//    NSLog(@"%zd", dataArray.retainCount);
//
//    self.dataArray = dataArray;
//    NSLog(@"%zd", self.dataArray.retainCount);
//
//    // 记得释放一次
//    [dataArray release];
//    NSLog(@"%zd", self.dataArray.retainCount);
}

- (void)dealloc {
    // 记得最后释放一次
    self.dataArray = nil;
    
    NSLog(@"%s", __func__);
    [super dealloc];
}

@end
