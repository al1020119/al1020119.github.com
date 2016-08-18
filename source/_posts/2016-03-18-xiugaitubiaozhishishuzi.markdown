---
layout: post
title: "修改图标数字"
date: 2016-03-18 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

修改程序图标标示数字

 
1.修改自身应用图标标示数字：
   [UIApplication sharedApplication].applicationIconBadgeNumber = 10;
2. 修改其他应用图标标示数字：
   ios7.0下的sdk
   Use class-dump to dump the headers for /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.0.sdk/System/Library/PrivateFrameworks/iTunesStore.framework/iTunesStore

涉及的头文件

	ISOperation-ISAuthentication.h
	ISOperation-ISLoadSoftwareMapAdditions.h
	ISOperation-ISLoadURLBagAdditions.h
	ISOperation.h
	ISOperationDelegate-Protocol.h
	ISOperationQueue.h
	ISSetApplicationBadgeOperation.h
	
	You may have to edit ISOperation.h:





<!--more-->




1. Change the #import "NSOperation.h" to #import
2. Remove the "" in the first part of the interface. 
3. So you're just left with "id _delegate;"

Then copy these 3 files into a "Headers" dir inside of the /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.0.sdk/System/Library/PrivateFrameworks/iTunesStore.framework dir.

You can now add the iTunesStore framework to your xcode project. Just point to the dir above.

Now add "#import " to your code and, for your convenience, here's an example-function ready for use:

CODE：
   
	ISSetApplicationBadgeOperation *sbadge = [[ISSetApplicationBadgeOperation alloc] init];
    
    
    [sbadge setBundleIdentifier:bundleIdentifier];
    [sbadge setBadgeValue:[NSString stringWithFormat:@"%d",number]];
    [sbadge run];
    [sbadge release];
    
    
===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  