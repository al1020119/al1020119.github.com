---
layout: post
title: "检测是否越狱"
date: 2016-03-05 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---


底层开发之越狱开发第二篇

 

今天项目中要用到检查iPhone是否越狱的方法。

Umeng统计的Mobclick.h里面已经包含了越狱检测的代码，可以直接使用





<!--more-->

复制代码

	/*方法名:
	 *        isJailbroken
	 *介绍:
	 *        类方法，判断设备是否越狱，判断方法根据 apt和Cydia.app的path来判断
	 *参数说明:
	 *        无
	 *        
	 *
	 */
	
	#pragma mark utils api
	// 类方法，判断当前设备是否已经越狱
	+ (BOOL)isJailbroken;
	// 类方法，判断你的App是否被破解
	+ (BOOL)isPirated;
复制代码

apt和Cydia的方式来进行判断的，没看见源码

 

然后再介绍两种方法来查看是否已经越狱，知其然知其所以然、、、

1. apt

---

	 - (BOOL) hasAPT
	 {
	 return [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"];
	 }

2. system

---


	1 - (BOOL) successCallSystem
	2 {
	3 return (system("ls") == 0) ? YES : NO;
	4 }
 

3.示例代码


	 1 static const char* jailbreak_apps[] =
	 2 
	 3     {
	 4         "/Applications/Cydia.app",
	 5         "/Applications/limera1n.app",
	 6         "/Applications/greenpois0n.app",
	 7         "/Applications/blackra1n.app",
	 8         "/Applications/blacksn0w.app",
	 9         "/Applications/redsn0w.app",
	10         "/Applications/Absinthe.app",
	11         NULL,
	12     };
	13      
	14     - (BOOL) isJailBroken
	15     {
	16         // Now check for known jailbreak apps. If we encounter one, the device is jailbroken.
	17         for (int i = 0; jailbreak_apps[i] != NULL; ++i)
	18         {
	19             if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]])
	20             {
	21                 //NSLog(@"isjailbroken: %s", jailbreak_apps[i]);
	22                 return YES;
	23             }
	24         }
	25          
	26         // TODO: Add more checks? This is an arms-race we're bound to lose.
	27          
	28         return NO;
	29     }
	30  
	31 
	32 @interface UIDevice (Helper)  
	33 - (BOOL)isJailbroken;  
	34 @end
	35 
	36 @implementation UIDevice (Helper)  
	37 - (BOOL)isJailbroken {  
	38   BOOL jailbroken = NO;  
	39   NSString *cydiaPath = @"/Applications/Cydia.app";  
	40   NSString *aptPath = @"/private/var/lib/apt/";  
	41   if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {  
	42     jailbroken = YES;  
	43   }  
	44   if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {  
	45     jailbroken = YES;  
	46   }  
	47   return jailbroken;  
	48 }  
	49 @end

  