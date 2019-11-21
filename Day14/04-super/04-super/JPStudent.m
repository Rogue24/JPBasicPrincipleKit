//
//  JPStudent.m
//  04-super
//
//  Created by 周健平 on 2019/11/20.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPStudent.h"
#import <objc/runtime.h>

@implementation JPStudent

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"%@ [self class] %@", self, [self class]); // JPStudent
        NSLog(@"%@ [self superclass] %@", self, [self superclass]); // JPPerson
        NSLog(@"--------------------");
        NSLog(@"%@ [super class] %@", self, [super class]); // JPStudent
        NSLog(@"%@ [super superclass] %@", self, [super superclass]); // JPPerson
    }
    return self;
}

- (void)run {
    [super run];
}

struct objc_super {
    /// Specifies an instance of a class.
    __unsafe_unretained _Nonnull id receiver;

    /// Specifies the particular superclass of the instance to message.
#if !defined(__cplusplus)  &&  !__OBJC2__
    /* For compatibility with old objc-runtime.h header */
    __unsafe_unretained _Nonnull Class class;
#else
    __unsafe_unretained _Nonnull Class super_class;
#endif
    /* super_class is the first class to search */
};

- (void)a {
// 编译成C++的代码：
//static void _I_JPStudent_run(JPStudent * self, SEL _cmd) {
//    ((void (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("JPStudent"))}, sel_registerName("run"));
    
    // ↓↓↓↓↓
    // struct __rw_objc_super ==在OC源码中为==> struct objc_super
//    struct __rw_objc_super arg = {
    struct objc_super arg = {
        self,
        class_getSuperclass(objc_getClass("JPStudent"))
    };
    
    objc_msgSendSuper(arg, @selector(run));
    objc_msgSendSuper(arg, @selector(run));
//}
}

@end
