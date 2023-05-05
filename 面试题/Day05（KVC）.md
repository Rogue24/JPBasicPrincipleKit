1. 通过KVC修改属性会触发KVO么？
	- 会触发（不管有没有对应的setter方法）
		- 通过-_isKVOA方法判定是否有监听器（_isKVOA为KVO生成的NSKVONotifying_XXX的方法）
		- 内部实现：
			1. [per willChangeValueForKey:@"age"]; // 保存旧值，标识等会调用didChangeValueForKey
			2. 执行setter方法，如果没有则直接对成员变量赋值：per->_age = 20;
			3. [per didChangeValueForKey:@"age"]; // 通知监听器，XX属性值发送了改变

2. KVC的赋值和取值过程是怎样的？原理是什么？
	- 赋值 -setValue:forKey: 的过程：
		1. 按照优先级为 -setKey: 、-_setKey: 的顺序查找方法
			- 找到：传递参数，调用方法
		2. 找不到，查看 +accessInstanceVariablesDirectly 方法是否为YES
			- NO，不允许：抛出NSUnknownKeyException异常
		3. YES，允许，按照优先级为 _key、_isKey、key、isKey 的顺序查找成员变量
			1. 找到：直接赋值
			2. 找不到：抛出NSUnknownKeyException异常
	- 取值 -valueForKey: 的过程：
		1. 按照优先级为 -getKey 、-key、-isKey、-_key 的顺序查找方法
			- 找到：调用方法，取值
		2. 找不到，查看 +accessInstanceVariablesDirectly 方法是否为YES
			- NO，不允许：抛出NSUnknownKeyException异常
		3. YES，允许，按照优先级为 _key、_isKey、key、isKey 的顺序查找成员变量
			1. 找到：直接取值
			2. 找不到：抛出NSUnknownKeyException异常
	- PS：+accessInstanceVariablesDirectly：是否允许访问成员变量，默认为YES