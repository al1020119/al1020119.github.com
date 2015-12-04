---

layout: post
title: "全屏返回（Runtime）"
date: 2015-10-06 02:51:33 +0800
comments: true
categories: 项目实战

---



> 前言

> 此次文章，讲述的是导航控制器全屏滑动返回效果，而且代码量非常少，10行内搞定。


如果喜欢我的文章，可以关注我，也可以来小码哥，了解下我们的iOS培训课程。陆续还会有更新ing....

#####一、自定义导航控制器

目的：以后需要使用全屏滑动返回功能，就使用自己定义的导航控制器。

#####二、分析导航控制器侧滑功能

效果：导航控制器默认自带了侧滑功能，当用户在界面的左边滑动的时候，就会有侧滑功能。

系统自带的侧滑效果：


分析：

* 1.导航控制器的view自带了滑动手势，只不过手势的触发范围只能在左边。

* 2.当用户在界面左边拖动，就会触发滑动手势方法，并且有滑动返回功能，说明系统手势触发的方法已经实现了滑动返回功能。

* 3.为什么说系统手势触发的方法已经实现了滑动返回功能？

###原因：

创建滑动手势对象的时候，需要绑定监听者，当触发手势的时候会调用target的action。

UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:action];
当用户在界面左边滑动，有滑动返回功能，这是因为触发手势了，调用target的action方法，说明action方法内部实现滑动返回功能，否则就不会有滑动返回效果。

#####三、实现全屏滑动功能分析

打印导航控制器自带的滑动手势，看下它的真实面目。

系统自带的滑动手势interactivePopGestureRecognizer

 
	//  self指向的导航控制器，在导航控制器的viewDidLoad方法打印 
	- (void)viewDidLoad { 
	    [super viewDidLoad]; 
	    NSLog(@"%@",self.interactivePopGestureRecognizer); 
	} 



由图中可知：

* 1.系统自带的手势是UIScreenEdgePanGestureRecognizer类型对象,屏幕边缘滑动手势

* 2.系统自带手势target是_UINavigationInteractiveTransition类型的对象

* 3.target调用的action方法名叫handleNavigationTransition:

分析：

UIScreenEdgePanGestureRecognizer，看名称就知道，这个手势的范围只能在屏幕的周边，就是因为这个手势，系统自带的滑动效果，只能实现侧边滑动。

#####四、如何实现全屏滑动功能

给自己的导航控制器，添加一个全屏的滑动手势，调用系统自带滑动手势的target的action方法，利用系统实现的滑动返回功能，加上自己全屏滑动手势，就有全屏滑动功能了。

问题：如何拿到系统自带的target对象?，action方法名已经知道，而且系统肯定在target对象实现了，只要拿到target对象，调用这个方法就行。

通过打印系统自带的滑动手势的代理，发现正好是_UINavigationInteractiveTransition对象，因此我猜测这个代理对象就是target对象,只要拿到它，就拿到系统自带滑动手势的target对象。

	// 打印系统自带滑动手势的代理对象 
	SLog(@"%@",self.interactivePopGestureRecognizer.delegate); 


导航控制器全屏滑动注意点:

* 1.禁止系统自带滑动手势使用。

* 2.只有导航控制器的非根控制器才需要触发手势，使用手势代理，控制手势触发。

全屏滑动代码实现

	- (void)viewDidLoad { 
	    [super viewDidLoad]; 
	    // 获取系统自带滑动手势的target对象 
	    id target = self.interactivePopGestureRecognizer.delegate; 
	    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法 
	    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)]; 
	    // 设置手势代理，拦截手势触发 
	    pan.delegate = self; 
	    // 给导航控制器的view添加全屏滑动手势 
	    [self.view addGestureRecognizer:pan]; 
	    // 禁止使用系统自带的滑动手势 
	    self.interactivePopGestureRecognizer.enabled = NO; 
	} 
	// 什么时候调用：每次触发手势之前都会询问下代理，是否触发。 
	// 作用：拦截手势触发 
	- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer 
	{ 
	    // 注意：只有非根控制器才有滑动返回功能，根控制器没有。 
	    // 判断导航控制器是否只有一个子控制器，如果只有一个子控制器，肯定是根控制器 
	    if (self.childViewControllers.count == 1) { 
	        // 表示用户在根控制器界面，就不需要触发滑动手势， 
	        return NO; 
	    } 
	    return YES; 
	} 
