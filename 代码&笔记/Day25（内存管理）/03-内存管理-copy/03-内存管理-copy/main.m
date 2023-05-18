//
//  main.m
//  03-内存管理-copy
//
//  Created by 周健平 on 2019/12/16.
//  Copyright © 2019 周健平. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning 当前在MRC环境下！
// 关闭ARC：Targets --> Build Settings --> 搜索automatic reference --> 设置为NO

/**
 * 拷贝的目的：产生一个副本对象，跟源对象互不影响
 * 修改了源对象，不会影响副本对象
 * 修改了副本对象，不会影响源对象
 */

void copyTest1(void) {
    NSLog(@"-----------------copyTest1-----------------");
    
    // 系统的类方法创建的对象已经调用过autorelease，不需要手动内存管理
    NSMutableString *str1 = [NSMutableString stringWithFormat:@"123"]; // TaggedPointer
    NSString *str2 = str1.copy; // 浅拷贝 TaggedPointer
    NSMutableString *str3 = str1.mutableCopy; // 深拷贝 对象
    
    NSLog(@"str1 %@ --- %p", str1, str1);
    NSLog(@"str2 %@ --- %p", str2, str2);
    NSLog(@"str3 %@ --- %p", str3, str3);
}

// 常量区的数据（字符串常量）、TaggedPointer的引用计数一直都为【-1】
// TaggedPointer：不是对象，是个指针。
static NSString *str_;
void copyTest2(void) {
    NSLog(@"-----------------copyTest2-----------------");
    
    str_ = @"zjp"; // 直接写出来的，不是通过方法创建的字符串，编译时会生成为【字符串常量】
    NSLog(@"str_ %@ --- %zd --- %p", str_, str_.retainCount, str_);
    
    NSString *str1 = str_.copy; // 浅拷贝 字符串常量
    NSLog(@"str1 %@ --- %zd --- %p", str1, str1.retainCount, str1);
    
    str_ = [[NSString alloc] initWithFormat:@"zjp"]; // TaggedPointer
    NSLog(@"str_ %@ --- %zd --- %p", str_, str_.retainCount, str_);
    
    NSMutableString *str2 = str_.mutableCopy; // 深拷贝 对象
    NSString *str3 = str2.copy; // 深拷贝 对象
    
    NSLog(@"str2 %@ --- %zd --- %p", str2, str2.retainCount, str2);
    NSLog(@"str3 %@ --- %zd --- %p", str3, str3.retainCount, str3);
}

/*
 * iOS提供了两个拷贝方法：
    - copy 不可变拷贝，产生【不可变】副本（即便本来是可变的，拷贝出来的都是不可变的）
    - mutableCopy 可变拷贝，产生【可变】副本（即便本来是不可变的，拷贝出来的都是可变的）
 *
 * 浅拷贝和深拷贝
    - 浅拷贝：指针拷贝，【没有】产生新对象，引用计数会加1（retainCount += 1）
    - 深拷贝：内容拷贝，【有】产生新对象，引用计数初始1（retainCount = 1）
 * 不可变 --copy--> 不可变 ==> 浅拷贝（两个类型和内容都一样并且都不可变的对象，共用一个内存好了）
 * 可变 ----copy--> 不可变 ==> 深拷贝
 * 不可变 --mutableCopy--> 可变 ==> 深拷贝
 * 可变  ---mutableCopy--> 可变 ==> 深拷贝
 */

void copyTest3(void) {
    NSLog(@"-----------------copyTest3-----------------");
    
    NSString *str1 = [[NSString alloc] initWithFormat:@"zjp"]; // TaggedPointer
    NSString *str2 = str1.copy; // 浅拷贝 TaggedPointer
    NSMutableString *str3 = str1.mutableCopy; // 深拷贝 对象
    [str3 appendString:@"xixi"];
    
    NSLog(@"str1 %@ --- %zd --- %p", str1, str1.retainCount, str1);
    NSLog(@"str2 %@ --- %zd --- %p", str2, str2.retainCount, str2);
    NSLog(@"str3 %@ --- %zd --- %p", str3, str3.retainCount, str3);
}

void copyTest4(void) {
    NSLog(@"-----------------copyTest4-----------------");
    
    NSMutableString *str1 = [[NSMutableString alloc] initWithFormat:@"zjp"]; // 对象
    NSString *str2 = str1.copy; // 深拷贝 TaggedPointer
    NSMutableString *str3 = str1.mutableCopy; // 深拷贝 对象
    
    [str1 appendString:@"h"];
    [str3 appendString:@"x"];
    
    NSLog(@"str1 %@ --- %zd --- %p", str1, str1.retainCount, str1);
    NSLog(@"str2 %@ --- %zd --- %p", str2, str2.retainCount, str2);
    NSLog(@"str3 %@ --- %zd --- %p", str3, str3.retainCount, str3);
}

