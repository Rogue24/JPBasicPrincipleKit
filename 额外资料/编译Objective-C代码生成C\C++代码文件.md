####不同平台支持的代码肯定不一样（Windows、Mac、iOS）
1. 没指定架构：`clang -rewrite-objc main.m -o main.cpp`
2. 指定iOS64位机构：`xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-arm64.cpp`
	- 如果需要链接其他框架，使用-framework参数，比如 `-framework UIKit`

####当代码里面使用了weak引用会报错（weak引用需要runtime的支持）：cannot create __weak reference because the current deployment target does  not support weak references
- 解决方法：支持ARC、指定运行时系统版本，后面加上：`-fobjc-arc -fobjc-runtime=ios-8.0.0`
- 完整写法：`xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-8.0.0 main.m -o main-arm64.cpp`