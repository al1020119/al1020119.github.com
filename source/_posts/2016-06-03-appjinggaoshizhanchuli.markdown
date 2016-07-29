---

layout: post
title: "警告与实战"
date: 2016-06-03 13:53:19 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



---  


App实战中遇到的警告问题及处理方式

<!--more-->

Xcode 升级后，常常遇到的遇到的警告、错误，解决方法


#####警告：“xoxoxoxo”  is deprecated

	解决办法：查看xoxoxoxo的这个方法的文档，替换掉这个方法即可。

##### 警告：Declaration of "struct sockaddr" will not be visible outside of this function

	解决办法：在你的开源.m文件中添加 #import <netinet/in.h>

	
#####警告：Implicit conversion from enumeration type 'UIInterfaceOrientation' to different enumeration type 'UIDeviceOrientation'

	解决办法：类型不匹配。跳到出错的那一行，UIInterfaceOrientation强制转换为UIDeviceOrientation就行了。

#####警告：incompatible pointer types assigning to 'MyArrayList*'from 'NSMutableArray'

	解决办法：加入强制转换(MyArrayList*)

#####警告：'&&' within '||'
问题出处：
    if (exists && !isDirectory || !exists)………
  
	  解决办法： if ((exists && !isDirectory) || !exists)………

#####警告：Warning：The Copy Bundle Resources build phase contains this target's Info.plist file

	解决办法：将Info.plist文件移到Resources目录下，而不要直接放在target下。

	

#####警告：在使用ASIHttp…第三方库的，运行报错。

	解决办法：看你的项目中是否添加CFNetwork.framework、SystemConfiguration.framework, MobileCoreServices.framework,
CoreGraphics.framework和libz.1.2.3.dylib，如果是sdk5.0以上，改添加libz.1.2.5.dylib

##### 警告：xxxooo，missing required architecture i386 in file

	解决办法：如果是错误信息的话：Target->Build Settings->Search Paths, 删除FrameworkSearch Paths 里面内容就可以了。
要只是一个警告的话，真机调试可以过。具体解决方法待大神出现。

#####警告：
clang: error: no such file or directory: '/demo2/控件代码/13/Recorder/Recorder_Prefix.pch'
clang: error: no input files
Command /Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/clang failed with exit code 1

	解决办法： 在你的主工程文件 target搜素，pch ，找到Prefix Header    把它后面的值，都删除，再运行就解决了。

#####警告：
“ARC forbids synthesizing a property of an Objective-C object with unspecified ownership or storage attribute

	解决办法：如果定义了ARC有效，那么必须要有所有者属性的定义;所以代码改成下面这样
	@property (nonatomic, strong, readonly) NSString *ss;

#####警告：
io6一下的xib系统均没有自动选择Use Autolayout， Supporting iOS 5 and below with xib of iOS 6

	解决办法：Just un-select “Use Autolayout” in the file inspector of the xib’s view and we are back to the familiar autosizing in size inspector and boom, it supports iOS 5 and below.

#####警告：
Warning: Multiple build commands for output file xxx.png

	解决办法：找到项目里xxx.png重复，删除重复的资源。

//以下是升级到 xcode 5.0.1 之后使用遇到的警告
##### 警告：
 “iOS 模拟器”未能安装此应用程序。

	解决办法：删除模拟器上当前要运行那个APP，重新运行项目。就ok

#####警告：
SpringBoard无法启动应用程序 错误:-3
	
	解决办法：退出模拟器，重新运行这个项目。

##### 警告：
The server certificate failed to verify.  

	解决办法：
	1、打开终端（实用工具 -->终端），在终端中输入如下命令：
	svn ls https://192.100.1.11?0/svn/xxxxxx（注意下面的url更换成你自己的url地址）
	然后直接输入 “ p ”  确认，就可以重新连接了。

#####警告：
Bitmasking for introspection of Objective-C object pointers is strongly discouraged.  

	解决办法：
	某数字& 0x1的时候是代表要取最低位是否为1，改成了  if(JK_EXPECT_F(((NSUInteger)object)%2))即可。
#####警告：
Implicit conversion loses integer precision: 'unsigned long' to 'CC_LONG' (aka 'unsigned int').  

	解决办法：
    CC_MD5(str,strlen(str), r);，改成了     CC_MD5(str, (CC_LONG)strlen(str), r);即可。

#####警告：
error: failed to launch '/private/var/mobile/Applications/xxxxx' -- failed to get the task for process 11140.  
	
	解决办法：
	    重启你的开发手机即可，还有一种可能是你的开发者证书与发布证书搞错了，检查在xcode中证书是否一直 。

#####警告：
error: ignoring filxxxxxx/libBaiduMobStat.a, missing required architecture x86_64 in filexxxx/libBaiduMobStat.a   

	解决办法：
	    targets ->build setting 下的  architectures 设置为 standard architetures(armv7,armv7s)   vaild architectures 设置为armv7,armv7s。

#####警告：
error: Directory not found for option '-L/Users/joryoubonxx/BaiduStatistic   

	解决办法：
	  删除  targets ->build setting 下的  library search path不正确的地址,如果还不行，重新添加第三库、clean ,重启Xcode.即可。

遇到相关的警告，一般编译器都会提供解决方案，所以，作为新手，我们应该看懂编译器给我们的提示，这样我们解决问题就会事半功倍。

