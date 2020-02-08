//
//  NSObject+JPExtension.h
//  WoTV
//
//  Created by 周健平 on 2018/7/23.
//  Copyright © 2018 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JPExtension)
+ (void)jp_lookIvars;
- (void)jp_lookIvars;
+ (void)jp_lookMethods;
- (void)jp_lookMethods;
+ (NSString *)jp_className;
- (NSString *)jp_className;
@end
