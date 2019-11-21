//
//  JPPerson.m
//  03-Block-循环引用
//
//  Created by 周健平 on 2019/11/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

- (void)dealloc {
    NSLog(@"%p %s", self, __func__);
}

- (void)test {
    __weak typeof(self) weakSelf = self;
    self.block = ^{
        NSLog(@"+ %d", weakSelf.age);
    };
    self.block();
}

/*
 
 循环引用：
 self --强引用--> block
  ↑_____强引用_____↓
 
 // 查看编译的C++代码中的block的结构体：
 struct __JPPerson__test_block_impl_0 {
   struct __block_impl impl;
   struct __JPPerson__test_block_desc_0* Desc;
 
   // 有一个strong引用的成员变量self
   // self是指向对象自己的指针，是方法里面的隐式参数，同时也是一个局部变量，所以能被block捕获
   JPPerson *const __strong self;
   
   __JPPerson__test_block_impl_0(void *fp, struct __JPPerson__test_block_desc_0 *desc, JPPerson *const __strong _self, int flags=0) : self(_self) {
     impl.isa = &_NSConcreteStackBlock;
     impl.Flags = flags;
     impl.FuncPtr = fp;
     Desc = desc;
   }
 };
 */

@end
