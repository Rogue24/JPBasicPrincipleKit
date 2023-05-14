//
//  JPPermenantThread.m
//  02-RunLoop-线程保活的封装
//
//  Created by 周健平 on 2019/12/2.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPermenantThread.h"

@implementation JPThread
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end

@implementation JPPort
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end

@interface JPPermenantThread ()
@property (nonatomic, strong) JPThread *innerThread;
@property (nonatomic, assign) BOOL isStopped;
@end

@implementation JPPermenantThread

#pragma mark - 生命周期

- (instancetype)init {
    if (self = [super init]) {
        self.isStopped = YES;
        
        __weak typeof(self) weakSelf = self;
        self.innerThread = [[JPThread alloc] initWithBlock:^{
            // 添加一个port，用于线程间通信，相当于添加了个Source1，捕获事件给Source0处理（performSelector:onThread:）
            [[NSRunLoop currentRunLoop] addPort:[[JPPort alloc] init] forMode:NSDefaultRunLoopMode];
            while (weakSelf && !weakSelf.isStopped) {
                // 有了Port，启动RunLoop就不会立马退出
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            NSLog(@"RunLoop is done.");
        }];
    }
    return self;
}

- (void)dealloc {
    [self stop];
    NSLog(@"%s", __func__);
}

#pragma mark - 公开方法

- (void)run {
    if (!self.innerThread || !self.isStopped) return;
    self.isStopped = NO;
    [self.innerThread start];
}

- (void)stop {
    if (!self.innerThread) return;
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES]; // waitUntilDone要为YES，确保RunLoop退出了再继续
}

- (void)executeTask:(JPPermenantThreadTask)task {
    if (!self.innerThread || !task) return;
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}

#pragma mark - 私有方法

- (void)__stop {
    // 1.要先修改标识
    self.isStopped = YES;
    // 2.再停止RunLoop，否则可能标识都还没改就已经新循环的判断
    CFRunLoopStop(CFRunLoopGetCurrent());
    // 3.不再使用线程就置为nil
    self.innerThread = nil;
}

- (void)__executeTask:(JPPermenantThreadTask)task {
    task();
}

@end
