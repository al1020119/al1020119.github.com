---
layout: post
title: "移动端性能优化"
date: 2014-09-25 14:16:31 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

之前写过一篇

[UItableView性能优化和卡顿问题](http://al1020119.github.io/blog/2015/03/02/uitableviewxing-neng-you-hua-yu-qia-dun-wen-ti/)

还有一篇

[App卡顿了怎么办](http://al1020119.github.io/blog/2015/11/16/appqia-dun-liao-zen-yao-ban-%3F/)


今天看到一篇总结的非常好的文章（[移动端性能优化](http://tgideas.qq.com/webplat/info/news_version3/804/808/811/m579/201412/293834.shtml)），就移过来，后期我也会根据自己所做的项目做一个开发中性能优化的总结，希望你们喜欢！



随着移动互联网的发展，我们越发要关注移动页面的性能优化，今天跟大家谈谈这方面的事情。
	
	
<!--more-->



###首先，为什么要最移动页面进行优化？

先来一篇前端优化的文章：腾讯一个大神的分享：

[http://www.cocoachina.com/webapp/20150126/11020.html](http://www.cocoachina.com/webapp/20150126/11020.html)




纵观目前移动网络的现状，



{% img /images/xn001.png Caption %}  


   移动页面布局越来越复杂，效果越来越炫，直接导致了文件越来越大，下载和运行速度越来越低，而速度低会造成不良影响，据统计：

 

{% img /images/xn002.png Caption %}  

 71%的用户期望移动页面跟pc页面一样快，74%的用户能容忍的响应时间为5秒，所以我们必须保证移动端页面有足够的速度。

 移动页面的速度跟三个因素有关，分别是：移动网络带宽速度，设备性能（CPU，GPU，浏览器），页面本身。

* 目前主流的移动网络制式为3g

 

{% img /images/xn003.png Caption %}  

 今年，我们还看到了4g网络制式在快速发展，这再一次提升了移动页面的加载速度；

 而移动设备本身，截止到目前，以iphong6三星Note4等设备为首，智能设备已经变得比以往屏幕更大，CPU、GPU、内存更靠谱

 

{% img /images/xn004.png Caption %}  

 而与其同时，浏览器产商也为提升页面的速度做出了不可磨灭的努力，这里大家可以看一个视频[http://www.iqiyi.com/w_19rsgfld99.html](http://www.iqiyi.com/w_19rsgfld99.html)

 

 网络制式供应商，手机制造商，浏览器产商如此给力，我们呢？我们能做什么。

 我们能做得是对移动端页面本身优化，这也是我们专业价值的体现，所以我们必须做移动端页面性能优化。



###那怎么做移动端页面优化呢？

 在说这个前，要提一下pc常用的优化手段：

* 代码优化（css、html、js优化）
* 减少HTTP请求（雪碧图，文件合并&hellip;）
* 减少DOM节点
* 无阻塞（内联CSS，JS置后&hellip;）
* 缓存
* ...



 这些手段大部分适用于移动端，这都是一些耳熟能详的手段，今天这里就讲了，有兴趣可以参考PDI课程《网站性能优化》。

 今天要讲的主要是一些适用于移动端的优化手段，现在进入正题。

 首先我们得关注一下一个页面从开始到呈现完毕需要经历什么阶段，主要有四个阶段：


{% img /images/xn005.png Caption %}  
  

 每个阶段的主要工作如上图所示，而我们的优化目标是：



{% img /images/xn006.png Caption %}  

 下面我们来针对上面的几个阶段细说一下都有哪些优化手段。

 首先，来看看加载中有哪些优化手段：


#####1. 预加载

 预加载方式有两种：

 * A.显性加载

 

{% img /images/xn007.png Caption %}  

 类似这种用户能明显感知的，我把它称为&ldquo;显性加载&rdquo;，互动页面都建议加上这种加载方式，它一方面能增加页面的趣味性，另一方面能让后续页面体验更流畅

 * B.隐性加载



{% img /images/xn008.png Caption %}  

这种在加载第一张图片的时候已经预先加载了第二张图片，从而使得页面体验更流畅的方式，我把它称为隐性加载，这种方式的好处是节省流量之余又能使得体验增强。

#####2.    按需加载

按需加载是不可或缺的优化手段，主要有以下两种方式：


{% img /images/xn009.png Caption %}  
 

 对于这种方式，在首屏加载的时候把首屏的内容加载尽量，而位于首屏之外的元素都只在出现在首屏时才加载，很大程度地节省了流量，提升了首次加载时间。


{% img /images/xn010.jpg Caption %}  
 

 这种叫响应式加载方式，意思是利用js或者css判断分辨率，从而选择不同尺寸的图片进行引入，这种的好处显而易见，同样可以加快加载速度和节省流量。


#####3.    压缩图片

 对于压缩图片，首先要提的是jpg文件：

 

{% img /images/xn011.png Caption %}  

 对于移动端的Jpg文件，有这样的结论：

      a.使用大尺寸大有损压缩比的jpg

      b.使用jpegtran进行无损压缩



{% img /images/xn012.png Caption %}  

 而对于png有以下结论：

      a.多彩图片使用png24

      b.低彩图片使用png8

      c.推荐使用pngquant



#####4.尽量避免重定向

 为什么要尽量避免重定向呢？因为如图：

 

{% img /images/xn013.png Caption %}  

 这是一个同一网速下的测试结果，重定向之所以会比较慢，是因为它重复了域名查找，tcp链接，发送请求。

#####5. 使用其他方式代替图片

 有两种方式，第一种是：依靠css3绘制图片

 

{% img /images/xn014.png Caption %}  

 第二种：使用iconfont代替图片

 

{% img /images/xn015.png Caption %}  

 但iconfont不一定比图片好，这里做了个实验：

 

{% img /images/xn016.png Caption %}  

 对于大图片，iconfont并不比雪碧图好，建议单侧小尺寸图标才使用iconfont.



 然后，针对脚本执行中有哪些优化手段，这里只提两点：


#####1.尽量避免DataURI

 DataUri在移动端并不如它在pc端吃香，因为：


{% img /images/xn017.png Caption %}  
 

 经测试，DataURI要比简单的外链资源慢6倍，生成的代码文件相对图片文件体积没有减少反而增大，而且浏览器在对这种base64解码过程中需要消耗内存和cpu，这个在移动端坏处特别明显。

#####2.点击事件优化

 在移动端请适当使用touchstart，touchend，touch等事件代替延迟比较大的click事件。Click之所以慢是因为mousedown导致的：



{% img /images/xn018.png Caption %}  



 然后，针对渲染阶段中有哪些优化手段，这里也只提两点：

#####1. 动画优化

   a) 尽量使用css3动画

+ 优点：

	- 不占用js主线程

	- 可利用硬件加速

	- 浏览器可对动画做优化

+ 缺点：

	- 不支持中间状态监听

   b) 适当使用canvas动画

+ 优点：

	- 可规避渲染树的计算渲染更快

+ 缺点：

	- 开发成本高

	- 维护较麻烦

 
 通过对css3动画和canvas动画对比：

 

{% img /images/xn019.png Caption %}  

 得到结论：5个元素以内使用css3动画，5个以上使用canvas动画。

   c) 合理使用RAF(requestAnimationFrame)

   + 优点：

	- 能解决脚本问题引起的丢帧，卡顿问题

	- 支持中间状态监听

   + 缺点：

	- 兼容问题

       

{% img /images/xn020.png Caption %}  

 通过RAF动画与settimeout动画对比：

       

{% img /images/xn021.png Caption %}  

 得到结论：不需要兼容android 4.3浏览器的情况下，请使用RAF制作脚本动画

 2. 高频事件优化

 

{% img /images/xn022.png Caption %}  

 类似touchmove，scroll这类的事件可导致多次渲染，对于这种事件可以通过以下手段进行优化：

* 1.使用requestAnimationFrame监听帧变化，使得在正确的时间进行渲染

* 2.增加响应变化的时间间隔，减少重绘次数。



 最后，针对合成/绘制只提一个优化手段：

   GPU加速

 触发GPU加速的方式有：

* CSS3 transitions

* CSS3 3D transforms

* WebGL 3D 绘制

* Video

* ...

 使用GPU加速前有对比实验：

       

{% img /images/xn023.png Caption %}  

 GPU加速实际上是大幅减少了合成/绘制时间，从而大大地提高了页面速度，但GPU加速有自己的缺点：

 过多的GPU层会带来性能开销，主要原因是使用GPU加速其实是利用了GPU层的缓存，让渲染资源可以重复使用，所以一旦层多了，缓存增大，就会引起别的性能问题。

 

总结

{% img /images/xn024.png Caption %}  
         

> 本文针对页面呈现的四个阶段提出了比较典型的优化手段，到最后，再提醒读者一下：其实优化是双刃剑。
  按需加载提升速度，但可能导致大量重绘；
  Touch响应快，但很多场景不适合；
  GPU加速效率高，但内存开销大等等
  Loading会让整体体验流畅，但容易造成用户流失
  图片压缩让带宽成本降低，但可能会导致视觉效果变差
 类似这样的矛盾点还有很多，请结合业务按照实际情况进行优化。

