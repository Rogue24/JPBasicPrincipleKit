//
//  JPPerson+JPTest1.h
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//
//  默认情况下，因为分类底层结构的限制，不能添加成员变量到分类中。
//  但可以通过【关联对象】来间接实现
//  关联对象提供了以下API：
//  1.添加关联对象： void objc_setAssociatedObject(id object, const void * key, id value, objc_AssociationPolicy policy)
//  2.获得关联对象：id objc_getAssociatedObject(id object, const void * key)
//  3.移除所有的关联对象：void objc_removeAssociatedObjects(id object)

#import "JPPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPPerson (JPTest1)
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int weight;
@property (nonatomic, assign) int height;
@property (nonatomic, assign, class) int money;
@end

NS_ASSUME_NONNULL_END
