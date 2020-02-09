//
//  main.m
//  01-class和meta-class的结构（查看缓存）
//
//  Created by 周健平 on 2019/11/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPSBStudent.h"
#import "MJClassInfo_New.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        Class sbStuCls = [JPSBStudent class];
        mj_objc_class *mj_sbStuCls = (__bridge mj_objc_class *)sbStuCls;
//        cache_t cache = mj_sbStuCls->cache;
//        bucket_t *buckets = cache._buckets;
        
        JPSBStudent *sbStu = [[JPSBStudent alloc] init];
        
        [sbStu personTest];
        [sbStu studentTest];
        
        NSLog(@"扩容了，之前的缓存被清空，再次调用放入缓存");
        [sbStu sbStudentTest];
        
        [sbStu personTest];
        [sbStu studentTest];
        
        NSLog(@"缓存好了，下面开始查看");
        
        cache_t cache = mj_sbStuCls->cache;
        bucket_t *buckets = cache._buckets;
        
        //【1】遍历
        for (int i = 0; i < cache._mask; i++) { // PS：本来这里应该用”<=“，不过访问最后一个时会坏内存访问，按照MJ的说法和源码可以看到，&上mark得出的下标最大不会超过mask，最大包括mark，那最后一个的内存空间应该是有分配的，可是这里会崩，有点出入，可能iOS13的源码改了规则。（**目前遗留问题**）
            bucket_t bucket = buckets[i];
            NSLog(@"遍历ing %d, %s(%lu), %p", i, bucket._key, bucket._key, bucket._imp);
        }
        
        //【2】直接通过索引
        // PS：不同的sel&mask得到的索引有可能会有重复的，得到的bucket有可能不是想要的那个
        SEL sel = @selector(sbStudentTest);
        int i = (long long)sel & cache._mask;
        bucket_t bucket = buckets[i];
        NSLog(@"直接通过索引 %d, %s(%lu), %p", i, sel, sel, bucket._imp);
        
        //【3】仿照源码获取
        SEL sel1 = @selector(personTest);
        NSLog(@"仿照源码获取 %s(%lu), %p", sel1, sel1, cache.imp(sel1));
        
        SEL sel2 = @selector(studentTest);
        NSLog(@"仿照源码获取 %s(%lu), %p", sel2, sel2, cache.imp(sel2));
        
        SEL sel3 = @selector(sbStudentTest);
        NSLog(@"仿照源码获取 %s(%lu), %p", sel3, sel3, cache.imp(sel3));
        
//        IMP imp = cache.imp(@selector(sbStudentTest));
//        NSLog(@"%p", imp);
        
        NSLog(@"hhhhhhhhhh");
    }
    return 0;
}
