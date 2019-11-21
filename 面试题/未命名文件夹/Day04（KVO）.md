1. iOS用什么方式实现对一个对象的KVO？（KVO的本质是什么）
 	· 使用RuntimeAPI动态生成一个子类(NSKVONotifying_XXX)，并且让instance对象的isa指向这个全新的子类
 	· 当修改instance对象的这个属性时，会调用Foundation的_NSSetXXXValueAndNotify函数
		· -willChangeValueForKey: 
			· 记录旧值，触发之后的didChangeValueForKey
    		· 原本父类的setter方法
			· 赋值
   		· -didChangeValueForKey:  
			· 内部触发监听器Observer的监听方法(-observeValueForKeyPath:ofObject:change:context:)

	· PS：直接监听成员变量不起效，除非有成员变量的setXXX:方法，因为生成的子类要重写这个方法来进行监听
		// 直接修改不会触发KVO
		self.per1->_height += 1;
		// 这样才会触发KVO，说明NSKVONotifying_XXX内部重写的是setXXX:方法
		 [self.per1 setHeight:10];

2. 如何手动触发KVO
	· 手动调用-willChangeValueForKey:方法和-didChangeValueForKey:方法
	· 必须先-willChangeValueForKey:后-didChangeValueForKey:，且缺一不可