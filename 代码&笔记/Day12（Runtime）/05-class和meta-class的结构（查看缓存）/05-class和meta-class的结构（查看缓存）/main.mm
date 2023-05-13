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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat"

void lookCaches(mj_objc_class *mj_cls) {
    cache_t cache = mj_cls->cache;
    bucket_t *buckets = cache._buckets;
    
    /*
     * 目前的遗留问题：
     * 1. 本来这里应该用”<=“来判断，不过访问最后一个时会坏内存访问，按照MJ的说法和源码可以看到，&上mask得出的下标最大不会超过mask，最大包括mask，那最后一个的内存空间应该是有分配的，可是这里会崩，
        - 个人猜测：应该最后一个索引（mask）是不给用的，会寻找下一个索引，反正散列表肯定至少会有一个空留的位置，空出最后一个操作系统会比较好计算吧
     * 2. cache._occupied 和 cache.imp(bucket._imp) 的值有问题，有可能是新版的源码改了规则吧
     */
    for (int i = 0; i < cache._mask; i++) {
        bucket_t bucket = buckets[i];
        NSLog(@"%d, %s(%lu), %p", i, bucket._key, bucket._key, bucket._imp);
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        Class sbStuCls = [JPSBStudent class];
        mj_objc_class *mj_sbStuCls = (__bridge mj_objc_class *)sbStuCls;
        
        JPSBStudent *sbStu = [[JPSBStudent alloc] init]; // 1
        
        [sbStu sbStudentTest]; // 2
        
//        NSLog(@"--------- 扩容前遍历 begin ---------");
//        lookCaches(mj_sbStuCls);
//        NSLog(@"--------- 扩容前遍历 end ---------");
        
        NSLog(@"调用studentTest方法前，发现缓存快满了，得先扩容");
        // 包括基类的init方法也会清掉的喔~
        [sbStu studentTest]; // 3 -> 1
        NSLog(@"扩容后，清空了之前的缓存，然后才放入现在调用的studentTest方法");
        
//        NSLog(@"--------- 扩容后遍历 begin ---------");
//        lookCaches(mj_sbStuCls);
//        NSLog(@"--------- 扩容后遍历 end ---------");
        
        NSLog(@"之前调用的方法得再次调用，重新放入缓存");
        [sbStu sbStudentTest]; // 2
        [sbStu personTest]; // 3
        
        NSLog(@"全部缓存好了，下面开始查看\n");
        
        cache_t cache = mj_sbStuCls->cache;
        bucket_t *buckets = cache._buckets;
        
        SEL sel1 = @selector(studentTest);
        SEL sel2 = @selector(sbStudentTest);
        SEL sel3 = @selector(personTest);
        
        // 由于内存地址不是固定的，所以有可能会有重复的索引
        NSLog(@"mask: %d", cache._mask);
        NSLog(@"sel1: %lu, sel2: %lu, sel3: %lu", (long long)sel1, (long long)sel2, (long long)sel3);
        NSLog(@"index1: %lu, index2: %lu, index3: %lu", (long long)sel1 & cache._mask, (long long)sel2 & cache._mask, (long long)sel3 & cache._mask);
        
        //【1】遍历
        NSLog(@"--------- 完整遍历 begin ---------");
        lookCaches(mj_sbStuCls);
        NSLog(@"--------- 完整遍历 ended ---------\n");
        
        //【2】直接通过索引
        // 注意：不同的sel&mask得到的索引有可能是【重复的】，因此直接通过索引获取的bucket有可能不是想要的那个
        NSLog(@"--------- 直接通过索引 begin ---------");
        int index1 = (long long)sel1 & cache._mask;
        bucket_t bucket1 = buckets[index1];
        NSLog(@"%d, %s(%lu), %p", index1, sel1, sel1, bucket1._imp);
        
        int index2 = (long long)sel2 & cache._mask;
        bucket_t bucket2 = buckets[index2];
        NSLog(@"%d, %s(%lu), %p", index2, sel2, sel2, bucket2._imp);
        
        int index3 = (long long)sel3 & cache._mask;
        bucket_t bucket3 = buckets[index3];
        // 可能会有索引重复的情况（这里只是演示，才判断了一种情况）
        //  - 实际上通过索引获取，如果不为空还得判断key（也就是sel）是否一致，具体去看`cache.imp(sel1)`里面的实现。
        if (index3 == index1 || index3 == cache._mask) {
            if (index3 == index1) {
                NSLog(@"index3与index1重复了！寻找下一个索引！");
            } else {
                NSLog(@"居然是最后一个索引 %d，不给用的，寻找下一个索引！", index3);
            }
            // x86_64架构获取【下一个索引】的方式是：(i+1) & mask; // 参考MJClassInfo_New
            while (index3 == index1 || index3 == cache._mask) { // 不能用最后一个索引(mask)！会崩！
                index3 = (index3 + 1) & cache._mask;
            }
            bucket3 = buckets[index3];
        }
        NSLog(@"%d, %s(%lu), %p", index3, sel3, sel3, bucket3._imp);
        NSLog(@"--------- 直接通过索引 ended ---------\n");
        
        //【3】仿照源码获取
        NSLog(@"--------- 仿照源码获取 begin ---------");
        NSLog(@"%s(%lu), %p", sel1, sel1, cache.imp(sel1));
        NSLog(@"%s(%lu), %p", sel2, sel2, cache.imp(sel2));
        NSLog(@"%s(%lu), %p", sel3, sel3, cache.imp(sel3));
        NSLog(@"--------- 仿照源码获取 ended ---------\n");
        
//        IMP imp = cache.imp(sel1);
//        NSLog(@"%p", imp);
        
        NSLog(@"over~~~");
    }
    return 0;
}

#pragma clang diagnostic pop
