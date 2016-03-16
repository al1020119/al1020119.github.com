
---
layout: post
title: "简单App实战"
date: 2016-03-14 13:32:08 +0800
comments: true
categories: Summary
---


底层开发之越狱开发第一篇

 

做越狱开发也有一些时间了，有很多东西想总结一下，希望给他人一些借鉴，也是自己对过去开发经历的一些总结。个人不推荐使用盗版，这里主要以技术介绍为主。

这个系列里面主要介绍怎样进行越狱开发，涉及到以下几个方面:

* (1)主要涉及到越狱市场的建立，在App内部实现ipa的安装和卸载以及更新。参照的对象就是91助手，25pp，同步推那样的应用。建立一个盗版的App Store.当然了，如果通过299刀的企业证书的话，是不需要通过Cydia的，直接通过网页链接就可以实现app的推广，有一定的风险。这里面涉及到一些协议，后面会进行介绍。
* (2)在App内部实现壁纸和铃声的替换。这个过程涉及到的东西很多，特别是铃声的替换，iPhone里面非常麻烦；
* (3)一些越狱插件的开发，通过里面有些插件非常好用，合理，而且非常美观漂亮。
这里先从App内部安装ipa包开始讲，后面逐步把上面提到的3点全部讲完。

一般情况下安装91助手，同步推这样的应用需要手机越狱，同时安装AppSync，这样才能使用，所以进行开发的必备条件也是如此。

上传的demo工程的地址，我的github链接：https://github.com/easonoutlook/IPAInstaller

之前一直在fork别人的东西，也没做什么贡献，从现在开始，为开发为开源，做一点自己的贡献。

 

进入正题：

需要的工具和环境：

* A. iPhone or iPad越狱，安装AppSync
* B. Xcode安装 Command Line Tools
* C. 下载最新版本的ldid https://github.com/downloads/rpetrich/ldid/ldid.zip
 

####1、修改SDKSettings.plist文件

我用的是Xcode4.6.3版本，iPhone的版本是6.1.2, 路径为：/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/

将这个目录下的 SDKSettings.plist里面的CODE_SIGNING_REQUIRED置为NO

执行命令为：

转到目录下

	cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk

将原有文件备份

	sudo cp SDKSettings.plist SDKSettings.plist.orig

对SDKSettings.plist文件进行编辑

	sudo vim SDKSettings.plist

将下面对应的字段改为NO

	<key>CODE_SIGNING_REQUIRED</key>
	<string>YES</string>  // 默认为YES, 需要改为NO
此操作参考的路径如下：http://kqwd.blog.163.com/blog/static/4122344820117191351263/

 

####2、给工程添加相应的权限，iOS6里面需要赋予权限才可以，iOS5之前不需要此操作

新建一个plist文件，命名为entitlements.



{% img /images/nixiang005.png Caption %}  


创建一个plist



{% img /images/nixiang006.png Caption %}  

将plist文件改为：

复制代码
复制代码

	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	    <dict>
	        <key>com.apple.private.mobileinstall.allowedSPI</key>
	        <array>
	            <string>Install</string>
	            <string>Browse</string>
	            <string>Uninstall</string>
	            <string>Archive</string>
	            <string>RemoveArchive</string>
	        </array>
	    </dict>
	</plist>
复制代码
复制代码
将Code Signing 的Code Signing Entilements设置为刚刚创建的entitlements.plist文件



{% img /images/nixiang007.png Caption %}  


后面还需要一个手续，将生产的app文件用ldid签名。后面再介绍。

 

3、实现越狱安装的代码：

复制代码
复制代码

	typedef NSDictionary *(*	PMobileInstallationLookup)(NSDictionary *params, id callback_unknown_usage);
	NSDictionary *IPAInstalledApps()
	{
	    void *lib = dlopen("/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation", RTLD_LAZY);
	    if (lib)
	    {
	        PMobileInstallationLookup pMobileInstallationLookup = (PMobileInstallationLookup)dlsym(lib, "MobileInstallationLookup");
	        if (pMobileInstallationLookup)
	        {
	            NSArray *wanted = nil;//[NSArray arrayWithObjects:@"com.celeware.IPADeploy",@"com.celeware.celedial",nil]; Lookup specified only
	            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"User", @"ApplicationType", wanted, @"BundleIDs",nil];
	            NSDictionary *dict = pMobileInstallationLookup(params, NULL);
	#ifdef DEBUG
	            NSLog(@"%@", dict);
	#endif
	            return dict;
	        }
	    }
	    return nil;
	}
复制代码
复制代码
所有代码均在之前的github目录中，可以自行查看。

 

4、编译生成App文件

因为需要给APP签名加权限，所以不要生成IPA文件，而是生成APP文件。等把签名与权限加好后，再手动用APP制作IPA文件。

 在Xcode中选择设备（IOS Device）（图3），编译（Build）（图4）。编译完成后，在工程的Products文件夹中可以看到刚刚编译好的APP文件，右键Show in Finder（图5），就可以在文件夹中显示。将APP复制到一个别的文件夹中，什么地方都可以，后面需要用到。




{% img /images/nixiang008.png Caption %}  

 

5、制作ipa文件

将之前提到的ldid下载好后，将ldid文件放到/usr/bin中。

比如在 Download 目录下， sudo -i 

然后 cp ldid /usr/bin/即可将文件拷贝到/usr/bin中。

然后对之前生成的文件，进行ldid签名



{% img /images/nixiang009.png Caption %}  

 

这个命令中“ldid -S” ，“ldid”与“-S”之间有一个空格。“-S”与“entitlements.xml”之间没有空格。“entitlements.xml”就是上面说到的XML文件，如果你的XML不是这个名，请将命令修改为你的XML文件名即可。

“-Sentitlements.xm”与“ipainstall.app”之间有一个空格。“ipainstall”是刚刚生成的APP文件，如果你的名字不一样，请修改为你的名字。“/“后面和APP的名字是一样的。  如果没有输出错误信息或是卡住（就是敲回车后没反应）就是添加权限成功了。

 

6、生成ipa文件，安装

新建一个文件夹，命名为“Payload”。将刚刚添加好权限的APP文件放到这个文件夹中。右键“压缩Payload”，得到一个“.zip”文件，将这个ZIP文件的后缀名改为“.ipa”。好了，IPA文件就制作完成了。

然后通过itools安装，测试刚刚生成的文件


{% img /images/nixiang010.png Caption %}  

 

整合了很多资源，有些地方弄的比较凌乱，后面加以完善

 

参考资源链接：

http://since2006.com/blog/240/ios6-mobileinstallationinstall
http://blog.sina.com.cn/s/blog_9cd1705d0101l4bo.html
http://kqwd.blog.163.com/blog/static/4122344820117191351263/
http://blog.csdn.net/linkai5696/article/details/5924356
http://www.yonsm.net/post/553
http://stackoverflow.com/questions/14871748/how-do-i-change-my-applications-entitlements-to-com-apple-backboard-client
http://stackoverflow.com/questions/13817569/how-to-programatically-install-a-ipa-file-in-ios-6/15062538#15062538
http://since2006.com/blog/240/ios6-mobileinstallationinstall
http://hi.baidu.com/prognostic/item/831b622202b2dd0f72863e9c
http://www.vsyo.com/a/t/89895554d4043c5a
http://mobile.dotblogs.com.tw/cmd4shell/archive/2013/03/26/98967.aspx
 

