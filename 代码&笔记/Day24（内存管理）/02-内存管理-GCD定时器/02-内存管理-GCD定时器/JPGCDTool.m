//
//  JPGCDTool.m
//  02-内存管理-GCD定时器
//
//  Created by 周健平 on 2019/12/13.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPGCDTool.h"

@implementation JPGCDTool

static NSMutableDictionary *timers_ = nil;
static dispatch_semaphore_t semaphore_;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers_ = [NSMutableDictionary dictionary];
        semaphore_ = dispatch_semaphore_create(1);
    });
}

+ (dispatch_queue_t)getMainQueue {
    return dispatch_get_main_queue();
}

+ (dispatch_queue_t)getGlobalQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

+ (dispatch_queue_t)createSerialQueue:(char *)name {
    return dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
}

+ (dispatch_queue_t)createConcurrentQueue:(char *)name {
    return dispatch_queue_create(name, DISPATCH_QUEUE_CONCURRENT);
}

+ (void)globalQueueSyncExecTask:(void(^)(void))task {
    [self syncExecTask:task onQueue:[self getGlobalQueue]];
}

+ (void)globalQueueAsyncExecTask:(void(^)(void))task {
    [self asyncExecTask:task onQueue:[self getGlobalQueue]];
}

+ (void)mainQueueSyncExecTask:(void(^)(void))task {
    if ([NSThread currentThread] == [NSThread mainThread]) {
        NSLog(@"在主线程同步执行主队列的任务会死🔐的啊 哥");
        return;
    }
    [self syncExecTask:task onQueue:[self getMainQueue]];
}

+ (void)mainQueueAsyncExecTask:(void(^)(void))task {
    [self asyncExecTask:task onQueue:[self getMainQueue]];
}

+ (void)syncExecTask:(void(^)(void))task onQueue:(dispatch_queue_t)queue {
    if (!task || !queue) return;
    dispatch_sync(queue, task);
}

+ (void)asyncExecTask:(void(^)(void))task onQueue:(dispatch_queue_t)queue {
    if (!task || !queue) return;
    dispatch_async(queue, task);
}

+ (NSString *)execTask:(id)target action:(SEL)action start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    if (!target || !action || ![target respondsToSelector:action]) {
        return nil;
    }
    return [self execTask:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:action];
#pragma clang diagnostic pop
    } start:start interval:interval repeats:repeats async:async];
}

+ (NSString *)execTask:(void (^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    
    if (!task ||
        start < 0 ||
        (interval <= 0 && repeats)) return nil;
    
    // 设置队列
    dispatch_queue_t queue = async ? [self getGlobalQueue] : [self getMainQueue];
        
    // 创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    static int timerKeyIndex_ = 0;
    // 不建议用timers_.count，不安全，有可能会覆盖掉已经存在的timer
    // 例如，timer_[0] = timer0，timer_[1] = timer1
    // 然后取消timer0并移除，这时timers_.count变为1
    // 接着添加新的timer2，但key为1，这样就会覆盖掉timer1，timer1就无法取消了。
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    NSString *timerKey = [NSString stringWithFormat:@"%d", timerKeyIndex_];
    timerKeyIndex_ += 1;
    timers_[timerKey] = timer;
    dispatch_semaphore_signal(semaphore_);
    
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC),
                              interval * NSEC_PER_SEC,
                              0);
    
    if (repeats) {
        dispatch_source_set_event_handler(timer, task);
    } else {
        dispatch_source_set_event_handler(timer, ^{
            task();
            if (!repeats) [self cancelTask:timerKey];
        });
    }
    
    // 启动定时器
    dispatch_resume(timer);
    
    return timerKey;
}

+ (void)cancelTask:(NSString *)timerKey {
    if (!timerKey.length) return;
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    
    dispatch_source_t timer = timers_[timerKey];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers_ removeObjectForKey:timerKey];
    }
    
    dispatch_semaphore_signal(semaphore_);
}

@end
