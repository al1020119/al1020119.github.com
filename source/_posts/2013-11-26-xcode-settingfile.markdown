---

layout: post
title: "Xcode配置文件"
date: 2013-11-26 13:53:19 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



--- 
一个xcodeproj文件，其实是一个目录，它的格式大体上是这样的： 


这里写图片描述


有的文件，比如user.mode1v3，在没有多个用户操作项目的时候，是没有的。Apple并没有提供.xcodeproj文件的文档，而且它也没有准备提供，更坑爹的是，xcodeproj的格式、内容都是随时可变的，比如一个Xcode版本上来，可能其目录就会变化，而没有任何通知。这可苦了那些为.xcodeproj开发每三方库的同学，不仅要一点一点摸索各个文件的内容，修改方法，还要忍受Apple没有任何通知地修改格式。

Stackoverflow中这位就在抱怨苹果开发人员的傲慢：

[http://stackoverflow.com/questions/49478/git-ignore-file-for-xcode-projects/12021580#12021580](http://stackoverflow.com/questions/49478/git-ignore-file-for-xcode-projects/12021580#12021580) 

<!--more-->



闲话少说，下面进入正题：各个文件/目录的作用，以及要不要提交更新。

* project.pbxproj文件 

这个文件包含了所有此项目build需要的元数据，setting、file reference、configuration、targets…也就是说，这个文件代表的就是这个project。 
因此，在修改了这个文件之后，需要提交上去。

* project.xcworkspace目录 

这个文件比较特殊。 
首先要了解的是workspace和project的概念。project应该比较清楚，那workspace是什么呢？workspace是一种Xcode documentation，可以将多个project和其它文件放到一起，这样可以work on them together。一个project也可以属于多个workspace。所以简单来讲，workspace里面就是一个或多个projects的reference，放在一起，有时候比较好工作。 
这样的话，如果项目里面根本就没有workspace的概念，或者只有一个workspace+一个project，这个workspace并不会有什么变动，那这个文件就不需要提交同步。如果project很依赖workspace，没有workspace就运行不了，活不下去了，这时候这个文件肯定是要同步的。

* user.pbxuser文件 

Xcode项目为每一个使用这个项目的用户创建一个user.pbxuser文件，存储了此用户对项目的偏好设置，如Xcode的位置和大小、文件书签等。可以看到这个文件是针对某个用户的，可以说是私人性质的，跟整个项目没有太大关系，所以一般不需要同步。

* user.mode1v3和user.mode2v3文件 

这个也是用户相关的文件，和user.pbxuser差不多，存储某用户特定的项目设置，比如Xcode中window的状态和结构，断点等等。 
因此也不需要同步。

* xcuserdata目录/xcshareddata目录： 

大体上来说，和上面两种一样，也是用户相关的文件，包含user state，folders的状态，最后打开的文件等。因此一般来说是不需要同步的。 
例外是，这个目录里也包含了scheme相关的内容。如果项目里需要同步特定的scheme，这时候，需要在Edit Scheme里，勾选Share框，然后把新生成的xcshareddata目录提交上去。

* .xccheckout 

我没有碰到过这个文件。 
这个文件在xcworkspace目录里。 

* .xccheckout文件包含了关于workspace中用到了什么repo的数据。 

根据说明，它的规则和xcworkspace差不多：如果没用过，或者只是简单使用workspace，不需要同步；如果深入使用workspace，则需要同步。

总结1： 
.xcodeproj里的文件大体上有3种：

* 项目文件
* 单个用户的文件
* 跟workspace相关的文件

> 项目文件，需要同步； 

> 单个用户的文件，不需要同步； 

> 跟workspace相关的文件，视有没有深入使用workspace而定。

总结2：

需要同步的文件：

* project.pbxproj文件
* xcsharedata目录

> 不需要同步的文件

* user.pbxuser文件
* user.mode1v3/user.mode2v3文件


xcuserdata目录,视workspace情况而定的文件：

* .xcworkspace目录
* .xccheckout文件