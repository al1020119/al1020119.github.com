---

layout: post
title: "UIView&CALayer是撒？"
date: 2014-08-15 13:53:19 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



--- 

UIView与CALayer详解

研究Core Animation已经有段时间了，关于Core Animation，网上没什么好的介绍。苹果网站上有篇专门的总结性介绍，但是似乎原理性的东西不多，看得人云山雾罩，感觉，写那篇东西的人，其实是假 设读的人了解界面动画技术的原理的。今天有点别的事情要使用Linux，忘掉了ssh的密码，没办法重新设ssh，结果怎么也想不起来怎么设ssh远程登 陆了，没办法又到网上查了一遍，太浪费时间了，痛感忘记记笔记是多么可怕的事情。鉴于Core Animation的内容实在是非常繁杂，应用的Obj-C语言本身的特性也很多，所以写个备忘录记录一下，懂的人看了后如果发现了错误，还不吝指教。



<!--more-->




* 1.UIView 是iOS系统中界面元素的基础，所有的界面元素都继承自它。它本身完全是由CoreAnimation来实现的（Mac下似乎不是这样）。它真正的绘图部 分，是由一个叫CALayer（Core Animation Layer）的类来管理。UIView本身，更像是一个CALayer的管理器，访问它的跟绘图和跟坐标有关的属性，例如frame，bounds等等， 实际上内部都是在访问它所包含的CALayer的相关属性。

2.UIView有个layer属性，可以返回它的主CALayer实例，UIView有一个layerClass方法，返回主layer所使用的类，UIView的子类，可以通过重载这个方法，来让UIView使用不同的CALayer来显示，例如通过
 
	- (class) layerClass {
	 
	  return ([CAEAGLLayer class]);
	 
	}
	 

 

使某个UIView的子类使用GL来进行绘制。

* 3.UIView的CALayer类似UIView的子View树形结构，也可以向它的layer上添加子layer，来完成某些特殊的表示。

例如下面的代码


	grayCover = [[CALayer alloc] init];

	grayCover.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
	
	[self.layer addSubLayer: grayCover];
 

 

会在目标View上敷上一层黑色的透明薄膜。

* 4.UIView的layer树形在系统内部，被系统维护着三份copy（这段理解有点吃不准）。

例如：

	第一份，逻辑树，就是代码里可以操纵的，例如更改layer的属性等等就在这一份。
	第二份，动画树，这是一个中间层，系统正在这一层上更改属性，进行各种渲染操作。
	第三份，显示树，这棵树的内容是当前正被显示在屏幕上的内容。
	这三棵树的逻辑结构都是一样的，区别只有各自的属性。

* 5.动画的运作
UIView 的主layer以外（我觉得是这样），对它的subLayer，也就是子layer的属性进行更改，系统将自动进行动画生成，动画持续时间有个缺省时间， 个人感觉大概是0.5秒。在动画时间里，系统自动判定哪些属性更改了，自动对更改的属性进行动画插值，生成中间帧然后连续显示产生动画效果。

* 6.坐标系系统（对position和anchorPoint的关系还是犯晕）
CALayer 的坐标系系统和UIView有点不一样，它多了一个叫anchorPoint的属性，它使用CGPoint结构，但是值域是0~1，也就是按照比例来设 置。这个点是各种图形变换的坐标原点，同时会更改layer的position的位置，它的缺省值是{0.5, 0.5}，也就是在layer的中央。
某layer.anchorPoint = CGPointMake(0.f, 0.f);
如果这么设置，layer的左上角就会被挪到原来的中间的位置，
加上这样一句就好了
某layer.position = CGPointMake(0.f, 0.f);

* 7.真实例子的分析


这 是iphone上iBook翻页的效果，假设每一页都是一个UIView，我觉得一个页面是贴了俩个Layer，文字Layer显示正面的内容，背面 layer用文字layer的快照做affine翻转，贴在文字layer的后面。因为Layer可以设置显示阴影，也许后面的阴影效果没有使用单独的一 个layer来显示。至于这个曲面效果，我查了很多资料也没有结果，估计是使用了GL的曲面绘图？

* 8.最后一个让人恶心的。
layer 可以设置圆角显示，例如UIButton的效果，也可以设置阴影显示，但是如果layer树中的某个layer设置了圆角，树中所有layer的阴影效果 都将显示不了了。如果既想有圆角又想要阴影，好像只能做两个重叠的UIView，一个的layer显示圆角，一个的layer显示阴影.....





