//
//  JPPerson.m
//  01-super补充
//
//  Created by 周健平 on 2019/11/24.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPPerson.h"

@implementation JPPerson

/**
 * Objective-C在变为机器代码之前，会被LLVM编译器转换为中间代码（Intermediate Representation）
 * OC --> 中间代码（后缀为 .ll ） --> 汇编、机器代码
 * 中间代码是LLVM特有的，并且通用、跨平台的，介于开发语言和最终的机器语言之间的一种代码
 * 命令行生成中间代码的指令：clang -emit-llvm -S JPPerson.m
 * 官方文档：https://llvm.org/docs/LangRef.html
 */

void test(int param) {
    NSLog(@"%d", param);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [super forwardInvocation:anInvocation];
    
    int a = 5;
    int b = 3;
    int c = a + b;
    test(c);
    
    /*
     * 编译的C++代码：
         objc_msgSendSuper({self, class_getSuperclass(objc_getClass("JPPerson"))},
                           sel_registerName("forwardInvocation:"),
                           anInvocation);
     */
    
    /*
     * 中间代码：
     * 搜“objc_msgSendSuper2”定位：
         [super forwardInvocation:anInvocation]
           ↓↓↓
         对应这一句
           ↓↓↓
         call void bitcast (i8* (%struct._objc_super*, i8*, ...)* @objc_msgSendSuper2 to void (%struct._objc_super*, i8*, %2*)*)(%struct._objc_super* %7, i8* %18, %2* %12)
     
         int a = 5;
         int b = 3;
         int c = a + b;
         test(c);
           ↓↓↓
         对应这一段
           ↓↓↓
         store i32 5, i32* %8, align 4      ==> %8 = 5
         store i32 3, i32* %9, align 4      ==> %9 = 3
         %19 = load i32, i32* %8, align 4   ==> %19 = %8 = 5
         %20 = load i32, i32* %9, align 4   ==> %20 = %9 = 3
         %21 = add nsw i32 %19, %20         ==> %21 = %19 + %20 = 5 + 3 = 8
         store i32 %21, i32* %10, align 4   ==> %10 = %21 = 8
         %22 = load i32, i32* %10, align 4  ==> %22 = %10 = 8
         call void @test(i32 %22)           ==> 调用test
     
     * store：存储（set）
     * load：加载（get）
     */
}

@end
