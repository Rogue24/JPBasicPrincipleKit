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

/**
 *【RunLoop与线程】
 * 每条线程都有唯一的一个与之对应的RunLoop对象
 * RunLoop 保存在全局的Dictionary，线程作为key，RunLoop作为value ==> 就像`NSDictionary<NSThread *, NSRunLoop *> *runLoops;`
 * 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建（懒加载，主线程的RunLoop是在`UIApplicationMain()`里面获取过的）
 * RunLoop会在线程结束时销毁（一对一的关系，共生体）
 * 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop（除非子线程里面调用`[NSRunLoop currentRunLoop]`就会自动创建）
 *
 *【CFRunLoopModeRef】
 * `CFRunLoopModeRef`代表RunLoop的运行模式
 * 一个RunLoop包含若干个Mode，每个Mode又包含若干个`Source0`/`Source1`/`Timer`/`Observer`
 * RunLoop启动时只能选择其中一个Mode，作为`currentMode`
 * 如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入
 *  - 不同组的`Source0`/`Source1`/`Timer`/`Observer`能分隔开来，互不影响
 * 如果Mode里没有任何`Source0`/`Source1`/`Timer`/`Observer`，RunLoop会立马退出
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
        // 添加一个port，用于线程间通信，相当于添加了个Source1，捕获事件给Source0处理（performSelector:onThread:）
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        
        /**
         * `[[NSRunLoop currentRunLoop] run];`
         * NSRunLoop的`-run`方法是无法停止的，ta专门用于开启一个【永不销毁】的线程（NSRunLoop）。
         *
         * `- (void)run`方法的文档解释+翻译：
         * if no input sources or timers are attached to the run loop, this method exits immediately;
           如果在`RunLoop`中没有【输入源】或【定时器】，则该方法立即退出；
         * otherwise, it runs the receiver in the NSDefaultRunLoopMode by repeatedly invoking runMode:beforeDate:.
           否则，它将通过【重复调用】`runMode:beforeDate:`，在`NSDefaultRunLoopMode`中运行接收器。
         * In other words, this method effectively begins an infinite loop that processes data from the run loop’s input sources and timers.
           换句话说，该方法有效地开始了一个【无限循环】，该循环处理来自`RunLoop`的【输入源】和【定时器】的数据。
         *
         * 也就是说，当添加了`port`（相当于添加了个Source1，捕获事件给Source0处理），再调用`run`
         * 底层会开启一个【无限循环】去执行`-runMode:beforeDate:`方法。
         * 相当于酱紫：
         
                 while (1) {
                     // [NSDate distantFuture]：遥远的未来
                     // beforeDate:[NSDate distantFuture]：在这个未来到来之前一直运行，保证永不超时（除非你能活几百年）
                     [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                 }
         
         * `-runMode:beforeDate:` ==> 开启RunLoop，阻塞（休眠）当前线程
         * 当线程有任务了，RunLoop让线程去执行任务，任务执行完，RunLoop就会自动退出，停止阻塞，继续下面的代码
         *
         * 默认的`-run`方法其实就是套个`while(1)`循环调用`-runMode:beforeDate:`来实现线程不被销毁
         *  - RunLoop一退出就重新开启RunLoop
         *
         * 由于套上了一层死循环，每一次的循环结束了接着又是新一轮循环的开始（闲->睡，忙->干），
         * 所以Runloop对象使用`[[NSRunLoop currentRunLoop] run]`这种方式来启动的话是无法停止的。
         * PS：即使调用了`CFRunLoopStop`去停止，在底层也只是【停止当前这一次】的循环。
         */
        
        // ----------------【解决方案】----------------
        // 不使用 [[NSRunLoop currentRunLoop] run]，自定义RunLoop的启动（仿照run方法内部的做法）
        // <<自定义标识条件，每次循环先判断条件是否继续开启>> --- weakSelf && !weakSelf.isStoped
        while ([ViewController isContinue:weakSelf]) {
            NSLog(@"开启了新的RunLoop啦！等着做事情~ %@", [NSThread currentThread]);
            
            // runMode:beforeDate: ==> 当任务执行完runloop就会自动退出，没有任务时就让线程休眠
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            // PS：线程没任务时，这里并不是一直while循环，只有收到消息，才会唤醒线程去执行，执行完之后才会进入下一次循环
            
            NSLog(@"【这一次】的RunLoop退出啦！开启下一次循环去~ %@", [NSThread currentThread]);
        }
        
        NSLog(@"RunLoop已经【彻底】退出啦！！！%@", [NSThread currentThread]);
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
    NSLog(@"%s in %@", __func__, [NSThread currentThread]);
}

#pragma mark 去死
/**
 * 停止RunLoop的任务不能给到实例对象去调用！
 * 因为在自动退出的情况下，实例对象dealloc后就已经销毁了，再用ta来performSelector会造成坏内存访问
 */
+ (void)stopRunLoop:(ViewController *)vc {
    NSLog(@"%s --- %@", __func__, [NSThread currentThread]);
    // 设置标记为NO
    vc.isStoped = YES;
    // 停止RunLoop
    CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma mark - 事件回调
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 线程没事做时，RunLoop会让它休眠，调用performSelector就会唤醒线程去执行任务（Source1 -> Source0）
    [self performSelector:@selector(doSomeThing) onThread:self.thread withObject:nil waitUntilDone:NO];
    // waitUntilDone：是否等待thread的任务执行完再继续下面代码（是否阻塞当前线程）
}

- (IBAction)stopAction {
    [self.class performSelector:@selector(stopRunLoop:) onThread:self.thread withObject:self waitUntilDone:NO];
}

@end
