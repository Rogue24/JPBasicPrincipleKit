//
//  JPPerson.h
//  01-多线程-atomic
//
//  Created by 周健平 on 2019/12/10.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * atom：原子，不可再分割的单位
 * atomic：原子性，不可分割的操作（一般用在mac系统）
 * nonatomic：非原子性
 
 * 给属性加上atomic修饰，可以保证属性的setterg和getter都是原子性操作
 * 也就是保证setterg和getter【内部】都是线程同步的（原子性，当作一个原子，内部临界区无法切割）
 * 例如：
     - (void)setName:(NSString *)name {
         // 加🔐
         // 临界区（加锁的代码）
         // 解🔐
     }
     - (NSString *)name {
         // 加🔐
         // 临界区（加锁的代码）
         // 解🔐
     }
 
 * 并不能保证使用属性的【过程】是线程安全的
 * 例如：
     JPPerson *per = [[JPPerson alloc] init];
 
     // 只有这两句是保证线程安全（setterg和getter）
     per.mArray = [NSMutableArray array];
     NSMutableArray *mArray = per.mArray;
 
     // 属性的其他使用方法（addObject）不能保证是线程安全的
     [mArray addObject:@"1"];
     [mArray addObject:@"2"];
     [mArray addObject:@"3"];
 
 *【iOS上why很少用？--- 因为性能消耗大，而且没必要每次setterg或getter都加🔐】
 */

@interface JPPerson : NSObject
@property (nonatomic, assign) int age;
@property (atomic, copy) NSString *name;
@property (atomic, strong) NSMutableArray *mArray;
@end
