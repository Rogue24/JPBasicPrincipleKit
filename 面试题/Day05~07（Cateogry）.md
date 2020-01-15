1. Category的实现原理。
	- Category编译之后的底层结构是struct category_t，里面存储着分类的实例方法、类方法、属性、协议信息
	- 在程序运行的时候，Runtime会将Category的数据，合并附加到类信息中（class对象、meta-class对象）
	- PS1：Runtime将分类的方法放在原来的方法的前面，因此分类的方法优先级更高，所以如果有重名的方法，会优先调用分类的方法
	- PS2：如果多个分类有重名的方法，【后】编译的分类的方法优先级更高，因为Runtime里面的方法列表附加操作的顺序是下标从大到小进行的，越往后越靠前
	· PS3：在 Tatgets -> Build Phases -> Compile Sources 中可以控制编译顺序，编译是从上到下的顺序，想调用的优先级高的就往下放

2. Category和Class Extension的区别是什么？
	- Class Extension在编译的时候，它的数据就已经包含在类信息中
	- Category是在运行时，才会将数据合并到类信息中

3. Category中有load方法吗？load方法是什么时候调用的？load方法能继承吗？
	- 有。
	- load方法在Runtime加载类、分类的时候调用
	- load方法可以继承，在子类没有重写load方法，主动去调用load方法（发送消息的方式）时会调用父类的load方法，说明是有继承关系的，但是一般情况下不会主动去调动load方法，都是让系统自动调用（Runtime加载时是直接拿到load方法的地址去调用，之后手动调用时其实就是利用消息发送机制：子类没有load方法就会去父类的方法列表里面找）

4. load、initialize方法的区别是什么？它们在Category中的调用的顺序？以及出现继承时它们之间的调用过程？
	- 区别：
		1. 调用方式
			1. load是根据函数地址直接调用
			2. initialize是通过objc_msgSend调用
		2. 调用时刻
			1. load是Runtime加载类、分类的时候调用，只会调用1次
			2. initialize是类第一次接收到消息的时候调用，每一个类只会调用initialize一次，但父类的initialize方法可能会被调用多次（例如：子类和子类的分类都没有实现initialize方法时就会去调用父类的initialize方法）
	- 调用顺序
		1. load：
			1. 先调用类的load
				1. 先编译的类，优先调用load
				2. 调用子类的load之前，会先调用父类的load
			2. 再调用分类的load
				- 先编译的分类，优先调用load
		2. initialize：
			1. 调用父类的initialize（初始化）
			2. 再调用子类的initialize（初始化）
	
			`可能最终调用的是父类的initialize（子类没有实现initialize）`

5. Category能否添加成员变量？如果可以，如何给Category添加成员变量？
	- 不能直接给Category添加成员变量，但是可以间接实现Category有成员变量的效果（关联对象）。
￼
￼
￼













