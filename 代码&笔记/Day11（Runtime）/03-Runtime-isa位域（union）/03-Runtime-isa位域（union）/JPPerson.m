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
    
//    struct {
//        char tall : 1;
//        char rich : 1;
//        char handsome : 1;
//    } _tallRichHandsome;
    // ”: 1” ==> 位域，1代表只占1位的意思，这里声明的这3个成员就各占1bit，共3bit
    // 所以这个结构体只需要用到3bit的内存，这样系统只需要分配1个字节就够用了（内存分配至少也得1个字节）
    // 在结构体编写的顺序，在字节里面是从右边开始排起
    // 0b00000 0    0    0
    //         ↓    ↓    ↓
    //    handsome rich tall
    
    /*
     * union：共同体，所有成员共用一块内存（内存大小以成员所占内存最大的那一个来分配）
     * 例：
         union {
             char a; // 占1字节
             int b;  // 占4字节
         } _jpunion; // 以最大的那一个成员的内存来分配，所以共同体占4字节
         _jpunion.a = 3;
         _jpunion.b = 10;
         // 此时再次访问 _jpunion.a 就不再是3，而是10了，因为这两个成员共用一块内存，之前的3被覆盖了
     */
    union {
        char bits;
        //【这个结构体纯属摆设】，只为了提高可读性，用来说明bits里面存放的是这3个成员信息，并且每一个成员占1位
        // 而且这个结构体也只占1个字节（3个成员才各占1位，总共3位不及8位），不会超出char的存储范围（1字节占8位）
        // 自始至终只操作bits，也没有用到这个结构体，不影响存储
        struct {   // >>>>> 纯属摆设，只用来看存的什么成员，占多少位而已
            char tall : 1;
            char rich : 1;
            char handsome : 1;
        };
        // 存值和取值都使用位运算（效率高），使用位域来增加可读性
    } _tallRichHandsome;
    
    /*
     * isa 结构
     * 在arm64架构之前，isa就是一个普通的指针，存储着Class、Meta-Class对象的内存地址
     * 从arm64架构开始，对isa进行了优化，变成了一个共用体（union）结构，还使用位域来存储更多的信息
     * 【在原有的空间里面，存放了更多的信息】
         union isa_t {
             isa_t() { }
             isa_t(uintptr_t value) : bits(value) { }

             Class cls;
             uintptr_t bits;
         #if defined(ISA_BITFIELD)
             struct {
                 define ISA_BITFIELD
             };
         #endif
        };
     * ISA_BITFIELD（arm64架构，真机）：
         # if __arm64__
         #   define ISA_MASK        0x0000000ffffffff8ULL
         #   define ISA_MAGIC_MASK  0x000003f000000001ULL
         #   define ISA_MAGIC_VALUE 0x000001a000000001ULL
         #   define ISA_BITFIELD                                                      \
               uintptr_t nonpointer        : 1;                                       \
               uintptr_t has_assoc         : 1;                                       \
               uintptr_t has_cxx_dtor      : 1;                                       \
               uintptr_t shiftcls          : 33; // MACH_VM_MAX_ADDRESS 0x1000000000  \
               uintptr_t magic             : 6;                                       \
               uintptr_t weakly_referenced : 1;                                       \
               uintptr_t deallocating      : 1;                                       \
               uintptr_t has_sidetable_rc  : 1;                                       \
               uintptr_t extra_rc          : 19
         #   define RC_ONE   (1ULL<<45)
         #   define RC_HALF  (1ULL<<18)
     * ISA_BITFIELD（x86_644架构，模拟机、mac）：
         # elif __x86_64__
         #   define ISA_MASK        0x00007ffffffffff8ULL
         #   define ISA_MAGIC_MASK  0x001f800000000001ULL
         #   define ISA_MAGIC_VALUE 0x001d800000000001ULL
         #   define ISA_BITFIELD                                                        \
               uintptr_t nonpointer        : 1;                                         \
               uintptr_t has_assoc         : 1;                                         \
               uintptr_t has_cxx_dtor      : 1;                                         \
               uintptr_t shiftcls          : 44; // MACH_VM_MAX_ADDRESS 0x7fffffe00000  \
               uintptr_t magic             : 6;                                         \
               uintptr_t weakly_referenced : 1;                                         \
               uintptr_t deallocating      : 1;                                         \
               uintptr_t has_sidetable_rc  : 1;                                         \
               uintptr_t extra_rc          : 8
         #   define RC_ONE   (1ULL<<56)
         #   define RC_HALF  (1ULL<<7)
     *
     * shiftcls：存储着Class、Meta-Class对象的内存地址信息
     * 从arm64架构开始：
        · Class、Meta-Class对象都是通过isa & ISA_MASK获取
        · 把ISA_MASK放计算机里面可以看出，Class、Meta-Class对象的地址值最后3位肯定是0
     */
}

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"%lu", sizeof(_tallRichHandsome)); // 1，占1个字节大小
    }
    return self;
}

#define JPTallMask     (1<<0) // 1左移0位 (0b00000001 << 0) = 0b00000001 = 1
#define JPRichMask     (1<<1) // 1左移1位 (0b00000001 << 1) = 0b00000010 = 2
#define JPHandsomeMask (1<<2) // 1左移2位 (0b00000001 << 2) = 0b00000100 = 4

// 如果是4位
//#define JPTallMask (0b1111<<4) // 左移4位 0b00001111 << 4 = 0b11110000

- (void)setTall:(BOOL)tall {
    if (tall) {
        _tallRichHandsome.bits |= JPTallMask;
    } else {
        _tallRichHandsome.bits &= ~JPTallMask;
    }
}
- (void)setRich:(BOOL)rich {
    if (rich) {
        _tallRichHandsome.bits |= JPRichMask;
    } else {
        _tallRichHandsome.bits &= ~JPRichMask;
    }
}
- (void)setHandsome:(BOOL)handsome {
    if (handsome) {
        _tallRichHandsome.bits |= JPHandsomeMask;
    } else {
        _tallRichHandsome.bits &= ~JPHandsomeMask;
    }
}

- (BOOL)isTall {
    return !!(_tallRichHandsome.bits & JPTallMask);     // ==> & 0b00000001 取出第1位
}
- (BOOL)isRich {
    return !!(_tallRichHandsome.bits & JPRichMask);     // ==> & 0b00000010 取出第2位
}
- (BOOL)isHandsome {
    return !!(_tallRichHandsome.bits & JPHandsomeMask); // ==> & 0b00000100 取出第3位
}

@end
