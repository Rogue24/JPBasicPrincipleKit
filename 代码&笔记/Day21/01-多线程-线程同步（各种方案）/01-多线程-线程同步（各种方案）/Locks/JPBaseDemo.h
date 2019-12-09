//
//  JPBaseDemo.h
//  07-多线程-线程同步（其他方案）
//
//  Created by 周健平 on 2019/12/6.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPBaseDemo : NSObject
- (void)ticketTest;
- (void)moneyTest;

- (void)otherTest;

#pragma mark 留给子类重写的方法
- (void)__saleTicket;
- (void)__saveMoney;
- (void)__drawMoney;
@end

