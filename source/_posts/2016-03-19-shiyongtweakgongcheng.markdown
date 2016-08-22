---
layout: post
title: "使用Tweak工程"
date: 2016-03-19 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---


{% img /images/bgHeader.png Caption %}  



iOS逆向 - 使用Tweak工程

创建第一个Tweak工程
1、创建工程

在目录下面启动NIC /opt/theos/bin/nic.pl ,可以看到有好多个模板可以选择。 1、4、6、8、9 是Theos自带的模板,其他的是 https://github.com/DHowett/theos-nic-templates 下载的。 这里主要学习tweak的用法，选择9

	  NIC 2.0 - New Instance Creator
	------------------------------
	  [1.] iphone/application
	  [2.] iphone/cydget
	  [3.] iphone/framework
	  [4.] iphone/library
	  [5.] iphone/notification_center_widget
	  [6.] iphone/preference_bundle
	  [7.] iphone/sbsettingstoggle
	  [8.] iphone/tool
	  [9.] iphone/tweak
	  [10.] iphone/xpc_service
	Choose a Template (required):





<!--more-->




输入工程的名字

	Project Name (required): reverseDemo

输入deb包的名字，相当于App的bundle id

	Package Name [com.yourcompany.reversedemo]: com.liuchendi.iOSReverse

输入tweak作者的名字

	Author/Maintainer Name [lovelydd]: liuchendi

输入MobileSubstrate Bundle filter，就是设置tweak作用对象的bundle identifier。就像上一节用Reveal查看别人的App一样，需要知道作用的对象是谁

	[iphone/tweak] MobileSubstrate Bundle filter [com.apple.springboard]: com.apple.springboard

安装完成后需要重启的应用，已进程名表示

	[iphone/tweak] List of applications to terminate upon installation (space-separated, '-' for none) [SpringBoard]: SpringBoard

一个Tweak工程就创建完成了
2、定制工程文件

查看工程里面的文件目录

	liuchendi@lovelyddtekiMBP reversedemo$ ls -l
	total 40
	-rw-r--r--  1 liuchendi  staff   182 12 17 17:30 Makefile
	-rw-r--r--  1 liuchendi  staff  1045 12 17 17:30 Tweak.xm
	-rw-r--r--  1 liuchendi  staff   222 12 17 17:30 control
	-rw-r--r--  1 liuchendi  staff    57 12 17 17:30 reverseDemo.plist
	lrwxr-xr-x  1 liuchendi  staff    10 12 17 17:30 theos -> /opt/theos

Makefile：指定工程用到的文件、框架、库等信息，整个过程自动化。

// 固定写法
	include theos/makefiles/common.mk
	
	// tweak名字,就是工程的名字
	TWEAK_NAME = reverseDemo
	
	//tweak包含的源文件(不包括头文件),多个文件以空格分隔
	reverseDemo_FILES = Tweak.xm
	
	// 根据Theos工程的不同类型，指定不同的.mk文件。
	// 逆向初级阶段一般是Application、 Tweak 、Tool三种类型的程序
	// 分别对应的.mk文件是 application.mk 、tweak.mk 、tool.mk
	include $(THEOS_MAKE_PATH)/tweak.mk
	
	// 安装完成后,杀掉SpringBoard进程,好让CydiaSubstrate在进程启动时加载对应的dylib
	after-install::
	  install.exec "killall -9 SpringBoard"

其他功能：

	// 指定处理器架构，arm64架构不兼容armv7/armv7s架构,必须适配arm64的dylib
	ARCHS = armv7 arm64
	
	//指定SDK版本
	TARGET = iphone:8.1:8.0 	// 8.1是指定采用的SDK版本，8.0是可以部署安装的版本
	TARGET = iphone:latest:8.0 // Xcode附带的最新版本SDK
	
	//导入framework
	reverseDemo_FRAMEWORKS = UIKit CoreTelephony
	
	//导入私有framework
	reverseDemo_PRIVATE_FRAMEWORK = AppSupport ChatKit
	
	//链接Mach-O对象(Mach-O object)
	// -lx 代表链接libx.a 或者libx.dylib
	reverseDemo_LDFLAGS = -lx

Tweak.xm

