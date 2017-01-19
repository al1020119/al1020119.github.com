---
layout: post
title: "站在AFN上看ASI"
date: 2015-01-05 14:53:45 +0800
comments: true
categories: Foundation
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

######一、底层实现

* 1> AFN的底层基于OC的NSURLConnection和NSURLSession

* 2> ASI的底层基于纯C语言的CFNetwork框架

* 3> ASI的运行性能 高于 AFN



<!--more-->




######二、对服务器返回的数据处理

* 1> ASI没有直接提供对服务器数据处理的方式，直接返回data\string

* 2> AFN提供了多种对服务器数据处理的方式
	
	* JSON处理
	
	* XML处理
	
	* 其他处理

######三、监听请求的过程

* 1> AFN提供了success和failure两个block来监听请求的过程（只能监听成功和失败）

	* success : 请求成功后调用
	
	* failure : 请求失败后调用

* 2> ASI提供了3套方案，每一套方案都能监听请求的完整过程

（监听请求开始、接收到响应头信息、接受到具体数据、接受完毕、请求失败）

	* 成为代理，遵守协议，实现协议中的代理方法
	
	* 成为代理，不遵守协议，自定义代理方法
	
	* 设置block

######四、在文件下载和文件上传的使用难易度

* 1> AFN

	* 不容易监听下载进度和上传进度
	
	* 不容易实现断点续传
	
	* 一般只用来下载不大的文件

* 2> ASI

	* 非常容易实现下载和上传
	
	* 非常容易监听下载进度和上传进度
	
	* 非常容易实现断点续传
	
	* 下载或大或小的文件都行

######五、ASI提供了更多的实用功能

* 1> 控制圈圈要不要在请求过程中转

* 2> 可以轻松地设置请求之间的依赖：每一个请求都是一个NSOperation对象

* 3> 可以统一管理所有请求（还专门提供了一个叫做ASINetworkQueue来管理所有的请求对象）

	* 暂停\恢复\取消所有的请求
	
	* 监听整个队列中所有请求的下载进度和上传进度




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