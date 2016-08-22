---
layout: post
title: "驱动开发"
date: 2016-04-15 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---


{% img /images/bgHeader.png Caption %}  


####一、系统架构


{% img /images/nixiangqudong001.png Caption %}  

我们编写的驱动一般运行在i/o Kit框架下。

####二、一些记录

* 开发工具 xcode
* 开发语言：c++, c

c++用的是嵌入式c++，是标准c++的子集。





<!--more-->





所以，stl、异常、多重继承、模板和runtime类型信息  都无法使用。


因为这些东西会导致编译出来的文件很大，且容易导致问题。


c++只能编写基于i/o Kit框架的驱动，而c语言则可以编写任意的驱动。

并且c++的驱动反汇编后很难看。

> 所以写驱动还是用c吧。这一点和微软默认的一样。
 
####三、编写一个驱动例子

1. 创建工程


{% img /images/nixiangqudong002.png Caption %}  


因为不是设备驱动，只能选择extension；如果是设备驱动，则选择IOKit Driver。 

2. 写代码

{% img /images/nixiangqudong003.png Caption %}  


苹果将studio.h这样的c++库换成了自己的libkern.h。

3. 添加引用库
因为代码中使用了libkern.h，所以要修改工程。


{% img /images/nixiangqudong004.png Caption %}  

4. 驱动入口


{% img /images/nixiangqudong005.png Caption %}  

5. 编译驱动

* 在xcode的product菜单里点击build就可以编译驱动了。
* xcode只是能编辑和编译驱动，无法调试驱动的。
* 编译驱动时，你需要有一个开发者账号，否则编译不过。
* 我没有账号，所以后面的操作无法进行，只能把书上的翻译过来。

6、运行驱动有2种方式：

* 1、拷贝驱动文件到目录 /system/library/extensions下，重启后自动运行；
* 2、在terminal中运行命令启动驱动：
  
  - sudo chown -R root:wheel 驱动名.kext   // 设置驱动文件的权限，如果有权限，这步可省略。
  sudo kextload 驱动名.kext  // 运行驱动

7. 卸载驱动：sudo kextunload 驱动名.kext

8. 显示当前系统中的驱动：kextstat


{% img /images/nixiangqudong006.png Caption %}  

9. 查看调试信息
printf输出的信息是保存在磁盘上的log文件中。通过tail和cat命令就可以查看。log文件在/var/log/kernel.log或者/Applications/Utilities目录下。


{% img /images/nixiangqudong007.png Caption %}  



===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  