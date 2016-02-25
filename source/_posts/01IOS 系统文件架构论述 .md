---
layout: post
title: "温馨提示"
date: 2016-01-24 13:32:08 +0800
comments: true
categories: Summary
---

系统文件架构概述

1.IOS是由Mac OS X演化而来，而Mac OS X则是基于UNIX操作系统的，三者有区别，但血脉相连

2. IOS系统主要的文件目录说明：
    /Applications : 存放系统的App和来自Cydia 的App，不包括App Store下载的，越狱过程把/Applications变成了一个符号链接，实际指向/var/stash/Applications
    /Library : 存放系统APP和Cydia App的数据（数据文件、动态链接库等）
    /Library/MobileSubstrate : 存放所有基于MobileSubstrate的插件，MobileSubstrate是一个提供  hook功能的基础平台，运行在这个平台上的插件通称为tweak   
   /System/Library/Frameworks
   /System/Library/PrivateFrameworks : IOS的共有和私有框架库，路径与模拟器的不同，在使用一些私有函数库时需要指定这样的路径
   /System/Library/CoreServices/SpringBoard.app，也就是桌面管理器，越狱开发时刻用到
   /System/Library/PreferenceBundles : 各种bundle提供了“设置”中得大多数功能，越狱开发可用
   /User 实际指向 /var/mobile ： 存放用户数据（跟用户相关的数据都在此）
   /var/mobile/Application :  一般应用程序安装的目录

3.越狱/逆向分析方法：
    找到需要实现的功能点，可能是一个app、framework、动态库， 对于app先要哪个Reveal找到界面上的触发点，然后class-dump可执行文件或framework  找到对应的函数  然后结合IDA、Hopper汇编分析