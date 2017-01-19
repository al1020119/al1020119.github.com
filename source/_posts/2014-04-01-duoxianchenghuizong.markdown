---

layout: post
title: "多线程总结"
date: 2014-04-01 13:53:19 +0800
comments: true
categories: Summarize
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



--- 

###一、进程和线程

#####1.什么是进程

进程是指在系统中正在运行的一个应用程序

每个进程之间是独立的，每个进程均运行在其专用且受保护的内存空间内

 

* 比如同时打开QQ、Xcode，系统就会分别启动2个进程

* 通过“活动监视器”可以查看Mac系统中所开启的进程

 


<!--more-->





#####2.什么是线程

1个进程要想执行任务，必须得有线程（每1个进程至少要有1条线程）

线程是进程的基本执行单元，一个进程（程序）的所有任务都在线程中执行

比如使用酷狗播放音乐、使用迅雷下载电影，都需要在线程中执行

 

#####3.线程的串行

1个线程中任务的执行是串行的

如果要在1个线程中执行多个任务，那么只能一个一个地按顺序执行这些任务

也就是说，在同一时间内，1个线程只能执行1个任务

比如在1个线程中下载3个文件（分别是文件A、文件B、文件C）

 

 

###二、多线程

#####1.什么是多线程

1个进程中可以开启多条线程，每条线程可以并行（同时）执行不同的任务

进程 ->车间，线程->车间工人

多线程技术可以提高程序的执行效率

比如同时开启3条线程分别下载3个文件（分别是文件A、文件B、文件C）

 

#####2.多线程的原理

同一时间，CPU只能处理1条线程，只有1条线程在工作（执行）
多线程并发（同时）执行，其实是CPU快速地在多条线程之间调度（切换）
如果CPU调度线程的时间足够快，就造成了多线程并发执行的假象
思考：如果线程非常非常多，会发生什么情况？
CPU会在N多线程之间调度，CPU会累死，消耗大量的CPU资源
每条线程被调度执行的频次会降低（线程的执行效率降低）

 

#####3.多线程的优缺点

* 多线程的优点

能适当提高程序的执行效率

能适当提高资源利用率（CPU、内存利用率）

 

* 多线程的缺点

开启线程需要占用一定的内存空间（默认情况下，主线程占用1M，子线程占用512KB），如果开启大量的线程，会占用大量的内存空间，降低程序的性能

线程越多，CPU在调度线程上的开销就越大

程序设计更加复杂：比如线程之间的通信、多线程的数据共享

 

#####4.多线程在iOS开发中的应用

主线程:一个iOS程序运行后，默认会开启1条线程，称为“主线程”或“UI线程”

主线程的主要作用

显示\刷新UI界面

处理UI事件（比如点击事件、滚动事件、拖拽事件等）

 

主线程的使用注意:别将比较耗时的操作放到主线程中。

耗时操作会卡住主线程，严重影响UI的流畅度，给用户一种“卡”的坏体验

 

#####5.代码示例

	//  YYViewController.m
	//  01-阻塞主线程
	//
	//  Created by apple on 14-6-23.
	//  Copyright (c) 2014年 itcase. All rights reserved.
	//
	
	#import "YYViewController.h"
	
	@interface YYViewController ()
	- (IBAction)btnClick;
	@end
	
	
	@implementation YYViewController
	
	
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	}
	
	
	//按钮的点击事件
	- (IBAction)btnClick {
	    //1.获取当前线程
	    NSThread *current=[NSThread currentThread];
	    //2.使用for循环执行一些耗时操作
	    for (int i=0; i<10000; i++) {
	        //3.输出线程
	        NSLog(@"btnClick---%d---%@",i,current);
	    }
	}
	
	@end

> 说明：当点击执行的时候，textView点击无响应。

执行分析：等待主线程串行执行。

开启子线程。




===
===


######微信号：
	
clpaial10201119（Q Q：2211523682）
    
######微博WB:

[http://weibo.com/u/3288975567?is_hot=1](http://weibo.com/u/3288975567?is_hot=1)

######gitHub：


[https://github.com/al1020119](https://github.com/al1020119)
	
######博客

[http://al1020119.github.io/](http://al1020119.github.io/)

===

{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  