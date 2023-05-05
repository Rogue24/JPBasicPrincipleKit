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

/*
 面试题：一个NSObject对象占用多少内存？
 · 系统分配了16个字节给NSObject对象（通过malloc_size函数获得）
 · 但NSObject对象内部只使用了8个字节的空间（64bit环境下，可以通过class_getInstanceSize函数获得）
*/

/**
 * 将Objective-C代码转换为C\C++代码：
 * 不同平台支持的代码肯定不一样（Windows、Mac、iOS）
 * 没指定架构：clang -rewrite-objc main.m -o main.cpp
 * 指定iOS64位机构：xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-arm64.cpp
 */

// NSObject在OC中的定义
/*
@interface NSObject <NSObject> {
    Class isa;
}
@end
*/

// NSObject转成C++后的定义（在C++里面的底层实现）
struct NSObject_IMPL { // -> NSObject_Implementation
    Class isa;
};

// Class的定义：typedef struct objc_class *Class;
// 所以`isa`属于Class类型，是一个指向【结构体struct】的指针（指针类型在64位里面占8个字节，32位占4个字节）

// `NSObject/NSObject_IMPL`只有一个Class类型的成员变量isa，
// 所以`NSObject/NSObject_IMPL`只占8个字节，并且isa所在的地址就是这个结构体的地址。

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        // OC的对象、类主要是基于C\C++的【结构体】的数据结构实现的
        NSObject *obj = [[NSObject alloc] init];
        
        // 获取NSObject的实例对象的成员变量（isa）所占用的大小 >> 8
        // class_getInstanceSize -> alignedInstanceSize，它的描述：Class's ivar size rounded up to a pointer-size boundary.
        NSLog(@"%zd", class_getInstanceSize(obj.class));
        
        // 获取obj这个指针所指向的内存大小 >> 16
        NSLog(@"%zd", malloc_size((__bridge const void *)(obj)));
        // __bridge const void * -> 桥接成C语言的指针
        
        // 分配给NSObject的内存大小为16个字节，真正利用的只有前8个字节（用来存放isa这个成员变量）
        
        // 苹果开放的oc源码下载：https://opensource.apple.com/tarballs/objc4/
        
        // 查看malloc_size为何为16个字节：
        // 1.源码搜索：_objc_rootAllocWithZone -> class_createInstance -> _class_createInstanceFromZone
        // 2.找到里面有C语言的alloc语句：(id)calloc(1, size);
        // 3.查看这个size的创建：size_t size = cls->instanceSize(extraBytes);
        /*
            // 可以看到规定至少为16个字节
            size_t instanceSize(size_t extraBytes) {
                size_t size = alignedInstanceSize() + extraBytes;
                // CF requires all objects be at least 16 bytes.
                if (size < 16) size = 16;
                return size;
            }
         */
    }
    return 0;
}
