//
//  ViewController.m
//  01-KVO
//
//  Created by 周健平 on 2019/10/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "JPPerson.h"
#import "NSObject+JPExtension.h"

@interface ViewController ()
@property (nonatomic, strong) JPPerson *per1;
@property (nonatomic, strong) JPPerson *per2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.per1 = [[JPPerson alloc] init];
    self.per1.age = 10;
    
    self.per2 = [[JPPerson alloc] init];
    self.per2.age = 13;
    
    // 添加KVO
    /*
     * 假设 keyPath 为 xxx
     * 没有xxx这个属性的情况下KVO也能生效的条件（属性本来就满足这些条件）：
     * 1.必须要有`-setXxx:`这样的set方法，或者是`-_setXxx:`（名字前多一个下划线），必须要用驼峰法，返回值类型必须要为void（KVC那套判定）
     * 2.必须要有`-xxx`这样的get方法，返回值类型最好跟set方法的参数类型一致
     * 如果条件1不成立，不会触发KVO，因为KVO生成的子类找不到对应的set方法来重写；
     * 如果条件1成立，会触发KVO，但如果条件2不成立，那必须要有 _xxx、_isXxx、xxx、isXxx 其中一个这样的成员变量（优先级从左到右），否则当调用set方法程序会【崩溃】
        - 重写的set方法：
            [self willChangeValueForKey:@"xxx"]; ==> 使用了KVC去获取【旧】值（没有get方法就去查找对应的成员变量，都没有就崩溃）
            [self setXxx:123]; ==> 原来的setter方法
            [self didChangeValueForKey:@"xxx"]; ==> 使用了KVC去获取【新】值，到这里就会触发KVO的回调（把旧值和新值回传出去）
     * 漏了！还有最后一种！！！只有成员变量，没有set方法，使用【KVC】设值也会触发KVO！！！
     * 注意：最好别乱写get方法，因为KVO的回调是从get方法这里取值的！点击🌰【例5】看看就知道了！！
     */
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    
    //【例1】
    [self.per1 addObserver:self forKeyPath:@"age" options:options context:nil];
    
    //【例2】
    // 没有height属性，但有”_height“成员变量
    // 想要KVO生效还需要有-setHeight:方法
    [self.per1 addObserver:self forKeyPath:@"height" options:options context:nil];
    
    //【例3】
    [self.per1 addObserver:self forKeyPath:@"weight" options:options context:nil];
    
    //【例4】
    // 没有money属性，也没有”_money“成员变量
    // 想要KVO生效不仅需要有-setMoney:方法，还要有-money方法
    [self.per1 addObserver:self forKeyPath:@"money" options:options context:nil];
    
    //【例5】
    // 只有成员变量，没有set方法
    // 想要KVO生效：使用KVC方式设值！
    [self.per1 addObserver:self forKeyPath:@"douer" options:options context:nil];
    
    NSLog(@"per1 %@, per2 %@", object_getClass(self.per1), object_getClass(self.per2));
    NSLog(@"per1 %@, per2 %@", self.per1.class, self.per2.class);
    /*
     * object_getClass(self.per1) ==> NSKVONotifying_JPPerson
     * self.per1.class ==> JPPerson
     * 获取的结果不同？？？
     *
     * 由于object_getClass返回的是确切的结果
     * 所以很有可能就是NSKVONotifying_JPPerson内部重写了class方法，返回的是它自己的父类
     * 说明系统【不想暴露】KVO的子类的存在，让我们使用起来跟本来的没什么差异
     *
     * 为啥重写class方法：
     * 如果不重写，就会去到基类找class方法调用，而基类的class方法内部其实就是调用object_getClass方法，这样就会直接返回NSKVONotifying_JPPerson，会暴露自己的存在。
     * 所以重写的主要目的是让外界察觉不了这个类的存在（隐藏），从而屏蔽这个子类的内部实现。
     */
    
    // 窥探KVO子类的方法
    [object_getClass(self.per1) jp_lookMethods];
    
    // _isKVOA 是 NSObject 的私有方法，用来判定该类是否为KVO生成的子类
