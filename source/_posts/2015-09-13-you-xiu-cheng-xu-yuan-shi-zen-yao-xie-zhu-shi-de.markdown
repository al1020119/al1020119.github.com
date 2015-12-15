---

layout: post
title: "够逼格的注释习惯"
date: 2015-09-13 02:59:30 +0800
comments: true
categories: Developer

---





够逼格的注释习惯总结

 

 

首先关于注意这里就不说什么VVDocument了，来点新鲜的！

######也许你使用过#warning 警告提示

######也许你也使用过#pragma marks。

但是你见过或者使用过下面这个吗？

	Comments containing:
	MARK:
	TODO:
	FIXME:
	!!!:
	???:
没有，那么你就快速的看看下面的内容，非常好用，也非常简单，不过具体使用看个人



<!--more-->





 首先说一下三个最常用的：
 
 * 1、TODO

 等待实现的功能
 
 * 2、FIXME

 需要修正的功能
 
 * 3、！！！

 需要改进的功能

具体使用
	
	// FIXME:sss
	/* FIXME: sss */
	
	
	// MARK:sss
	/* MARK:sss */
	
	
	// !!!:sss
	/* !!!: sss */
	
	
	// ???:sss
	/* ???: sss */
	
	
	// TODO:sss
	/* TODO: sss */


	// Comments containing: sss
	/* Comments containing: sss */

注意空格.

 最后你会发现下面的效果，虽然和#pragma marks没有什么区别，但是这就是装逼原因

关于最后一个/* Comments containing: sss */，笔者还没照发对应的使用方法，如果你知道可以联系我哦！


<!--more-->