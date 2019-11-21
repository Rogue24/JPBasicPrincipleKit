//
//  main.m
//  03-class和meta-class的结构
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MJClassInfo.h"

@interface JPPerson : NSObject <NSCopying>
{
    @public
    int _age;
}
@property (nonatomic, assign) int no;
- (void)personInstanceMethod;
+ (void)personClassMethod;
@end

@implementation JPPerson
- (void)personInstanceMethod {
    
}
+ (void)personClassMethod {
    
}
- (id)copyWithZone:(NSZone *)zone {
    return nil;
}
@end

@interface JPStudent : JPPerson <NSCoding>
{
    @public
    int _weight;
}
@property (nonatomic, assign) int height;
- (void)studentInstanceMethod;
+ (void)studentClassMethod;
@end

@implementation JPStudent
- (void)studentInstanceMethod {
    
}
+ (void)studentClassMethod {
    
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    return nil;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    
}
@end

int main(int argc, const char * argv[]) {
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
        mj_objc_class *stuCls = (__bridge mj_objc_class *)[JPStudent class];
        
        class_rw_t *perClsData = perCls->data();
        class_rw_t *stuClsData = stuCls->data();
        
        class_rw_t *perMClsData = perCls->metaClass()->data();
        class_rw_t *stuMClsData = stuCls->metaClass()->data();
        
        // 打断点查看控制台
        // 可以看到class对象和meta-class对象的结构是一样的
        // 只是meta-class对象只有方法列表（里面放类方法），其他为NULL
        
        NSLog(@"123");
    }
    return 0;
}


/*
// Class 是一个 struct objc_class 的类型
typedef struct objc_class *Class;

// struct objc_class 在objc源码中是酱紫：
struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;
    class_data_bits_t bits;
    // 还有其他方法...
}
// struct objc_class 是继承于父类 struct objc_object，他是酱紫：
struct objc_object {
    isa_t isa;
    // 还有其他方法...
}

// 所以 struct objc_class 可以这样表示：
struct objc_class {
    Class ISA;
    Class superclass;
    cache_t cache;
    class_data_bits_t bits;
    // 还有其他方法...
}
*/
