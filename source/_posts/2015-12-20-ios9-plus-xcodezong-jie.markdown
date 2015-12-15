---
layout: post
title: "iOS9+Xcode7总结"
date: 2015-12-20 23:56:09 +0800
comments: true
categories: Newfeatures
---



刚更新了Xcode 9 beat 2，运行了之前的工程，发现了一些问题，就针对性的做了一下iOS9的适配。
####1，默认使用HTTPS请求
如果在Xcode 9之前使用的时http请求，那么在XCode 9上编译的App是不能联网的，会提示如下错误:

	App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.
修改方法是要么使服务器支持https访问，要么关闭https的使用。第一种方法对于个人开发者来说代价还是比较大的，因此推荐使用后面一种方法，具体的做法是:在工程的Info.plist文件里添加NSAppTransportSecurity字典类型的，添加一个元素：key为NSAllowsArbitraryLoads，值为YES。

####2，iOS 9使用URL scheme必须将其加入白名单
否则会提示类似如下错误:


<!--more-->


		canOpenURL: failed for URL: "mqqopensdkapiV2://qqapp" - error: "This app is not allowed to query for scheme mqqopensdkapiV2”
修正方法是，Info.plist文件中添加一个key为LSApplicationQueriesSchemes的数组值，里面包含需要添加白名单的string类型的scheme。特酷吧在项目中使用了qq，微信等分享登录功能，需要添加的值为：

* mqqopensdkapiV2
* mqqOpensdkSSoLogin
* mqq
* mqzoneopensdkapiV2
* mqzoneopensdkapi19
* mqzoneopensdkapi
* mqzoneopensdk
* mqzone
* weixin
* wechat
更多其他适配点后续不断跟进。

####3，bitcode
使用Xcode7编译提示：
	
	XXX does not contain bitcode. You must rebuild it with bitcode enabled (Xcode setting ENABLE_BITCODE), obtain an updated library from the vendor, or disable bitcode for this target. for architecture arm64
	
bitcode是被编译程序的一种中间形式的代码。包含bitcode配置的程序将会在App store上被编译和链接。bitcode允许苹果在后期重新优化我们程序的二进制文件，而不需要我们重新提交一个新的版本到App store上。
Xcode7 默认开启了bitcode，如果App使用的第三方类库不支持bitcode会提示错误，只需要在”Build Settings”->”Enable Bitcode”选项中看关闭bitcode即可。

> 开启Bitcode编译后，编译产生的文件体积会变大 (因为是中间代码，不是用户下载的包)，且dSYM文件不能用来崩溃日志的符号化 (用户下载的包是Apple服务重新编译产生的，有产生新的符号文件)。通过Archive方式上传AppStore的包，可以在 Xcode的Organizer工具中下载对应安装包的新的符号文件。
转载请注明来自特酷吧,本文地址:www.tekuba.net/program/364/
 
 
####4，使用XCode7链接第三方库提示warning
	Lots of warnings when building with Xcode 7 with 3rd party libraries
	warning: Could not resolve external type c:objc(cs)NSString
	warning: Could not resolve external type c:objc(cs)NSDictionary
	warning: Could not resolve external type c:objc(cs)NSMutableString
	warning: Could not resolve external type c:objc(cs)NSError
https://forums.developer.apple.com/thread/17921
目前没发现好的解决办法，可以尝试如下:
I had this problem too.  Here's how I fixed it.

* 1)  Go to Build Settings -> Build Options -> Debug Information Format
* 2)  Change the Debug setting from "DWARF with dSYM File" to "DWARF"
* 3)  Leave the Release setting at "DWARF with dSYM File"

The problem appears to be that Xcode was trying to create dSYM files for Debug builds.  You don't need dSYM files for Debug builds -- it's release builds where you need them. 


***


######既然提到了Xcode7，那么Xcode7中也有几个需要注意的地方（Xcode7是随着ios9一起出来的，其实也就是ios9的新特性，只是不是sdk），

升级到XCode7之后，编译和上传到itunes connect中遇到了一些问题（特酷吧XCode版本7.0.1），在这里总结下：
####1，was built for newer iOS version (9.0) than being linked (7.0)
解决方法参考：http://qaseeker.com/32270491-xcode-7-warning-was-built-for-newer-ios-version-5-1-1-than-being-linked-5-1/

	the -w flag can be added to Build Settings -> Other Linker Flags

####2，Could not resolve external type c:objc(cs)
解决方法参考：

	https://community.pushwoosh.com/questions/2774/lot-of-warnings-with-xcode-70-and-pushwoosh-304
It looks like a bug of XCode 7. See the discussion here:

	https://forums.developer.apple.com/thread/17921

***

	To get rid of this warning you need to change debug information from "DWARF + dSYM" to DWARF.
	DWARF seems to be the default setting for new projects created in Xcode 7, but existing projects that are migrating to Xcode 7 probably still have DWARF with dSYM File as the setting.
特酷吧亲测发现使用XCode7新建工程的时候，Debug模式默认选择了DWARF。

####3，"The resulting API analysis file is too large. We were unable to validate your API usage prior to delivery
https://forums.developer.apple.com/thread/18493
建议处理

* 1，export IPA file (after you select Archive from within xCode)
* 2，Use Application Loader to upload
* 3，de-select Bitcode and Symbols

似乎目前对bitcode的支持还不是很好，建议关闭。再上传。

####4.最后就是和swift相关的。

如果使用了混编技术，也就是说里面涉及到了swift代码，实现了桥接，那么系统会偶尔出现崩溃的现象，这个时候需要修改一个属性

+ 1：选中项目
+ 2：选中target，在build Setting中搜索swift
+ 3：在出现的embedded content contains swift code选中对应的值
	
	- 使用了swift就是YES
	- 没有swift就是NO
