---
layout: post
title: "图片处理-补充"
date: 2016-01-14 16:21:08 +0800
comments: true
categories: Performance
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---


前面介绍了iOS开发中常见的图片处理方式，而在iOS开发中除了前面几个提到的，还有两个东西是最值得注意的东西，那就是选择什么格式的图片，和怎么去加载图片，下面就来补充一下！

1. 图片资源使用png还是jpg格式

2. 如何选择图片加载方式imageNamed&imageWithContentsOfFile



###图片资源使用png还是jpg格式


<!--more-->



对于iOS本地应用程序来说最简单的答案就是始终使用PNG，除非你有非常非常好的理由不用它。

当iOS应用构建的时候，Xcode会通过一种方式优化.png文件而不会优化其它文件格式。它优化得相当的好

他们之间有以下区别：

1.	同个分辨率的图片，保存为png要比jpg大；

2.	png图片有alpha通道，因此它支持图片透明，这点在ios开发中尤为重要；而jpg不支持透明

3.	xcode会对png格式进行特殊的优化处理，而对于其他图片不做处理

总结一下有以下几点：

	1.如果你的图片都是xcode本地就有，那就用png；如果图片是从网络上下载的，考虑到流量以及速度，可以考虑用jpg因为它具有较高的压缩率
	
	2.本地的png优化由xcode帮你做；其他格式的需要在程序运行时做优化，更耗性能
	
	3.如果你的图片要求有较高的色彩饱和度、图像质量，那就用jpg
	
###如何选择图片加载方式imageNamed&imageWithContentsOfFile
	
IOS内存稀缺，而图片资源通常又是最占内存的部分之一，因此，选择如何加载图片，对于优化应用内存占用量，能起到立竿见影的效果。通常加载图片的方式有两种：

#####一、imageNamed
为什么有两种方法完成同样的事情呢？imageNamed的优点在于可以缓存已经加载的图片。苹果的文档中有如下说法：
	
	This method looks in the system caches for an image object with the specified name and returns that object if it exists. If a matching image object is not already in the cache, this method locates and loads the image data from disk or asset catelog, and then returns the resulting object. You can not assume that this method is thread safe.

这种方法会首先在系统缓存中根据指定的名字寻找图片，如果找到了就返回。如果没有在缓存中找到图片，该方法会从指定的文件中加载图片数据，并将其缓存起来，然后再把结果返回，下次再使用该名称图片的时候就省去了从硬盘中加载图片的过程。对于相同名称的图片，系统只会把它Cache到内存一次。

另外，在iOS4及以上系统中，如果是PNG格式的图片，使用该方法加载时不用再指定文件的.png后缀，即只写文件名称即可。

> 最后，在iOS4及以上系统中，如果屏幕的scale是2（即高分辨率屏幕），该方法会自动使用加上@2x后缀的图片。比如在高分辨率屏幕设备上要加载名称为button的图片，该方法会自动使用名称为button@2x的图片；如果找不到该名称图片再去加载名称为button的图片。这就为开发者省去了适配高、低分辨率屏幕的时间。


#####二、imageWithContentsOfFile或者imageWithData
而imageWithContentsOfFile方法只是简单的加载图片，并不会将图片缓存起来，图像会被系统以数据方式加载到程序。当你不需要重用该图像，或者你需要将图像以数据方式存储到数据库，又或者你要通过网络下载一个很大的图像时，可以使用这种方式。


#####三、如何选择
两种加载图片方法的使用方式：
 
	UIImage *img = [UIImage imageNamed:@"myImage"]; // caching    
	// or    
	UIImage *img = [UIImage imageWithContentsOfFile:@"myImage"]; // no caching  

那么该如何选择呢？


+ 如果加载一张很大的图片，并且只使用一次，那么就不需要缓存这个图片。这种情况imageWithContentsOfFile比较合适——系统不会浪费内存来缓存图片。

+ 然而，如果在程序中经常需要重用的图片，比如用于UITableView的图片，那么最好是选择imageNamed方法。这种方法可以节省出每次都从磁盘加载图片的时间。

