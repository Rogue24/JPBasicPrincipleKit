//
//  ViewController.m
//  03-RunLoop-线程保活
//
//  Created by 周健平 on 2019/11/28.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPThread.h"

@interface ViewController ()
@property (nonatomic, strong) JPThread *thread;
@end

@implementation ViewController

/**
 *【RunLoop与线程】
 * 每条线程都有唯一的一个与之对应的RunLoop对象
 * RunLoop 保存在全局的Dictionary，线程作为key，RunLoop作为value ==> @ {线程：RunLoop}
 * 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建（懒加载，主线程的RunLoop是在UIApplicationMain()里面获取过的）
 * RunLoop会在线程结束时销毁（一对一的关系，共生体）
 * 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop
 *
 *【CFRunLoopModeRef】
 * CFRunLoopModeRef代表RunLoop的运行模式
 * 一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer
 * RunLoop启动时只能选择其中一个Mode，作为currentMode
 * 如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入
 * 不同组的Source0/Source1/Timer/Observer能分隔开来，互不影响
 * 如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.thread = [[JPThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [self.thread start];
}

#pragma mark - JPThread的任务

#pragma mark 启动线程的RunLoop
/**
 * 使用RunLoop实现线程保活
 * 让线程存活，不用每次都创建线程，减少开销
 * 节省CPU资源，提高程序性能：该做事时做事，该休息时休息
 */
- (void)run {
    NSLog(@"%s --- %@", __func__, [NSThread currentThread]);
    
    // 线程刚创建时并没有RunLoop对象，第一次获取RunLoop对象时才会创建（[NSRunLoop currentRunLoop]）
    
    // <<RunLoop启动后，如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出>>
    // 添加一个port，相当于添加了个Source，不给退出
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    
    // 启动RunLoop
    [[NSRunLoop currentRunLoop] run];
    // [[NSRunLoop currentRunLoop] run] 相当于下面这两个方法的默认调用：
    // [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    // [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    
    // 启动了RunLoop，就会不断地等待和处理消息，所以线程不会死
    // 并且阻塞当前线程（没事做时会让线程休眠），所以不会执行后面的代码
    // <<真正滴让线程休眠，任何事情都不干，连一句汇编代码都不执行，不占用CPU资源>>
    
    NSLog(@"如果能打印我，就是说明没有阻塞啦，就是说明RunLoop退出啦");
}

#pragma mark 线程任务
- (void)doSomeThing {
    NSLog(@"%s --- %@", __func__, [NSThread currentThread]);
}

#pragma mark - 事件回调
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 线程没事做时，RunLoop会让它休眠，调用performSelector就会唤醒线程去执行任务（Source0）
    [self performSelector:@selector(doSomeThing) onThread:self.thread withObject:nil waitUntilDone:NO];
    // waitUntilDone：是否等待thread的任务执行完再继续下面代码（是否阻塞当前线程）
    
    NSLog(@"%s --- %@", __func__, [NSThread currentThread]);
}

@end
