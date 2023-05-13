**********************************【1】消息发送阶段 **********************************
【objc-msg-arm64.s】
ENTRY _objc_msgSend
↓
判断消息接收者是否为空 -[为空]-> LNilOrTagged → LReturnZero → 给空对象发消息 → 退出函数
↓
不为空，查找缓存（参数是NORMAL）
↓
.macro CacheLookup -[找到缓存方法]-> .macro CacheHit → 执行方法
↓
没有缓存（参数是NORMAL）
↓
.macro CheckMiss
↓
STATIC_ENTRY __objc_msgSend_uncached（参数是NORMAL，对应的是这个）
↓
.macro MethodTableLookup
↓
__class_lookupMethodAndLoadCache3
↓
搜索 _class_lookupMethodAndLoadCache3 // 这是一个C语言函数
PS：C语言编写的函数名，编译成汇编后函数名会在前面多了一个“_”，所以搜索汇编里面的C语言函数要去掉第一个“_”
↓
【objc-runtime-new.mm】
_class_lookupMethodAndLoadCache3
↓
【核心代码】lookUpImpOrForward(cls, sel, obj, YES/*initialize*/, NO/*cache*/, YES/*resolver*/);
↓
0.会跳过首次缓存查找（NO/*cache*/），毕竟刚在上面汇编部分找过了，接着往下走
↓
1.又去自己的类对象的缓存里再找一遍，这是为了防止来到这一步时缓存里面可能已经有了 // Try this class's cache.
↓
cache_getImp -[找到了]-> goto done → 执行方法
↓
还是找不到
↓
2.去自己的类对象的方法列表查找 // Try this class's method lists.
↓
getMethodNoSuper_nolock
↓
cls->data()->methods 获取类对象的方法列表（二维数组），通过for循环，从每一个分类和本类原有的方法列表中搜索
↓
search_method_list
↓
如果没排好序，线性查找（普通for循环）；
如果排好序的，二分查找（findMethodInSortedMethodList，每一次拿中间值对比，不是就对比大小确定在左半部分还是右半部分，再取那部分的中间值来对比，以此类推）
↓                    ↓
找不到                找到，填充缓存，放入到cache_t里面
↓                    ↓
↓                    log_and_fill_cache → cache_fill → cache_fill_nolock
↓                    ↓
↓                    goto done
↓                    ↓
↓                    执行方法
↓
3.去自己的父类的类对象的缓存和方法列表查找 // Try superclass caches and method lists.
↓
通过for循环使用superclass不断一层一层地往上找父类
(Class curClass = cls->superclass; curClass != nil; curClass = curClass->superclass)
↓                                                               ↑
找到父类                                                      往上找父类 → 没有父类了
↓                                                               ↑          ↓
cache_getImp、getMethodNoSuper_nolock，跟查找自己类对象的方式一样 → 找不到        ↓
↓                                                                          ↓
找到，填充缓存，放入到【自己（消息接收者）】的cache_t里面。                          ↓
↓                                                                          ↓
log_and_fill_cache → cache_fill → cache_fill_nolock                        ↓
↓                                                                          ↓
goto done                                                                  ↓
↓                                                                          ↓
执行方法。                                                                   ↓
                                                                           ↓
                   当在自己的类对象的缓存和方法列表、以及所有父类的类对象的缓存和方法列表中统统都找不到
                                                                           ↓
                                                                  进入【动态方法解析】阶段
                                                                           ↓
                                                                      resolveMethod
**********************************【1】消息发送阶段 **********************************


*********************************【2】动态方法解析阶段 *********************************
【objc-runtime-new.mm】
lookUpImpOrForward
// No implementation found. Try method resolver once.
↓
resolveMethod →→→→→→→→→→→→→→→→→→→
↓                               ↓
类对象（实例方法）                元类对象（类方法）
↓                               ↓
resolveInstanceMethod         resolveClassMethod
↓                               ↓
【JPPerson.m】←←←←←←←←←←←←←←←←←←←←
↓
resolveInstanceMethod、resolveClassMethod →→→→→→→→→→→→→→→→→→→→→→→→→
↓                                                                 ↓
动态添加方法                                                    没重写或不添加
↓                                                                 ↓
class_addMethod                                                   ↓
↓                                                                 ↓
添加类/元类对象(objc_class)的bits(class_rw_t)的方法列表(methods)里去    ↓
↓                                                                 ↓
回去刚刚的代码继续。                                                  ↓
↓                                                                 ↓
【objc-runtime-new.mm】←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
回到lookUpImpOrForward继续后面的
↓
标记已经动态解析了
↓
triedResolver = YES; // 这里是写死的YES，并不是resolveXXXMethod返回的布尔值，因此不会重复
↓
goto retry;
↓
回到前面的 // Try this class's cache.
从缓存处开始重新再找一轮，不过这次不会进行动态解析（已经标记过）
↓                      ↓
刚刚有添加               刚刚没添加
↓                      ↓
肯定能找到方法           肯定找不到方法
↓                      ↓
goto done              跳过解析判断
↓                      ↓
放入缓存，执行方法        进入【消息转发】阶段
                       ↓
                       _objc_msgForward_impcache

为什么动态解析后要回去前面重新走一遍查找方法流程？
- 因为如果动态解析阶段添加了方法，那新方法也是放在【方法列表】里面，所以肯定要回去找啦
- 况且已经标记了，就算回去前面找不到，也不会重复再走一遍动态解析的
*********************************【2】动态方法解析阶段 *********************************




