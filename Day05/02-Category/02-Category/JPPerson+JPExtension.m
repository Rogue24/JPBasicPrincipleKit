//
//  JPPerson+JPExtension.m
//  02-Category
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson+JPExtension.h"

@implementation JPPerson (JPExtension)

- (void)fuck {
    NSLog(@"I am fucking");
}

- (void)sleep {
    NSLog(@"I am sleepping --- JPExtension");
}

- (void)setName:(NSString *)name {
    NSLog(@"setName --- JPExtension");
}

- (NSString *)name {
    return @"qunima --- JPExtension";
}

/*
 
 使用xcrun指令将分类编译之后就成为这种结构体对象，方法数据都存放到这个结构体里面：
 struct _category_t {
     const char *name; // 类名
     struct _class_t *cls;
     const struct _method_list_t *instance_methods; // 实例方法列表
     const struct _method_list_t *class_methods; // 类方法列表
     const struct _protocol_list_t *protocols; // 协议列表
     const struct _prop_list_t *properties; // 属性列表
 };
 
 最新源码中的category_t结构体：
 struct category_t {
     const char *name;
     classref_t cls;
     struct method_list_t *instanceMethods;
     struct method_list_t *classMethods;
     struct protocol_list_t *protocols;
     struct property_list_t *instanceProperties;
     // Fields below this point are not always present on disk.
     struct property_list_t *_classProperties;

     method_list_t *methodsForMeta(bool isMeta) {
         if (isMeta) return classMethods;
         else return instanceMethods;
     }

     property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
 };
 
 
 最新源码中Runtime的初始化操作：
 _objc_init
 ↓
 map_images             // 这里的images是镜像、模块的意思
 ↓
 map_images_nolock
 ↓
 _read_images
 ↓
 remethodizeClass ===> 重新组织类的方法
 ↓
 attachCategories ===> 将分类信息附加到类里面去（class、meta-class）
 ↓
 实现的源码：
 // cls ===> 目标类对象：[JPPerson class]
 // cats ===> 这个类的所有分类的数组：[category_t(JPExtension), category_t(JPOther)]
 static void
 attachCategories(Class cls, category_list *cats, bool flush_caches)
 {
     if (!cats) return;
     if (PrintReplacedMethods) printReplacements(cls, cats);

     bool isMeta = cls->isMetaClass();

     // fixme rearrange to remove these intermediate allocations
 
     // 方法数组（二维数组）
     // 例：[[method_t, method_t], [method_t, method_t], ...]
     method_list_t **mlists = (method_list_t **)
         malloc(cats->count * sizeof(*mlists));
 
     // 属性数组（二维数组）
     // 例：[[property_t, property_t], [property_t, property_t], ...]
     property_list_t **proplists = (property_list_t **)
         malloc(cats->count * sizeof(*proplists));
 
     // 协议数组（二维数组）
     // 例：[[protocol_t, protocol_t], [protocol_t, protocol_t], ...]
     protocol_list_t **protolists = (protocol_list_t **)
         malloc(cats->count * sizeof(*protolists));

     // Count backwards through cats to get newest categories first
     int mcount = 0;
     int propcount = 0;
     int protocount = 0;
     int i = cats->count;
     bool fromBundle = NO;
     while (i--) {
         // 取出某个分类
         auto& entry = cats->list[i];

         // 取出分类中的实例方法列表（假设现在的cls是class对象，所以isMeta为NO，方法为实例方法）
         method_list_t *mlist = entry.cat->methodsForMeta(isMeta);
         if (mlist) {
             mlists[mcount++] = mlist; // 将方法列表放入mlists数组中
             fromBundle |= entry.hi->isBundle();
         }

         // 取出分类中的属性列表
         property_list_t *proplist =
             entry.cat->propertiesForMeta(isMeta, entry.hi);
         if (proplist) {
             proplists[propcount++] = proplist; // 将属性列表放入proplists数组中
         }

         // 取出分类中的协议列表
         protocol_list_t *protolist = entry.cat->protocols;
         if (protolist) {
             protolists[protocount++] = protolist; // 将协议列表放入protolists数组中
         }
     }

     // 获取class对象里面的数据（这是struct class_rw_t结构体对象，查看class对象的结构图）
     auto rw = cls->data();

     prepareMethodLists(cls, mlists, mcount, NO, fromBundle);
 
     // 将所有分类的实例方法，附加到类对象的方法列表中
     rw->methods.attachLists(mlists, mcount);
     free(mlists);
     if (flush_caches  &&  mcount > 0) flushCaches(cls);

     // 将所有分类的属性，附加到类对象的属性列表中
     rw->properties.attachLists(proplists, propcount);
     free(proplists);

     // 将所有分类的协议，附加到类对象的协议列表中
     rw->protocols.attachLists(protolists, protocount);
     free(protolists);
 }
 ↓
 附加操作实现的源码：
 void attachLists(List* const * addedLists, uint32_t addedCount) {
     if (addedCount == 0) return;

     if (hasArray()) {
         // many lists -> many lists
 
         // 1.扩容
         // 旧个数
         uint32_t oldCount = array()->count;
         // 新个数 = 旧个数 + 新增个数
         uint32_t newCount = oldCount + addedCount;
         setArray((array_t *)realloc(array(), array_t::byteSize(newCount)));
         array()->count = newCount;
 
         // 2.将【原来的方法列表】挪到后面
         // array()->lists：原来的方法列表
         memmove(array()->lists + addedCount,
                 array()->lists,
                 oldCount * sizeof(array()->lists[0]));
 
         // 3.将【所有分类的方法列表】拷贝到【原来的方法列表挪动前的位置】
         // addedLists：所有分类的方法列表（二维数组）
         memcpy(array()->lists, addedLists,
                addedCount * sizeof(array()->lists[0]));
 
         // memmove和memcpy的区别：都是拷贝，但memmove会判断方向
         // 如果有重叠的区域那么memcpy就会有问题
         // 例：初始为：1234 --将12挪到中间--> 最终是：1124，重叠区域为第二位
         // 如果是memcpy，固定会先从低地址开始拷贝，所以会从1开始，第一步变成：1134，这时原本的2变成1，再从第2位进行拷贝，最后就变成：1114
         // 如果是memmove，会先判断往哪边挪，例如现在先判断了是往高地址挪，就会先从2开始，第一步变成：1224，最后变成：1124，达成目标
         // 因此，有重叠的地方就用memmove，判断方向防止被覆盖；没有重叠的地方使用memcpy，少了一层判断效率就会快点
         
         // 由此可见，由于分类的方法排在前面，所以分类的方法优先级更高，如果有重名的方法，会优先调用分类的方法
         // 如果多个分类有重名的方法，【后】编译的分类的方法优先级更高，因为循环是while (i--)，是从最后编译的分类开始插入方法，越往后越靠前。
         // PS：如何控制编译顺序？
         // 在 Tatgets -> Build Phases -> Compile Sources 中控制，编译是从上到下的顺序，想调用的优先级高的，就调整编译顺序，往下放。
     }
     else if (!list  &&  addedCount == 1) {
         // 0 lists -> 1 list
         list = addedLists[0];
     }
     else {
         // 1 list -> many lists
         List* oldList = list;
         uint32_t oldCount = oldList ? 1 : 0;
         uint32_t newCount = oldCount + addedCount;
         setArray((array_t *)malloc(array_t::byteSize(newCount)));
         array()->count = newCount;
         if (oldList) array()->lists[addedCount] = oldList;
         memcpy(array()->lists, addedLists,
                addedCount * sizeof(array()->lists[0]));
     }
 }
 */

@end
