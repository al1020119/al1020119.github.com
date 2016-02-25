---
layout: post
title: "温馨提示"
date: 2016-01-24 13:32:08 +0800
comments: true
categories: Summary
---

SpringBoard界面层级结构分析  


cycript -p 进程ID

通过cycript注入到SpringBoard进程中
首先SpringBoard有点类似于一般app的结构，只不过它是由好几个window构成的，总共如下：
  锁屏状态下是SBAlertWindow
  正常状态下是SBAppWindow
  通知栏滑下来时显示SBBulletinWindow
主要分析下正常状态的window

SpringBoard界面层级结构分析


nixiang0003