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
        
        /*
         * [[NSRunLoop currentRunLoop] run];
         * NSRunLoop的run方法是无法停止的，它专门用于开启一个永不销毁的线程（NSRunLoop）。
         *
         * - (void)run方法的文档解释+翻译：
         * if no input sources or timers are attached to the run loop, this method exits immediately;
           如果在运行循环中没有输入源或定时器，则该方法立即退出；
         * otherwise, it runs the receiver in the NSDefaultRunLoopMode by repeatedly invoking runMode:beforeDate:.
           否则，它将通过重复调用runMode:beforeDate:，在NSDefaultRunLoopMode中运行接收器。
         * In other words, this method effectively begins an infinite loop that processes data from the run loop’s input sources and timers.
           换句话说，该方法有效地开始了一个无限循环，该循环处理来自运行循环的输入源和计时器的数据。
         *
         * 也就是说，当添加了port（source），调用run，底层会开启一个无限循环去执行<<-runMode:beforeDate:>>方法。
         * 相当于酱紫：
             while (1) {
                 // [NSDate distantFuture]：遥远的未来
                 // beforeDate:[NSDate distantFuture]：在这个未来到来之前一直运行，保证永不超时（除非你能活几百年）
                 [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
             }
         * -runMode:beforeDate: ==> 开启RunLoop，阻塞（休眠）当前线程
         * 当线程有任务了，RunLoop让线程去执行任务，执行完RunLoop就会自动退出，继续下面代码
         * 默认的 -run 方法其实就是套个while(1)循环调用 -runMode:beforeDate: 来实现线程不被销毁 --- 不断开启RunLoop
         *
         * 由于套上了一层死循环，一次的循环结束了接着又是新一轮循环的开始（闲->睡，忙->干）
         * PS：即使调用了CFRunLoopStop去停止，在底层也只是【停止当前这一次】的循环
         * 所以Runloop对象使用 [[NSRunLoop currentRunLoop] run] 这种方式来启动的话是无法停止的。
         */
        
        // ----------------【解决方案】----------------
        // 不使用 [[NSRunLoop currentRunLoop] run]，自定义RunLoop的启动（仿照run方法内部的做法）
        // <<自定义标识条件，每次循环先判断条件是否继续开启>> --- weakSelf && !weakSelf.isStoped
        while ([ViewController isContinue:weakSelf]) {
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
    NSLog(@"%s", __func__);
    [self.class performSelector:@selector(stopRunLoop:) onThread:self.thread withObject:nil waitUntilDone:NO];
}

#pragma mark - 开启条件的判断

+ (BOOL)isContinue:(ViewController *)vc {
    // 1: self还活着（Block捕获的self不能强引用，否则会循环引用）
    BOOL isNoDie = vc != nil;
    
    // 2: 标识isStoped是否为NO（是否停止）
    BOOL isStoped = vc.isStoped;
    
    // 1+2: 确保此时self还活着且isStoped为NO，条件才成立（因为标识isStoped是self的属性，self死了的话永远都是NO）
    BOOL isContinue = isNoDie && !isStoped;
    NSLog(@"开启RunLoop不？%@", isContinue ? @"开咯嘛！" : @"开个毛线");
    
    return isContinue;
}

#pragma mark - 分发给JPThread的任务

#pragma mark 干活
- (void)doSomeThing {
    NSLog(@"%s --- %@", __func__, [NSThread currentThread]);
}

#pragma mark 去死
/**
 * 停止RunLoop的任务不能给到实例对象去调用！
 * 因为在自动退出的情况下，实例对象dealloc后就已经销毁了，再用ta来performSelector会造成坏内存访问
 */
+ (void)stopRunLoop:(ViewController *)vc {
    NSLog(@"%s --- %@", __func__, [NSThread currentThread]);
    vc.isStoped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma mark - 事件回调
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 线程没事做时，RunLoop会让它休眠，调用performSelector就会唤醒线程去执行任务（Source0）
    [self performSelector:@selector(doSomeThing) onThread:self.thread withObject:nil waitUntilDone:NO];
    // waitUntilDone：是否等待thread的任务执行完再继续下面代码（是否阻塞当前线程）
}

- (IBAction)stopAction {
    [self.class performSelector:@selector(stopRunLoop:) onThread:self.thread withObject:self waitUntilDone:NO];
}

@end
