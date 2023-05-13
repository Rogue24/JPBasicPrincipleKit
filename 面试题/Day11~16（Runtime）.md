1. 讲一下OC的消息机制
	- OC中的方法调用其实都是转成了objc_msgSend函数的调用，给receiver（方法调用者）发送一条消息（selector方法名）
	- objc_msgSend底层有3大阶段：
		1. 消息发送（当前类、父类中查找，先查找缓存，再查找方法列表）
		2. 动态方法解析（resolveInstanceMethod、resolveClassMethod）
		3. 消息转发（forwardingTargetForSelector、methodSignatureForSelector、forwardInvocation）

2. 消息转发机制流程       
	- 调用forwardingTargetForSelector:方法，返回转发对象
		- 返回值不为nil，将消息转发给别人 
			- objc_msgSend(转发对象, SEL);
		- 返回值为nil
			- 调用methodSignatureForSelector:方法，返回方法签名（返回值和参数信息）
				- 返回值不为nil
					- 调用forwardInvocation:方法 --> 根据方法签名包装成一个NSInvocation给到方法中让我们使用，自定义任何逻辑
				- 返回值为nil
					- 调用doseNotRecognizeSelector:方法 --> 报错
￼
3. 什么是Runtime？平时项目中有用过么？
	* Runtime：
		- OC是一门动态性比较强的编程语言，允许很多操作推迟到程序运行时再进行
		- OC的动态性就是由Runtime来支撑和实现，Runtime是一套C语言的API，封装了很多动态性相关的函数。
		- 平时编写的OC代码，底层都是转换成了Runtime API进行调用

	* 平时项目中用到的地方：
		- 利用关联对象（AssociatedObject）给分类添加属性
		- 遍历类的所有成员变量（可以访问私有成员变量）：修改私有成员变量、字典转模型、自动归档解档
		- 交换方法实现：交换系统的方法
		- 利用消息转发机制解决方法找不到的异常问题
		- 可以在程序运行的过程中动态生成新的类（KVO）