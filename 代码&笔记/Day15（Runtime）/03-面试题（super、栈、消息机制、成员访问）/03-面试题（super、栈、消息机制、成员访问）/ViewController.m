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
#import <malloc/malloc.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     * 查看编译的C++代码：
         objc_msgSendSuper({self, class_getSuperclass(objc_getClass("ViewController"))},
                            sel_registerName("viewDidLoad"));
     * 然而，这里打个断点然后查看汇编代码的话，可以看到这里实际上并不是调用【objc_msgSendSuper】
     * 而是调用了【objc_msgSendSuper2】！
                        ↓↓↓
                        ↓↓↓
                        ↓↓↓
     * super调用，其实底层会转换为【objc_msgSendSuper2】函数的调用，接收2个参数：1.struct objc_super2，2.SEL
     * 注意：编译的C++代码只能用作参考，并不是所有代码都是肯定对的（只是大部分是对的），而查看汇编肯定是对的（只是看不懂）
     
     *【objc_msgSendSuper】：
         objc_msgSendSuper(
            {
                self;
                class_getSuperclass(objc_getClass("ViewController"); // 父类是UIViewController
            },
            sel_registerName("viewDidLoad")
         );
         ↓↓↓
         第一个参数是这种结构体
         ↓↓↓
         struct objc_super {
             id receiver;
             Class super_class; ==> 父类
         };
     
     *【objc_msgSendSuper2】：
         objc_msgSendSuper2(
            {
                self;
                objc_getClass("ViewController");
            },
            sel_registerName("viewDidLoad")
         );
         ↓↓↓
         第一个参数是这种结构体
         ↓↓↓
         struct objc_super2 {
             id receiver;
             Class current_class; ==> 自己类，objc_msgSendSuper2函数内部会通过该类的superclass来获取其父类
         };
     * objc_msgSendSuper2是个汇编使用的函数，在runtime源码里面得加个下划线搜（”_objc_msgSendSuper2“），其实现是在 objc-msg-arm64 这个文件里面
     * ENTRY _objc_msgSendSuper2 -> ldr p16, [x16, #SUPERCLASS] // p16 = class->superclass -> 利用传进来的类通过superclass找到父类，然后去父类里面搜索方法。
     
     * 综上所述，所以这里地址最低的临时变量是ViewController这个类对象，而不是他的父类
     */
    
    NSString *hello = @"J了个P";
    NSString *hi = @"健了个平";
    id cls = [JPPerson class];
    void *obj = &cls;
    // (__bridge id)obj：强转成OC类型 --- 只要是OC对象就可以调用方法
    [(__bridge id)obj print1]; // My name is 健了个平
    [(__bridge id)obj print2]; // My nickname is J了个P
    [(__bridge id)obj print3]; // My littlename is <ViewController: 0x7ff8ccc0d810>
    [(__bridge id)obj print4]; // My othername is ViewController
    /*
     * 注意1：再往上就没临时变量了，继续访问会崩溃（野指针）；
     * 注意2：这里的self和ViewController是属于（使用了super生成的）结构体里面的成员，都是临时变量，第一个成员是指向self的指针变量，第二个成员是指向ViewController的指针变量；
     * 注意3：要是没用过super，就没有指向self和ViewController这两个指针变量了，self是方法的参数，其地址不是在栈空间上，虽然也是局部变量，但这是【存放在别处】的变量；
       ↓↓↓↓↓
     * 方法的参数（包括隐式参数self和_cmd）：在【arm64架构】中可不是在栈空间上，而是存放在【寄存器】中（寄存器的访问效率比内存更高），因此self的地址并不是紧跟在后面的，再往上的可是野指针！
     */
    
    /*
     * 证明super是使用了objc_msgSendSuper2函数，在此可以打断点查看结构体成员：
     * 1. p/x obj ==> 查看obj地址
     * 2. x/5g obj地址 ==> 查看obj地址存放的内容（以8个字节为一组，查看5组，排列顺序是从低到高，因为类对象不是在栈上）
     * 3. p (类型)其中一组地址 ==> 查看每一组地址存放的内容（可以查看最后一组地址，也就是栈底，为ViewController）
     *                      ==> p (Class)0x000000010f5ee700
     */
    
    /*
     *【1】[(__bridge id)obj print] 为什么能调用成功？
     * obj和实例对象指针per的指向关系：
     
         obj →→→ cls →→→→→→→→→
                             ↓
                     [JPPerson class]
                             ↑
         per →→→ isa →→→→→→→→→
     
     * 指针变量（obj、per）指向的地址 -> 从该地址起的前8个字节 -> 类对象的地址
     * per -> isa -> [JPPerson class] -> 找到print并执行
     * obj -> cls -> [JPPerson class] -> 找到print并执行
     
     * obj和per都是指针变量，obj->cls和per->isa都是指向[JPPerson class]
     * 本质上obj和per其实是一样的。
     * 此时的obj近似于一个实例对象（结构上），不同的是cls在栈上，isa在堆上
     
     * 因为实例对象调用实例方法实际上只是【通过isa来到类对象里面查找方法】再执行的
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
     * _name作为JPPerson的第一个成员，这个成员的内存地址是紧挨在isa后面（按照实例对象的结构排布，是isa地址+8）
     
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
     * 此时执行self.name，就是操控obj这个指针，从指向的地址开始跳过前8个字节，去获取后面8个字节（属性是个指针变量，占8字节）
     * 而obj指向的地址的前8个字节为cls的地址，之后那8个字节即为hi的地址
     * 所以“self.name”获取到的值是hi
     
     * obj指向的地址跳过16个字节（cls、hi）之后为hello的地址
     * 所以obj调用print2方法，里面的“self.nickname”为hello的值
     
     * <<本质来说，只要有指向类对象地址的指针，就可以调用实例方法，方法里面的self为消息接收者（同理元类对象的类方法）>>
     * <<方法里面不管这个self是谁，成员变量的访问就是跳动self这个指针去访问到其地址，至于跳多少字节是从类对象里的成员变量信息得知的>>
     
     * <<也就是说，hello、hi、cls、obj这四者在栈空间的分布可以模拟成一个JPPerson实例对象的内存结构>>
     * JPPerson实例对象在内存中是个struct（结构体），大概长酱紫：
        struct JPPerson_IMPL {
            Class isa;
            NSString *_name;
            NSString *_nickname;
        };
     * 由此可以看作这样：
        obj   <---> cls <---> per <---> per->isa
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
     * 因为这个结构体是执行objc_msgSendSuper2函数时【直接在函数调用里创建】的：
         objc_msgSendSuper2({
             self;
             [ViewController class];
         }, sel_registerName("viewDidLoad"));
     * 而不是先赋值给一个指针再传进去：
         struct objc_super2 arg = xxx;
         objc_msgSendSuper2(arg, sel_registerName("viewDidLoad"));
     * 这是有区别的，不然 [(__bridge id)obj print3] 打印的是 ---- My littlename is 这个指针的地址
     
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
