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
@property (nonatomic, assign) BOOL isStopped;
@end

@implementation JPPermenantThread

#pragma mark - 生命周期

- (instancetype)init {
    if (self = [super init]) {
        self.isStopped = YES;
        
        self.innerThread = [[JPThread alloc] initWithBlock:^{
            
            // 1.创建上下文
            //【注意】：没有初始化的局部变量，数据有可能是错乱的，因为当前的栈空间有可能是上一个函数剩下的，如果不初始化会报错。
            CFRunLoopSourceContext context = {0}; // 初始化结构体：{0} --> 初始化里面的成员都为0
            
            // 2.创建source
            // 参数2 order：0，代表不需要考虑顺序
            CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
            
            // 3.添加source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
            
            // 4.释放source
            CFRelease(source);
            
            // 5.启动RunLoop
            // 参数2 seconds：1.0e10，代表RunLoop的持续时间
            // 参数3 returnAfterSourceHandled：false，代表处理完source后函数【不】返回（不退出当前RunLoop）
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
            /*
             * 参数2：1.0e10是一个超大的值，参考自源码的CFRunLoopRunSpecific函数中的调用
             *
             * 参数3：如果设置为true，代表处理完source后就会退出RunLoop，
             * 这时想要继续使用该线程就得跟之前那样套个循环来重新启动RunLoop：
                 while (weakSelf || !weakSelf.isStopped) {
                     CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
                 }
             * 由此可见，C语言的方式对比OC的方式会更加精简，不需要手动添加循环，只要设置参数3为【false】即可，
             * 并且只需要调用`CFRunLoopStop(CFRunLoopGetCurrent())`就可以彻底停止和退出RunLoop，
             * 不需要再依赖和维护isStopped了（现在只是用来防止重复start）。
             */
            
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
