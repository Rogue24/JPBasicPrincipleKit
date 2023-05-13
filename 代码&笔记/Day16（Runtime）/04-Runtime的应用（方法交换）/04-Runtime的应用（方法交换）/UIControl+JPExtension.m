//
//  UIControl+JPExtension.m
//  04-Runtime的应用（方法交换）
//
//  Created by 周健平 on 2019/11/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "UIControl+JPExtension.h"
#import <objc/runtime.h>

@implementation UIControl (JPExtension)

/**
 * `Method`其实是指向结构体`objc_method`的指针（`struct objc_method *`）
 * 而`struct objc_method`的结构跟`struct method_t`基本是一样的，
 * `method_t`结构体：
 *
        struct method_t {
            SEL name;
            const char *types;
            IMP imp; // 指向函数的指针（函数地址）
        };
 */

/**
 * 方法交换`method_exchangeImplementations`的源码实现：
 *
         void method_exchangeImplementations(Method m1, Method m2)
         {
             if (!m1  ||  !m2) return;

             mutex_locker_t lock(runtimeLock);

             // 交换两个Method的imp指针
             IMP m1_imp = m1->imp;
             m1->imp = m2->imp;
             m2->imp = m1_imp;
              
             // RR/AWZ updates are slow because class is unknown
             // Cache updates are slow because class is unknown
             // fixme build list of classes whose Methods are known externally?

             // 清空方法缓存
             flushCaches(nil);

             updateCustomRR_AWZ(nil, m1);
             updateCustomRR_AWZ(nil, m2);
         }
 */

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /**
         * 方法交换`method_exchangeImplementations`的本质：
         * 两个`method_t`互相交换对方的`imp`指针
         */
        
        // 1. objc_class --> bits/class_rw_t --> methods --> method_list_t --> method_t --> m1、m2
        Method originMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
        Method exchangeMethod = class_getInstanceMethod(self, @selector(jp_sendAction:to:forEvent:));
        // 2. m1、m2 --> method_t --> imp ==> 交换！
        method_exchangeImplementations(originMethod, exchangeMethod);
        
        /**
         * 那以前在缓存`cache_t`里面的`bucket_t`的【imp】咋办？
         * 调用`method_exchangeImplementations`就会清空缓存，之后调用会重新添加到缓存里面（看上面源码实现）
         */
    });
}

- (void)jp_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    NSLog(@"拦截了嘻嘻，看看信息先：\n【func】: %s\n【self】: %@\n【target】: %@\n【action】: %@", __func__, self, target, NSStringFromSelector(action));
    
    // 执行原本的方法
    //【注意】：方法实现（imp）已经交换了，不能用原本的方法名去调用，不然又会来到这里，造成死循环
    [self jp_sendAction:action to:target forEvent:event];
}

@end
