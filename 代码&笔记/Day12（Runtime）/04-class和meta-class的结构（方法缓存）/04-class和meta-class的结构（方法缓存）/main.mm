//
//  main.m
//  04-class和meta-class的结构（方法缓存）
//
//  Created by 周健平 on 2019/11/11.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPerson.h"
#import "MJClassInfo.h"

#import "JPPomeranin.h"
#import <objc/runtime.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        /**
         * 散列表（哈希表）
         * 牺牲内存换取执行效率 ---> 空间换时间
         * 初始或扩容会开辟一整块内存空间，里面都是`NULL`，预留着存放`bucket_t`
         * 因为方法的`sel`地址是不确定的，但能确定的是`sel & mask`得到的索引值是在散列表范围之内
         * 例如：散列表长度为10，mask则为9，&上这个mask得到的索引值为`0~9`，绝对不会超过9
         *  - 索引值有冲突就-1、散列表都放满了就扩容
         */
        
#pragma mark 验证使用runtime进行方法交换后，会不会影响原先的缓存。
        
        NSLog(@"runtime交换方法，实际上本质交换的是method_t里面imp地址");
        NSLog(@"可是缓存cache_t里面的bucket_t的imp咋办？之后再调用会不会调用回原本的方法？也会影响子类的吗？");
        
        JPPomeranin *dog = [[JPPomeranin alloc] init]; // 1
        
        mj_objc_class *mj_dogCls = (__bridge mj_objc_class *)(dog.class);
        int dog_mask = mj_dogCls->cache._mask; // 散列表长度 - 1
        int dog_length = dog_mask ? (dog_mask + 1) : 0; // 散列表长度
        NSLog(@"一开始：dog_length = %d，临界点为 4 / 4 * 3 = 3", dog_length); // 一开始长度是4，临界点为 4 / 4 * 3 = 3
        
        JPDog *d = [[JPDog alloc] init]; // 1
        mj_objc_class *mj_dCls = (__bridge mj_objc_class *)(d.class);
        int d_mask = mj_dCls->cache._mask; // 散列表长度 - 1
        int d_length = d_mask ? (d_mask + 1) : 0; // 散列表长度
        NSLog(@"父类：d_length = %d", d_length); // 一开始长度是4，临界点为 4 / 4 * 3 = 3
        
        NSLog(@"先调用方法放入缓存");
        [dog test1]; // 2
        [dog test2]; // 3，达到临界点，第一次扩容，清空缓存，长度变成8，新临界点为 8 / 4 * 3 = 6，再放入，缓存数量变成1
        [dog test1]; // 2，刚刚扩容这个方法被清掉了，再次调用重新放入缓存，还没到临界点，不会第二次扩容
        
        // 只要达到临界点就会扩容，不信把注释去掉看看长度是不是变成16。
//        [dog eat1]; // 3
//        [dog eat2]; // 4
//        [dog eat3]; // 5
//        [dog eat4]; // 6
        
        dog_mask = mj_dogCls->cache._mask;
        dog_length = dog_mask ? (dog_mask + 1) : 0;
        NSLog(@"第一次扩容后：dog_length = %d，新临界点为 8 / 4 * 3 = 6", dog_length); // 8
        