void copyTest5(void) {
    NSLog(@"-----------------copyTest5-----------------");
    
    NSString *str1 = [[NSString alloc] initWithFormat:@"zhoujianping"]; // 对象 str1.retainCount = 1
    NSString *str2 = str1.copy; // 浅拷贝 对象 str1.retainCount = 2
    NSMutableString *str3 = str1.mutableCopy; // 深拷贝 对象 str3.retainCount = 1
    
    NSLog(@"str1 %@ --- %zd --- %p", str1, str1.retainCount, str1);
    NSLog(@"str2 %@ --- %zd --- %p", str2, str2.retainCount, str2);
    NSLog(@"str3 %@ --- %zd --- %p", str3, str3.retainCount, str3);
}

void arrayCopyTest1(void) {
    NSLog(@"-----------------arrayCopyTest1-----------------");
    
    NSArray *array1 = [[NSArray alloc] initWithObjects:@"1", @"2", nil]; // 对象 array1.retainCount = 1
    NSArray *array2 = array1.copy; // 浅拷贝 对象 array1.retainCount = 2
    NSMutableArray *array3 = array1.mutableCopy; // 深拷贝 对象 array3.retainCount = 1
    
    NSLog(@"array1 %@ --- %zd --- %p", array1, array1.retainCount, array1);
    NSLog(@"array2 %@ --- %zd --- %p", array2, array2.retainCount, array2);
    NSLog(@"array3 %@ --- %zd --- %p", array3, array3.retainCount, array3);
}

void arrayCopyTest2(void) {
    NSLog(@"-----------------arrayCopyTest2-----------------");
    
    NSMutableArray *array1 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", nil]; // 对象
    NSString *array2 = array1.copy; // 深拷贝 对象
    NSMutableArray *array3 = array1.mutableCopy; // 深拷贝 对象
    
    [array1 addObject:@"hahaha"];
    [array3 addObject:@"xixixi"];
    
    NSLog(@"array1 %@ --- %zd --- %p", array1, array1.retainCount, array1);
    NSLog(@"array2 %@ --- %zd --- %p", array2, array2.retainCount, array2);
    NSLog(@"array3 %@ --- %zd --- %p", array3, array3.retainCount, array3);
}

void dictionaryCopyTest1(void) {
    NSLog(@"-----------------dictionaryCopyTest1-----------------");
    
    NSDictionary *dic1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"z", @"1", @"j", @"2", nil]; // 对象 dic1.retainCount = 1
    NSDictionary *dic2 = dic1.copy; // 浅拷贝 对象 dic1.retainCount = 2
    NSMutableDictionary *dic3 = dic1.mutableCopy; // 深拷贝 对象 dic3.retainCount = 1
    
    NSLog(@"dic1 %@ --- %zd --- %p", dic1, dic1.retainCount, dic1);
    NSLog(@"dic2 %@ --- %zd --- %p", dic2, dic2.retainCount, dic2);
    NSLog(@"dic3 %@ --- %zd --- %p", dic3, dic3.retainCount, dic3);
}

void dictionaryCopyTest2(void) {
    NSLog(@"-----------------dictionaryCopyTest2-----------------");
    
    NSMutableDictionary *dic1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"z", @"1", @"j", @"2", nil]; // 对象
    NSDictionary *dic2 = dic1.copy; // 深拷贝 对象
    NSMutableDictionary *dic3 = dic1.mutableCopy; // 深拷贝 对象
    
    dic1[@"3"] = @"p";
    dic3[@"4"] = @"a";
    
    NSLog(@"dic1 %@ --- %zd --- %p", dic1, dic1.retainCount, dic1);
    NSLog(@"dic2 %@ --- %zd --- %p", dic2, dic2.retainCount, dic2);
    NSLog(@"dic3 %@ --- %zd --- %p", dic3, dic3.retainCount, dic3);
}

@interface JPPerson : NSObject <NSCopying>
@property (nonatomic, copy) NSMutableArray *mArray;
@property (nonatomic, retain) NSArray *array;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) int weight;
@end
@implementation JPPerson
// copy修饰的属性，内部setter方法的实现大概酱紫：
//- (void)setMArray:(NSMutableArray *)mArray {
//    if (_mArray != mArray) {
//        [_mArray release];
//        _mArray = [mArray copy];
//    }
//}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n%p\n%@\n%@\n%d\n%d", self, self.mArray, self.array, self.age, self.weight];
}

