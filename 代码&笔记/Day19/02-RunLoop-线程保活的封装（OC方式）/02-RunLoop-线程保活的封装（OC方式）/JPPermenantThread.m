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
@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) BOOL isStopped;
@end

@implementation JPPermenantThread

#pragma mark - 公开方法

- (instancetype)init {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        self.innerThread = [[JPThread alloc] initWithBlock:^{
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

- (void)run {
    if (!self.innerThread || self.isStarted) return;
    [self.innerThread start];
    self.isStarted = YES;
}

- (void)stop {
    if (!self.innerThread) return;
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

- (void)executeTask:(JPPermenantThreadTask)task {
    if (!self.innerThread || !task) return;
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}

#pragma mark - 私有方法

- (void)__stop {
    self.isStopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)__executeTask:(JPPermenantThreadTask)task {
    task();
}


#pragma mark - 重写父类方法

- (void)dealloc {
    [self stop];
    NSLog(@"%s", __func__);
}

@end
