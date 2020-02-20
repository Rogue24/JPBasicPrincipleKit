//
//  ViewController.m
//  04-Runtime的应用（方法交换）
//
//  Created by 周健平 on 2019/11/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)buttonDicClick111:(UIButton *)sender {
    NSLog(@"%s", __func__);
}

/*
 * 类簇：是Foundation framework框架下的一种设计模式，它管理了一组隐藏在公共接口下的私有类。
 * NSString、NSArray、NSDictonary...这些的真实类型是其他类型
 * 例如：
    - NSMutableArray 实际上是 __NSArrayM 这个类
    - NSMutableDictionary 实际上是 __NSDictionaryM 这个类。
 */

// NSMutableArray+JPExtension：数组元素防空措施
- (IBAction)buttonDicClick222:(UIButton *)sender {
    NSString *obj = nil;
    
    // __NSArrayM
    NSMutableArray *arrayM = [NSMutableArray array];
    NSLog(@"======= %@ =======", arrayM.class);
    // -addObject: 内部调用的是 -insertObject:atIndex
    [arrayM addObject:@"0"];
    [arrayM addObject:obj];
    NSLog(@"arrayM %@", arrayM);
    
    // __NSArrayI
    NSArray *arrayI = @[@"11", @"22", @"33", @"44"];
    NSLog(@"======= %@ =======", arrayI.class);
    
    // __NSArrayI 应该是 __NSArrayM 的父类
    // I：immutable（不可变），M：mutable（可变的）
}

// NSMutableDictionary+JPExtension：字典键防空措施
- (IBAction)buttonDicClick333:(UIButton *)sender {
    NSString *obj = nil;
    
    // __NSDictionaryM
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    NSLog(@"======= %@ =======", dicM.class);
    dicM[@"abc"] = @"123";

    // 存
    dicM[obj] = @"456";
    NSLog(@"dicM %@", dicM);

    // 取
    id value = dicM[obj];
    NSLog(@"value %@", value);
    
    // __NSDictionaryI
    NSDictionary *dicI = @{@"11": @"22", @"33": @"44"};
    NSLog(@"======= %@ =======", dicI.class);
    value = dicI[obj];
    NSLog(@"value %@", value);
    
    // __NSDictionaryI 应该是 __NSDictionaryM 的父类
    // I：immutable（不可变），M：mutable（可变的）
}

@end
