//
//  JPPerson.h
//  03-内存管理-内存布局
//
//  Created by 周健平 on 2020/6/10.
//  Copyright © 2020 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPPerson : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickname;
@end

NS_ASSUME_NONNULL_END
