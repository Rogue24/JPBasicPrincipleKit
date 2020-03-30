//
//  NSObject+JPExtension.m
//  WoTV
//
//  Created by 周健平 on 2018/7/23.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import "NSObject+JPExtension.h"
#import <objc/runtime.h>

@implementation NSObject (JPExtension)

+ (void)jp_lookIvars {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(self.class, &count);
    NSLog(@"=================== %@ start ===================", NSStringFromClass(self));
    for (NSInteger i = 0; i < count; i++) {
        Ivar ivar = ivars[i]; // ivars[i] 等价于 *(ivars+i)，指针挪位
        NSLog(@"%s --- %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    NSLog(@"=================== %@ end ===================", NSStringFromClass(self));
    free(ivars);
    
    /**
     * d <--> double
     * f <--> float
     * i <--> int
     * q <--> long
     * Q <--> long long
     * B <--> bool
     */
}

- (void)jp_lookIvars {
    [self.class jp_lookIvars];
}

+ (void)jp_lookMethods {
    unsigned int count;
    Method *methods = class_copyMethodList(self.class, &count);
    NSLog(@"=================== %@ start ===================", NSStringFromClass(self));
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        char retType[512] = {};
        method_getReturnType(method, retType, 512);
        NSLog(@"%s -> %s", sel_getName(method_getName(method)), retType);
    }
    NSLog(@"=================== %@ end ===================", NSStringFromClass(self));
    free(methods);
}

- (void)jp_lookMethods {
    [self.class jp_lookMethods];
}

+ (NSString *)jp_className {
    return NSStringFromClass(self);
}

- (NSString *)jp_className {
    return NSStringFromClass(self.class);
}

@end