// ============= _objc_msgSend ===============
    ENTRY _objc_msgSend
    UNWIND _objc_msgSend, NoFrame

    //【p0寄存器：消息接收者，receiver】
    cmp    p0, #0            // nil check and tagged pointer check
#if SUPPORT_TAGGED_POINTERS
    //【b：跳转，le：条件是否小于等于0】
    b.le    LNilOrTagged        //  (MSB tagged pointer looks negative)【判断消息接收者是否<=0，即消息接收者是否为空，是的话就来到这里】
#else
    b.eq    LReturnZero
#endif
    ldr    p13, [x0]        // p13 = isa
    GetClassFromIsa_p16 p13        // p16 = class
LGetIsaDone:
    CacheLookup NORMAL        // calls imp or objc_msgSend_uncached【消息接收者不为空就来到这里，查找缓存，参数是NORMAL】

#if SUPPORT_TAGGED_POINTERS
LNilOrTagged:
    b.eq    LReturnZero        // nil check 【消息接收者为空来到这里，执行LReturnZero】

    // tagged
    adrp    x10, _objc_debug_taggedpointer_classes@PAGE
    add    x10, x10, _objc_debug_taggedpointer_classes@PAGEOFF
    ubfx    x11, x0, #60, #4
    ldr    x16, [x10, x11, LSL #3]
    adrp    x10, _OBJC_CLASS_$___NSUnrecognizedTaggedPointer@PAGE
    add    x10, x10, _OBJC_CLASS_$___NSUnrecognizedTaggedPointer@PAGEOFF
    cmp    x10, x16
    b.ne    LGetIsaDone

    // ext tagged
    adrp    x10, _objc_debug_taggedpointer_ext_classes@PAGE
    add    x10, x10, _objc_debug_taggedpointer_ext_classes@PAGEOFF
    ubfx    x11, x0, #52, #8
    ldr    x16, [x10, x11, LSL #3]
    b    LGetIsaDone
// SUPPORT_TAGGED_POINTERS
#endif

LReturnZero:
    // x0 is already zero
    mov    x1, #0
    movi    d0, #0
    movi    d1, #0
    movi    d2, #0
    movi    d3, #0
    ret //【相当于return，退出这个函数】

    END_ENTRY _objc_msgSend
// ============= _objc_msgSend ===============

// ============= CacheLookup ===============
.macro CacheLookup //【查找缓存方法，参数是NORMAL】
    // p1 = SEL, p16 = isa
    ldp    p10, p11, [x16, #CACHE]    // p10 = buckets, p11 = occupied|mask
#if !__LP64__
    and    w11, w11, 0xffff    // p11 = mask
#endif
    and    w12, w1, w11        // x12 = _cmd & mask
    add    p12, p10, p12, LSL #(1+PTRSHIFT)
                     // p12 = buckets + ((_cmd & mask) << (1+PTRSHIFT))

    ldp    p17, p9, [x12]        // {imp, sel} = *bucket
1:    cmp    p9, p1            // if (bucket->sel != _cmd)
    b.ne    2f            //     scan more
    CacheHit $0            // call or return imp【命中，查找到缓存方法】
    
2:    // not hit: p12 = not-hit bucket
    CheckMiss $0            // miss if bucket->sel == 0【没查找到缓存方法】
    cmp    p12, p10        // wrap if bucket == buckets
    b.eq    3f
    ldp    p17, p9, [x12, #-BUCKET_SIZE]!    // {imp, sel} = *--bucket
    b    1b            // loop

3:    // wrap: p12 = first bucket, w11 = mask
    add    p12, p12, w11, UXTW #(1+PTRSHIFT)
                                // p12 = buckets + (mask << 1+PTRSHIFT)

    // Clone scanning loop to miss instead of hang when cache is corrupt.
    // The slow path may detect any corruption and halt later.

    ldp    p17, p9, [x12]        // {imp, sel} = *bucket
1:    cmp    p9, p1            // if (bucket->sel != _cmd)
    b.ne    2f            //     scan more
    CacheHit $0            // call or return imp
    
2:    // not hit: p12 = not-hit bucket
    CheckMiss $0            // miss if bucket->sel == 0
    cmp    p12, p10        // wrap if bucket == buckets
    b.eq    3f
    ldp    p17, p9, [x12, #-BUCKET_SIZE]!    // {imp, sel} = *--bucket
    b    1b            // loop

3:    // double wrap
    JumpMiss $0
    
.endmacro
// ============= CacheLookup ===============

// ============= CheckMiss ===============
.macro CheckMiss //【参数是NORMAL】
    // miss if bucket->sel == 0
.if $0 == GETIMP
    cbz    p9, LGetImpMiss
.elseif $0 == NORMAL
    cbz    p9, __objc_msgSend_uncached //【==> MethodTableLookup ==> __class_lookupMethodAndLoadCache3 ==> lookUpImpOrForward(cls, sel, obj, YES, NO, YES)】
.elseif $0 == LOOKUP
    cbz    p9, __objc_msgLookup_uncached
.else
.abort oops
.endif
.endmacro

.macro JumpMiss
.if $0 == GETIMP
    b    LGetImpMiss
.elseif $0 == NORMAL
    b    __objc_msgSend_uncached
.elseif $0 == LOOKUP
    b    __objc_msgLookup_uncached
.else
.abort oops
.endif
.endmacro
// ============= CheckMiss ===============
