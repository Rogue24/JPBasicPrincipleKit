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
#import "JPPerson+JPTest.h"

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
    
    NSLog(@"----------------------- 添加KVO【前】-----------------------");
    IMP per1IMP = [self.per1 methodForSelector:@selector(setAge:)];
    IMP per2IMP = [self.per2 methodForSelector:@selector(setAge:)];
    NSLog(@"方法地址：per1：%p， per2：%p", per1IMP, per2IMP);
    
    Class per1Cls = object_getClass(self.per1);
    Class per2Cls = object_getClass(self.per2);
    NSLog(@"类对象：per1：%@ --- %p， per2：%@ --- %p", per1Cls, per1Cls, per2Cls, per2Cls);
    
    Class per1MCls = object_getClass(per1Cls);
    Class per2MCls = object_getClass(per2Cls);
    NSLog(@"元类对象：per1：%@ --- %p， per2：%@ --- %p", per1MCls, per1MCls, per2MCls, per2MCls);
    
    
    NSLog(@"----------------------- 添加KVO【后】-----------------------");
    
    // 添加KVO
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.per1 addObserver:self forKeyPath:@"age" options:options context:nil];
    // 监听没有该成员变量的key（只写了set方法和get方法的）
    [self.per1 addObserver:self forKeyPath:@"money" options:options context:nil]; // 分类
    [self.per1 addObserver:self forKeyPath:@"height" options:options context:nil];
    
    per1IMP = [self.per1 methodForSelector:@selector(setAge:)];
    per2IMP = [self.per2 methodForSelector:@selector(setAge:)];
    NSLog(@"方法地址：per1：%p， per2：%p", per1IMP, per2IMP);
    
    per1Cls = object_getClass(self.per1);
    per2Cls = object_getClass(self.per2);
    NSLog(@"类对象：per1：%@ --- %p， per2：%@ --- %p", per1Cls, per1Cls, per2Cls, per2Cls);
    // 可以看到，添加KVO之后实例对象的isa已经指向一个新的类对象（NSKVONotifying_JPPerson）
    // NSKVONotifying_JPPerson是继承JPPerson类对象的子类
    
    per1MCls = object_getClass(per1Cls);
    per2MCls = object_getClass(per2Cls);
    NSLog(@"元类对象：per1：%@ --- %p --- %d， per2：%@ --- %p", per1MCls, per1MCls, class_isMetaClass(per1MCls), per2MCls, per2MCls);
    // 可以看到，添加KVO之后类对象的isa已经指向一个新的元类对象（NSKVONotifying_JPPerson）
    // 这应该也是一个继承JPPerson元类对象的子类（类对象和元类对象名字是一样的）
    
    // 打个断点：输入“p (IMP)方法地址”以查看方法的信息
    
    // 查看per1IMP方法的两个地址
    // 第一个：(IMP) $0 = 0x000000010d93bd60 (01-KVO`-[JPPerson setAge:] at JPPerson.m:13)
    // 第二个：(IMP) $1 = 0x00007fff257223da (Foundation`_NSSetIntValueAndNotify)
    // 可以看出两个per1IMP的地址在添加KVO之后就分别是不同的类的方法了
    // _NSSetIntValueAndNotify：没有加减号也没有方括号，这是个C语言函数。
}

- (void)dealloc {
    [self.per1 removeObserver:self forKeyPath:@"age"];
    [self.per1 removeObserver:self forKeyPath:@"money"];
    [self.per1 removeObserver:self forKeyPath:@"height"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.per1.age += 1;
//    self.per2.age += 2;
    
    // self.per1->isa ==> NSKVONotifying_JPPerson
    // self.per2->isa ==> JPPerson
    
    // 当添加了监听器，self.per1的isa就会指向一个新的类NSKVONotifying_JPPerson
    // NSKVONotifying_JPPerson是使用Runtime动态创建的一个类，是JPPerson的一个子类
    // NSKVONotifying_JPPerson内部有一个新的setAge:方法，实现监听作用
    
    // 打断点，使用lldb指令查看方法的具体信息：
    // 查看添加KVO前的setAge:方法：p (IMP)0x104354360 ==> (IMP) $0 = 0x0000000104354360 (01-KVO`-[JPPerson setAge:] at JPPerson.m:12)
    // 查看添加KVO后的setAge:方法：p (IMP)0x7fff2564d626 ==> (IMP) $1 = 0x00007fff2564d626 (Foundation`_NSSetIntValueAndNotify)
    
    // self.per1.age += 1;【有KVO】的流程：
    // [self willChangeValueForKey:@"age"];  // 添加KVO之后新增的流程：保存旧值，标识等会调用didChangeValueForKey
    // [super setAge:age];
    // [self didChangeValueForKey:@"age"]; // 添加KVO之后新增的流程：通知监听器，XX属性值发送了改变
    
    // self.per2.age += 2;【没有KVO】的流程：
    // [super setAge:age];
    
    //【money是分类的属性，并没有_money这个成员变量，也能通过KVO监听】
    // 证明：不管有没有这个key的成员变量
    // 只要有这个key对应的set方法和get方法，也能触发KVO（通过set方法），旧值和新值通过get方法获取
    self.per1.money += 1;
    [self.per1 setHeight:888];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"oldValue --- %@", change[NSKeyValueChangeOldKey]);
    NSLog(@"newValue --- %@", change[NSKeyValueChangeNewKey]);
}

@end