// 自定义类要使用copy功能，需要内部实现`-copyWithZone:`方法。
- (id)copyWithZone:(struct _NSZone *)zone {
    JPPerson *per = [[JPPerson allocWithZone:zone] init];
    per.mArray = self.mArray;
    per.array = self.array.copy; // 注意这是个strong引用
    per.age = self.age;
    per.weight = self.weight;
    return per;
}

- (void)dealloc {
    NSLog(@"%zd %s", self.hash, __func__);
    [super dealloc];
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
//        copyTest1();
//        copyTest2();
//        copyTest3();
//        copyTest4();
//        copyTest5();
//
//        arrayCopyTest1();
//        arrayCopyTest2();
//
//        dictionaryCopyTest1();
//        dictionaryCopyTest2();
        
        
        // 浅拷贝 引用计数+1
        NSString *str = [[NSString alloc] initWithFormat:@"zhoujianping"]; // 对象 str.retainCount = 1
        NSLog(@"before copy --- %zd", str.retainCount);
        [str copy]; // 对象 str.retainCount = 2
        NSLog(@"after copy --- %zd", str.retainCount);
        
        
        NSMutableArray *mArray = @[@"1", @"2", @"3"].mutableCopy;
        
        JPPerson *per = [[JPPerson alloc] init];
        
        // mArray是NSMutableArray类型，而属性是copy类型
        // 因此setter方法内部会进行copy操作，可变的经copy之后是【不可变的新对象】（可不可变的只要经copy之后都是不可变的）
        // 所以mArray虽然声明的是NSMutableArray类型，但实际上mArray是NSArray类型（不可变）
        per.mArray = mArray; // NSMutableArray --copy--> NSArray 深拷贝
        
        // 这时继续使用NSMutableArray的API就会报错 --- unrecognized selector sent to instance
//        [per.mArray addObject:@"4"];
        
        // array是NSArray类型，而属性是retain类型
        // 因此setter方法内部只会进行retain操作，retainCount+1而已
        // 所以array虽然声明的是NSArray类型，但实际上array是NSMutableArray类型，因为引用的还是【同一个对象】
        per.array = mArray;
        
        NSLog(@"=================[before change]=================");
        NSLog(@"mArray %@", mArray);
        NSLog(@"per.mArray %@", per.mArray);
        NSLog(@"per.array %@", per.array);
        
        // 当外界修改了这个对象：
        // 如果使用copy修饰的属性，不受影响；而使用retain/strong修饰的属性，会随之变化。
        [mArray addObject:@"4"]; // 修改源对象
        
        NSLog(@"=================[after change]=================");
        NSLog(@"mArray %@", mArray);
        NSLog(@"per.mArray %@", per.mArray); // 不会影响副本对象
        NSLog(@"per.array %@", per.array); // 会随之变化
        
        
        NSLog(@"=================[自定义类的copy]=================");
        // 自定义类要使用copy功能，需要内部实现`-copyWithZone:`方法。
        
        per.age = 18;
        per.weight = 160;
        
        JPPerson *per2 = per.copy;
        
        per.age = 33;
        per.weight = 250;
        
        NSLog(@"per %@", per);
        NSLog(@"per2 %@", per2);
        
        
        NSLog(@"=============[表面类型虽骗人，但身体却很诚实]=============");
        // 表面可变，实际不可变
        NSLog(@"111 per.mArray --- %zd", per.mArray.retainCount);
        NSMutableArray *iArray1 = per.mArray; // copy修饰符只会在set方法进行copy，get方法是不会的~
        NSLog(@"222 per.mArray --- %zd", per.mArray.retainCount); // 没变，说明get方法是直接取。
        NSMutableArray *iArray2 = per.mArray.copy; // 不可变的copy，浅拷贝
        NSLog(@"333 per.mArray --- %zd", per.mArray.retainCount); // +1
        NSMutableArray *iArray3 = per.mArray.mutableCopy;
        NSLog(@"%@ %@ %@ %@", per.mArray.class, iArray1.class, iArray2.class, iArray3.class);
        NSLog(@"%p %p %p %p", per.mArray, iArray1, iArray2, iArray3);
        // 表面不可变，实际可变
        NSArray *mArray1 = per.array;
        NSArray *mArray2 = per.array.copy; // 可变的copy，深拷贝
        NSArray *mArray3 = per.array.mutableCopy;
        NSLog(@"%@ %@ %@ %@", per.array.class, mArray1.class, mArray2.class, mArray3.class);
        NSLog(@"%p %p %p %p", per.array, mArray1, mArray2, mArray3);
        
        [per release];
        [per2 release];
        // PS：严谨来说还有一些临时数组要release的，不过懒得搞了，毕竟只是个demo。
    }
    return 0;
}
