//
//  JPPerson.h
//  01-内存管理-MRC
//
//  Created by 周健平 on 2019/12/15.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPDog.h"


@interface JPPerson : NSObject
{
    JPDog *_dog;
}

- (void)setDog:(JPDog *)dog;
- (JPDog *)dog;

@end
