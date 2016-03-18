
---
layout: post
title: "静态分析与使用"
date: 2016-03-10 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---


逆向工程－静态分析及使用

 

 

看到一篇装逼技术，有机会好好研究一下。。。。。

 

最近在学习IOS逆向工程，查看网络上的资料也不是太多，边学边总结一下。

首先学习资料：

念茜（大神）的博客： http://nianxi.net

《ios应用逆向工程 分析与实战》





<!--more-->




----------------------------------------------------凌乱的分割线------------------------------------------

其次讲讲要用到的工具（ios安装工具使用Cydia中搜索安装，有些需要数据源可以自行查找）：

* 已经越狱的IOS设备：这是必须的

* OpenSSH（数据源：http://apt.saurik.com）：用于远程登录ssh和文件传输scp

* class-dump-z: 用于简单分析出工程中的类名和函数名

* IDA：强大的反编译工具

* Hopper Disassembler：类似IDA 我比较喜欢，能简单转换成OC的功能

* Reveal:UI层解析工具

* iFunBox 、 iTools ：两个都是强大的ios设备管理工具，越狱后能轻松读取应用文件等功能

 

----------------------------------------------------凌乱的分割线------------------------------------------

恩，差不多就这么多了！上面的工具大部分都是收费的，不过都是有试用版的，接下来我们一个个分析：

ios设备越狱，这个我就不讲了吧，不过我要赞@盘古团队一个，目前所有ios系统都可以越狱（包括ios8.x）

在ios设备上下载OpenSSH （数据源：http://apt.saurik.com），然后用电脑远程登录ios：

然后输入密码，@后面是手机的IP号，越狱后默认密码好像是123456.

传输文件的命令是

	scp gdbinit root@172.168.1.100:/var/root
	scp root@172.168.1.100:/var/root/123.txt ~/
 3. class-dump-z 是一个强大的函数提取工具，非常好用，也是基础工具

下载地址：http://stevenygard.com/projects/class-dump

                  https://code.google.com/p/networkpx/wiki/class_dump_z

可以发到手机里调用，也可以在电脑上调用，要解析的文件是在应用目录下x.app（里面还有用到的所有文件资源）下面的x（x是你要分析的应用名）以唱吧为例，用ifunbox找到应用进入应用目录就可以看到ktv.app了打开包文件就能找到ktv。

 

	$ class-dump-z ktv > ktv.txt       //导出所有内容到文件
	$ class-dump-z -H ktv -o ktvdir/   //导出所有内容目录到文件夹（首先要创建ktvdir文件夹）
 

 

*这里会有一个问题，就是从app store下载的应用解析出来会是乱码，因为应用被加密了。解决办法


{% img /images/nixiang001.png Caption %}  

去渠道上下应用如同步推、91

解密工具 如AppCrackr(源http://cydia.xsellize.com)、Crackulous、Clutch

	  class-dump 只能解析出类名和函数名，不能看到具体的实现逻辑。但是很直观

 4.IDA和Hopper Disassembler差不多，能看到每个函数的具体逻辑（但是-都是汇编）IDA很强大，能在后面标记的oc的函数名，但是我更喜欢Hopper Disassembler，因为他能简单的模拟出oc源码，但是也是非常简单的。两者按空格键都能显示出分支逻辑来。

    汇编非常难看懂，我们需要的是耐心+耐心。后面可以加上动态工具联合分析能更有效


{% img /images/nixiang002.png Caption %}  


 5.Reveal的功能就更强大了，能表明出UI的具体结构来，告诉你每个View的类型是什么，这通常也是我们常用的分析一个app的切入点。

下载地址：http://revealapp.com

下载完后打开reveal在菜单目录中help-show reveal library in finder打开库文件，将两个文件发到手机里



{% img /images/nixiang003.png Caption %}  

接下来编辑libReveal.plist文件

在/Library/MobileSubstrate/DynamicLibraries/下创建文件libReveal.plist，指定app的Bundle，可以指定多个

同学们会问了，app 的bundleID怎么查看呢，我们还是用ifunbox工具找到应用目录，在x.app文件夹中会有info.plist文件，打开就能找到。

最后重启设备-打开想分析的应用-电脑打开reveal接口，就可以点击分析了



{% img /images/nixiang004.png Caption %}  

总结一下吧，分析一个应用的逻辑是这样的：

* 拿个越狱机-下好工具

* 去越狱平台下个想分析的应用（或者去app store下，用解密工具解密一下）

* 导入reveal分析页面，得到想要的知道的具体视图类或者大致范围

* 分析class-dump中，找到想要的类和函数

* 在IDA中找到具体函数，查看逻辑

> 单纯的静态分析只能知道个大概，想知道框架和具体内容还需要动态分析（下面分析）的帮助。不过想知道一个应用用到了什么库，界面是什么结构，有什么图片资源，上面的绝对够用了。总之逆向工程是比较枯燥无味的东西，资料又少，需要的是。。。。。加油