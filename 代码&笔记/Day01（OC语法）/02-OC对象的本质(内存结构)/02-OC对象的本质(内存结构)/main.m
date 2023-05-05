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

@interface Student : NSObject
{
    @public
    int _no;
    int _age;
}
@end
@implementation Student
@end

@interface Teacher : NSObject
{
    // isa 8
    @public
    Student *_stu; // 8
    int _no; // 4
    int _age; // 4
    int _height; // 4
    // 8 + 8 + 4 + 4 + 4 = 28 ==> 24 < 28 < 32
}
@end
@implementation Teacher
@end

struct NSObject_IMPL {
    Class isa;
};

struct Student_IMPL {
    // 这个就是上面那个结构体里面的成员变量isa指针，子类包含了父类的结构体
    struct NSObject_IMPL NSObject_IVARS; // 8字节
    int _no; // 4字节
    int _age; // 4字节
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        Student *stu = [[Student alloc] init];
        NSLog(@"stu %zd", class_getInstanceSize(stu.class));
        NSLog(@"stu %zd", malloc_size((__bridge const void *)stu));
        
        Teacher *tea = [[Teacher alloc] init];
        NSLog(@"tea %zd", class_getInstanceSize(tea.class));
        NSLog(@"tea %zd", malloc_size((__bridge const void *)tea));
        
        stu->_no = 3;
        stu->_age = 4;
        
        // 可以在这里打个断点，使用【memory write 0x1030aedf8 9】指令可修改该内存地址的值
        // 0x1030aedf0 为stu的内存地址（假设，实际看断点打印）
        // 0x1030aedf8 <==> 0x1030aedf0 + 8 <==> _no的内存地址（前8个字节放的是isa指针）
        
        // NSObject 转 struct
        // OC的指针桥接成C语言的指针
        struct Student_IMPL *stuImpl = (__bridge struct Student_IMPL *)stu;
        // 转成struct也能访问到成员变量，证明NSObject的本质就是struct
        NSLog(@"no is %d, age is %d", stuImpl->_no, stuImpl->_age);
    }
    return 0;
}
