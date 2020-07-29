//
//  ViewController.m
//  03-内存管理-定时器
//
//  Created by 周健平 on 2019/12/12.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPProxyObject.h"
#import "JPProxy.h"
#import <objc/runtime.h>

/**
 * NSTimer不准时：
 * 因为NSTimer依赖于RunLoop，RunLoop每跑一圈就会累积这一圈的时间，然后在循环的开头查看累积的时间是否达到NSTimer要触发的时间
 * 但是RunLoop每一圈所花费的时间是不固定的（RunLoop的任务过于繁重的话就会长一点），所以可能会导致NSTimer不准时
 * 例：timer设置为每隔1s触发任务，RunLoop第1圈0.2s，第2圈0.3s，第3圈0.3s，差0.2s，但第4圈却0.4s，加起来0.2+0.3+0.3+0.4=1.2 > 1.0
 */

@interface ViewController ()
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ViewController

+ (void)abc {
    NSLog(@"caonima");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     * self弱引用timer会造成内存泄漏，强引用timer会造成循环引用
     * timer的target强引用self，而RunLoop强引用timer，只要这个timer一直工作，就会一直持有self，self就无法释放
        [NSRunLoop mainRunLoop] --strong--> timer.target --strong--> self
                                              ↑                       ↓
                                              ←-------weak/strong-----←
     * 解决方案：使用proxy，弱引用self，打破循环
        [NSRunLoop mainRunLoop] --strong--> timer.target --strong--> proxy -x-weak-x-> self
                                              ↑                                         ↓
                                              <----------------weak/strong--------------←
     * 利用proxy的消息转发机制，将消息转发给self去执行，而实际上timer的target强引用的是proxy，跟self没关系
     * 注意：记得销毁timer，不然target就会一直持有着proxy，proxy就无法释放，跟不使用self一样的情况，只是对象不同了而已
     */
    
    // 会自动转发实例方法的isKindOfClass（这方法在GNUStep里面的实现就是直接转发）：
    JPProxy *proxy = [JPProxy proxyWithTarget:self];
    JPProxyObject *proxyObj = [JPProxyObject proxyWithTarget:self];
    NSLog(@"%d", [proxy isKindOfClass:self.class]); // 1
    NSLog(@"%d", [proxyObj isKindOfClass:self.class]); // 0
    /*
     * JPProxy继承于NSProxy，所有方法都是通过消息转发出去的，就连isKindOfClass也是转发给self(ViewController)去执行的，所以当然是YES
     * JPProxyObject继承于NSObject，NSObject当然不属于ViewController，所以是NO
     */
    
    // 类方法也可以转发
    [JPProxy performSelector:@selector(abc)];
    
    //【绝】大部分的方法会自动转发，有一小部分不会，例如类方法的isKindOfClass：
    NSLog(@"%d", [JPProxy isKindOfClass:self.class]); // 0
    NSLog(@"%d", [JPProxy isKindOfClass:object_getClass([ViewController class])]); // 0
    // 自身是跟NSObject同级别的根类，所以也不属于NSObject
    NSLog(@"%d", [JPProxy isKindOfClass:NSObject.class]); // 0
    NSLog(@"%d", [JPProxy isKindOfClass:object_getClass([NSObject class])]); // 0
    // 证明了类方法的isKindOfClass并没有转发
    NSLog(@"%d", [JPProxy isKindOfClass:JPProxy.class]); // 0
    NSLog(@"%d", [JPProxy isKindOfClass:object_getClass([JPProxy class])]); // 1
    
    /*
     __weak typeof(self) weakSelf = self;
     
     // ❌ 这种方式不能解决循环引用的问题，给到target虽然是weakSelf，不过weakSelf指向的是self的地址值，这样target还是能拿到self来做强引用
     [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(timerHandle) userInfo:nil repeats:YES];
     
     // ✅ __weak 只针对Block才会起作用，是用来告诉Block对外面这个变量使用弱引用
     [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
         [weakSelf timerHandle];
     }];
     */
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:proxy selector:@selector(timerHandle) userInfo:nil repeats:YES];
    
    // 调用频率和屏幕的刷新频率一致（60FPS）
//    self.link = [CADisplayLink displayLinkWithTarget:proxyObj selector:@selector(linkHandle)];
//    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)dealloc {
    [self.link invalidate];
    [self.timer invalidate];
    NSLog(@"%s", __func__);
}

- (void)linkHandle {
    NSLog(@"%s", __func__);
}

- (void)timerHandle {
    NSLog(@"%s", __func__);
}

@end