//        [d test1]; 2
//        [d test2]; 3
        d_mask = mj_dCls->cache._mask;
        d_length = d_mask ? (d_mask + 1) : 0;
        NSLog(@"子类扩容了，如果父类也缓存的话，那应该也会扩容，看看：d_length = %d", d_length); // 4
        NSLog(@"还是一样，说明子类调用父类的方法，父类不会将其放入缓存。");
        
        NSLog(@"父类交换方法");
        Method originMethod = class_getInstanceMethod([JPDog class], @selector(test1));
        Method exchangeMethod = class_getInstanceMethod([JPDog class], @selector(test2));
        method_exchangeImplementations(originMethod, exchangeMethod);
        dog_mask = mj_dogCls->cache._mask;
        dog_length = dog_mask ? (dog_mask + 1) : 0;
        NSLog(@"交换方法后：dog_length = %d", dog_length); // 8
        
        [dog eat1]; // 3？ 1
        [dog eat2]; // 4？ 2
        [dog eat3]; // 5？ 3
        [dog eat4]; // 6？ 4
        dog_mask = mj_dogCls->cache._mask;
        dog_length = dog_mask ? (dog_mask + 1) : 0;
        NSLog(@"如果没有清空缓存（或者是重新放入缓存），此时数量应该达到临界点，长度就会变为16，看看：dog_length = %d", dog_length); // 8
        NSLog(@"然而实际上并没有出现第二次扩容，说明（自己类或父类）交换方法后，所有缓存都被清空了");
        
        [dog test1]; // 5
        dog_mask = mj_dogCls->cache._mask;
        dog_length = dog_mask ? (dog_mask + 1) : 0;
        NSLog(@"此时数量应该为5，还没到临界点，长度还是8，看看：dog_length = %d", dog_length); // 8
        
        [dog test2]; // 6
        dog_mask = mj_dogCls->cache._mask;
        dog_length = dog_mask ? (dog_mask + 1) : 0;
        NSLog(@"这时候应该达到临界点了，会进行第二次扩容，长度为16，看看：dog_length = %d", dog_length); // 16
        NSLog(@"的确扩容了，说明runtime交换方法会清空方法缓存");
        
        d_mask = mj_dCls->cache._mask;
        d_length = d_mask ? (d_mask + 1) : 0;
        NSLog(@"交换方法后的父类：d_length = %d", d_length); // 8
        NSLog(@"交换方法后父类扩容了，说明runtime交换方法，即便这2个方法从来没调用过，交换过程也会进行是否需要扩容的操作"); // 1 + 2 = 3，达到一开始的临界点，扩容！
        
        NSLog(@"不过缓存也是被清空的，不信看看这样过后扩容没？");
        [d eat1]; // 3？ 1
        [d eat2]; // 4？ 2
        [d eat3]; // 5？ 3
        [d eat4]; // 6？ 4
        d_mask = mj_dCls->cache._mask;
        d_length = d_mask ? (d_mask + 1) : 0;
        NSLog(@"没扩容哦：d_length = %d", d_length); // 8
        
        [d test1]; // 5？ 3
        [d test2]; // 6？ 4
        d_mask = mj_dCls->cache._mask;
        d_length = d_mask ? (d_mask + 1) : 0;
        NSLog(@"这样就扩容了吧：d_length = %d", d_length); // 16
        
        NSLog(@"这次验证说明了：");
        NSLog(@"1.子类调用父类的方法，方法只会放入子类的缓存，不会放入父类的缓存，不影响父类的缓存");
        NSLog(@"2.runtime交换方法中，即便这2个方法从来没调用过，交换过程也会进行是否需要扩容的操作");
        NSLog(@"PS：也就是说，如果这2个方法没缓存过，那么如果当前的缓存数量加2达到了临界点，那就会扩容");
        NSLog(@"3.runtime交换方法后，会【清空】方法缓存（包括其子类的）");
        NSLog(@"综上所述，不用担心调用过的方法其imp被交换后，再调用会不会调用回原本方法，不会有问题的。");
        NSLog(@"=========================================================================");
        
