```swift
断点打印：
print xxx、p xxx ---> 打印地址存放的内容
po xxx ---> 打印对象

以16机制形式打印地址存放的内容（x在/右边代表16进制）：
p/x per->_tallRichHandsome
```

```swift
查看寄存器存的内容（地址）：
register read rax
打印：
rax = 0x0000000100008468  JPTestSwift6`static JPTestSwift6.Car.price : Swift.Int
```

```swift
x —> 查看地址存的内容：
1：x 0x10282b9c0 ---> View Memory形式
打印：
0x10282b9c0: 19 21 eb 94 ff ff 1d 00 00 00 00 00 00 00 00 00  .!..............
0x10282b9d0: 2d 5b 4e 53 54 69 74 6c 65 62 61 72 56 69 65 77  -[NSTitlebarView

2：x/5xg 0x0000000100008468 ---> 规定格式（右边的x代表16进制，g代表8个字节为一组，5代表给5组）
打印：
0x100008468: 0x000000000000000b 0x0000000000000000
0x100008478: 0x0000000000000000 0x0000000000000000
0x100008488: 0x0000000000000000
```

```swift
查看方法地址：[对象 methodForSelector:@selector(方法名)]
查看方法信息：p (IMP)方法地址
p (IMP)0x109924060 ==> (IMP) $1 = 0x0000000109924060 (01-KVO`-[JPPerson setAge:] at JPPerson.m:13)
```

```swift
查看完整的函数调用栈：bt ---> breakpoint tree
```