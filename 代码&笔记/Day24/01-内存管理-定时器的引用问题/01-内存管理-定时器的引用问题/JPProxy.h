//
//  JPProxy.h
//  03-内存管理-定时器
//
//  Created by 周健平 on 2019/12/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * NSProxy --- 跟NSObject同一级别，不继承任何类，也是个基类
 * 在消息转发方面会比NSObject效率高，专门用来做消息转发的
 *
 * 调用方法时，在缓存和自身找不到方法时：
 * 如果不是直接继承NSProxy，会先到父类找该方法，直到父类是NSProxy还是没有的话：
 * 就会【跳过】以下过程：
    1. 去父类寻找方法（本来NSProxy自身也没其他方法了）
    2. 动态方法解析阶段
    3. 消息转发的第一步【forwardingTargetForSelector】
 * 直接来到消息转发的第二步，执行【methodSignatureForSelector】---- 有返回值再执行【forwardInvocation】
 */

// 验证一下NSProxy的子类并不会跳过中间的父类
@interface JPProxy2 : NSProxy
+ (instancetype)proxyWithTarget:(id)target;
@property (nonatomic, weak) id target;
@end

@interface JPProxy : JPProxy2

@end