#pragma mark 模拟runtime的方法缓存过程
        NSLog(@"模拟runtime的方法缓存过程");
        
        Class perCls = [JPPerson class];
        mj_objc_class *mj_perCls = (__bridge mj_objc_class *)perCls;
        
        NSMutableDictionary *occupiedArr = [NSMutableDictionary dictionary]; // 已经缓存的方法数组
        __block int mask = mj_perCls->cache._mask; // 散列表长度 - 1
        __block int length = mask ? (mask + 1) : 0; // 散列表长度
        NSLog(@"occupied = %@, length = %d, mask = %d, currentCount = %zd", occupiedArr, length, mask, occupiedArr.count); // 一开始长度是4
        
        JPPerson *per = [[JPPerson alloc] init];
        
        __block NSString *methodName = @"init";
        mask = mj_perCls->cache._mask;
        length = mask + 1;
        uint32_t cacheIndex = (uint32_t)(uintptr_t)NSSelectorFromString(methodName) & mask;
        occupiedArr[@(cacheIndex)] = methodName;
        NSLog(@"occupied = %@, length = %d, mask = %d, currentCount = %zd", occupiedArr, length, mask, occupiedArr.count);
        
        __block NSInteger index = -1;
        void (^abc)(void) = ^{
            BOOL isBreak = NO;
            for (NSInteger i = 0; i < length; i++) {
                if (index >= 0 && index == i) { // 防止执行已经缓存的方法
                    continue;
                }
                
                // 存之前会先判断，如果【已经缓存的方法数量 + 1】超过【散列表长度】的【四分之三】，就会先进行扩容
                if (mj_perCls->cache._mask > mask) {
                    // 需要扩容
                    NSLog(@"(currentCount + 1 = %zd) > (length / 4 * 3 = %d) ==> 扩容", occupiedArr.count + 1, length / 4 * 3);
                    mask = mj_perCls->cache._mask;
                    length = mask + 1;
                    
                    // 清空缓存
                    [occupiedArr removeAllObjects];
                    
                    index = i; // 记录要缓存的方法
                    isBreak = YES;
                }
                // 再进行缓存
                
                switch (i) {
                    case 0:
                        methodName = [per eat1];
                        break;
                    case 1:
                        methodName = [per eat2];
                        break;
                    case 2:
                        methodName = [per eat3];
                        break;
                    case 3:
                        methodName = [per eat4];
                        break;
                    case 4:
                        methodName = [per eat5];
                        break;
                    case 5:
                        methodName = [per eat6];
                        break;
                    case 6:
                        methodName = [per eat7];
                        break;
                    case 7:
                        methodName = [per eat8];
                        break;
                    case 8:
                        methodName = [per eat9];
                        break;
                    case 9:
                        methodName = [per eat10];
                        break;
                    case 10:
                        methodName = [per eat11];
                        break;
                    case 11:
                        methodName = [per eat12];
                        break;
                    default:
                        break;
                }
                
                SEL sel = NSSelectorFromString(methodName); // 获取选择器
                uint32_t cacheIndex = (uint32_t)(uintptr_t)sel & mask; // 用选择器的内存地址&上mask获取索引
                uint32_t begin = cacheIndex;
                do {
                    // do-while会先执行循环体
                    if (!occupiedArr[@(cacheIndex)]) {
                        occupiedArr[@(cacheIndex)] = methodName; // 有空位，存储
                        begin = cacheIndex; // 跳出循环
                    } else {
                        cacheIndex = cacheIndex ? (cacheIndex - 1) : mask; // 这里已经有缓存，索引冲突 ==> 减1往上挪1位
                        begin = cacheIndex ? (cacheIndex - 1) : mask; // 继续循环，或者 begin == cacheIndex，跳出循环
                    }
                } while (cacheIndex != begin); // YES->继续，NO->跳出
                
                NSLog(@"occupied = %@, length = %d, mask = %d, currentCount = %zd", occupiedArr, length, mask, occupiedArr.count);
                
                if (isBreak) {
                    break;
                }
            }
        };
        
        abc();
        abc();
        abc();
    }
    return 0;
}

/*
 * Class 是一个 struct objc_class 的类型（typedef struct objc_class *Class）
 * struct objc_class 在objc源码中是酱紫：
    struct objc_class : objc_object {
        // Class ISA;
        Class superclass;
        cache_t cache; // 方法缓存
        class_data_bits_t bits;
        // 其他方法...
    }
 * struct objc_class 是继承于父类 struct objc_object，他是酱紫：
    struct objc_object {
        isa_t isa;
        // 其他方法...
    }
 * 所以 struct objc_class 可以这样表示：
    struct objc_class {
        Class ISA;
        Class superclass;
        cache_t cache;
        class_data_bits_t bits;
        // 其他方法...
    }
 *
 */

