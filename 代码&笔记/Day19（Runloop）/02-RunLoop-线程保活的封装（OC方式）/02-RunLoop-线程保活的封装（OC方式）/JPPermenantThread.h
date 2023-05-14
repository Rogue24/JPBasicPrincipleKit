//
//  JPPermenantThread.h
//  02-RunLoop-线程保活的封装
//
//  Created by 周健平 on 2019/12/2.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPThread : NSThread

@end

@interface JPPort : NSPort

@end

typedef void(^JPPermenantThreadTask)(void);

/**
 * 为什么不直接继承`NSThread`？
 * 这是为了不让外界来控制线程的生命周期和其他对线程的操作（NSThread的`start`和`cancel`方法是公开的），
 * 这些全部交由`JPPermenantThread`内部来管理。
 */
@interface JPPermenantThread : NSObject
- (void)run;
- (void)stop;
- (void)executeTask:(JPPermenantThreadTask)task;
@end
