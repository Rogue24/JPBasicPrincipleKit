//
//  main.m
//  03-class和meta-class的结构（深入了解）
//
//  Created by 周健平 on 2019/11/11.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <objc/runtime.h>
#import "JPPerson.h"
#import "MJClassInfo.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        /**
         * 如何查看类对象和元类对象里面的东西：
         * 仿照源码里面的结构自定义对应的struct，转换过来查看
         */
        
        /**
         * 导入MJClassInfo.h报错：
         * 因为MJClassInfo.h是一个C++文件，而main.m是OC文件，不认识C++语法，只认识OC语法和C语法
         * 解决：将main.m改成main.mm，转成Object-C++文件，既认识OC语法又认识C++语法
         * PS：C++的struct使用时不需要额外再写一个struct在前面
         */
        
        mj_objc_class *perCls = (__bridge mj_objc_class *)[JPPerson class];
        
        class_rw_t *perClsData = perCls->data();
        
        class_rw_t *perMClsData = perCls->metaClass()->data();
        
        // 打断点查看控制台
        // 可以看到class对象和meta-class对象的结构是一样的
        // 只是meta-class对象只有方法列表（里面放类方法），其他为NULL
        
        JPPerson *per = [[JPPerson alloc] init];
        // 打印 p perClsData->methods->first.imp ==> 0x000000010028dd30
        // 打印 p perClsData->methods->first.types ==> v16@0:8
        [per test]; // 在方法里面打断点查看汇编信息，可以看到函数地址也是0x000000010028dd30
        
        
        // 数组可以放不同类型
//        NSArray *arr = @[@"abc", @123, [JPPerson new]];
//        NSLog(@"%@", arr);
        
        // 所有名字一样的选择器(SEL)的地址都是同一个，不同类中相同名字的方法，所对应的方法选择器(SEL)是相同的
        NSLog(@"%p %p %p", @selector(test), @selector(test), sel_registerName("test"));
        
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}


/*
 * Class 是一个 struct objc_class 的类型（typedef struct objc_class *Class）
 * struct objc_class 在objc源码中是酱紫：
    struct objc_class : objc_object {
        // Class ISA;
        Class superclass;
        cache_t cache;
        class_data_bits_t bits;
        // 其他方法...
    }
 * struct objc_class 是继承于父类 struct objc_object，他是酱紫：
    struct objc_object {
        isa_t isa;
        // 其他方法...
    }
 * 所以 struct objc_class 可以这样表示：
    struct objc_class {
        Class ISA;
        Class superclass;
        cache_t cache;
        class_data_bits_t bits;
        // 其他方法...
    }
 *
 */

/*
 * objc_class里的bits存储的信息结构是class_rw_t，通过bits & FAST_DATA_MASK -> class_rw_t。
 * class_rw_t的结构：
 
     struct class_rw_t { // ==> rw：可读可写，说明运行时里面的数据可修改（例如分类添加的方法、属性、协议）
        uint32_t flags;
        uint32_t version;
     
        const class_ro_t *ro; // ro：只读，里面的数据不可修改，存储着类的初始信息
     
        method_array_t methods; // 方法列表（二维数组<method_t, method_list_t>）
        property_array_t properties; // 属性列表（二维数组<property_t, property_list_t>）
        protocol_array_t protocols; // 协议列表（二维数组<protocol_ref_t, protocol_list_t>）
        ↓↓↓
        // 使用二维数组的好处：按类别的信息列表(数组)当作一个元素
          （包含类本身和其他分类的，有新的分类就将这个分类的信息列表(数组)当作一个元素插入）
        ↓↓↓
        // C++泛型语法：list_array_tt<method_t, method_list_t>
           --> method_array_t里面放的是method_list_t类型的数组，method_list_t里面放的是method_t类型的元素
        ↓↓↓
        // 一开始是没有rw的，bits指向的是ro
        // 初始化时创建rw
        // 将ro里面的初始信息、其他分类的信息列表作为元素分别合并到rw里面这3个二维数组对应的那个
        // rw的ro指向ro，
        // 然后bits改成指向rw
     
        Class firstSubclass;
        Class nextSiblingClass;
        char *demangledName;
     
        // 其他方法...
    }
 *
 * class_rw_t里的ro存储的信息结构是class_ro_t。
 * class_ro_t的结构：
 
     struct class_ro_t {
         uint32_t flags;
         uint32_t instanceStart;
         uint32_t instanceSize; // instance对象占用的内存空间
     #ifdef __LP64__
         uint32_t reserved;
     #endif
         const uint8_t * ivarLayout;
         const char * name; // 类名
         method_list_t * baseMethodList; // 方法列表（一维数组<method_t>，只读，类的初始方法）
         protocol_list_t * baseProtocols; // 协议列表（一维数组<protocol_ref_t>，只读，类的初始协议）
         const ivar_list_t * ivars; // 成员变量列表（一维数组<ivar_t>，只读，类的成员变量）
         const uint8_t * weakIvarLayout;
         property_list_t *baseProperties; // 属性列表（一维数组<property_t>，只读，类的初始属性）
        
         // 其他方法...
     }
 *
 * method_t是对方法/函数的封装
 * method_t的结构：
 
     struct method_t {
         SEL name; // SEL：选择器（typedef struct objc_selector *SEL），代表方法/函数名
                   // 底层结构跟C字符串(char *)类似，其实就是一个名字，就是一个字符。
                   // 获取选择器：SEL sbSel = @selector(sb)、sel_registerName("sb")
                   // 所有名字一样的选择器(SEL)的地址都是同一个，不同类中相同名字的方法，所对应的方法选择器(SEL)是相同的
                   // 获取方法名：sel_getName(SEL)返回C字符串、NSStringFromSelector(SEL)返回OC字符串
 
         const char *types; // 编码（返回值类型、参数信息，编码含义去查看TypeEncoding对应表）
                            // 返回值类型 + 所有参数所占字节数 + 参数1类型 + 参数1位置 +... 参数n类型 + 参数n位置
                            // 例：
                               - (int)test:(int)i sb:(float)f
                               xxx->methods->first.types ==> i24@0:8i16f20
                               i           @        :         i      f
                               ↓           ↓        ↓         ↓      ↓
                               int(return) id(self) SEL(_cmd) int(i) float(f)
                               24 = 8(id) + 8(SEL) + 4(int) + 4(float) ==> 所有参数所占字节数
                               0、8、16、20 ==> 参数从函数地址的第x个字节开始排列
 
         MethodListIMP imp; // 指向函数的指针（函数地址）
                            //【using MethodListIMP = IMP】==> IMP代表函数的具体实现
         
         // 其他方法...
     };
 *
 */
