---
layout: post
title: "获取短信-联系人"
date: 2016-03-28 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

{% img /images/bgHeader.png Caption %}  



越狱的 ios 如何 获取 读取 提取 手机上的 短信 通话记录 联系人 等信息

http://willson.sinaapp.com/2011/12/iphone 获取短信脚本.html  Iphone获取短信脚本
http://bbs.9ria.com/thread-209349-1-1.html          IPhone短信相关部分研究（转载）
http://blog.csdn.net/slinloss/article/details/8722806       整理：iOS 短信与电话事件的获取
http://308812025-qq-com.iteye.com/blog/1549756              IOS 5 拦截手机短信(需越狱)

http://www.iteye.com/problems/84131                                IOS 短信截取 监听到了事件缺不能往下执行。。。





<!--more-->




http://blog.csdn.net/ceko_wu/article/details/8021133     短信数据库分析（一）

一般地，ios只要越狱，整体的文件系统就全部暴漏出来，使用ifunbox 工具连接iphone，即可查看。

短信数据库的存放位置在ios的：    /private/var/mobile/Library/SMS/sms.db                  

联系人数据库存放的位置在ios的：//private/var/mobile/Library/AddressBook/AddressBook.sqlitedb

     联系人的头像估计存放在这里：//private/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb

通话记录数据库的存放路径是：//private/var/wireless/Library/CallHistory/call_history.db

备忘录数据库的存放路径是：//private/var/mobile/Library/Notes/notes.sqlite

safira 浏览器的收藏夹数据库存放路径是：//private/var/mobile/Library/Safari/Bookmarks.db

日历数据库的存放路径是：//private/var/mobile/Library/Calendar/Calendar.sqlitedb


上面的数据库，无论其后缀名是.db也好，.sqlitedb、.sqlite也好，它们的真实面目是，全部都是sqlite数据库。在实际查看这些数据库时，可以将其后缀名统一改成.sqlite，当然也可以不改。查看这些数据库最好的工具是 火狐浏览器上的插件：Sqlite Manager

 
===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  