//
//  JPSynchronizedDemo.h
//  01-多线程-线程同步（各种方案）
//
//  Created by 周健平 on 2019/12/9.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPBaseDemo.h"

/**
 * `@synchronized`是一个对`pthread_mutex`递归锁封装后的C++类
 *  - 最新的版本是对`os_unfair_recursive_lock`进行的封装
 *
 * `@synchronized(obj)`内部会生成`obj`对应的【递归锁】，用于进行加锁、解锁操作
 *  - 递归🔐：允许【同一个线程】对同一把🔐进行【重复】加🔐
 *
 * 源码查看：`objc4`中的`objc-sync.mm`文件（`objc_sync_enter`、`objc_sync_exit`）
 * 底层使用了哈希表的结构：用这个`obj`对象当作`key`去`StripedMap`中获取对应的`SyncData`对象，然后进行加锁、解锁操作
 *  - `StripedMap`是一个哈希表，作用类似于字典
 *  - `SyncData`是一个结构体，里面存放着🔐，而这个🔐是一个封装了`pthread_mutex`递归锁的C++类
 *
 * 不建议使用:【由于结构过于复杂，所以性能最差】
 */

@interface JPSynchronizedDemo : JPBaseDemo

@end