CALayer属于Core Animation部分的内容，比较重要而不太好理解。以下是园子中看到的一篇文章的摘录：

1. UIView是iOS系统中界面元素的基础，所有的界面元素都是继承自它。它本身完全是由CoreAnimation来实现的。它真正的绘图部分，是由一个CALayer类来管理。UIView本身更像是一个CALayer的管理器，访问它的跟绘图和跟坐标有关的属性，例如frame，bounds等，实际上内部都是在访问它所包含的CALayer的相关属性。

2. UIView有个重要属性layer，可以返回它的主CALayer实例。


// 要访问层，读取UIView实例的layer属性

	CALayer *layer = myView.layer

所有从UIView继承来的对象都继承了这个属性。这意味着你可以转换、缩放、旋转，甚至可以在Navigation bars，Tables，Text boxes等其它的View类上增加动画。每个UIView都有一个层，控制着各自的内容最终被显示在屏幕上的方式。

UIView的layerClass方法，可以返回主layer所使用的类，UIView的子类可以通过重载这个方法，来让UIView使用不同的CALayer来显示。代码示例：
	 
	- (class)layerClass {
	   return ([CAEAGLLayer class]);
	 
	}
 

上述代码使得某个UIView的子类使用GL来进行绘制。


3. UIView的CALayer类似UIView的子View树形结构，也可以向它的layer上添加子layer，来完成某些特殊的表示。即CALayer层是可以嵌套的。

示例代码：

	grayCover = [[CALayer alloc] init];
	
	grayCover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
	[self.layer addSubLayer:grayCover];
 

上述代码会在目标View上敷上一层黑色透明薄膜的效果。

4. UIView的layer树形在系统内部，被维护着三份copy。分别是逻辑树，这里是代码可以操纵的；动画树，是一个中间层，系统就在这一层上更改属性，进行各种渲染操作；显示树，其内容就是当前正被显示在屏幕上得内容。

5. 动画的运作：对UIView的subLayer（非主Layer）属性进行更改，系统将自动进行动画生成，动画持续时间的缺省值似乎是0.5秒。

6. 坐标系统：CALayer的坐标系统比UIView多了一个anchorPoint属性，使用CGPoint结构表示，值域是0~1，是个比例值。这个点是各种图形变换的坐标原点，同时会更改layer的position的位置，它的缺省值是{0.5,0.5}，即在layer的中央。

某layer.anchorPoint = CGPointMake(0.f,0.f);
如果这么设置，只会将layer的左上角被挪到原来的中间位置，必须加上这一句：
某layer.position = CGPointMake(0.f,0.f);
最后：layer可以设置圆角显示（cornerRadius），也可以设置阴影 (shadowColor)。但是如果layer树中某个 layer设置了圆角，树种所有layer的阴影效果都将不显示了。因此若是要有圆角又要阴影，变通方法只能做两个重叠的UIView，一个的layer 显示圆角，一个layer显示阴影......

7.渲染：当更新层，改变不能立即显示在屏幕上。当所有的层都准备好时，可以调用setNeedsDisplay方法来重绘显示。


	[gameLayer setNeedsDisplay];
若要重绘部分屏幕区域，请使用setNeedsDisplayInRect:方法，通过在CGRect结构的区域更新：

	[gameLayer setNeedsDisplayInRect:CGRectMake(150.0,100.0,50.0,75.0)];
如果是用的Core Graphics框架来执行渲染的话，可以直接渲染Core Graphics的内容。用renderInContext:来做这个事。

	[gameLayer renderInContext:UIGraphicsGetCurrentContext()];
8.变换：要在一个层中添加一个3D或仿射变换，可以分别设置层的transform或affineTransform属性。


	1 characterView.layer.transform = CATransform3DMakeScale(-1.0,-1.0,1.0);
	2 
	3 CGAffineTransform transform = CGAffineTransformMakeRotation(45.0);
	4 backgroundView.layer.affineTransform = transform;
 

9.变形：Quartz Core的渲染能力，使二维图像可以被自由操纵，就好像是三维的。图像可以在一个三维坐标系中以任意角度被旋转，缩放和倾斜。CATransform3D的一套方法提供了一些魔术般的变换效果。