/*
 * 调用方法的步骤：
 * 1.先从自己的chache里面找，找到就调用
 * 2.找不到就去bits(class_rw_t)里面的methods找，找到就调用并放到chache里
 * 3.又找不到就通过superclass去父类的chache里面找，找到就调用并放到自己的chache里
 * 4.又又找不到一样去父类的bits(class_rw_t)里面的methods找，找到就调用并放到自己的chache里
 * 5.又又又找不到就继续通过superclass同样的步骤去找，直到基类，有就调用并放到自己的chache里，都没有就报错。
 *
 * objc_class里的cache结构是cache_t，是用来做方法缓存的，用散列表（哈希表）来缓存曾经调用过的方法，可以提高方法的查找速度
 * 散列表（哈希表）：创建就分配固定大小的内存空间，留空这些空间用来之后缓存，索引是通过SEL&上mask获得（【空间换时间】）
 *
 * cache_t的结构：
     struct cache_t {
         struct bucket_t *_buckets; // 散列表(一维数组，放的是bucket_t结构的元素)
         // XX对象调用xxx方法：objc_msgSend(XX, @selector(xxx))
         // 当第一次调用并找到xxx方法时，就会将SEL作为key和方法地址一起包装成bucket_t放入到_buckets数组里面
         // 当再次调用xxx方法时，会来到_buckets里面去找对应的bucket_t
         // ==> 判断SEL跟bucket_t的key是否一样，是的话就直接拿_imp获取方法地址去调用方法
        
         mask_t _mask; // 散列表的长度 - 1（可以保证&出来的索引值不会超过散列表的长度）
         mask_t _occupied; // 已经缓存的方法数量（<=散列表的长度）
            
         // 其他方法...
     }
 *
 * bucket_t的结构：
    struct bucket_t {
        cache_key_t _key // SEL作为key（SEL：选择器，@selector(xxx)）
        IMP _imp // 函数的内存地址
        // 其他方法...
    }
 *
 * 缓存读写过程：
 * 例：假设buckets的长度为16，
 
    SEL s = @selector(xxx);
    bucket_t *b = buckets();
    mask_t m = mask() = 16 - 1 = 15 = 0b1111;（散列表的长度 - 1）
    mask_t i = s & m = 0~15 = 0b0000~0b1111 <= m;（索引是不会大于mask的）
    
    取：
        do {
            if (b[i].sel() == 0  ||  b[i].sel() == s) {
                // b[i].sel() == 0 -> 空的，找不到，说明没有缓存
                // b[i].sel() == s -> key一样，找到了，说明有缓存
                return &b[i];
            }
        } while ((i = cache_next(i, m)) != begin);
        
        // 因为sel的内存地址不确定，所以多个sel&上mask有一定几率会得到重复的索引
        // 当发现这个索引已经有缓存了，那就去获取下一个索引
        // i ? i-1 : mask; ==> 当i减到0都没有空位，就去到最后一位以此类推继续找
        // 直到发现i位置是空的（不会全部都遍历完的，因为会扩容，总有空位），说明方法压根没有缓存，
        // 这才去方法列表找（遍历），找到就存到缓存中。
 
    存：
        // 先判断是否需要扩容
        // 例如如果现在散列表长度为4，已经存有3个，现在打算要新增1个，存之前判断：(3 + 1 = 4) > (4 / 4 * 3) ==> 扩容、清空缓存
        // 再存：
        bucket_t *bucket = cache->find(sel, receiver);
        if (bucket->sel() == 0) cache->incrementOccupied();
        bucket->set<Atomic>(sel, imp);
        
        // 大概长酱紫：
        do {
            if (b[i].sel() == 0) {  // 为空
                b[i] = bucket_t(_sel = @selector(xxx), _imp); // 存进去
                return;
            }
        } while ((i = cache_next(i, m)) != begin);
        
        // 因为sel的内存地址不确定，所以多个sel&上mask有一定几率会得到重复的索引
        // 当发现这个索引已经有缓存了，那就去获取下一个索引
        // cache_next ==> i ? i-1 : mask ==> 当i减到0都没有空位，就去到最后一位以此类推继续找
        // 不用担心散列表会被填满，永远都会有四分之一的空位
        // 因为存之前会先判断，如果【已经缓存的方法数量 + 1】超过【散列表长度】的【四分之三】，就会进行扩容（同时清空缓存）
 
    获取下一个索引：
        // 应该是按照大小端进行+1还是-1操作
        static inline mask_t cache_next(mask_t i, mask_t mask) {
            // __x86_64__架构：
            return (i+1) & mask;
            // __arm64__架构：
            return i ? i-1 : mask;
        }
 
    扩容：
        // 存之前先判断，如果【已经缓存的方法数量 + 1】超过【散列表长度】的【四分之三】，就会进行扩容
        mask_t newOccupied = cache->occupied() + 1; // 已经缓存的方法数量 + 1
        mask_t capacity = cache->capacity(); // capacity() -> mask()+1 -> 散列表长度
        if (cache->isConstantEmptyCache()) {
            // Cache is read-only. Replace it.
            cache->reallocate(capacity, capacity ?: INIT_CACHE_SIZE);
        }
        else if (newOccupied <= capacity / 4 * 3) {
            // Cache is less than 3/4 full. Use it as-is.
        }
        else {
            // Cache is too full. Expand it.
            cache->expand(); // 扩容
        }
 
        // 扩容
        void cache_t::expand()
        {
            cacheUpdateLock.assertLocked();
            
            uint32_t oldCapacity = capacity();
            uint32_t newCapacity = oldCapacity ? oldCapacity*2 : INIT_CACHE_SIZE; // 容量扩大两倍

            if ((uint32_t)(mask_t)newCapacity != newCapacity) {
                // mask overflow - can't grow further
                // fixme this wastes one bit of mask
                newCapacity = oldCapacity;
            }
            
            reallocate(oldCapacity, newCapacity); // 所有缓存清空
        }
        ↓↓↓
        buckets的长度扩大两倍：16 * 2 = 32
        ↓↓↓
        m = 32 - 1 = 31 = 0b00011111;
        i = s & m = 0~31 = 0b00000000~0b00011111 <= m;
        ↓↓↓
        存
 */
