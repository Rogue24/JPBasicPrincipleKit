//
//  JPPerson.m
//  01-Runtime-消息转发
//
//  Created by 周健平 on 2019/11/17.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"
#import <objc/runtime.h>

@implementation JPPerson

/*
 * @property
 * 以前的`@property`只会给属性的set方法和get方法的【声明】，并没有实现，也没有成员变量
 * 现在的融合了`@synthesize`的特性，会自动帮属性生成【下划线+属性名的成员变量】、【set方法】、【get方法】的实现
 */

/*
 * @synthesize xxx = _xxx; // xxx为`@property`声明的属性名
 * 使用`@synthesize`修饰的属性，编译器会自动生成该属性的成员变量、set方法和get方法的【实现】
 * 等号右边为成员变量的名字，可以随便改，如果不写，例：`@synthesize yyy;`，则成员变量名字就只为`yyy`
 * 现在的编译器会自动帮【属性】添加这个修饰，默认成员变量名字为下划线+属性名，例：`@synthesize yyy = _yyy;`
 */
@synthesize age = _age;
@synthesize money; // 这样的话成员变量名就是money

- (void)setAge:(int)age {
    _age = age;
}
- (int)age {
    return _age;
}

- (void)setMoney:(int)money2 {
    money = money2;
}
- (int)money {
    return money;
}

/*
 * @dynamic xxx; // xxx为`@property`声明的属性名
 * 使用`@dynamic`修饰的属性：
    1.告诉编译器不要生成该属性的成员变量
    2.告诉编译器不要生成set方法和get方法的【实现】（声明还是有的，别处能调用这两个方法，只是没实现）
 */
@dynamic height;

// 编译器没有生成set和get方法的实现，调用这两个方法就会报错（方法找不到）！
// 那就等到运行时再添加方法实现（动态解析或消息转发）。

void setHeight(id self, SEL _cmd, int height) {
    NSLog(@"setHeight:%d", height);
}

int height(id self, SEL _cmd) {
    NSLog(@"height");
    return 24;
}

#pragma mark - 第一次机会：resolveInstanceMethod（动态解析）- 找不到方法，可以在这里添加该方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(setHeight:)) {
        class_addMethod(self, sel, (void *)setHeight, "v20@0:8i16");
        return YES;
    } else if (sel == @selector(height)) {
        class_addMethod(self, sel, (void *)height, "i16@0:8");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

@end
