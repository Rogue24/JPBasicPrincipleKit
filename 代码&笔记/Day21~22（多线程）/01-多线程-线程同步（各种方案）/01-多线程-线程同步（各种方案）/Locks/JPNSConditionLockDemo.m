//
//  JPNSConditionLockDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPNSConditionLockDemo.h"

@interface JPNSConditionLockDemo ()
@property (nonatomic, strong) NSConditionLock *conditionLock;
@property (nonatomic, strong) NSMutableArray *mArray;
@end

@implementation JPNSConditionLockDemo

- (instancetype)init {
    if (self = [super init]) {
        self.conditionLock = [[NSConditionLock alloc] initWithCondition:1]; // 默认是0
        self.mArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 其他：条件🔐演示，可以控制线程执行顺序

- (void)otherTest {
    NSLog(@"-------------开始-------------");
    [[[NSThread alloc] initWithTarget:self selector:@selector(__test1) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(__test2) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(__test3) object:nil] start];
}

/**
 * - (void)lockWhenCondition:(NSInteger)condition;
 * 条件符合就加🔐，否则就等待（休眠）
 * [self.conditionLock lock] ---> 不用判断条件值，只要🔐可以用就加🔐
 *
 * - (void)unlockWithCondition:(NSInteger)condition;
 * 解🔐并修改条件值
 * [self.conditionLock unlock] ---> 直接解🔐
 */

- (void)__test1 {
    // 加🔐
    [self.conditionLock lockWhenCondition:1];
    
    NSLog(@"a线程：Hi");
    sleep(1);
    
    // 解🔐
    [self.conditionLock unlockWithCondition:2];
}

- (void)__test2 {
    // 加🔐
    [self.conditionLock lockWhenCondition:2];
    
    NSLog(@"b线程：Hi");
    sleep(1);
    
    // 解🔐
    [self.conditionLock unlockWithCondition:3];
}

- (void)__test3 {
    // 加🔐
    [self.conditionLock lockWhenCondition:3];
    
    NSLog(@"c线程：Hi");
    sleep(1);
    
    // 解🔐
    [self.conditionLock unlockWithCondition:1];
}

@end
