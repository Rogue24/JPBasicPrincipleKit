//
//  JPNewsViewController.m
//  01-设计模式-MVC(Apple)
//
//  Created by 周健平 on 2019/12/29.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPNewsViewController.h"
#import "JPNewsViewModel.h"

@interface JPNewsViewController ()
@property (nonatomic, copy) NSArray *newsData;
@property (nonatomic, strong) JPNewsViewModel *newsVM;
@end

@implementation JPNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsVM = [[JPNewsViewModel alloc] init];
    
    [self.newsVM loadNewData:^(NSArray *newsData) {
        self.newsData = newsData;
    }];
    
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
    
    cell.textLabel.text = news.title;
    cell.detailTextLabel.text = news.content;
    
    return cell;
}

@end
