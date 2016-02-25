---
layout: post
title: "玩转定时器"
date: 2015-03-09 18:17:51 +0800
comments: true
categories: Projects
---

 {% img /images/dingshiqi.png Caption %}  

在软件开发过程中，我们常常需要在某个时间后执行某个方法，或者是按照某个周期一直执行某个方法。在这个时候，我们就需要用到定时器。

> 然而，在iOS中有很多方法完成以上的任务，到底有多少种方法呢？经过查阅资料，大概有三种方法：NSTimer、CADisplayLink、GCD。接下来我就一一介绍它们的用法。



<!--more-->




##一、NSTimer

#####1. 创建方法

	1     // 设置定时器
	2     [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
	3     
	4     // 0.1 setNeedsDisplay 绑定一个标识,等待下次刷新的时候才会调用drawRect方法
	5     // 0.15 屏幕的刷新时间
	
+ TimerInterval : 执行之前等待的时间。比如设置成1.0，就代表1秒后执行方法

+ target : 需要执行方法的对象。

+ selector : 需要执行的方法

+ repeats : 是否需要循环

#####2. 释放方法

	 [timer invalidate]; 

> 注意 :
调用创建方法后，target对象的计数器会加1，直到执行完毕，自动减1。如果是循环执行的话，就必须手动关闭，否则可以不执行释放方法。

#####3. 特性

+ 存在延迟

不管是一次性的还是周期性的timer的实际触发事件的时间，都会与所加入的RunLoop和RunLoop Mode有关，如果此RunLoop正在执行一个连续性的运算，timer就会被延时出发。重复性的timer遇到这种情况，如果延迟超过了一个周期，则会在延时结束后立刻执行，并按照之前指定的周期继续执行。

+ 必须加入Runloop

使用上面的创建方式，会自动把timer加入MainRunloop的NSDefaultRunLoopMode中。如果使用以下方式创建定时器，就必须手动加入Runloop:

 
	NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self <span style="color: #3366ff;">selector</span>:@selector(timerAction) userInfo:nil repeats:YES];<br><br>
	[[NSRunLoop mainRunLoop] <span style="color: #3366ff;">addTimer</span>:timer forMode:NSDefaultRunLoopMode];
 注意NSTimer还有一个方法，因为每次用的时候都是使用带target的这个方法，突然有一天很好奇就研究了一下，他的使用也很简单，只是相对上面那个有点繁琐，

#####1:创建一个签名：

	 NSMethodSignature *singature = [NSMethodSignature signatureWithObjCTypes:"v@:"]; 2  

这里我想如果你仔细的话肯定注意到了：后面的“v@：”，这里是运行时的语法

在这里是指一个方法

	v放回viod类型
	@一个id类型的对象
	：对应SEL
	
关于运行时这里不多介绍请查看笔者之前的文章，或者查看官方文档，这是一个iOS开发者必须会的知识点

#####2:通过前面创建一个请求，并且设置对应的target和SEL


	<span style="color: #3366ff;">    NSInvocation</span> *vocation = [NSInvocation invocationWithMethodSignature:singature];
	    vocation.target = self;
	    vocation.selector = @selector(timeChange);
##### 3:在讲请求传到NSTimer中去实现定时

	[NSTimer scheduledTimerWithTimeInterval:1 invocation:vocation repeats:YES]; 

 

##二、CADisplayLink

#####1. 创建方法
 
	self.displayLink = [CADisplayLink displayLinkWithTarget:self <span style="color: #3366ff;">selector</span>:@selector(handleDisplayLink:)];   
	[self.displayLink <span style="color: #3366ff;">addToRunLoop</span>:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
 

#####2. 停止方法

  
	self.displayLink <span style="color: #3366ff;">invalidate</span>]; 
	self.displayLink = nil;
	         
 当把CADisplayLink对象add到runloop中后，selector就能被周期性调用，类似于重复的NSTimer被启动了；执行invalidate操作时，CADisplayLink对象就会从runloop中移除，selector调用也随即停止，类似于NSTimer的invalidate方法。
 

#####3. 特性

+ 屏幕刷新时调用

CADisplayLink是一个能让我们以和屏幕刷新率同步的频率将特定的内容画到屏幕上的定时器类。CADisplayLink以特定模式注册到runloop后，每当屏幕显示内容刷新结束的时候，runloop就会向CADisplayLink指定的target发送一次指定的selector消息， CADisplayLink类对应的selector就会被调用一次。所以通常情况下，按照iOS设备屏幕的刷新率60次/秒

* 延迟

iOS设备的屏幕刷新频率是固定的，CADisplayLink在正常情况下会在每次刷新结束都被调用，精确度相当高。但如果调用的方法比较耗时，超过了屏幕刷新周期，就会导致跳过若干次回调调用机会。

如果CPU过于繁忙，无法保证屏幕60次/秒的刷新率，就会导致跳过若干次调用回调方法的机会，跳过次数取决CPU的忙碌程度。

* 使用场景

从原理上可以看出，CADisplayLink适合做界面的不停重绘，比如视频播放的时候需要不停地获取下一帧用于界面渲染。

#####4. 重要属性

* frameInterval

NSInteger类型的值，用来设置间隔多少帧调用一次selector方法，默认值是1，即每帧都调用一次。

* duration

readOnly的CFTimeInterval值，表示两次屏幕刷新之间的时间间隔。需要注意的是，该属性在target的selector被首次调用以后才会被赋值。selector的调用间隔时间计算方式是：调用间隔时间 = duration × frameInterval。

#####CADisplayLink底层实现：

     setNeedsDisplay:底层并不会马上调用drawRect,只会给当前的控件绑定一个刷新的标识,每次屏幕刷新的时候,就会把绑定了刷新(重绘)标识的控件重新刷新(绘制)一次,就会调用drawRect去重绘


>  注意：如果以后每隔一段时间需要重绘,一般不使用NSTimer,使用CADisplayLink,不会刷新的时候有延迟

 

##三、GCD方式

#####执行一次
	 
	1 double delayInSeconds = 2.0;
	2 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); 
	3 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){ 
	4     //执行事件
	5 });
 

#####重复执行
	 
	1 NSTimeInterval period = 1.0; //设置时间间隔
	2 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	3 dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
	4 dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
	5 dispatch_source_set_event_handler(_timer, ^{
	6     //在这里执行事件
	7 });
	8 dispatch_resume(_timer);
 