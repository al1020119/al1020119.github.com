---

layout: post
title: "iOS生命周期"
date: 2013-09-30 21:52:15 +0800
comments: true
categories: Foundation
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



---


###控制器（View）生命周期

当一个视图控制器被创建，并在屏幕上显示的时候。 代码的执行顺序

	1、 alloc                                   创建对象，分配空间
	2、init (initWithNibName) 初始化对象，初始化数据
	3、loadView                          从nib载入视图 ，通常这一步不需要去干涉。除非你没有使用xib文件创建视图
	4、viewDidLoad                   载入完成，可以进行自定义数据以及动态创建其他控件
	5、viewWillAppear              视图将出现在屏幕之前，马上这个视图就会被展现在屏幕上了
	6、viewDidAppear               视图已在屏幕上渲染完成



<!--more-->




当一个视图被移除屏幕并且销毁的时候的执行顺序，这个顺序差不多和上面的相反

	1、viewWillDisappear            视图将被从屏幕上移除之前执行
	2、viewDidDisappear             视图已经被从屏幕上移除，用户看不到这个视图了
	3、dealloc                                 视图被销毁，此处需要对你在init和viewDidLoad中创建的对象进行释放


再来看张网上找到的图，结合上面的总结那么久很清晰了！


{% img /images/kongzhiqshengmzhouqi001.jpg Caption %}  



－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 
###app的启动过程
	1.先执行main函数，main内部会调用UIApplicationMain函数

	2.UIApplicationMain函数里面做了什么事情：

		1> 创建UIApplication对象
		2> 创建UIApplication的delegate对象—–PYAppDelegate
		3> 开启一个消息循环
		
	每监听到对应的系统事件时，就会通知MJAppDelegate

	根据plist文件判断是否需要加载storyBoard

如果有storyBoard

	加载Info.plist文件，读取最主要storyboard文件的名称

	加载最主要的storyboard文件，创建白色箭头所指的控制器对象

	并且设置创建的控制器为UIWindow的rootViewController属性(根控制器)

	初始化对应的子控件

如果没有storyBoard

	在代理的difinishLuaunchWithOPtions中为应用程序创建一个UIWindow对象(继承自UIView)，设置为PYAppDelegate的window属性

	并且设置创建的控制器为UIWindow的rootViewController属性(根控制器)

	初始化对应的子控件

－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－

###App的生命周期

这里只是简单的总结，关于有些方法我们并没有解除过，所以就略过了。

     1、application didFinishLaunchingWithOptions：当应用程序启动时执行，应用程序启动入口，只在应用程序启动时执行一次。若用户直接启动，lauchOptions内无数据,若通过其他方式启动应用，lauchOptions包含对应方式的内容。
     2、applicationWillResignActive：在应用程序将要由活动状态切换到非活动状态时候，要执行的委托调用，如 按下 home 按钮，返回主屏幕，或全屏之间切换应用程序等。

     3、applicationDidEnterBackground：在应用程序已进入后台程序时，要执行的委托调用。

     4、applicationWillEnterForeground：在应用程序将要进入前台时(被激活)，要执行的委托调用，刚好与applicationWillResignActive 方法相对应。

     5、applicationDidBecomeActive：在应用程序已被激活后，要执行的委托调用，刚好与applicationDidEnterBackground 方法相对应。

     6、applicationWillTerminate：在应用程序要完全推出的时候，要执行的委托调用，这个需要要设置UIApplicationExitsOnSuspend的键值。

