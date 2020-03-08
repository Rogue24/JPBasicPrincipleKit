//
//  JPProxy.h
//  03-内存管理-定时器
//
//  Created by 周健平 on 2019/12/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * NSProxy --- 跟NSObject同一级别，不继承任何类，也是个基类
 * 在消息转发方面会比NSObject效率高，专门用来做消息转发的。
 *
 * 调用方法时，会先查找自己有没这个方法：
 * 如果是NSProxy的子类的子类，接着会到父类里面找该方法，又找不到再去往上的父类找，直到父类是NSProxy还是没有的话：
 * 就会【直接跳过】以下过程：
    1. 去父类寻找方法（本来NSProxy自身也没其他方法了）----> 不查找方法列表
    2. 动态方法解析阶段 ----> 不进行动态解析
    3. 消息转发的第一步【forwardingTargetForSelector】----> 不转发消息
 * 直接来到消息转发的第二步，执行【methodSignatureForSelector】----> 有返回值再执行【forwardInvocation】
 * 注意：只重写methodSignatureForSelector不重写forwardInvocation还是会崩溃。
 */

// 验证一下【NSProxy的子类的子类】会不会执行父类的方法 ---- 会，自己没重写的话会去执行自己父类的方法。
// 说明：父类还不是NSProxy时还是会去父类的方法列表查找方法。
@interface JPProxy2 : NSProxy
@property (nonatomic, weak) id target;
@end

@interface JPProxy : JPProxy2
+ (instancetype)proxyWithTarget:(id)target;
@end
