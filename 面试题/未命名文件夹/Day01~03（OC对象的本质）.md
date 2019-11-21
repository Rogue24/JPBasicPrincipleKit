1. 一个NSObject对象占用多少内存？
 	· 系统分配了16个字节给NSObject对象（通过malloc_size函数获得）
 	· 但NSObject对象内部只使用了8个字节的空间（64bit环境下，可以通过class_getInstanceSize函数获得），NSObject对象只有一个isa指针，这8个字节就是用来存放isa这个成员变量

2. 对象的isa指针指向哪里？
	· instance对象的isa指向class对象
	· class对象的isa指向meta-class对象
	· meta-class对象的isa指向基类的meta-class对象，基类的meta-class对象的isa指向自身

3. OC的类信息存放在哪里？
	· 实例方法、属性信息、成员变量信息、协议信息都存放在class对象中
	· 类方法存放在meta-class对象中
	· 成员变量的具体值存放在instance对象中
￼
￼￼
