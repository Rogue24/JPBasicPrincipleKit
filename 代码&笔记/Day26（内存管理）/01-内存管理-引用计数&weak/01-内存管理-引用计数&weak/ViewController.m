//
//  ViewController.m
//  04-内存管理-weak
//
//  Created by 周健平 on 2019/12/18.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPPerson.h"

/*
 * 在64bit中，引用计数可以直接存储在优化过的isa指针中，也可能存储在SideTable类中
     union isa_t {
         isa_t() { }
         isa_t(uintptr_t value) : bits(value) { }
         Class cls;
         uintptr_t bits; // 共用体（union）结构
         struct {        // 使用位域来存储更多的信息
             // 低字节
             uintptr_t nonpointer
             uintptr_t has_assoc
             uintptr_t has_cxx_dtor
             uintptr_t shiftcls
             uintptr_t magic
             uintptr_t weakly_referenced ==> 是否有被弱引用指向【过】（不管现在有没有被弱引用指向，只要被指向过都为1），如果没有，释放时会更快
             uintptr_t deallocating
             uintptr_t has_sidetable_rc ==> 引用计数器是否过大的标识，如果太大isa不够放，那么额外的引用计数会存储在SideTable类中
             uintptr_t extra_rc ===> 存储的值是引用计数的总数减1（例如现在引用计数是3，这里就存储着2）
             // 高字节
         };
     };
 
 * 查看OC源码：
 * 获取引用计数retainCount：
     - (NSUInteger)retainCount {
         return ((id)self)->rootRetainCount();
     }
                    ↓↓↓↓
 * rootRetainCount：
     inline uintptr_t
     objc_object::rootRetainCount()
     {
         if (isTaggedPointer()) return (uintptr_t)this; ==> TaggedPointer是没有引用计数的，值为-1

         sidetable_lock();
         isa_t bits = LoadExclusive(&isa.bits);
         ClearExclusive(&isa.bits);
         if (bits.nonpointer) { ==> 是否为优化过的isa
             uintptr_t rc = 1 + bits.extra_rc; ==> 获取引用计数
             if (bits.has_sidetable_rc) { ==> 是否标识过大
                 rc += sidetable_getExtraRC_nolock(); ==> 过大就去SideTable获取剩余的引用计数
             }
             sidetable_unlock();
             return rc;
         }

         sidetable_unlock();
         return sidetable_retainCount();
     }
                    ↓↓↓↓
 * sidetable_getExtraRC_nolock：
     size_t
     objc_object::sidetable_getExtraRC_nolock()
     {
         assert(isa.nonpointer);
         SideTable& table = SideTables()[this]; ==> 拿到SideTable
         RefcountMap::iterator it = table.refcnts.find(this); ==> 从refcnts获取引用计数
         if (it == table.refcnts.end()) return 0;
         else return it->second >> SIDE_TABLE_RC_SHIFT;
     }
 
 * SideTable里面的refcnts（RefcountMap）是存放着对象引用计数的散列表
 */

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 在218会讲解面试题
    
    __strong JPPerson *per1;
    __weak JPPerson *per2;
    __unsafe_unretained JPPerson *per3;
    
    {
        JPPerson *per = [[JPPerson alloc] init];
        per2 = per;
        per2 = nil;
        per1 = per;
        per1 = nil;
        per3 = per;
        
        NSLog(@"prepare to dead");
        
        // ARC是【LLVM编译器】和【Runtime系统】相互协助的一个结果
        // LLVM：例如在某个作用域的{}即将结束的时候，自动对里面的对象调用release方法
        // Runtime：例如weak指针的实现，在程序运行的过程中，监控到对象要销毁时会去清空对象的弱引用
    }
    
#warning __unsafe_unretained修饰的指针：对象被销毁后不会自动置nil，继续访问会造成坏内存访问
    NSLog(@"嗨 -- %@", per3);
    
    /**
     * __weak和__unsafe_unretained
     * 共同点：都不会产生强引用
     * 区别：__weak会在对象被销毁时会自动指向nil，__unsafe_unretained不会改变指向，对象被销毁后继续访问会造成坏内存访问
     */
    
    /*
     * __weak的实现原理：
     * 对象的弱指针存储在SideTable的weak_table中
     * 当对象销毁时会执行dealloc方法，底层实现：
        1. _objc_rootDealloc
        2. rootDealloc
        3.
            inline void
            objc_object::rootDealloc()
            {
                if (isTaggedPointer()) return;  // fixme necessary?

                if (fastpath(isa.nonpointer  &&
                             !isa.weakly_referenced  &&
                             !isa.has_assoc  &&
                             !isa.has_cxx_dtor  &&
                             !isa.has_sidetable_rc))
                {
                    assert(!sidetable_present());
                    free(this); ==> 很干净，直接销毁
                }
                else {
                    object_dispose((id)this); ==>【有诸如被弱引用过的操作，不会马上释放，先来这里】
                }
            }
        4. object_dispose
        5. objc_destructInstance -> free 释放
                    ↓↓↓
             void *objc_destructInstance(id obj)
             {
                 if (obj) {
                     // Read all of the flags at once for performance.
                     bool cxx = obj->hasCxxDtor(); ==> 是否有成员变量
                     bool assoc = obj->hasAssociatedObjects(); ==> 是否有关联对象

                     // This order is important.
                     if (cxx) object_cxxDestruct(obj); ==> 清除成员变量
                     if (assoc) _object_remove_assocations(obj); ==> 清除关联对象
                     obj->clearDeallocating(); ==>【将指向当前对象的弱指针置为nil】
                 }

                 return obj;
             }
        6. clearDeallocating -> clearDeallocating_slow
        7. weak_clear_no_lock(&table.weak_table, (id)this) ==> SideTable里面有个weak_table，专门存放弱指针
        8. weak_entry_for_referent ==> 从弱引用表里面找出entry（弱指针表是个散列表，要用掩码获取索引查找）
        9. 回到7，接着执行weak_entry_remove(weak_table, entry) ==> 通过entry清除弱引用表里面存储的弱引用
       10. 回到6，接着判断如果SideTable有引用计数，去清空引用计数
       11. 回到5，返回obj，接着free
     
     * SideTable的结构：
         struct SideTable {
             spinlock_t slock;
             RefcountMap refcnts; ==> 存放着对象的引用计数的散列表（超过isa的extra_rc范围的引用计数）
             weak_table_t weak_table; ==> 存放着对象的弱指针的散列表
         };
     */
}


@end
