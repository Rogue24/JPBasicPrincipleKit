//
//  JPPerson.m
//  01-Runtime-isa位域
//
//  Created by 周健平 on 2019/11/7.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson
{
    // 一个布尔类型只需要0跟1就可以表示，所以可以只用一个二进制位来存储
    // 例：使用一个字节来存储3个布尔值（一个字节占8位）
    // 0b00000 0    0    0
    //         ↓    ↓    ↓
    //    handsome rich tall
    char _tallRichHandsome;
}

- (instancetype)init {
    if (self = [super init]) {
        _tallRichHandsome = 0b00000101;
    }
    return self;
}

// 定义掩码（用来按位与运算的）的宏
// 掩码：特定位为1，其余为0
// <<：左移，二进制形式，乘以2^n
#define JPTallMask     (1<<0) // 1左移0位 0b00000001 << 0 = 0b00000001 ==> 1
#define JPRichMask     (1<<1) // 1左移1位 0b00000001 << 1 = 0b00000010 ==> 2
#define JPHandsomeMask (1<<2) // 1左移2位 0b00000001 << 2 = 0b00000100 ==> 4

/*
 * 使用掩码进行&运算（与运算，都为1得1，其余为0），取出特定的位
    例：
    1.1010取出第2位  2.0111取出第3位
              1010           0111
    &         0010           0100
    -----------------------------
    =         0010           0100
    规律：取第x位，就&上位数跟目标数一样，且第x位为1其他位为0的数
 
 * 使用掩码进行|运算（或运算，都为0得0，其余为1），设置特定位为1
    1.1000第2位置1  2.0001第3位置1
             1000           0001
    |        0010           0100
    ----------------------------
    =        1010           0101
    规律：第x位置1，就|上位数跟目标数一样，且第x位为1其他位为0的数
 
 * 使用掩码取反（取反，1置0，0置1）再进行&运算，设置特定位为0
    1.0110第2位置0  2.1101第3位置0
             0110           1101
    &       ~0010          ~0100
    ----------------------------
    =        0100           1001
    规律：第x位置0，就&上位数跟目标数一样，且第x位为0其他位为1的数
 
 * 【~】：取反
    ~(0010) ==> 1101
 */

- (void)setTall:(BOOL)tall {
    if (tall) {
        _tallRichHandsome |= JPTallMask;
    } else {
        _tallRichHandsome &= ~JPTallMask;
    }
}
- (void)setRich:(BOOL)rich {
    if (rich) {
        _tallRichHandsome |= JPRichMask;
    } else {
        _tallRichHandsome &= ~JPRichMask;
    }
}
- (void)setHandsome:(BOOL)handsome {
    if (handsome) {
        _tallRichHandsome |= JPHandsomeMask;
    } else {
        _tallRichHandsome &= ~JPHandsomeMask;
    }
}

/*
 * !!：通过&运算得出的值，要么大于0，要么等于0，可以根据这个值取【两次】非获得对应布尔值（不然YES时，就是1、2、4之类的）
 * 第一次取非：为了转成布尔值，不过是反的
 * 第二次取非：再取反获得正确的布尔值
 */
- (BOOL)isTall {
    return !!(_tallRichHandsome & JPTallMask);     // ==> & 0b00000001 取出第1位
}
- (BOOL)isRich {
    return !!(_tallRichHandsome & JPRichMask);     // ==> & 0b00000010 取出第2位
}
- (BOOL)isHandsome {
    return !!(_tallRichHandsome & JPHandsomeMask); // ==> & 0b00000100 取出第3位
}
//- (BOOL)isTall {
//    return (_tallRichHandsome & JPTallMask) > 0;     // ==> & 0b00000001 取出第1位
//}
//- (BOOL)isRich {
//    return (_tallRichHandsome & JPRichMask) > 0;     // ==> & 0b00000010 取出第2位
//}
//- (BOOL)isHandsome {
//    return (_tallRichHandsome & JPHandsomeMask) > 0; // ==> & 0b00000100 取出第3位
//}

@end
