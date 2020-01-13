//
//  main.m
//  01-OC对象的本质
//
//  Created by 周健平 on 2019/10/19.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

// -------------- OC ----------------
@interface Person : NSObject
{
    int _age;
}
@end

@implementation Person
@end

@interface Student : Person
{
    int _no;
}
@end

@implementation Student
@end
// ---------------------------------

// ------------- C/C++ -------------
struct NSObject_IMPL {
    Class isa;
};

struct Person_IMPL {
    struct NSObject_IMPL NSObject_IVARS; // 8
    int _age; // 4
};
// 内存对齐：结构体的大小必须是最大成员大小的倍数。
// 这里成员最大的是8字节（isa），再补上4字节（_age），所以Person所占内存为 8 * 2 = 16

struct Student_IMPL {
    struct Person_IMPL Person_IVARS; // 16
    int _no; // 4
};
// 这里Student所占内存还是16，虽然这里成员最大的是16字节，还有额外4字节（_no），不过这16个字节里面有4个字节是【空出来的】，刚好可以给_no使用，就不需要另外开辟16个字节了。==> 16 - 8 - 4 = 4，还有4个字节空出来可以用，刚刚好可以多放一个int
//【如果】Student再多一个int类型的属性，那么字面上的字节数 = 16 + 4 = 20，根据内存对齐，【至少】需要的内存大小 = 8 * 3 = 24，【实际】分配给对象的内存大小 = 16 * 2 = 32。
// ---------------------------------

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        Person *per = [Person new];
        NSLog(@"per %zd", class_getInstanceSize(per.class)); // 16
        NSLog(@"per %zd", malloc_size((__bridge const void *)(per))); // 16
        
        Student *stu = [Student new];
        NSLog(@"stu %zd", class_getInstanceSize(stu.class)); // 16
        NSLog(@"stu %zd", malloc_size((__bridge const void *)(stu))); // 16
        
        // class_getInstanceSize：对象【至少】需要的内存大小
        // 不考虑malloc函数的话，内存对齐一般是以【8】对齐
        
        // malloc_size：堆空间【实际】分配给对象的内存大小
        // 在Mac、iOS中的malloc函数分配的内存大小总是【16】的倍数
    }
    return 0;
}
