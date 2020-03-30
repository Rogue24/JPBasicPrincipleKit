//
//  JPGCDTool.h
//  02-内存管理-GCD定时器
//
//  Created by 周健平 on 2019/12/13.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPGCDTool : NSObject

+ (dispatch_queue_t)getMainQueue;

+ (dispatch_queue_t)getGlobalQueue;

+ (dispatch_queue_t)createSerialQueue:(char *)name;

+ (dispatch_queue_t)createConcurrentQueue:(char *)name;

+ (void)globalQueueSyncExecTask:(void(^)(void))task;

+ (void)globalQueueAsyncExecTask:(void(^)(void))task;

+ (void)mainQueueSyncExecTask:(void(^)(void))task;

+ (void)mainQueueAsyncExecTask:(void(^)(void))task;

+ (void)syncExecTask:(void(^)(void))task onQueue:(dispatch_queue_t)queue;

+ (void)asyncExecTask:(void(^)(void))task onQueue:(dispatch_queue_t)queue;

+ (NSString *)execTask:(void (^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async;

+ (NSString *)execTask:(id)target action:(SEL)action start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async;

+ (void)suspendTask:(NSString *)timerKey;

+ (void)resumeTask:(NSString *)timerKey;

+ (void)cancelTask:(NSString *)timerKey;

@end