默认生成的源文件，x表示支持Logos语法。

	/* How to Hook with Logos
	Hooks are written with syntax similar to that of an Objective-C @implementation.
	You don't need to #include <substrate.h>, it will be done automatically, as will
	the generation of a class list and an automatic constructor.
	
	%hook ClassName
	
	// Hooking a class method
	+ (id)sharedInstance {
	  return %orig;
	}
	
	// Hooking an instance method with an argument.
	- (void)messageName:(int)argument {
	  %log; // Write a message about this call, including its class, name and arguments, to the system log.
	
	  %orig; // Call through to the original function with its original arguments.
	  %orig(nil); // Call through to the original function with a custom argument.
	
	  // If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
	}
	
	// Hooking an instance method with no arguments.
	- (id)noArguments {
	  %log;
	  id awesome = %orig;
	  [awesome doSomethingElse];
	
	  return awesome;
	}
	
	// Always make sure you clean up after yourself; Not doing so could have grave consequences!
	%end
	*/

主要包括几个命令:

    %hook : 指定需要hook的class，必须以%end结尾

    %log : 在 %hook 函数内部使用，将函数的类名、参数等信息输出，还能够在结尾输出自定义格式信息

    %orig : 执行被hook住的源代码，更改原始函数的参数

    %group :将 %hook 分组，以%end结尾。便于代码管理及按条件初始化，不属于自定义的group都会隐式归类到%group_ungrouped中。 必须配合下面的 %init 命令才能生效

    %init : 初始化某个group，必须在 hook 或 %ctor 内调用。如果带参数，则初始化指定的group。不带参数则初始化_ungrouped。 只有调用了 %init ，group才能生效

    %ctor : 一个构造器，完成初始化工作。如果不显示定义，Theos自动生成一个 %ctor 。并在其中调用%init(_ungrouped), %ctor 不需要%end结尾

    %new : 给一个现有的class添加新函数,功能与class_addMethod相同

    %c : 等同于 objc_getClass 或者 NSClassFromString , 动态获取一个类的定义,在 %hook 或 %ctor 内使用

	control

control记录了deb包管理系统所需的基本信息, 会被打包进deb里。其内容如下:

	Package: com.liuchendi.iOSReverse
	Name: reverseDemo
	Depends: mobilesubstrate	//依赖条件
	Version: 0.0.1
	Architecture: iphoneos-arm
	Description: An awesome MobileSubstrate tweak!
	Maintainer: liuchendi	//deb包的维护人
	Author: liuchendi		//tweak作者
	Section: Tweaks			//所属程序类别

更全面的介绍在 这里

	reverseDemo.plist

记录一些配置信息，描述tweak的作用范围。其实就是一个字典， Filter 为外键，里面包含有 :

    Bundles : tweak作用对象, 也是app的bundle id
    Class : tweak作用的若干类
    Executables : 指定若干可执行文件

注意: 当Filter下有不同的类array时候，需要添加Mode: Any键值对
3、编译 + 打包 + 安装
编译:make

执行make,可能出现的错误

	Please run `/Users/liuchendi/Desktop/逆向/Demo/reversedemo/theos/bin/bootstrap.sh substrate` manually, with privileges.
	make: *** [before-all] Error 1

将iOS上的 /Library/Frameworks/CydiaSubstrate.framework/ CydiaSubstrate 拷贝到OSX中，将其重命名为libsubstrate.dylib后放到“/opt/theos/lib/libsubstrate. dylib”中

	/bin/sh: ldid: command not found

重新去 http://joedj.net/ldid 下载ldid，放在/opt/theos/bin/下面,然后赋予可执行权限 sudo chmod 777

成功后的显示,完成了预处理，编译，签名等一系列工作

	Making all for tweak reverseDemo...
	Preprocessing Tweak.xm...
	Compiling Tweak.xm...
	Linking tweak reverseDemo...
	Stripping reverseDemo...
	Signing reverseDemo...

发现多了一个obj文件夹

	liuchendi@lovelyddtekiMBP reversedemo$ ls -al
	total 40
	drwxr-xr-x  9 liuchendi  staff   306 12 17 23:20 .
	drwxr-xr-x  4 liuchendi  staff   136 12 17 17:31 ..
	drwxr-xr-x  4 liuchendi  staff   136 12 17 23:15 .theos
	-rw-r--r--  1 liuchendi  staff   182 12 17 17:30 Makefile
	-rw-r--r--  1 liuchendi  staff  1045 12 17 17:30 Tweak.xm
	-rw-r--r--  1 liuchendi  staff   222 12 17 17:30 control
	drwxr-xr-x  5 liuchendi  staff   170 12 17 23:20 obj
	-rw-r--r--  1 liuchendi  staff    57 12 17 17:30 reverseDemo.plist
	lrwxr-xr-x  1 liuchendi  staff    10 12 17 17:30 theos -> /opt/theos

