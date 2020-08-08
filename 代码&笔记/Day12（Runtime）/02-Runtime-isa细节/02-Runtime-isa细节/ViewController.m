//
//  ViewController.m
//  01-Runtime-枚举的位运算
//
//  Created by 周健平 on 2019/11/8.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPPerson.h"

typedef NS_ENUM(NSUInteger, JPOptions) {
    JPOptions_A = 1<<0, // 0b00000001
    JPOptions_B = 1<<1, // 0b00000010
    JPOptions_C = 1<<2, // 0b00000100
    JPOptions_D = 1<<3, // 0b00001000
    JPOptions_E = 1<<4  // 0b00010000
};

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 这里的局部变量地址不会被干扰
    int a = 3;
    NSLog(@"临时变量a %p", &a);
    int b = 4;
    NSLog(@"临时变量b %p", &b);
    long c = 5;
    NSLog(@"临时变量c %p", &c);
     
    JPOptions option = JPOptions_A | JPOptions_C | JPOptions_E;
    /*
            0b00000001
            0b00000100
        |   0b00010000
     -----------------
            0b00010101
     */
    
    /*
            0b00010101
        &   0b00000001
     -----------------
            0b00000001 > 0
     */
    if (option & JPOptions_A) {
        NSLog(@"有A");
    }
    
    /*
           0b00010101
       &   0b00000010
    -----------------
           0b00000000 = 0
    */
    if (option & JPOptions_B) {
        NSLog(@"有B");
    }
    
    /*
           0b00010101
       &   0b00000100
    -----------------
           0b00000100 > 0
    */
    if (option & JPOptions_C) {
        NSLog(@"有C");
    }
    
    /*
           0b00010101
       &   0b00001000
    -----------------
           0b00000000 = 0
    */
    if (option & JPOptions_D) {
        NSLog(@"有D");
    }
    
    /*
           0b00010101
       &   0b00010000
    -----------------
           0b00010000 > 0
    */
    if (option & JPOptions_E) {
        NSLog(@"有E");
    }
}


@end
