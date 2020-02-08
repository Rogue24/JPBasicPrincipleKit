//
//  NSObject+JPExtension.h
//  01-Runloop
//
//  Created by 周健平 on 2019/11/27.
//  Copyright © 2019 周健平. All rights reserved.
//

@class ViewController;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JPExtension)
#warning 会有内存泄漏的隐患，要用哈希字典，以后再优化了，或者用单例对象当作target吧
@property (nonatomic, strong) NSDictionary<NSString *, id> *jp_forwardingTargets;
@end

NS_ASSUME_NONNULL_END
