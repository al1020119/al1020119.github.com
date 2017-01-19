---
layout: post
title: "Code ReView"
date: 2016-01-07 16:21:08 +0800
comments: true
categories: Summarize
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---


提高代码质量的方法：


1，codereview 

 Why we do Code Review(为什么进行)
	
	1、提高质量
	2、及早发现潜在缺陷与BUG，降低事故成本。
	3、促进团队内部知识共享，提高团队整体水平
	4、评审过程对于评审人员来说，也是一种思路重构的过程。帮助更多的人理解系统。


 Options of Code Review(代码评审的选择)

	1、最近一次迭代开发的代码
	2、系统关键模块
	3、业务较复杂的模块
	4、缺陷率较高的模块
	
如何做出从零开始code review呢, 我的建议是:

    tech leader 强压所有人开始 code review, 这是最重要的一步
    安排一次编码规范的技术分享
    前期经常回顾, 这次的code review开展的怎样, 有哪些地方可以改善
    对于积极的同学表示鼓励, 支持现场重构代码
    每天不光可以review代码, 也可以安排整场的技术分享



<!--more-->



2，单元测试

　本文对比两个iOS开发中常见的单元测试框架：OCUnit，被官方集成进XCode 4.x版本中；GHUnit，被推荐最多的测试框架，带GUI界面。初窥两款测试框架非常相似，而上手使用就会发现其中的区别。细节上的区别使两款框架在不同角度各有优劣。

* 3种时候会去想写测试：

    - 代码完成以后
    - 开始写代码之前
    - 修复了一个bug以后
    
    
    >第一种是完成了代码，恩我要测试一下我写的这些方法可靠不可靠。那这时候可以写测试。

	> 第二种一个著名的方法论TDD。主要思想就是在写代码之前，就全部设计好借口。函数名字什么的。然后在写能通过测试的函数。

	>第三种就是发现了bug，我修复了这个bug。为了确保修复是成功的。那就写个测试吧。
    
    
#####OCUnit

　　OCUnit是XCode 4.x集成的单元测试框架，OCUnit中的测试分为两类，一类称为Logic Tests，另一类称为Application Tests。Logic Tests更倾向于所谓的白盒测试，用于测试工程中较细节的逻辑；Application Tests更倾向于黑盒测试，或接口测试，用于测试直接与用户交互的接口。
 

+ OCUnit的测试用例最常用的方法有三个

	1. - (void)setUp：每个test方法执行前调用

	2. - (void)tearDown：每个test方法执行后调用

	3. - (void)testXXX：命名为XXX的测试方法

#####GHUnit

　　GHUnit是一款Objective-C的测试框架，除了支持iOS工程还支持OSX的工程，但OSX不在本文的讨论范围。GHUnit不同于OCUnit，它提供了GUI界面来操作测试用例，而且也不区分Logic Tests和Application Tests。

+  添加单元测试
	- 与集成进XCode的OCUnit相比，GHUnit的添加过程略显复杂。首先在上下载GHUnit的框架包，当前的For iOS的最新版本是0.5.6，解压后是一个GHUnitIOS.framework的文件夹。

	- 打开已经存在的工程，添加一个EmptyApplication Target，并在新Target中添加刚刚下载的GHUnitIOS.framework 

	- 在Build Phases中添加非官方框架并不会把框架文件拷贝到工程目录，而是只做一个链接，所以建议在添加之前先把框架拷贝到工程目录下。

	- 接下来用相同的方法添加框架依赖的其他库：“QuartzCore.framework”。

	- 在Build Settings中搜索“linker flags”，设置Other Linker Flags - Debug - 添加一个支持全架构和全版本SDK的标示“-ObjC -all_load”

3，看AF 等开源程序



架构设计



测试用例
 
 
XCTAssert
XCTAssertNotNil






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