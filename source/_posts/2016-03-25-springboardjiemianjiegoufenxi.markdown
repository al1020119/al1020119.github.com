---
layout: post
title: "SpringBoard界面结构分析"
date: 2016-03-25 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

SpringBoard界面层级结构分析  


cycript -p 进程ID

通过cycript注入到SpringBoard进程中
首先SpringBoard有点类似于一般app的结构，只不过它是由好几个window构成的，总共如下：
  锁屏状态下是SBAlertWindow
  正常状态下是SBAppWindow
  通知栏滑下来时显示SBBulletinWindow
主要分析下正常状态的window





<!--more-->




SpringBoard界面层级结构分析

===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  