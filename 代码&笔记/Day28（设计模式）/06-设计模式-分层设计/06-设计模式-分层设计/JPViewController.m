//
//  JPViewController.m
//  06-设计模式-分层设计
//
//  Created by 周健平 on 2020/7/30.
//  Copyright © 2020 周健平. All rights reserved.
//

#import "JPViewController.h"

@interface JPViewController ()

@end

@implementation JPViewController

/*
 * 1.loadView什么时候被调用？
    - 每次访问UIViewController的view(比如controller.view、self.view)而且view为nil，loadView方法就会被调用。
 * 2.loadView有什么作用？
    - 是用来负责创建UIViewController的view
 * 参考：https://www.cnblogs.com/LiLihongqiang/p/5782994.html
 */
- (void)loadView {
    NSLog(@"loadView");
    // loadView：vc.view为nil时就会来到这里，负责创建vc.view
    // 此时vc.view为nil，有2种方式创建：
    
    // 1.调用父类的loadView
    // 1.1 storyboard或xib的vc，会从storyboard/xib中加载view
    // 1.2 通过代码创建的vc，则创建一个新的UIView（内部：[[UIView alloc] initWithFrame:......]）
//    [super loadView];

    // 2.自己创建想要的UIView
    // 想用自己创建的view就不要调用[super loadView]了，在前面调用会浪费不必要的开销，之后调用则会覆盖掉自己创建的
    self.view = [[UIImageView alloc] initWithFrame:self.navigationController.view.bounds];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.clipsToBounds = YES;
    [(UIImageView *)self.view setImage:[UIImage imageNamed:@"Joker"]];
    
    // 重写了loadView方法就一定要让vc.view有值（1或2），否则当访问到vc.view时会无限循环调用该方法直至【崩溃】
    NSLog(@"%@", self.view);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.yellowColor;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
