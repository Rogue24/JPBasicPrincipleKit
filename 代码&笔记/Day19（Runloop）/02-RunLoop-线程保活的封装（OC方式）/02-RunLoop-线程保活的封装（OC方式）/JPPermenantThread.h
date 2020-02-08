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

@interface JPPermenantThread : NSObject
- (void)run;
- (void)stop;
- (void)executeTask:(JPPermenantThreadTask)task;
@end
