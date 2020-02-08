//
//  main.m
//  01-Runtime-枚举的位运算
//
//  Created by 周健平 on 2019/11/8.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "JPPerson.h"
#import <objc/runtime.h>

/*
 * isa 结构
 * 在arm64架构之前，isa就是一个普通的指针，存储着Class、Meta-Class对象的内存地址
 * 从arm64架构开始，对isa进行了优化，变成了一个共用体（union）结构，还使用位域来存储更多的信息
 *【也就是说，现在的isa存放的不是一个真正的地址，而是整合了多种信息的一个数字】
 *【在原有的内存空间里面（8个字节），存放了更多的信息，充分利用了存储空间】
 * arm64、真机架构：
    define ISA_MASK        0x0000000ffffffff8ULL // x86_64为0x00007ffffffffff8ULL
    define ISA_MAGIC_MASK  0x000003f000000001ULL // x86_64为0x001f800000000001ULL
    define ISA_MAGIC_VALUE 0x000001a000000001ULL // x86_64为0x001d800000000001ULL
    union isa_t {
        isa_t() { }
        isa_t(uintptr_t value) : bits(value) { }
        Class cls;
        uintptr_t bits; // 共用体（union）结构
        struct {        // 使用位域来存储更多的信息
            // 低字节
            uintptr_t nonpointer        : 1;
            uintptr_t has_assoc         : 1;
            uintptr_t has_cxx_dtor      : 1;
            uintptr_t shiftcls          : 33; // x86_64为44
            uintptr_t magic             : 6;
            uintptr_t weakly_referenced : 1;
            uintptr_t deallocating      : 1;
            uintptr_t has_sidetable_rc  : 1;
            uintptr_t extra_rc          : 19  // x86_64为8
            // 高字节
        };
    };
    define RC_ONE   (1ULL<<45) // x86_64为(1ULL<<56)
    define RC_HALF  (1ULL<<18) // x86_64为(1ULL<<7)
 *
 *【真机为例】
 * 使用lldb指令查看isa存储的内容：p/x xxx->isa（就是查看里面bits的信息）
 * 例如：0x000001a102c7d471，放到计算器里面可以看到bits的每一位数值（二进制），根据位域查看对应的信息：
 *
 * nonpointer : 1
    · 0，代表普通的指针，存储着Class、Meta-Class对象的内存地址
    · 1，代表优化过，使用位域存储更多的信息
 *
 * has_assoc : 1
    · 是否有设置【过】关联对象（不管现在有没有关联对象，只要设置过都为1），如果没有，释放时会更快
 *
 * has_cxx_dtor : 1
    · 是否有C++的析构函数（.cxx_destruct，类似OC的dealloc方法），如果没有，释放时会更快
 *
 * shiftcls : 33
    · 存储着Class、Meta-Class对象的内存地址信息
    · 从arm64架构开始Class、Meta-Class对象都是通过 isa & ISA_MASK 获取（ISA_MASK = 0xFFFFFFFF8，用来取出这33位的值）
    · 把ISA_MASK放计算器里面可以看出，<<Class、Meta-Class对象>>的地址值最后3位肯定是0
 *
 * magic : 6
    · 用于在调试时分辨对象是否未完成初始化（对应ISA_MAGIC_VALUE这个掩码）
 *
 * weakly_referenced : 1
    · 是否有被弱引用指向【过】（不管现在有没有被弱引用指向，只要被指向过都为1），如果没有，释放时会更快
 *
 * deallocating : 1
    · 对象是否正在释放
 *
 * has_sidetable_rc : 1
    · 引用计数器是否过大无法存储在isa中
    · 如果为1，引用计数器无法存储在isa中，那么引用计数会存储在一个叫SideTable的类的属性中
    · 如果为0，引用计数器存储在isa中，存储在后面的19位里面（extra_rc）
 *
 * extra_rc : 19
    · rc是retain count的简称
    · 里面存储的值是引用计数器减1（例如现在引用计数是3，这里就存储着2）
 *
 */

/*
 * OC销毁实例对象的源码：
     void *objc_destructInstance(id obj)
     {
         if (obj) {
             Class isa = obj->getIsa();

             // 是否有C++的析构函数
             if (isa->hasCxxDtor()) {
                 object_cxxDestruct(obj);  // 调用C++的析构函数
             }

             // 是否有关联对象
             if (isa->instancesHaveAssociatedObjects()) {
                 _object_remove_assocations(obj); // 移除关联对象
             }
 
             // 所以实例对象没有C++的析构函数、关联对象，释放时会更快

             objc_clear_deallocating(obj);
         }

         return obj;
     }
 */

#warning 使用【真机（arm64）】来测试

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        
        NSLog(@"%lu", sizeof(uintptr_t)); // 8个字节的大小，即64位
        
        JPPerson *per = [[JPPerson alloc] init];
        
        Class cls1 = per.class;
        Class cls2 = object_getClass(per);
        NSLog(@"%p %p", cls1, cls2);
        
        /*
         * 打断点，再打印：p/x per->isa，查看isa的值，把这个值丢计算器查看二进制形式（位域）
         */
        
        // 设置了关联对象，has_assoc为1（第2位）
        objc_setAssociatedObject(per, @"name", @"zhoujianping", OBJC_ASSOCIATION_COPY_NONATOMIC);
        // 即便清空了关联对象，has_assoc还是为1，has_assoc代表的是否曾经设置过，只要有设置过了就一直为1
        objc_setAssociatedObject(per, @"name", nil, OBJC_ASSOCIATION_COPY_NONATOMIC);

        // 被弱引用指向了，weakly_referenced为1（第42位）
        __weak typeof(per) weakPer = per;
        
        NSLog(@"%@", weakPer);
        
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
