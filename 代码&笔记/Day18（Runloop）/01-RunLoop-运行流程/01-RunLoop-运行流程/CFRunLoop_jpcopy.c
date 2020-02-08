// RunLoop运行的源码（简化版）

/**
 * RunLoop处理各种事件的调用（调用外部的具体操作）：
 *【CALLING_OUT_TO】
 * 通知Observers：
    __CFRunLoopDoObservers --> __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__
 * 处理Source0：
    __CFRunLoopDoSources0 --> __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__
 * 处理Source1：
    __CFRunLoopDoSource1 --> __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__
 * 处理Blocks：
    __CFRunLoopDoBlocks --> __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__
 * 处理Timers：
    __CFRunLoopDoTimers --> __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__
 * 处理GCD：
    __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__
 */

/* rl, rlm are locked on entrance and exit */
static int32_t __CFRunLoopRun(CFRunLoopRef rl, CFRunLoopModeRef rlm, CFTimeInterval seconds, Boolean stopAfterHandle, CFRunLoopModeRef previousMode) {
    
    int32_t retVal = 0;
    do {
        /**
         * PS：只需要看一下这3个部署目标的代码就好了，其他是别的平台
         * DEPLOYMENT_TARGET_MACOSX：MacOS
         * DEPLOYMENT_TARGET_EMBEDDED：嵌入式设备（手机、平板）
         * DEPLOYMENT_TARGET_EMBEDDED_MINI：mini嵌入式设备（手机、平板）
         */
        
        // 通知Observers：即将处理Times
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeTimers);
        
        // 通知Observers：即将处理Sources
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeSources);

        // 处理Blocks
        __CFRunLoopDoBlocks(rl, rlm);

        // 处理Source0
        Boolean sourceHandledThisLoop = __CFRunLoopDoSources0(rl, rlm, stopAfterHandle);
        
        if (sourceHandledThisLoop) {
            // 处理Blocks
            __CFRunLoopDoBlocks(rl, rlm);
        }

        Boolean poll = sourceHandledThisLoop || (0ULL == timeout_context->termTSR);

        // 判断有无Source1
        if (__CFRunLoopServiceMachPort(dispatchPort, &msg, sizeof(msg_buffer), &livePort, 0, &voucherState, NULL)) {
            // 如果有Source1，就跳转到<<handle_msg>>
            goto handle_msg;
        }

        // 通知Observers：即将休眠
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeWaiting);
        // 开始休眠（等待消息唤醒）
        __CFRunLoopSetSleeping(rl);
        
        // ---------------> 阻塞当前线程 <---------------
        //【！这里并不是靠死循环来阻塞线程，而是切换到<内核态>控制当前线程休眠！】
        do {
            /**
             * 执行 __CFRunLoopServiceMachPort 让线程休眠等待消息唤醒
             * 这里其实并不是靠死循环来阻塞线程，而是真的让线程休眠，外面的do-while只是一层保险
             * 通过do-while不断循环判断实现线程阻塞，但还是会占用CPU资源
             * 真正让线程休眠的是指任何事情都不干，连一句汇编代码都不执行，不占用CPU资源（省电）
             */
            // 等待别的消息来唤醒当前线程（内部调用 mach_msg() 实现让线程休眠）
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY, &voucherState, &voucherCopy);
            /**
             * mach_msg()：从<用户态>调用，切换到<内核态>控制当前线程休眠，等待消息
                * 没有消息，让线程休眠
                * 有消息，唤醒线程，去处理消息
             * 内核态：内核、操作系统、硬件层面的API（例：直接杀死或者休眠线程这种操作）
             * 用户态：应用层面的API（例：搭建UI界面、发送网络请求等）
             */
        } while (1);
        // ---------------> 阻塞当前线程 <---------------
        
        // ↓↓↓ 来到这里就是有别的消息，唤醒了线程，跳出循环继续下面的代码 ↓↓↓
        
        // 结束休眠（被某个消息唤醒）
        __CFRunLoopUnsetSleeping(rl);
        // 通知Observers：结束休眠
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopAfterWaiting);

    handle_msg:
        
        // 查看醒来的原因

        // 被timer唤醒
        if (rlm->_timerPort != MACH_PORT_NULL && livePort == rlm->_timerPort) {
            CFRUNLOOP_WAKEUP_FOR_TIMER();
            // 处理Timers
            __CFRunLoopDoTimers(rl, rlm, mach_absolute_time());
        }
        // 被gcd唤醒
        else if (livePort == dispatchPort) {
            // 处理gcd
            __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
        }
        // 被Source1唤醒
        else {
            // 处理Source1
            __CFRunLoopDoSource1(rl, rlm, rls, msg, msg->msgh_size, &reply) || sourceHandledThisLoop;
        }
        
        // 处理Blocks
        __CFRunLoopDoBlocks(rl, rlm);
        
        // 设置返回值
        if (sourceHandledThisLoop && stopAfterHandle) {
            retVal = kCFRunLoopRunHandledSource;
            } else if (timeout_context->termTSR < mach_absolute_time()) {
                retVal = kCFRunLoopRunTimedOut;
        } else if (__CFRunLoopIsStopped(rl)) {
                __CFRunLoopUnsetStopped(rl);
            retVal = kCFRunLoopRunStopped;
        } else if (rlm->_stopped) {
            rlm->_stopped = false;
            retVal = kCFRunLoopRunStopped;
        } else if (__CFRunLoopModeIsEmpty(rl, rlm, previousMode)) {
            retVal = kCFRunLoopRunFinished;
        }
        
        voucher_mach_msg_revert(voucherState);
        os_release(voucherCopy);

    } while (0 == retVal);

    return retVal;
}

SInt32 CFRunLoopRunSpecific(CFRunLoopRef rl, CFStringRef modeName, CFTimeInterval seconds, Boolean returnAfterSourceHandled) {     /* DOES CALLOUT */

    // 通知Observers：进入loop
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopEntry);
    
    // 具体要做的事情
    result = __CFRunLoopRun(rl, currentMode, seconds, returnAfterSourceHandled, previousMode);
    
    // 通知Observers：退出loop
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
    
    return result;
}

