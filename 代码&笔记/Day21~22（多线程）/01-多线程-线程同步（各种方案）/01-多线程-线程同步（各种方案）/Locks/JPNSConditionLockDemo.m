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
        self.conditionLock = [[NSConditionLock alloc] initWithCondition:1]; // 初始化条件值（默认是0）
        self.mArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 其他：条件🔐演示，可以【控制线程执行顺序】

- (void)otherTest {
    NSLog(@"-------------开始-------------");
    // 实现按顺序执行：__test1 -> __test2 -> __test3
    [[[NSThread alloc] initWithTarget:self selector:@selector(__test3) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(__test2) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(__test1) object:nil] start];
}

/**
 * 有🔐可以用并且【条件值符合】就加🔐，否则就等待（休眠）：
 * `- (void)lockWhenCondition:(NSInteger)condition;`
 *
 * 解🔐并修改条件值（唤醒下一个【条件值符合】并且等待着的线程）：
 * `- (void)unlockWithCondition:(NSInteger)condition;`
 *
 * `[self.conditionLock lock]` ==> 不用判断条件值，只要有🔐可以用就加🔐
 * `[self.conditionLock unlock]` ==> 不修改条件值，直接解🔐
 *
 * 📢 注意：
 * 如果🔐已经被某个任务占用了，此时有两处地方正在等待，它们的加锁方式分别是：
 *  1. `[self.conditionLock lockWhenCondition:8];`
 *  2. `[self.conditionLock lock]`
 * 过了一会，刚刚那任务完成了，解🔐并且修改条件值：
 * `[self.conditionLock unlockWithCondition:8];`
 * 虽然条件值跟1一样，但这时候能用这个🔐的不一定是1，也不一定是2，都有可能，
 * 这取决于系统，我想应该是等待比较靠前的那个线程。
 */

- (void)__test1 {
    // 加🔐
    [self.conditionLock lockWhenCondition:1];
    
    NSLog(@"__test1线程：Hi");
    sleep(1);
    
    // 解🔐
    [self.conditionLock unlockWithCondition:2];
}

- (void)__test2 {
    // 加🔐
    [self.conditionLock lockWhenCondition:2];
    
    NSLog(@"__test2线程：Hi");
    sleep(1);
    
    // 解🔐
    [self.conditionLock unlockWithCondition:3];
}

- (void)__test3 {
    // 加🔐
    [self.conditionLock lockWhenCondition:3];
    
    NSLog(@"__test3线程：Hi");
    sleep(1);
    
    // 解🔐
    [self.conditionLock unlockWithCondition:1];
}

@end
