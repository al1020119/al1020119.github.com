---
layout: post
title: "逆向篇-方法与工具介绍"
date: 2016-02-25 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---



之前接触过iOS逆向开发，后来工作中没这方面需求，也就没再看了。最近一段时间由于各种原因又需要逆向某些App来用于学习，所以又重新拾起来。

这里总结一下几种iOS逆向的方法和工具：

####iOS逆向-静态分析

涉及到的工具有
    
   * OpenSSH (用于远程登录ssh和文件传输scp)
   * class-dump(用于简单分析出工程中的类名和函数名)
   * Hopper Disassembler(反编译工具)
   * Reveal (对越狱后的设备查看任意app的布局)





<!--more-->




iOS逆向-动态分析

涉及到的工具有
    cycript (cycript是一个脚本语言，可以看做Objective-JavaScript，形容 的非常贴切。配合静态调试，可以调用运行中的app内的任意方法)

iOS逆向-内部钩子

主要是编写iOS动态库，加载到越狱手机中，使用iOS的 Method Swizzling(方法调配)来获 得(截断/改变)底层调用的方法。这样我们可以自由的修改或者读取一些想要的东西。

iOS逆向相关:theos和iOSOpenDev搭建越狱开发环境，创建iOS动态链接库(Dylib文件)编写(hook)及测试；

iOS逆向思路进展:使用InspectiveC来查看调用堆栈：

跟踪一个程序，看看这个程序的执行流程是什么样的，以及某个函数的调用参数是什么。

常规的方法是在汇编中寻找objc_msgSend，一层一层跟下去。这是比较笨的办法，而且不能动态查看函数的数。

通过InspectiveC,我们可以动态的查看：

* 某个类的所有方法调用情况
* 某个类的某个方法的调用情况
* 某个类的实例对象的所有方法的调用情况
* 某个类的实例对象的某个方法的调用情况
* 某个方法签名的调用情况

跟踪一个程序，看看这个程序的执行流程是什么样的，以及某个函数的调用参数是什么。
 
常规的方法是在汇编中寻找objc_msgSend，一层一层跟下去。这是比较笨的办法，而且不能动态查看函数的数。
 
通过InspectiveC,我们可以动态的查看：
* 某个类的所有方法调用情况
* 某个类的某个方法的调用情况
* 某个类的实例对象的所有方法的调用情况
* 某个类的实例对象的某个方法的调用情况
* 某个方法签名的调用情况





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