---
layout: post
title: "App打包发布———坑中之坑"
date: 2017-01-10 10:54:05 +0800
comments: true
categories: 
---

>上线了这么多App，关于App上线的坑，也遇到了很多，但是这一次是最严重，也是最值得思考的，所以我打算翻云覆雨一番。

##问题起源

	构建版本中找不到提交的二进制文件



可能有人会说，这个一般等个20分钟就有了的，如果是这么简单，那我还在这里写个鬼啊！

所以，等待被咔嚓了，因为我等了一个晚上。。。。。



<!--more-->



	因为年前的最后第二个版本就在昨晚打包提交（不要问我为什么是最后第二个，因为放假的那天晚上还有一场奋斗），因为我一般的习惯是公司打包提交之后，回到家里再点提交以供审核，所以就直接回家了。
	
	回到家里撒野没管，该干撒干撒，看书，看电影，和家里视频。。。。10点钟的时候，被老大告知，itnues connect里面是空的，不应该，从没遇到过这种问题，我在想估计又是苹果的坑，网上一搜，原来还真有一大把类似问题发，其中大部分这样的是因为我或者UI不细心。


好了下面细数一下整个过程。

+ 网上找到了这么几种问题及分析方案。

####图片错误提示

	运行成功，打包也成功，但是打包的时候报了一个：pngcrush caught libpng error:类似错误（这里即时有错误还是成功打包）

######两种解决方法 ：

	   1.  在build settings里把工程里的Compress PNG files设置为NO，问题解决，但这样设置以后，弄出来的ipa会很大，感觉不是很理想。
	    
	   2. mac上的preview(预览)打开出问题的png文件，然后重新导出为png文件或者用photoshop把png图片保存为NOT INTERLACED(不交错)的，这样真机调试时就没有错误了。


######还有一种类似的提示，当然大部分都会直接提示到对应的图片。

	 While reading /Volumes/data2/project/ChildStory/ChildStory/nav_bar.png pngcrush caught libpng error:
	
	  
	Could not find file: /Users/hopo/Library/Developer/Xcode/DerivedData/ChildStory-cwdwhztnszhpawbnlproivndbuvw/Build/Products/Debug-iphoneos/ChildStory.app/nav_bar.png
	
	Command /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/copypng emitted errors but did not return a nonzero exit code to indicate failure
	

######原因：

该文件不是真正的png文件，可能是个jpg文件（被你手动更改的），实际的文件头信息是不一样的，造成不能识别。


解决方法有两种：

	1. 重新把图片文件处理成png文件
	
	2. 修改文件名后缀，比如改成.jpg


###关于二进制

	提交打包提交App，将包上传到iTunes Connect之后，以为就能发布了，便点击构建版本，发现没有刚刚上传的包，于是就点击"预发行"看一下,会看到"已上传"，过不久再刷新一次再看，就变成了二进制无效，无比的郁闷，上传了五六次都是二进制文件无效，
	

######原因：

自2015年2月份开始,新上传到iTunes上面审核的app,必须支持64位，新上传是指第一次上传，

或者没有审核通过过，总之就是在AppStore上面没有上架的app,必须支持64位，包括工程里面的代码和用到的静态库文件

	1. build setting中Archivecture指定arm64
	2. Schemes的Analyze和Archive设置release模式
	3. Build Active Architecture Only：是否只编译当前设备适用的指令集（如果这个参数设为YES，使用iPhone 6调试，那么最终生成的一个支持ARM64指令集的Binary。一般在DEBUG模式下设为YES，RELEASE设为NO）。


Valid architectures：即将编译的指令集。（Valid architectures 和 Architecture两个集合的交集为最终编译生成的版本）

Architectures：你想支持的指令集。（支持指令集是通过编译生成对应的二进制数据包实现的，如果支持的指令集数目有多个，就会编译出包含多个指令集代码的数据包，造成最终编译的包很大。）


温馨提示+警钟

上线的时候一定要切忌（作为一个好的程序员应有的习惯）

	1. 不要TMD直接修改jpg<-->png。
	2. 一定要跑真机，一定要Analyze，一定要跑一下Profile里面常见的工具。
	3. 编译，运行，打包的时候一定不能放过任何错误，一个都不行。
	4. 编译，运行，打包（尤其是打包）的时候一定要尽量减少警告。
	5. archive之前一定要细心检查相关配置，release/debug，API切换，脚本配置等等
	6. Archive-Upload之后，最好等提交以供审核了之后再下班，或者带电脑回去，不然运气不好加班也白加了。


######最后来个喜讯，相信这之前是大部分iOS开发者苦恼的问题之一，所以你们懂。



{% img /images/iCocosATS0001.png Caption %}  









===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  