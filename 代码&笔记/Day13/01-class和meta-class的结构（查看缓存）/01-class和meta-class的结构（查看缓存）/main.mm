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
        
        NSLog(@"----------扩容了---------");
        [sbStu sbStudentTest];
        
        [sbStu personTest];
        [sbStu studentTest];
        
        NSLog(@"---------------------");
        
        cache_t cache = mj_sbStuCls->cache;
        bucket_t *buckets = cache._buckets;
        
        //【1】遍历
        for (int i = 0; i <= cache._mask; i++) {
            bucket_t bucket = buckets[i];
            NSLog(@"遍历 %d %lu %p", i, bucket._key, bucket._imp);
        }
        
        //【2】直接通过索引
        // 不同的sel&mask得到的索引有可能会有重复的，得到的bucket有可能不是想要的那个
        SEL sel = @selector(sbStudentTest);
        int i = (long long)sel & cache._mask;
        bucket_t bucket = buckets[i];
        NSLog(@"直接通过索引 %d %s(%lu) %p", i, (char *)sel, (NSInteger)sel, bucket._imp);
        
        //【3】仿照源码获取
        SEL sel1 = @selector(personTest);
        NSLog(@"仿照源码获取 %s(%lu) %p", (char *)sel1, (NSInteger)sel1, cache.imp(sel1));
        
        SEL sel2 = @selector(studentTest);
        NSLog(@"仿照源码获取 %s(%lu) %p", (char *)sel2, (NSInteger)sel2, cache.imp(sel2));
        
        SEL sel3 = @selector(sbStudentTest);
        NSLog(@"仿照源码获取 %s(%lu) %p", (char *)sel3, (NSInteger)sel3, cache.imp(sel3));
        
//        IMP imp = cache.imp(@selector(sbStudentTest));
//        NSLog(@"%p", imp);
        
        NSLog(@"hhhhhhhhhh");
    }
    return 0;
}
