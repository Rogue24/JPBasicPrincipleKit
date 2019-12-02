1. 讲讲RunLoop，项目中有用到吗？
	- 运行循环，保持程序的持续运行，处理App中的各种事件（触摸事件、定时器事件等），节省CPU资源，提高程序性能（该做事时做事，该休息时休息）
	- 项目中用到的：
		1. 控制线程的生命周期（线程保活）
		2. 解决NSTimer在滑动时停止工作的问题
		3. 监控应用卡顿
		4. 性能优化。

2. RunLoop内部实现逻辑
	1. 通知Observers：进入Loop
	2. 通知Observers：即将处理Timers
	3. 通知Observers：即将处理Sources
	4. 处理Blocks
	5. 处理Source0（可能会再次处理Blocks）
	6. 如果存在Source1，就跳转到第8步
	7. 通知Observers：开始休眠（等待消息唤醒）
	8. 通知Observers：结束休眠（被某个消息唤醒）
		1. 处理Timer
		2. 处理GCD Async To Main Queue
		3. 处理Source1
	9. 处理Blocks
	10. 根据前面的执行结果，决定如何操作
		1. 回到第02步
		2. 退出Loop
	11. 通知Observers：退出Loop

3. RunLoop和线程的关系
	- 每条线程都有唯一的一个与之对应的RunLoop对象
	- RunLoop 保存在全局的Dictionary，线程作为key，RunLoop作为value ==> @ {线程：RunLoop}
	- 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建（懒加载，主线程的RunLoop是在UIApplicationMain()里面获取过的）
	- RunLoop会在线程结束时销毁（一对一的关系，共生体）
	- 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop

4. timer与RunLoop的关系
	- timer是存放在RunLoop对象中的``_modes集合``里面指定的那个Mode的``_timers数组``中（``runLoop._modes[x]._timers = [timer]``），如果是``commonMode模式``下，就存放在RunLoop对象的``_commonModeItems集合``中（``runLoop._commonModeItems = [timer]``）
	- timer是在RunLoop的运行流程中工作的，是RunLoop来控制timer什么时候执行的，首先会通知Observers即将处理timer，然后唤醒线程，通知Observers结束休眠，去处理timer

5. 程序中添加每3秒响应一次的NSTimer，当拖动tableView时timer可能无法响应要怎么解决？
	- 将timer添加到``commonMode模式``下，这不是真的模式，只是一个标记，RunLoop真正切换的还是``kCFRunLoopDefaultMode``和``UITrackingRunLoopMode``这两种模式，这只是告诉RunLoop要这样做：
		1. 将``kCFRunLoopDefaultMode``和``UITrackingRunLoopMode``放入到``_commonModes集合``中（这两个模式本来也存放在``_modes``中）
		2. 将timer放入到``_commonModeItems集合``中
	- 因为``_commonModeItems集合``里面的timer可以在``_commonModes集合``里面存放的所有模式下运行，所以无论有无滚动，timer都能运行

6. RunLoop是怎么响应用户操作的，具体流程是怎么样？
	- 由Source1捕捉系统事件，将事件放到事件队列里面（EventQueue），再由Source0去处理这些事件。

7. 说说RunLoop的几种状态
	- kCFRunLoopEntry：即将进入Loop
	- kCFRunLoopBeforeTimers：即将处理Times
   - kCFRunLoopBeforeSources：即将处理Sources
   - kCFRunLoopBeforeWaiting：即将进入休眠
   - kCFRunLoopAfterWaiting：刚从休眠中唤醒
   - kCFRunLoopExit：即将退出Loop

8. RunLoop的mode作用是什么？
	- Mode是用来隔离的，将不同的Mode的``Source0/Source1/Timer/Observer``隔离开来，互不影响，这样可以保证运行其中一种Mode时能比较流畅，不用处理其他Mode的``Source0/Source1/Timer/Observer``，例如滚动Mode时就只需要处理滚动的事情，不用处理默认Mode时的事情，让滚动更加流畅
		1. kCFRunLoopDefaultMode：App的默认Mode，通常主线程是在这个Mode下运行
		2. UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
		3. UIInitializationRunLoopMode: 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用 ---- <用不上>
		4. GSEventReceiveRunLoopMode: 接受系统事件的内部 Mode ---- <用不上>
		5. kCFRunLoopCommonModes: 这是一个标记（默认和滚动的Mode），不是一种真正的Mode