打包 make package

出现的错误

	make[2]: Nothing to be done for `internal-library-compile'.
	Making stage for tweak reverseDemo...
	make: *** [internal-package] Error 255

下载dm.pl文件 https://raw.githubusercontent.com/DHowett/dm.pl/master/dm.pl ,然后重命名为dpkg-deb.pl,放到/opt/theos/bin/目录下面。 我把pl后缀名字隐藏了

成功执行后的显示,生成一个*.deb的包

	liuchendi@lovelyddtekiMBP reversedemo$ make package
	Making all for tweak reverseDemo...
	Preprocessing Tweak.xm...
	Compiling Tweak.xm...
	Linking tweak reverseDemo...
	Stripping reverseDemo...
	Signing reverseDemo...
	Making stage for tweak reverseDemo...
	dpkg-deb：正在新建软件包“com.liuchendi.iosreverse”，包文件为“./com.liuchendi.iOSReverse_0.0.1-5_iphoneos-arm.deb”。

多了一个， _ 目录,里面有 DEBIAN 和 Library 文件夹

	liuchendi@lovelyddtekiMBP reversedemo$ ls
	Makefile
	Tweak.xm
	_
	com.liuchendi.iOSReverse_0.0.1-5_iphoneos-arm.deb
	control
	obj
	reverseDemo.plist
	theos
	liuchendi@lovelyddtekiMBP reversedemo$ ls _
	DEBIAN  Library



{% img /images/nixiangtweak001.png Caption %}  


用 dpkg -c 查看生成的内容

	liuchendi@lovelyddtekiMBP reversedemo$ dpkg -c com.liuchendi.iOSReverse_0.0.1-5_iphoneos-arm.deb
	drwxr-xr-x liuchendi/staff   0 2015-12-17 23:48 ./
	drwxr-xr-x liuchendi/staff   0 2015-12-17 23:48 ./Library/
	drwxr-xr-x liuchendi/staff   0 2015-12-17 23:48 ./Library/MobileSubstrate/
	drwxr-xr-x liuchendi/staff   0 2015-12-17 23:48 ./Library/MobileSubstrate/DynamicLibraries/
	-rwxr-xr-x liuchendi/staff 49952 2015-12-17 23:48 ./Library/MobileSubstrate/DynamicLibraries/reverseDemo.dylib
	-rw-r--r-- liuchendi/staff    57 2015-12-17 23:48 ./Library/MobileSubstrate/DynamicLibraries/reverseDemo.plist

可以看到内容都是一样的
安装

	make package install

首先在Makefile添加下面的内容,主要是指定安装的手机ip
	
	ARCHS = armv7 arm64
	TARGET = iphone:latest:7.0
	THEOS_DEVICE_IP = 192.168.1.100

安装成功后的显示,期间要输入两次密码

	liuchendi@lovelyddtekiMBP reversedemo$ make package install
	Making all for tweak reverseDemo...
	make[2]: Nothing to be done for `internal-library-compile'.
	Making stage for tweak reverseDemo...
	dpkg-deb：正在新建软件包“com.liuchendi.iosreverse”，包文件为“./com.liuchendi.iOSReverse_0.0.1-7_iphoneos-arm.deb”。
	install.exec "cat > /tmp/_theos_install.deb; dpkg -i /tmp/_theos_install.deb && rm /tmp/_theos_install.deb" < "./com.liuchendi.iOSReverse_0.0.1-7_iphoneos-arm.deb"
	root@192.168.1.100's password: 
	Selecting previously deselected package com.liuchendi.iosreverse.
	(Reading database ... 2389 files and directories currently installed.)
	Unpacking com.liuchendi.iosreverse (from /tmp/_theos_install.deb) ...
	Setting up com.liuchendi.iosreverse (0.0.1-7) ...
	install.exec "killall -9 SpringBoard"
	root@192.168.1.100's password:


===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  