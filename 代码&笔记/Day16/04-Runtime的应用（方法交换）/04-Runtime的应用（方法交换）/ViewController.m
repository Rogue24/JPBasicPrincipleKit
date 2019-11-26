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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *obj = nil;
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"0"];
    [array addObject:obj];
    NSLog(@"array %@", array);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"abc"] = @"123";
    dic[obj] = @"456";
    NSLog(@"dic %@", dic);
    
    id value = dic[obj];
    NSLog(@"value %@", value);
}

- (IBAction)buttonDicClick111:(UIButton *)sender {
    NSLog(@"%s", __func__);
}

- (IBAction)buttonDicClick222:(UIButton *)sender {
    NSLog(@"%s", __func__);
}

- (IBAction)buttonDicClick333:(UIButton *)sender {
    NSLog(@"%s", __func__);
}

@end
