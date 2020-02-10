**********************************【1】消息发送阶段 **********************************
【objc-msg-arm64.s】
ENTRY _objc_msgSend
↓
判断消息接收者是否为空 →为空→ LNilOrTagged → LReturnZero → 给空对象发消息 → 退出函数
↓
不为空，查找缓存（参数是NORMAL）
↓
.macro CacheLookup →找到缓存方法→ .macro CacheHit → 执行方法
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
搜索 _class_lookupMethodAndLoadCache3
PS：C语言编写的函数名，编译成汇编后函数名会在前面多了一个“_”，所以搜索汇编里面的C语言函数要去掉第一个“_”
↓
【objc-runtime-new.mm】
_class_lookupMethodAndLoadCache3
↓
【核心代码】lookUpImpOrForward(cls, sel, obj, YES/*initialize*/, NO/*cache*/, YES/*resolver*/);
↓
0.会跳过首次缓存查找（NO/*cache*/），毕竟刚在上面汇编部分找过了，接着往下走
↓
1.又去自己的类对象的缓存里再找一遍，这是为了防止来到这一步时缓存里面已经有了 // Try this class's cache.
↓
cache_getImp →找到了→ goto done → 执行方法
↓
还是找不到
↓
2.去自己的类对象的方法列表查找 // Try this class's method lists.
↓
getMethodNoSuper_nolock
↓
cls->data()->methods 获取类对象的方法列表，搜索列表
↓
search_method_list
↓
如果没排好序，线性查找；
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
找到，填充缓存，放入到【自己的（消息接收者）】cache_t里面。                          ↓
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
triedResolver = YES;
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
*********************************【2】动态方法解析阶段 *********************************


*********************************【3】消息转发阶段 *********************************
【objc-runtime-new.mm】
lookUpImpOrForward
// No implementation found, and method resolver didn't help.
// Use forwarding.
↓
_objc_msgForward_impcache
↓
搜索_objc_msgForward_impcache找不到，就搜__objc_msgForward_impcache，发现在汇编代码里
PS：汇编的函数名会比C语言编写的函数名多了一个“_”，所以搜索汇编的函数要加多一个“_”
↓
【objc-msg-arm64.s】
STATIC_ENTRY __objc_msgForward_impcache
↓
ENTRY __objc_msgForward
↓
__objc_forward_handler
↓
void *_objc_forward_handler = (void*)xxx;
_objc_forward_handler：这是一个存储着函数地址的指针
↓
存储的那个函数是闭源的，无法查看
↓
从【unrecognized selector sent to instance】错误的线程栈里可以看出：
0   CoreFoundation      0x00007fff35096f53 __exceptionPreprocess + 250
1   libobjc.A.dylib     0x00007fff6b166835 objc_exception_throw + 48
2   CoreFoundation      0x00007fff35121106 -[NSObject(NSObject) __retain_OA] + 0
3   CoreFoundation      0x00007fff3503d6cb ___forwarding___ + 1427
4   CoreFoundation      0x00007fff3503d0a8 _CF_forwarding_prep_0 + 120
6   libdyld.dylib       0x00007fff6c4c92e5 start + 1
7   ???                 0x0000000000000001 0x0 + 1
报错前最后调用到【___forwarding___】这个函数，是那个转发的函数
↓
【___forwarding___.c】
查看国外开发者和MJ整理的___forwarding___函数
↓
forwardingTargetForSelector
↓
【JPPerson.m】
- (id)forwardingTargetForSelector:(SEL)aSelector
↓
返回想将消息转发的那个对象forwardingTarget →→→→→→→→→→→
↓                                               ↓
forwardingTarget不为空                           没有重写或返回的forwardingTarget为空，进入下一步
↓                                               ↓
让forwardingTarget去执行这个方法                   获取方法签名
↓                                               ↓
objc_msgSend(forwardingTarget, sel);            methodSignatureForSelector →→→→→→→→→→→→→→
↓                                               ↓                                       ↓
之后就是另一个对象的objc_msgSend过程                返回方法签名                    没有重写或返回空
                                                ↓                                       ↓
              根据方法签名将方法调用者、方法名字、方法参数包装成一个NSInvocation让我们使用          ↓
                                                ↓                                       ↓
                                                forwardInvocation                       ↓
                                                ↓                                       ↓
                                                在这里想做什么都阔以                        ↓
                                                ↓                                       ↓
                                                例：修改target并执行                       ↓
                            [anInvocation invokeWithTarget:[[JPDog alloc] init]];       ↓
                                                ↓                                       ↓
                                  之后就是另一个对象的objc_msgSend过程。                     ↓
                                                                                        ↓
                                                        ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
                                                        ↓
                                            doesNotRecognizeSelector（__retain_OA）
                                                        ↓
                                    报错：【unrecognized selector sent to instance】
*********************************【3】消息转发阶段 *********************************
