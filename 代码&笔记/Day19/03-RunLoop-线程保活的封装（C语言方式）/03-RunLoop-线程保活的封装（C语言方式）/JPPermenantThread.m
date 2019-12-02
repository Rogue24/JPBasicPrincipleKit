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

@interface JPPermenantThread ()
@property (nonatomic, strong) JPThread *innerThread;
@property (nonatomic, assign) BOOL isStarted;
@end

@implementation JPPermenantThread

#pragma mark - 公开方法

- (instancetype)init {
    if (self = [super init]) {
        
        self.innerThread = [[JPThread alloc] initWithBlock:^{
            // 创建上下文
            // 注意：没有初始化的局部变量，数据有可能是错乱的，因为当前的栈空间可能是上一个函数剩下的，这样会报错
            // 初始化结构体：{0} --> 初始化里面的成员都为0
            CFRunLoopSourceContext context = {0};
            
            // 创建source
            // 0：不需要考虑顺序
            CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
            
            // 添加source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
            
            // 释放source
            CFRelease(source);
            
            // 启动RunLoop
            // 参数2：seconds --> RunLoop的持续时间（传一个超大的值，1.0e10参考自源码的CFRunLoopRunSpecific函数的调用）
            // 参数3：returnAfterSourceHandled --> 执行完source后函数是否返回（退出当前RunLoop）
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
            // 如果参数3设置为true，执行完一次source后就退出RunLoop，如果要继续使用该线程就得重新启动RunLoop
//            while (weakSelf || !weakSelf.isStopped) {
//                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
//            }
            
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
