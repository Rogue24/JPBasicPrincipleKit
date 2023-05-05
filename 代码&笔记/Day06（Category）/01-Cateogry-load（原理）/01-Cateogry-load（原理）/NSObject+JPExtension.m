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
    BOOL isMetaClass = class_isMetaClass(self);
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(self.class, &count);
    NSLog(@"=================== %@%@ start ===================", NSStringFromClass(self), isMetaClass ? @"(MetaClass)" : @"");
    for (NSInteger i = 0; i < count; i++) {
        Ivar ivar = ivars[i]; // ivars[i] 等价于 *(ivars+i)，指针挪位
        NSLog(@"%s --- %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    NSLog(@"=================== %@%@ end ===================", NSStringFromClass(self), isMetaClass ? @"(MetaClass)" : @"");
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
    BOOL isMetaClass = class_isMetaClass(self);
    unsigned int count;
    Method *methods = class_copyMethodList(self.class, &count);
    NSLog(@"=================== %@%@ start ===================", NSStringFromClass(self), isMetaClass ? @"(MetaClass)" : @"");
    for (int i = 0; i < count; i++) {
        NSLog(@"%s", sel_getName(method_getName(methods[i])));
    }
    NSLog(@"=================== %@%@ end ===================", NSStringFromClass(self), isMetaClass ? @"(MetaClass)" : @"");
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
