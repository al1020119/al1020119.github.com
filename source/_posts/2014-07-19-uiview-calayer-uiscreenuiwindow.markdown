---

layout: post
title: "面试会问到的？"
date: 2014-07-19 13:53:19 +0800
comments: true
categories: 面试汇总 

--- 

####1、UIScreen可以获取设备屏幕的大小。
 

	// 整个屏幕的大小
	CGRect bounds = [UIScreen mainScreen].bounds;
	NSLog(@"UIScreen bounds: %@", NSStringFromCGRect(bounds));
	
` {0, 0, 320, 480}`
 
	// 应用程序窗口大小 
	CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
	NSLog(@"UIScreen applicationFrame: %@", NSStringFromCGRect(applicationFrame));

`{0, 20, 320, 460}`
####2、UIView对象定义了一个屏幕上的一个矩形区域，同时处理该区域的绘制和触屏事件。
可以在这个区域内绘制图形和文字，还可以接收用户的操作。一个UIView的实例可以包含和管理若干个子UIView。

ViewController.m

 

	-(void)viewDidAppear:(BOOL)animated
	
	{
	
	    [super
	 viewDidAppear:animated];
	
	    UIView*
	 myView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
	
	    myView.backgroundColor=[UIColor
	 redColor];
	
	    [self.view
	 addSubview:myView];
	
	}
####3、UIWindow对象是所有UIView的根，管理和协调的应用程序的显示
UIWindow类是UIView的子类，可以看作是特殊的UIView。一般应用程序只有一个UIWindow对象，即使有多个UIWindow对象，也只有一个UIWindow可以接受到用户的触屏事件。

AppDelegate.m


 

	-
	 (BOOL)application:(UIApplication
	 *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	
	{
	
	    UIWindow
	 *myWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	    myWindow.backgroundColor=[UIColor
	 whiteColor];
	
	    [myWindow
	 makeKeyAndVisible];
	
	    _window
	 = myWindow;
	
	    return
	
	YES;
	
	}
 ####4、UIViewController对象负责管理所有UIView的层次结构，并响应设备的方向变化。

AppDelegate.m
 

	-
	 (BOOL)application:(UIApplication
	 *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	
	{
	
	    UIWindow
	 *myWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	    myWindow.backgroundColor=[UIColor
	 whiteColor];
	
	    UIViewController
	 *myViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
	
	    myWindow.rootViewController
	 = myViewController;
	
	    [myWindow
	 makeKeyAndVisible];
	
	    _window
	 = myWindow;
	
	    return
	
	YES;
	
	}
 
 
####CALayer是在/System/Library/Frameworks/QuartzCore.framework定义的。而且CALayer作为一个低级的，可以承载绘制内容的底层对象出现在该框架中。
 
 
现在比较一下uiview和calayer都可以显示图片文字等信息。难道apple提供了，两套绘图机制吗？不会。
 
 UIView相比CALayer最大区别是UIView可以响应用户事件，而CALayer不可以。UIView侧重于对显示内容的管理，CALayer侧重于对内容的绘制。
 
 大家都知道QuartzCore是IOS中提供图像绘制的基础库。并且CALayer是定义该框架中。难道UIView的底层实现是CALayer？？
 
官方做出了明确的解释：

	
	Core Animation doesn't provide a means for actually displaying layers in a window, they must be hosted by a view. When paired with a view, the view must provide event-handling for the underlying layers, while the layers provide display of the content.
	
	The view system in iOS is built directly on top of Core Animation layers. Every instance of UIView automatically creates an instance of a CALayer class and sets it as the value of the view’s layer property. You can add sublayers to the view’s layer as needed.
	
	On Mac OS X you must configure an NSView instance in such a way that it can host a layer.
 
由此可见UIView是基于CALayer的高层封装。The view system in iOS is built directly on top of Core Animation layers. 
 
 
> 结论：
 UIView来自CALayer，高于CALayer，是CALayer高层实现与封装。UIView的所有特性来源于CALayer支持。