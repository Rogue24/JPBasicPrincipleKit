//
//  JPSynchronizedDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * @synchronized 是对 pthread_mutex 递归锁的封装（最新的版本是对 os_unfair_recursive_lock 进行的封装）后的一个类（C++）
 * 源码查看：objc4 中的 objc-sync.mm 文件（objc_sync_enter、objc_sync_exit）
 * @synchronized(obj) 内部会生成obj对应的递归锁，然后进行加锁、解锁操作
 * 底层中是用这个 obj 当作 key 去 StripedMap（是一个哈希表，作用类似于字典）来获取对应的 SyncData 对象（🔐放在这个对象里面）
 * <<由于结构过于复杂，所以性能最差>>
 */

@interface JPSynchronizedDemo : JPBaseDemo

@end
