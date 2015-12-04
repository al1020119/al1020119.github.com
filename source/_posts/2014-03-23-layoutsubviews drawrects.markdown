---

layout: post
title: "layoutSubViews&drawRects会了吗？"
date: 2014-03-23 13:53:19 +0800
comments: true
categories: 高级开发 

--- 

首先两个方法都是异步执行。layoutSubviews方便数据计算，drawRect方便视图重绘。
 
 

####layoutSubviews在以下情况下会被调用：
 

* 1、init初始化不会触发layoutSubviews。
* 2、addSubview会触发layoutSubviews。
* 3、设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化。
* 4、滚动一个UIScrollView会触发layoutSubviews。
* 5、旋转Screen会触发父UIView上的layoutSubviews事件。
* 6、改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件。
* 7、直接调用setLayoutSubviews。

####drawRect在以下情况下会被调用：
 

* 1、如果在UIView初始化时没有设置rect大小，将直接导致drawRect不被自动调用。drawRect 掉用是在Controller->loadView, Controller->viewDidLoad 两方法之后掉用的.所以不用担心在 控制器中,这些View的drawRect就开始画了.这样可以在控制器中设置一些值给View(如果这些View draw的时候需要用到某些变量 值).
* 2、该方法在调用sizeToFit后被调用，所以可以先调用sizeToFit计算出size。然后系统自动调用drawRect:方法。
* 3、通过设置contentMode属性值为UIViewContentModeRedraw。那么将在每次设置或更改frame的时候自动调用drawRect:。
* 4、直接调用setNeedsDisplay，或者setNeedsDisplayInRect:触发drawRect:，但是有个前提条件是rect不能为0。

> 以上1,2推荐；而3,4不提倡

######drawRect方法使用注意点：
 
* 1、 若使用UIView绘图，只能在drawRect：方法中获取相应的contextRef并绘图。如果在其他方法中获取将获取到一个invalidate 的ref并且不能用于画图。drawRect：方法不能手动显示调用，必须通过调用setNeedsDisplay 或 者 setNeedsDisplayInRect，让系统自动调该方法。
 
* 2、若使用calayer绘图，只能在drawInContext: 中（类似鱼drawRect）绘制，或者在delegate中的相应方法绘制。同样也是调用setNeedDisplay等间接调用以上方法
3、若要实时画图，不能使用gestureRecognizer，只能使用touchbegan等方法来掉用setNeedsDisplay实时刷新屏幕