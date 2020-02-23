//
//  ViewController.m
//  03-RunLoop-线程保活
//
//  Created by 周健平 on 2019/11/28.
//  Copyright © 2019 周健平. All rights reserved.
//
//  问题：退出vc后停止RunLoop崩溃、退出vc后thread没死、停止RunLoop后退出vc崩溃
//  MJ做法：
//  1.【waitUntilDone:YES】--> performSelector去执行stopRunLoop，waitUntilDone设置为YES，确保停止RunLoop的过程中不会坏内存访问
//  2.【weakSelf && !weakSelf.isStoped】--> 防止vc销毁后继续启动RunLoop
//  3.【self.thread = nil】+【if (!self.thread) return】--> 防止停止RunLoop后继续让线程做事情，这样会报错（因为waitUntilDone:YES）
//  我的做法：
//  1.【weakSelf && !weakSelf.isStoped】
//  2. 将-stopRunLoop改成+stopRunLoop:，参数为vc，退出时传nil，其他没改，这样就能防止坏内存访问，因为类对象不会被销毁

#import "ViewController.h"
#import "JPThread.h"

@interface ViewController ()
@property (nonatomic, strong) JPThread *thread;
@property (nonatomic, assign) BOOL isStoped;
@end

@implementation ViewController

/*
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

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * 使用RunLoop实现线程保活
     * 让线程存活，不用每次都创建线程，减少开销
     * 节省CPU资源，提高程序性能：该做事时做事，该休息时休息
     */
    __weak typeof(self) weakSelf = self;
    self.thread = [[JPThread alloc] initWithBlock:^{
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        
        while (weakSelf && !weakSelf.isStoped) {
            NSLog(@"如果能打印我，就是说明开启了新的RunLoop啦！等着做事情~");
            
            // runMode:beforeDate: ==> 当任务执行完runloop就会自动退出，没有任务时就让线程休眠
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            // PS：线程没任务时，这里并不是一直while循环，只有收到消息，才会唤醒线程去执行，执行完之后才会进入下一次循环
            
            NSLog(@"如果能打印我，就是说明这一次的RunLoop退出啦！继续下一轮循环去~");
        }
        
        NSLog(@"如果能打印我，就是说明RunLoop彻底退出啦！！！");
    }];
    [self.thread start];
}

- (void)dealloc {
    [self stopAction];
    NSLog(@"%s", __func__);
}

#pragma mark - 分发给JPThread的任务
- (void)doSomeThing {
    NSLog(@"%s --- %@", __func__, [NSThread currentThread]);
}

- (void)stopRunLoop {
    NSLog(@"%s --- %@", __func__, [NSThread currentThread]);
    
    // 设置标记为YES，停止启动RunLoop的循环
    self.isStoped = YES;
    
    // 停止RunLoop
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    // 清空线程，防止之后继续让线程去做事情
    // 因为线程的RunLoop已经停止工作了（线程本来的{}已经执行完了），不能再处理事情了
    // 继续让该线程做事情可能会报错（例如：performSelector去执行doSomeThing，waitUntilDone设置为YES，肯定报错，线程都没了，永远等不到）
    self.thread = nil;
}

#pragma mark - 事件回调
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 先判断子线程是否还存活
    if (!self.thread) return;
    
    // 线程没事做时，RunLoop会让它休眠，调用performSelector就会唤醒线程去执行任务（Source0）
    [self performSelector:@selector(doSomeThing) onThread:self.thread withObject:nil waitUntilDone:NO];
    // waitUntilDone：是否等待thread的任务执行完再继续下面代码（是否阻塞当前线程）
}

- (IBAction)stopAction {
    // 先判断子线程是否还存活
    if (!self.thread) return;
    
    /*
     * 在dealloc中使用performSelector去执行stopRunLoop，这种方式stopRunLoop会迟一点点才开始执行，很有可能dealloc执行完stopRunLoop才开始执行，由于dealloc执行完self就立马被销毁，所以当stopRunLoop用到self时，self很大几率是死了的，因此造成坏内存访问。
     * 解决方法：waitUntilDone:YES
     * 意思是，在dealloc方法过程中，必须得等stopRunLoop执行完才继续后面代码（在dealloc方法的作用域内self就死不了）
     * 这样可以确保stopRunLoop方法内的self没有被销毁，能彻底执行完（停止RunLoop）
     */
    [self performSelector:@selector(stopRunLoop) onThread:self.thread withObject:nil waitUntilDone:YES];
}

@end
