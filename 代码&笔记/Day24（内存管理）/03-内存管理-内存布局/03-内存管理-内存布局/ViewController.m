//
//  ViewController.m
//  03-内存管理-内存布局
//
//  Created by 周健平 on 2019/12/14.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "JPPerson.h"
#import "JPDog.h"

@interface ViewController ()

@end

/*
 * 内存分布：
 低地址
  - 保留：其他用途，大小由平台决定（32位、64位）
  - 代码段（__TEXT）：编译之后的代码，例如函数
  - 数据段（__DATA）：比如全局变量、静态变量
    - 常量区
        · 字符串常量：例如 NSString *str = @"123";（直接写出来的，不是通过方法创建的那种字符串）
    - 静态区/全局区
        · 已初始化数据：例如 static int a = 10;（定义就赋值的）
        · 未初始化数据：例如 static int b;（没赋值的）
  - 堆（heap）：通过alloc、malloc、calloc等动态分配的空间（实例对象），分配的内存空间地址【越来越大】
  - 栈（stack）：函数调用开销，比如局部变量，分配的内存空间地址【越来越小】（先进后出）
  - 内核区：系统内核相关的区域，只能系统访问，例如让线程休眠的操作
 高地址
 */

@implementation ViewController

static int const aa = 100;

//【外面】定义的静态变量的地址会比【函数内】定义的静态变量的地址【高】
// 有可能是因为函数所在的【代码段】的地址比【数据段】的地址【低】，先编译函数里面的，之后才轮到外面的。
static int a = 10;
static int b;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    IMP imp = method_getImplementation(class_getInstanceMethod(self.class, @selector(viewDidLoad)));
    NSLog(@"【代码段】==> 编译之后的函数");
    NSLog(@"imp --- %p", imp);
    
    NSLog(@"【数据段/常量区】");
    NSLog(@"aa --- %p", &aa);
    
    static int c = 10;
    static int d;
    
    int e = 20;
    int f;
    
    NSString *str1 = @"鸡你太美"; // 直接写出来的，不是通过方法创建的字符串，编译时会生成为【字符串常量】
    NSString *str2 = @"鸡你太美";
    NSString *str22 = @"鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美鸡你太美"; // 直接写出来的，无论多长，编译时都会生成为【字符串常量】
    NSString *str3 = [NSString stringWithFormat:@"%@", @"鸡你太美"]; // 通过方法创建的，并且超出8字节范围的字符串，会生成【实例对象】
    
    NSObject *obj = [[NSObject alloc] init];
    Class objCls = obj.class;
    Class objMCls = object_getClass(objCls);
    
    JPPerson *per0 = [[JPPerson alloc] init];
    Class perCls = per0.class;
    Class perMCls = object_getClass(perCls);
    
//    JPDog *dog = [[JPDog alloc] init];
//    Class dogCls = dog.class;
//    Class dogMCls = object_getClass(dogCls);
//    NSLog(@"dogMCls -------- %p", dogMCls);
//    NSLog(@"dogCls --- %p", dogCls);
    
    NSLog(@"【数据段/常量区】==> 字符串常量");
    NSLog(@"str1 --- %p", str1);
    NSLog(@"str2 --- %p", str2);
    NSLog(@"str22 --- %p", str22);
    
    NSLog(@"【数据段/静态区】==> 已初始化数据");
    NSLog(@"c ------ %p", &c);
    NSLog(@"a ------ %p", &a);
    
    NSLog(@"【数据段/静态区】==> 未初始化数据");
    NSLog(@"d ------ %p", &d);
    NSLog(@"b ------ %p", &b);
    
    NSLog(@"【数据段】==> meta class & class");
    NSLog(@"objMCls --- %p", objMCls);
    NSLog(@"objCls ---- %p", objCls);
    
    NSLog(@"perMCls -- %p", perMCls);
    NSLog(@"perCls --- %p", perCls);
    
    NSLog(@"【堆】==> 实例对象"); // 分配的内存空间地址【越来越大】，不连续的
    NSLog(@"obj ---- %p", obj);
    NSLog(@"str3 --- %p", str3);
    NSLog(@"per0 --- %p", per0);
    
    NSLog(@"【栈】==> 局部变量"); // 分配的内存空间地址【越来越小】，是连续的，不管有没有初始化都会分配
    NSLog(@"f ------ %p", &f);
    NSLog(@"e ------ %p", &e);
    
    NSLog(@"=============测试=============");
    
    NSString *str4 = [NSString stringWithFormat:@"dofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirbni"];
    NSLog(@"str4 ------ %p 方法创建的字符串，堆", str4);
    
    NSString *str5 = @"dofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirbnidofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirfsfsdfbni";
    NSLog(@"str5 ------ %p 直接写出来的字符串，数据段", str5);
    
    NSString *str6 = [NSString stringWithFormat:@"%@", @"a"];
    NSLog(@"str6 ------ %p 这是Tagged Pointer，使用指针的地址来存值", str6);
    
    NSString *str7 = [NSString stringWithFormat:@"%@", @"dofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirbnidofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirfsfsdfbni"];
    NSLog(@"str7 ------ %p 超出Tagged Pointer范围（一个指针的大小，8字节），堆", str7);
    
    JPPerson *per = [JPPerson new];
    NSLog(@"per ------ %p 实例对象，堆", per);
        
    per.name = [NSString stringWithFormat:@"dofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirbnidofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirbni"];
    NSLog(@"per.name ------ %p 方法创建的字符串，堆", per.name);
    
    per.nickname = @"dofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirbnidofnsoinsovnreonborebneribneornbeoirnberobnerbneribenrubeirnbiernbeirbneirbni";
    NSLog(@"per.nickname ------ %p 直接写出来的字符串，数据段", per.nickname);
}


@end
