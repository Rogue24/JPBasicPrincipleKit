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
    // 1个BOOL值只需要0跟1就可以表示，因此可以只用1个二进制【位】来存储1个BOOL值
    // 所以可以酱紫：使用1个字节来存储3个BOOL值（1个字节占8位，最多可以存储8个BOOL值）
    // 0b00000 0    0    0
    //         ↓    ↓    ↓
    //    handsome rich tall
//    char _tallRichHandsome;
    
    struct {
        char tall : 1;
        char rich : 1;
        char handsome : 1;
    } _tallRichHandsome;
    // ”: 1” ==> 位域，1代表只占1位的意思，这里声明的这3个成员就各占1bit，共3bit
    // 所以这个结构体只需要用到3bit的内存，这样系统只需要分配1个字节就够用了（内存分配至少也得1个字节）
    // 在结构体编写的顺序，在字节里面是从右边开始排起
    // 0b00000 0    0    0
    //         ↓    ↓    ↓
    //    handsome rich tall
}

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"%lu", sizeof(_tallRichHandsome)); // 1，占1个字节大小
        
        /*
         * Byte的值域范围为 -128 ~ 127（0, 1, ... 127, -128, ... -2, -1）【有符号的存值】
         * 二进制表示为 0b0000 ~ 0b1111
         * 十进制表示为 0 ~ 255
         * 十六进制表示为 0x00 ~ 0xFF
         *
         *【BOOL是有符号的】
         * 给BOOL连续赋值得出：
         * 0, 1, ... 127, -128, -127, ... -2, -1,  0,  1, ... 按值域范围循环
           ↓  ↓       ↓     ↓     ↓        ↓   ↓   ↓   ↓
           0  1      127   128   129      254 255 256 257     对应的十进制
         */
//        for (NSInteger i = 0; i <= 257; i++) {
//            BOOL abc = i;
//            NSLog(@"abc %d", abc);
//        }
    }
    return self;
}

- (void)setTall:(BOOL)tall {
    _tallRichHandsome.tall = tall; // 0b0000000x
}
- (void)setRich:(BOOL)rich {
    _tallRichHandsome.rich = rich; // 0b000000x0
}
- (void)setHandsome:(BOOL)handsome {
    _tallRichHandsome.handsome = handsome; // 0b00000x00
}

/*
 * !!：1位，无非就是0或1，取【两次】非获得对应布尔值（不然YES时，就会是-1）
 * 第一次取非：为了转成布尔值，不过是反的
 * 第二次取非：再取反获得正确的布尔值
 */
- (BOOL)isTall {
    // 如果直接返回_tallRichHandsome.tall，当该值等于1时，输出为-1，原因是：
    // BOOL大小为1个Byte，即8bit，而_tallRichHandsome.tall只有1bit
    // 将1位【强制转换/扩展】成8位，造成的后果就是【只能用这一位】去覆盖其他位
    //         [1]
    //    ↓↓↓↓↓↓↓  覆盖
    // 0b[0000000]1 -> 0b11111111 -> 255 -> -1（255用BOOL表示则为-1）
    
    // 解决方法1：将成员扩展成2位：char tall : 2;
    // 此时为01，用【第一位】去覆盖其他位（这是位域的特点，强转时以最前面的那一位拉伸/扩展/填充其他位）
    //         [0]1
    //    ↓↓↓↓↓↓↓  覆盖
    // 0b[0000000]1 -> 0b00000001 -> 1 -> 1
    
    // 解决方法2：!!（推荐，毕竟省内存，效率也高）
    
    return !!_tallRichHandsome.tall;
}
- (BOOL)isRich {
    return !!_tallRichHandsome.rich;
}
- (BOOL)isHandsome {
    return !!_tallRichHandsome.handsome;
}

@end
