//
//  JPViewController.m
//  01-内存管理-定时器的引用问题
//
//  Created by 周健平 on 2020/7/26.
//  Copyright © 2020 周健平. All rights reserved.
//

#import "JPViewController.h"
#import "ViewController.h"

@interface JPViewController ()
@property (nonatomic, strong) id abc;
@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)pushVC:(id)sender {
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    // __weak只作用于Block，是用来告诉Block对这个变量使用弱引用
//    __weak typeof(vc) wvc = vc;
//    self.abc = wvc; // wvc只是个局部变量的弱指针，存储着vc的地址值，所以强引用wvc也就是强引用vc
    
    [self.navigationController pushViewController:vc animated:YES];
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
