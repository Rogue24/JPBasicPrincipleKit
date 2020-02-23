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
 * 为什么不直接继承NSThread？
 * 这是为了不让外界来控制线程的生命周期和其他对线程的操作，全部由JPPermenantThread内部来管理。
 */
@interface JPPermenantThread : NSObject
- (void)run;
- (void)stop;
- (void)executeTask:(JPPermenantThreadTask)task;
@end
