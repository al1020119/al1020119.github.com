---
layout: post
title: "函数&amp;方法的奥秘"
date: 2015-02-08 23:54:30 +0800
comments: true
categories: Foundation
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---




首先问个问题，你知道函数与方法的区别吗？

什么？没有区别？那你就out了！


函数(function)，方法(method)，之前没细究它们的不同，随心所欲的想说哪个就说哪个，“这个初始化函数…”，“这个初始化方法…”，看着都差不多，没什么区别。
直到前几天，一个新来的同事，在看我整理的 Objective-C代码规范文档，里面有一段是这样的：

#####初始化函数

	- (void)init
	{
	…
	} 
	…

他看到后，疑惑的跟我说：“你这表达方式不对吧，你标题说的是函数，但是内容却说的是方法。”
哦？原来函数跟方法是不一样的。

##函数

一个代码块，完成特定的功能，然后将结果返回给调用方，常见的函数的格式是这样的：
 
	<return type> <function name> (<arg1 type> <arg1 name>, <arg2 type> <arg2 name>, ... )
	{
	  // Code here
	}
	一个函数声明与调用的例子：
	 
	// 实现函数
	int plus(int x, int y)
	{
	  return x * y;
	}
	
	int main (int argc, const char *argv[])
	{
	  int x = 2;
	  int y = 3;
	  // 调用函数
	  int result = plus(x, y);
	
	  return 0;
	}
##方法

也是一个代码块，不过方法是需要写在类里面的，调用时需要类或者对象才可以调用，一个 Objective-C 的方法例子如下：
 
	@implementation Person
	
	// 实现方法
	- (void)setName:(NSString *)name
	{
	  //code here
	}
	
	@end
	
	int main (int argc, const char *argv[])
	{
	  // 使用对象调用方法
	  [[Person new] setName:@"zhenby"];
	
	  return 0;
	}
***

#有什么不同


>那说到底，函数跟方法的不同就是：方法是属于类或者对象的，而函数则不一定，可以独立于类与对象之外，独立调用，所以可以说 函数 >= 方法，因此方法也可以叫 member function。

###Objective-C中的函数

Objective-C 中一般的函数是全局有效的(可在函数前加 static 关键字使得该函数只在该文件中有效)，即在一个文件中实现了一个函数，在同个项目中的其他代码中都可以直接调用此函数，所以定义函数时，函数名需要唯一，重复的函数名(不管参数是否一致)是编译不过的。
知道这个特性后，就可以把一些常用的代码块，比如获取当前时间戳这样的功能的整理成了一个函数，这样的好处是项目中的代码在需要时都可以直接调用，而不需要类或者对象，类似于 NSLog 函数。

而我在实现函数的时候，遇到了一个这样的警告“no previous prototype for function xxx ”，这个警告的意思是没找到一个前置的函数原型，在文件的顶端，或者头文件(如果有的话)加上你所加的函数原型就可以了，例如：
 
	// 函数原型
	int plus(int, int);
	/*
	 如果参数为空的话，在函数原型中需要传 void，在函数原型中参数为空的话，
	 在C中表示此函数可以接受任意个参数，在 Objective-C 中也有一样的规则
	 */
	long timestamp(void);
	
	
	// 实现函数
	int plus(int x, int y)
	{
	  return x * y;
	}
	
	long timestamp()
	{
	  // 返回当前的时间戳
	    return (long)[[NSDate date] timeIntervalSince1970];
	}
###Objective-C中的方法

在 Objective-C 中，方法的调用是通过消息传递来进行的，需要在运行时才能确定方法的地址(只要知道一个类的方法名，不管这个方法是否公开，都可以调用到，这也是为啥苹果的私有 API 会被挖出来，所以也没有受保护方法这样的说法，方法要么是公开的，要么是不公开的，无论公不公开，通过方法名都可以调用到方法)，而消息传递就是通过id objc_msgSend(id theReceiver, SEL theSelector, ...)这个函数来达到目的的，可以说 Objective-C 中的方法，其实相当于固定前两个参数的 objc_msgSend 函数。比如：
 
	@implementation Test
	
	- (long)timestamp
	{
	  NSLog(@"in timestamp");
	  // 返回当前时间戳   
	    return (long)[[NSDate date] timeIntervalSince1970];
	}
	
	@end
	
	// 调用 timestamp 方法
	Test *test = [Test new];
	[test timestamp];
	[test release];
	
	//----------------------------------------------------------
	
	/*
	 上面 [test timestamp] 这句代码就相当于以下的函数调用，
	 直接执行下面的代码，也可以在控制台中打印出 in timestamp。
	 */
	#import <objc/message.h>
	
	objc_msgSend(test, @selector(timestamp));



> 如果你还不了解是什么回事，那么你可以看看swift，我记得在学习swift1.2版的时候，官方提到了函数与方法的区别和注意点！





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