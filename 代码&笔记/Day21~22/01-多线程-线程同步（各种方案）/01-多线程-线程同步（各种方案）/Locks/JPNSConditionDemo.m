//
//  JPNSConditionDemo.m
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPNSConditionDemo.h"

@interface JPNSConditionDemo ()
@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSMutableArray *mArray;
@end

@implementation JPNSConditionDemo

- (instancetype)init {
    if (self = [super init]) {
        self.condition = [[NSCondition alloc] init];
        self.mArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 其他：条件🔐演示

- (void)otherTest {
    NSLog(@"-------------开始-------------");
    [[[NSThread alloc] initWithTarget:self selector:@selector(__removeObj) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(__hi) object:nil] start];
    
    sleep(1);
    [[[NSThread alloc] initWithTarget:self selector:@selector(__addObj) object:nil] start];
}

- (void)__removeObj {
    // 加🔐
    [self.condition lock];
    
    NSLog(@"a线程：打算删除元素");
    
    if (self.mArray.count == 0) {
        NSLog(@"a线程：条件不成立，让当前线程休眠，并且解🔐");
        [self.condition wait];
        NSLog(@"a线程：条件已经成立，唤醒当前线程，重新加🔐");
    }
    
    [self.mArray removeLastObject];
    NSLog(@"a线程：删除了元素");
    
    // 解🔐
    [self.condition unlock];
}

- (void)__hi {
    // 加🔐
    [self.condition lock];
    
    NSLog(@"aa线程：打算say个hi");
    
    if (self.mArray.count == 0) {
        NSLog(@"aa线程：条件不成立，让当前线程休眠，并且解🔐");
        [self.condition wait];
        NSLog(@"aa线程：条件已经成立，唤醒当前线程，重新加🔐");
    }
    
    NSLog(@"aa线程：hi");
    
    // 解🔐
    [self.condition unlock];
}

- (void)__addObj {
    // 加🔐
    [self.condition lock];
    
    NSLog(@"b线程：准备添加元素");
    sleep(3);
    
    [self.mArray addObject:@"baby"];
    NSLog(@"b线程：添加了元素");
    
    NSLog(@"b线程：发送信号/广播，告诉【使用着这个条件并等待着的线程】条件成立了，不过要先解了当前这个🔐");
    
    // 信号（唤醒一条【使用着这个条件并等待着的线程】）
    // PS：如果有多条，只会唤醒排在最前等待的那一条线程，其他的线程会继续休眠，所以有多少条等待的线程就得唤醒多少次，或者直接广播
//    [self.condition signal];
//    [self.condition signal];
    
    // 广播（唤醒所有【使用着这个条件并等待着的线程】）
    [self.condition broadcast];
    
    // 解🔐
    [self.condition unlock];
}

@end
