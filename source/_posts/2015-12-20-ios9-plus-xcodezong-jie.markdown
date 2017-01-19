---
layout: post
title: "iOS9+Xcode7总结"
date: 2015-12-20 23:56:09 +0800
comments: true
categories: News
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---



刚更新了Xcode 9 beat 2，运行了之前的工程，发现了一些问题，就针对性的做了一下iOS9的适配。
####1，默认使用HTTPS请求
如果在Xcode 9之前使用的时http请求，那么在XCode 9上编译的App是不能联网的，会提示如下错误:

	App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.
修改方法是要么使服务器支持https访问，要么关闭https的使用。第一种方法对于个人开发者来说代价还是比较大的，因此推荐使用后面一种方法，具体的做法是:在工程的Info.plist文件里添加NSAppTransportSecurity字典类型的，添加一个元素：key为NSAllowsArbitraryLoads，值为YES。


Apple介绍了iOS9中的App Transport Security，它要求所有App在默认情况下使用HTTPS来进行网络请求。由于不是所有的服务器都运行在HTTPS环境下，Apple也提供了相关的方法来禁用ATS。
 
 
+ 最后：出于数据安全考虑，在完全禁用ATS的情况下，你也应该为某些重要的站点打开ATS。你可以通过NSExceptionDomainskey来禁用/启用特定的站点的ATS。参照如下图片: 


{% img /images/ats001.png Caption %}  

* 该plist文件允许用户在HTTP环境下下载文件，但是只能在HTTPS情况下访问"workflow.is"

需要提醒的是，ATS的设置只针对当前bundle。这意味着你不仅需要在你主项目的info.plist中添加ATS相关的Key,同时也需要在其他bundle下的info.plist中添加相关配置。

> 关于iOS9的适配，github上有一个中文项目iOS9AdaptationTips可以提供很大的帮助。

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



####5.UILayoutGuide与NSLayoutGuide

在iOS 9.0和 OS X 10.11中，分别有两个新的类：UILayoutGuide 和 NSLayoutGuide。他们可以作为一种类似View的对象，参与到AutoLayout的布局约束中。作为一种新的布局解决方案,这两个类的出现使你无需再创建、显示无关的View了。举个栗子，原本需要一个空的UIView占位的地方，现在只需要用UILayoutGuide去替代它就可以了。
 
	// 创建LayoutGuide
	let layoutGuideA = UILayoutGuide()  
	let layoutGuideB = UILayoutGuide()
	 
	// 添加到View上
	let view: UIView = ...  
	view.addLayoutGuide(layoutGuideA)  
	view.addLayoutGuide(layoutGuideB)
	 
	// 用UILayoutGuide来添加布局约束
	layoutGuideA.heightAnchor.constraintEqualToAnchor(layoutGuideB.heightAnchor).active = true
	// 设置Identifier，为了方便DEBUG
	 
	layoutGuideA.identifier = "layoutGuideA"  
	layoutGuideB.identifier = "layoutGuideB"
	 
	// ...然后看看他们的Frame吧
	print("layoutGuideA.layoutFrame -> \(layoutGuideA.layoutFrame)")


#### NSLayoutAnchor

iOS9中另一个新增的API是NSLayoutAnchor。它的出现不仅仅是让使用代码添加约束变得简洁明了。通过该类强大的静态检查能力，还提供了额外的约束正确定保证。举个栗子，考虑以下使用NSLayoutConstraintAPI创建的约束会出现什么问题：
 
	NSLayoutConstraint *constraint =  
	    [NSLayoutConstraint constraintWithItem:view1 
	                                 attribute:NSLayoutAttributeLeading 
	                                 relatedBy:NSLayoutRelationEqual 
	                                    toItem:view2 
	                                 attribute:NSLayoutAttributeTop 
	                                multiplier:1.0 
	                                  constant:0.0];
这个约束是无效的。因为你将一个X轴上的属性(leading)同一个Y轴属性(top)绑定。然而，这个错误可以毫无警告地通过编译，在运行的时候默默地就失效了，最终留下一个出错的布局。由于这个错误不会产生任何的日志信息，导致极难debug。假如工程里有许多(成千上万)这样的约束代码，那对于维护来说真是一场噩梦。

好在NSLayoutAnchor利用了"泛型"解决了这个问题。"泛型"现在在Swift和Objective-C中都已经得到了支持。UIView中NSLayoutAnchor相关的存取方法，明确指出了需要哪些继承自NSLayoutAnchor的子类。这些子类被分为了三类，X轴，Y轴，和尺寸(宽/高)，一种类型的Anchor只允许绑定约束到另外一个相同类型的Anchor上。通过指定NSLayoutAnchor中参数的类型，这个API可以通过类型检查，来避免创建出例子中无效的约束。

我们回到之前的例子，用NSLayoutAnchor来实现一下这个约束：
 
	NSLayoutConstraint *constraint =  
		    [view1.leadingAnchor constraintEqualToAnchor:view2.topAnchor];
相比旧的API，新的API非常明显地提升了代码可读性。并且，当你传入错误的Anchor类型时，新的API会抛出一个"Incompatible pointer type"警告，因为编译器知道这个是两个不同的类。

> 想要了解更多，请查阅NSLayoutAnchor官方文档




#### Storyboard Reference

Storyboard真是让人又爱又恨，每个在多人合作项目中使用Storyboard的人，都遇到过Storyboard文件的冲突。类似的冲突解决起来比较棘手，常常是以回滚告终。这一点直接造成了一些团队放弃使用Storyboard开发而推荐纯代码布局。

如果需要使用Storyboard，但又想最大化地避免冲突呢？最好的方法就是将UI划分的更小的、不同的Storyboard文件中。在过去如果想要做到这一点，意味跨Storyboard的跳转方法，需要在代码里完成：
 
	UIStoryboard *destinationStoryboard = [UIStoryboard storyboardWithName:@"StoryboardName" bundle:nil];  
	DestinationViewController *vc = [destinationStoryboard instantiateViewControllerWithIdentifier:@"identifier"];
	//一顿设置
	...
	[self.navigationController pushViewController:vc animated:YES];
	
在Xcode7 和 iOS 9中，只需要用Storyboard Reference就可以用Segue轻松实现跨Storyboard的跳转了。Storyboard Reference的出现，保留了单个Storyboard文件跳转的优点的同时，提供了多Storyboard文件时利于合并的便利。

开始分割你那巨大的Storyboard文件吧。最快的方法是:

+ 缩放Storyboard
+ 框选一组逻辑相近的scenes
+ 选择Editor > Refactor to Storyboard...

自动Refactord的故事板文件会为每一个scenes留下一个UIStoryboard Reference，并且在需要的地方自动创建可读性不好的Storyboard ID。所以就个人来说，我更推荐手动复制scenes到新的故事板文件中，然后在源文件中删除这些scenes并手动添加Storyboard Reference。

> 如果你已经有多个故事板文件了，为自己庆祝一下吧——你又可以精简你的代码了！从Object库中拖拽一个UIStoryboard Reference，并配置segue。然后选取你手动跳转的代码，大力地按下删除键吧！




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