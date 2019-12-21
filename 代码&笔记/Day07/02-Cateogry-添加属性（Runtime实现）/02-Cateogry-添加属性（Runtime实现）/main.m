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

// extern：表示变量或者函数的定义可能在别的文件中，提示编译器遇到此变量或者函数时，在别的文件里寻找其定义。
extern const void *JPTestKey;
extern const void *JPNameKey;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSLog(@"指针的内存大小 %zd", sizeof(void *)); // 8
        NSLog(@"int的内存大小 %zd", sizeof(int)); // 4
        NSLog(@"char的内存大小 %zd", sizeof(char)); // 1
        NSLog(@"SEL的内存大小 %zd", sizeof(SEL)); // 8 也是指针
        
        NSLog(@"外部访问JPTestKey --- %p", JPTestKey);
        
        JPPerson *per1 = [[JPPerson alloc] init];
        per1.age = 27;
        per1.name = @"shuaigepinng";
        per1.weight = 160;
        per1.height = 177;
        NSLog(@"per1 age is %d, name is %@, weight is %d, height is %d", per1.age, per1.name, per1.weight, per1.height);
        
        JPPerson *per2 = [[JPPerson alloc] init];
        per2.age = 25;
        per2.name = @"shadou";
        per2.weight = 105;
        per2.height = 162;
        NSLog(@"per2 age is %d, name is %@, weight is %d, height is %d", per2.age, per2.name, per2.weight, per2.height);
    }
}

/*
 
 关联对象的原理：
    ·关联对象并不是存储在被关联对象本身内存中
    ·关联对象存储在全局的统一的一个AssociationsManager中
    ·设置关联对象为nil，就相当于移除关联对象
    （int这种基本数据类型实际会被包装成NSNumber类型，移除这种就不是置0，而是置nil）

 Runtime底层实现：
 
 objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
 ↓
 _object_set_associative_reference(object, (void *)key, value, policy)
 ↓
 AssociationsManager
    - AssociationsHashMap <disguised_ptr_t, ObjectAssociationMap>
        - AssociationsMap(ObjectAssociationMap) <void *, ObjcAssociation>
            - ObjcAssociation <uintptr_t _policy, id _value>
 
 AssociationsManager：
 class AssociationsManager {
     static AssociationsHashMap *_map;
     ...
 };
 ↓
 AssociationsHashMap：
 class AssociationsHashMap : public unordered_map<disguised_ptr_t, ObjectAssociationMap *, DisguisedPointerHash, DisguisedPointerEqual, AssociationsHashMapAllocator> {
     ...
 };
 // AssociationsHashMap 继承于 unordered_map
 // 其中disguised_ptr_t为Key，ObjectAssociationMap为value，而ObjectAssociationMap也是一个map
 ↓
 ObjectAssociationMap：
 class ObjectAssociationMap : public std::map<void *, ObjcAssociation, ObjectPointerLess, ObjectAssociationMapAllocator> {
     ...
 };
 // 其中void *为Key，ObjcAssociation为value
 ↓
 ObjcAssociation：
 class ObjcAssociation {
     uintptr_t _policy;
     id _value;
     ...
 };
 // 可以看到objc_setAssociatedObject传的value和policy（属性存储策略）都被存到ObjcAssociation里面
 
 */
