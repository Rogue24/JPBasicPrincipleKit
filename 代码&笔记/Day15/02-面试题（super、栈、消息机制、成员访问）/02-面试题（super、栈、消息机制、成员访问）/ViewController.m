//
//  ViewController.m
//  02-面试题（print）
//
//  Created by 周健平 on 2019/11/23.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPPerson.h"

#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // ↓↓↓↓
    /*
     * 编译的C++代码：
     objc_msgSendSuper({self, class_getSuperclass(objc_getClass("ViewController"))},
                       sel_registerName("viewDidLoad"));
     
     * 打个断点，然后查看汇编代码，可以看到这里实际上并不是调用objc_msgSendSuper，而是调用了objc_msgSendSuper2
     *【super调用，其实底层会转换为objc_msgSendSuper2函数的调用】，接收2个参数：1.struct objc_super2，2.SEL
     
     * objc_msgSendSuper和objc_msgSendSuper2的区别：
     
     objc_msgSendSuper({
         self;
         class_getSuperclass(objc_getClass("ViewController");
     }, sel_registerName("viewDidLoad"));
     ↓↓↓↓↓第一个参数是这种结构体↓↓↓↓↓
     struct objc_super {
         __unsafe_unretained _Nonnull id receiver;
         __unsafe_unretained _Nonnull Class super_class; ==> 父类
     };
     
     objc_msgSendSuper2({
         self;
         objc_getClass("ViewController");
     }, sel_registerName("viewDidLoad"));
     ↓↓↓↓↓第一个参数是这种结构体↓↓↓↓↓
     struct objc_super2 {
         id receiver;
         Class current_class; ==> 自己类，objc_msgSendSuper2内部会通过该类的superclass查找父类
     };
     
     */
    
    NSString *hello = @"J了个P";
    NSString *hi = @"健了个平";
    id cls = [JPPerson class];
    void *obj = &cls;
    [(__bridge id)obj print];  // My name is 健了个平
    [(__bridge id)obj print2]; // My nickname is J了个P
    [(__bridge id)obj print3]; // My littlename is <ViewController: 0x7ff8ccc0d810>
    [(__bridge id)obj print4]; // My othername is ViewController
    
    /*
     * 在此可以打断点查看：
     * 1. p/x obj ==> 查看obj地址
     * 2. x/5g obj地址 ==> 查看obj地址存放的内容（以8个字节为一组，查看5组，排列顺序是从低到高）
     * 3. p (类型)其中一组地址 ==> 查看每一组地址存放的内容（可以查看最后一组地址，也就是栈底，为ViewController）
     */
    
    /*
     *【1】[(__bridge id)obj print] 为什么能调用成功？
     * obj和实例对象指针per的指向关系：
     
     obj →→→ cls →→→→→→→→→
                         ↓
                 [JPPerson class]
                         ↑
     per →→→ isa →→→→→→→→→
     
     * 指针变量指向的地址 -> 该地址的前8个字节 -> 类对象的地址
     * per -> isa -> [JPPerson class] -> 找到print并执行
     * obj -> cls -> [JPPerson class] -> 找到print并执行
     
     * obj和per都是指针变量，obj->cls和per->isa都是指向[JPPerson class]
     * 本质上obj和per其实是一样的。
     
     * 因为实例对象调用实例方法只是通过isa来到类对象里面查找方法再执行的
     * 能不能调用实例方法并不是一定要创建实例对象去调用，只需要有这个指针就可以（除非要用到成员变量，那就只能用实例对象了）
     
     * 所以obj能调用print
     * <<也就是说，这里的obj->cls只是模仿实例对象在内存中的指引>>
     */
    
    
    /*
     *【2】[(__bridge id)obj print] ==> My name is 健了个平，为什么print里面的“name”为临时变量hi ？
     * print方法的实现：
     
     - (void)print {
         NSLog(@"My name is %@", self.name);
     }
     
     * 因为本质上obj和per其实是一样的，obj->cls是模仿实例对象在内存中的指引
     * print方法里面的“self.name”相当于self->_name，是为了去获取_name这个成员变量
     * _name作为JPPerson的第一个成员，这个成员的内存地址是紧挨在isa后面（isa地址+8）
     
     * hello、hi、cls、obj都为局部变量，此时在viewDidLoad作用域范围内的内存排布为：
     【栈】（地址是从高往低分配）
     - 低地址 -
     ←← obj
     ↓
     →→ cls   --> [JPPerson class] ----------→
                                             ↓
        hi    --> @"健了个平" ------------→【全局区】
                                             ↑
        hello --> @"J了个P" ------------------→
     - 高地址 -
     
     * 当obj调用print方法，里面的“self”为obj
     * 此时执行self.name，就是操控obj这个指针，从指向的地址开始跳过前8个字节，去获取后面8个字节（字符串占8字节）
     * 而obj指向的地址的前8个字节为cls的地址，之后那8个字节即为hi的地址
     * 所以“self.name”获取到的值是hi
     
     * obj指向的地址跳过16个字节（cls、hi）之后为hello的地址
     * 所以obj调用print2方法，里面的“self.nickname”为hello的值
     
     * <<本质来说，成员变量的访问，就是跳动指针去访问该成员变量地址，跳多少字节应该就是从类对象里的成员变量信息得知的>>
     * <<也就是说，hello、hi、cls、obj这四者在栈空间的分布可以模拟成一个JPPerson实例对象的内存结构>>
     
     * JPPerson实例对象在内存中是个struct（结构体），大概长酱紫：
        struct JPPerson_IMPL {
            Class isa;
            NSString *_name;
            NSString *_nickname;
        };
     * 由此可以看作这样：
        obj   <---> per
        cls   <---> per->isa
        hi    <---> per->_name
        hello <---> per->_nickname
     */
    
    /*
     *【3】为什么再往后的打印结果为：
     * [(__bridge id)obj print3]; // My littlename is <ViewController: 0x7ff8ccc0d810>
     * [(__bridge id)obj print4]; // My othername is ViewController
     
     * 因为此时紧挨在后面的是【struct objc_super2】这种结构的临时变量
     * 这是前面 [super viewDidLoad] 里面使用super所生成的临时变量
     
     * 因为前面[super viewDidLoad]里面使用了super
     * super调用，底层会转换为objc_msgSendSuper2函数的调用：
         
     * 生成了【struct objc_super2】这种结构体里面两个临时变量
     * 这种结构体的前8个字节（第一个成员）为self
     * 再接着后面的是class，是自己的类对象
     * 再再接着后面就啥都没了~
     
     * PS：为什么栈里是这种结构体的内部成员，而不是一个指向这种结构体的指针？
     * 因为这个结构体是直接在函数调用里创建：
         objc_msgSendSuper2({
             self;
             [ViewController class];
         }, sel_registerName("viewDidLoad"));
     * 而不是先赋值给一个指针再传进去：
         struct objc_super2 arg = xxx;
         objc_msgSendSuper2(arg, sel_registerName("viewDidLoad"));
     
     * 又因为结构体里面的self的地址比[ViewController class]的地址低，所以最终的内存分布为：
     
     【栈】（地址是从高往低分配）
     - 低地址 -
     ←← obj
     ↓
     →→ cls   --> [JPPerson class] ----------→
                                             ↓
        hi    --> @"健了个平" ------------→【全局区】
                                             ↑
        hello --> @"J了个P" ------------------→
     
        self  --> 第一个成员 ←-------------------------←
                                                     ↑
                                            【struct objc_super2】（注意这并不是struct objc_super）
                                                     ↓
        [ViewController class] --> 第二个成员 ←--------←
     - 高地址 -
     
     */
}


@end
