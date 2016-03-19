---

layout: post
title: "EXC_BAD_ACCESS无处不在"
date: 2013-12-08 13:53:19 +0800
comments: true
categories: Developer
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

 

--- 

这种错误可以说是每次写代码都会遇到的，所以如果是你你会怎么解决呢，如果不知道那么请往下看
EXC_BAD_ACCESS, objc_msgSend, 

此类报错往往来的莫明奇妙.

原因往往是内存过度释放导致, 即多写了release;

至于是哪里多写了release, 很难查知,

 
出现这种情况， 也就是对指针对象的过度释放，导致次指针为野指针报错， （注意：如：[nil release] 操作空指针是不会报错的，在java中是有问题， [野指针 release] 报错  crash  很危险，）解决中bug，有很多中，暂时简单的说下几种简单的： 
 
#####一： 在xcode中Run，Stop 右边也就是选择设备的地方左边找到 
 
<!--more-->


 Scheme >Edit Scheme>Arguments>Environment Variables下添加

 1. NSZombieEnabled               YES    
 2. MallocStackLoggingNoCompact  YES
 3. MallocStackLogging                      YES

{% img /images/BADACCESS001.png Caption %}  

{% img /images/BADACCESS002.png Caption %}  

{% img /images/BADACCESS003.png Caption %}  


* 第一項 让系统把错误地址打印出来
* 第二項 可让xcode记录每个地址alloc的历史，这样我们就可以用命令把这个地址还原出来
* 第三項 可開啟MallocStack，就知道記憶體在程式運行中被配置的歷史

> （注意：这个命令只支持gdb，必须把控制台的输出改成gdb，只支持模拟器，不支持真机调试）

 
#####二：在.m或者.mm文件中  直接添加打印最后日志文件 代码如下：
 
	
	#ifdef _FOR_DEBUG_
	
	- (BOOL)respondsToSelector:(SEL)rtSelector
	
	{
	
	    NSString *className = NSStringFromClass([self class]) ;    
	
	    NSLog(@"%@ --> RTSelector: %s",className,[NSStringFromSelector(rtSelector)UTF8String]);
	
	        return [super respondsToSelector:rtSelector];
	
	}
	
	#endif
 

#####三：找到模糊的地方， 断点调试， 或者打印标识 从大范围到小范围，
 
具体操作我这里就不多说了，根据项目的需求在对应代码行的左边点击就可以打断点
 

#####四：Leak的方式
 
1. 打开Instruments工具:

Xcode -> Open Developer Tool -> Instruments, 

2. 选择Zombies类型.
{% img /images/BADACCESS004.png Caption %}  

3. 重新启动运行Project, 先不要执行到崩溃点.


4. 在打开的Instruments工具中choose要检查的程序名称;


5. 然后点击Instruments左上角的record按钮, 开始记录内存使用情况.

{% img /images/BADACCESS005.png Caption %}  
 
{% img /images/BADACCESS006.png Caption %}  
6. 继续执行程序至崩溃点.

程序执行到第40秒报出zombie Messaged错误;

7. 点击图中圈选的">"查看内存详情.
{% img /images/BADACCESS007.png Caption %}  

8. 分析内存调用详情:

排除操作系统retain, release的部分,

可知是由于CameraLiveViewController执行dealloc, 

对内存0x180d5420多调用了release.
{% img /images/BADACCESS008.png Caption %}  



###综合以上结果:

可知是存在于CameraLiveViewController中的一个UILabel多执行了release.

此时可添加代码对CameraLiveViewController中的可疑UILabel打印日志.

重新执行上述过程, 对比打印UILabel与Zobmie内存的地址, 

从而定位出错位置.
{% img /images/BADACCESS009.png Caption %}  

 

 
 
