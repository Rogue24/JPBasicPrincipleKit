//
//  JPNewPerson.h
//  01-内存管理-MRC
//
//  Created by 周健平 on 2019/12/16.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPCar.h"

@interface JPNewPerson : NSObject
//{
//    JPCar *_car;
//    int _age;
//}
//
//- (void)setCar:(JPCar *)car;
//- (JPCar *)car;
//
//- (void)setAge:(int)age;
//- (int)age;

/*
 * 使用属性（property），编译器会自动生成这个属性对应的成员变量（名字是”_属性名“）、setter和getter方法的声明和实现
 * 根据修饰关键字来确定setter方法的内部实现过程：
    - 如果是assign就直接赋值（不能用来修饰对象类型的属性，因为没有内存管理的操作）
    - 如果是retain就先判断新值是否跟旧值一样，不一样的话先release旧值再retain新值，然后赋值给成员变量
 * 不过在dealloc方法中还是得自己手动去释放这个属性生成的成员变量的内存（对象才需要）
 */
@property (nonatomic, retain) JPCar *car;
@property (nonatomic, assign) int age;

@end