//    [NSObject jp_lookMethods];
    
    SEL sel = NSSelectorFromString(@"_isKVOA");
    if ([self.per1 respondsToSelector:sel]) {
        NSMethodSignature *signature = [self.per1 methodSignatureForSelector:sel];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:sel];
        [invocation invokeWithTarget:self.per1];
        BOOL value;
        [invocation getReturnValue:&value];
        NSLog(@"per1 _isKVOA --- %d", value);
    } else {
        NSLog(@"per1 没有这方法");
    }
    if ([self.per2 respondsToSelector:sel]) {
        NSMethodSignature *signature = [self.per2 methodSignatureForSelector:sel];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:sel];
        [invocation invokeWithTarget:self.per2];
        BOOL value;
        [invocation getReturnValue:&value];
        NSLog(@"per2 _isKVOA --- %d", value);
    } else {
        NSLog(@"per2 没有这方法");
    }
}

- (void)dealloc {
    [self.per1 removeObserver:self forKeyPath:@"age"];
}

#pragma mark - KVO触发的回调

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSValue *oldValue = change[NSKeyValueChangeOldKey];
    NSValue *newValue = change[NSKeyValueChangeNewKey];
    NSLog(@"****** KVO代理方法_begin ******");
    NSLog(@"%@ --- %@", object, keyPath);
    NSLog(@"old --- %@", oldValue);
    NSLog(@"new --- %@", newValue);
    NSLog(@"****** KVO代理方法_ended ******");
}

#pragma mark - 能触发KVO的例子

#pragma mark 【例1】：点语法
- (IBAction)action1:(id)sender {
    // 点语法、set方法的使用
    self.per1.age += 1; // 本质上调用了-setAge:方法
}

#pragma mark 【例2】：set方法
- (IBAction)action2:(id)sender {
    // ❌ 直接修改成员变量不会触发KVO
    self.per1->isHeight += 1;
    // ✅ 这样才会触发KVO，说明NSKVONotifying_Xxx内部重写的是这个属性的-setXxx:方法
    // 并且是在重写的set方法里面触发了KVO
    [self.per1 _setHeight:10];
}

#pragma mark 【例3】：手动触发KVO
- (IBAction)action3:(id)sender {
    // 手动触发KVO（必须先willChangeValueForKey后didChangeValueForKey，且缺一不可）
    // 要先调用 willChangeValueForKey 之后再调用 didChangeValueForKey 其内部才会调用 observer的observeValueForKeyPath:ofObject:change:context:
    [self.per1 willChangeValueForKey:@"weight"];
    [self.per1 didChangeValueForKey:@"weight"];
    // 也就是说重写的set方法里面是有调用这两个方法的
}

#pragma mark 【例4】：没有成员变量但只要同时有set方法和get方法也可以触发KVO
- (IBAction)action4:(id)sender {
    [self.per1 setMoney:999];
}

#pragma mark 【例5】：只有成员变量，没有set方法，使用KVC设值才可以触发KVO
- (IBAction)action5:(id)sender {
    [self.per1 setValue:@888 forKey:@"douer"];
    NSLog(@"douer: %d", self.per1->douer);
}

#pragma mark 当把监听的属性全部移除后就会变回原本的类
- (IBAction)action6:(id)sender {
    [self.per1 removeObserver:self forKeyPath:@"age"];
    NSLog(@"移除age per1 %@", object_getClass(self.per1));
    [self.per1 removeObserver:self forKeyPath:@"height"];
    NSLog(@"移除height per1 %@", object_getClass(self.per1));
    [self.per1 removeObserver:self forKeyPath:@"weight"];
    NSLog(@"移除weight per1 %@", object_getClass(self.per1));
    [self.per1 removeObserver:self forKeyPath:@"money"];
    NSLog(@"移除money per1 %@", object_getClass(self.per1));
}

@end
