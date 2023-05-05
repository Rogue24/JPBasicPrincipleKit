//
//  main.m
//  01-Cateogry-load
//
//  Created by 周健平 on 2019/10/26.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "JPPerson.h"
#import "JPPerson+JPTest1.h"
#import "JPPerson+JPTest2.h"
#import "JPStudent.h"
#import "JPStudent+JPTest1.h"
#import "JPStudent+JPTest2.h"
#import "NSObject+JPExtension.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        /**
         * load方法在是在Runtime加载这个类/分类时（_objc_init）就会调用，
         * 是直接取到【方法地址】去调用，并不是经过objc_msgSend函数（发消息）调用。
         */
        
        // insert code here...
        NSLog(@"Hello, World!");
        
        JPPerson *per = [[JPPerson alloc] init];
        JPStudent *stu = [[JPStudent alloc] init];
        
        // 没实现的方法，可以通过分类实现
        [per sleep];
        [stu sleep];
        
        // 子类可以调用父类的分类方法
        [per xixi];
        [stu xixi];
        
        // 查看JPPerson的类方法列表：
        [object_getClass(JPPerson.class) jp_lookMethods];
        // 共有3个load方法
        // 1.JPPerson+JPTest2的load
        // 2.JPPerson+JPTest1的load
        // 3.JPPerson的load
        
        // 这里是通过消息发送机制调用load方法，所以会优先调用分类的load方法
        [JPPerson load];
        [JPStudent load];
    }
    return 0;
}


/*
 
 最新源码中Runtime的初始化操作（加载类、分类）：
 _objc_init
 ↓
 load_images             // 这里的images是镜像、模块的意思
 ↓
 call_load_methods
 ↓
 call_class_loads 【*1*】       // 先调用所有类的load方法
 call_category_loads 【*2*】    // 再调用所有分类的load方法，所以【就算分类先编译，也是先调用类的load方法】
 
【*1*】
 call_class_loads
 ↓
 load_method_t load_method = (load_method_t)classes[i].method; // 直接取出类的load方法的地址
 ↓
 (*load_method)(cls, SEL_load); // 这里是直接使用这个地址去调用这个类的load方法
 // 而不是通过消息机制（objc_msgSend）去调用，所以并没有去【元类对象和分类的方法列表】找load方法
 
【*2*】
 call_category_loads
 ↓
 load_method_t load_method = (load_method_t)cats[i].method; // 直接取出分类的load方法的地址
 ↓
 (*load_method)(cls, SEL_load); // 同样也是直接使用这个地址去调用这个分类的load方法，不需要去【元类对象和分类的方法列表】找load方法
 
【*1*】的classes数组里面放的是这种结构体，表示全部可以加载的类：
 struct loadable_class {
     Class cls;  // may be nil
     IMP method; //【只】指向类的load方法
 };
 classes[i].method; ==> 直接取出类的load方法的地址

【*2*】的cats数组里面放的是这种结构体，表示全部可以加载的分类：
 struct loadable_category {
     Category cat;  // may be nil
     IMP method;    //【只】指向分类的load方法
 };
 cats[i].method; ==> 直接取出分类的load方法的地址
 
*/
