//
//  ViewController.m
//  03-内存管理-内存布局
//
//  Created by 周健平 on 2019/12/14.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

/*
 * 内存分布：
 低地址
  - 保留：其他用途，大小由平台决定（32位、64位）
  - 代码段（__TEXT）：编译之后的代码，例如函数
  - 数据段（__DATA）：常量区，比如全局变量、静态变量
   · 字符串常量：例如 NSString *str = @"123";（直接写出来的，不是通过方法创建的那种字符串）
   · 已初始化数据：例如 static int a = 10;（定义就赋值的）
   · 未初始化数据：例如 static int b;（没赋值的）
  - 堆（heap）：通过alloc、malloc、calloc等动态分配的空间（实例对象），分配的内存空间地址【越来越大】
  - 栈（stack）：函数调用开销，比如局部变量，分配的内存空间地址【越来越小】（先进后出）
  - 内核区：系统内核相关的区域，只能系统访问，例如让线程休眠的操作
 高地址
 */

@implementation ViewController

static int a = 10;
static int b;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static int c = 10;
    static int d;
    
    int e = 20;
    int f;
    
    NSString *str1 = @"鸡你太美"; // 直接写出来的，不是通过方法创建的字符串，编译时会生成为【字符串常量】
    NSString *str2 = @"鸡你太美";
    NSString *str3 = [NSString stringWithFormat:@"%@", @"鸡你太美"];
    
    NSObject *obj = [[NSObject alloc] init];
    
    NSLog(@"【常量区】==> 字符串常量");
    NSLog(@"str1 --- %p", str1);
    NSLog(@"str2 --- %p", str2);
    
    NSLog(@"【常量区】==> 已初始化数据");
    NSLog(@"c ------ %p", &c);
    NSLog(@"a ------ %p", &a);
    
    NSLog(@"【常量区】==> 未初始化数据");
    NSLog(@"d ------ %p", &d);
    NSLog(@"b ------ %p", &b);
    
    NSLog(@"【常量区】==> meta class & class");
    NSLog(@"meta class --- %p", object_getClass(NSObject.class));
    NSLog(@"class -------- %p", NSObject.class);
    
    NSLog(@"【堆】==> 实例对象"); // 分配的内存空间地址【越来越大】，不连续的
    NSLog(@"obj ---- %p", obj);
    NSLog(@"str3 --- %p", str3);
    
    NSLog(@"【栈】==> 局部变量"); // 分配的内存空间地址【越来越小】，是连续的，不管有没有初始化都会分配
    NSLog(@"f ------ %p", &f);
    NSLog(@"e ------ %p", &e);
}


@end
