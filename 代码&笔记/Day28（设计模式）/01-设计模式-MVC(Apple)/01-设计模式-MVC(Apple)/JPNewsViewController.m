//
//  JPNewsViewController.m
//  01-设计模式-MVC(Apple)
//
//  Created by 周健平 on 2019/12/29.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPNewsViewController.h"
#import "JPNews.h"

@interface JPNewsViewController ()
@property (nonatomic, strong) NSMutableArray *newsData;
@end

@implementation JPNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadNewsData];
}

- (void)loadNewsData {
    self.newsData = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 20; i++) {
        JPNews *news = [[JPNews alloc] init];
        news.title = [NSString stringWithFormat:@"news-title-%zd", i];
        news.content = [NSString stringWithFormat:@"news-content-%zd", i];
        [self.newsData addObject:news];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JPNewsCell" forIndexPath:indexPath];
    
    JPNews *news = self.newsData[indexPath.row];
    
    // 优点：View和Model互相独立，互相不知道对方的存在，搭配自由度高
    // 缺点：由Controller建立它们的关系（将Model数据赋值到View上），这样的话如果界面很复杂，Controller的代码就会很臃肿
    // 特定：View把显示的控件暴露出来，可随意配置
    
    cell.textLabel.text = news.title;
    cell.detailTextLabel.text = news.content;
    
    return cell;
}

@end
