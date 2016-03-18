---
layout: post
title: "屏幕旋转的奥妙"
date: 2015-01-10 23:51:52 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---


###一，决定当前UIViewController显示方向的因素
######1，全局控制
工程设置中设置支持的Device Orientation，如果这里没有设置其中的一个方向，即使后面的UIViewController中配置了改方向，也是不会起作用的。实际上就是设置工程plist文件的Supported interface orientations属性。

######2，配置AppDelegate
配置AppDelegate的如下方法返回需要用到的全部方向集合，如果要支持多个方向，一般都返回UIInterfaceOrientationMaskAll

	- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window{
		return UIInterfaceOrientationMaskAll;
	}
似乎该方法默认值为Info.plist中配置的Supported interface orientations项的值。

######3，自定义UIViewController，并实现如下orientation相关的三个方法（iOS6以后）:
折叠复制内容到剪贴板

	//是否支持多方向旋转屏，会考察当前设备方向和支持的方向。一些文档上说shouldAutorotate如果返回NO则不会执行下面两个方法纯属扯淡。  
	-(BOOL)shouldAutorotate  
	{  
	    return YES;  
	}  
	//第二个方法返回支持的旋转方向  
	-(UIInterfaceOrientationMask)supportedInterfaceOrientations  
	{  
	    return [self.viewControllers.lastObject supportedInterfaceOrientations];  
	}  
返回最优先显示的屏幕方向，比如同时支持Portrait和Landscape方向，但想优先显示Landscape方向，那软件启动的时候就会先显示Landscape，在手机切换旋转方向的时候仍然可以在Portrait和Landscape之间切换；  

	-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation  
	{  
	    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];  
	}  
 
以上三个规则在每一个UIViewController中都会得到一个方向的交集集合，就是最终显示的方向。如果交集为空，会抛出UIApplicationInvalidInterfaceOrientationException崩溃异常。

###二，典型的控制方案
另外一个非常重要的点就是并不是每一个UIViewController都会主动执行以上三个方法，根据特酷吧的实验，发现：

* 1，当UIViewController是rootViewController（Device Orientation方向变化时会主动执行）
* 2，当UIViewController是UINavigationController（Device Orientation方向变化时会主动执行）
* 3，当UIViewController以modal模态形式弹出时会主动执行。
一个典型的方案是，我们就可以在UINavigationController中这样写：

折叠复制内容到剪贴板

	-(BOOL)shouldAutorotate  
	{  
	    return YES;  
	}  
	-(UIInterfaceOrientationMask)supportedInterfaceOrientations  
	{  
	    return [self.viewControllers.lastObject supportedInterfaceOrientations];//主动调用UIViewController对应的方法，达到在UIViewController中自定义的效果  
	}  
	-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation  
	{  
	    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];  
	}  
 
接下来就只需要自定义各自的VC

	-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
	    return UIInterfaceOrientationMaskPortrait;//根据需要
	}
	- (BOOL)shouldAutorotate
	{
	    return NO;//根据需要
	}
	-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
	{
	    return UIInterfaceOrientationPortrait;//根据需要
	}
事实上在作为一个UINavigationController的堆栈系统，普通的UIViewController的orientation方法只是一个配置项，最终决定屏幕方向的还是UINavigationController控制器，也就是UINavigationController拿UIViewController得配置决定当前控制器的方向。

###三，强制屏幕旋转
如果UIInterfaceOrientation和UIDeviceOrientation方向不一样，想强制将UIInterfaceOrientation旋转成UIDeviceOrientation的方向，可以通过l类方法attemptRotationToDeviceOrientation，但是如果想将interface强制旋转成任一指定方向，就不太好实现了。目前大致有以下几种方式：
######1，使用私有方法
折叠复制内容到剪贴板

	[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];  
具体可以这样：  
			
			 if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {  
	        SEL selector = NSSelectorFromString(@"setOrientation:");  
	        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];  
	        [invocation setSelector:selector];  
	        [invocation setTarget:[UIDevice currentDevice]];  
	        int val = UIInterfaceOrientationLandscapeRight;  
	        [invocation setArgument:&val atIndex:2];  
	        [invocation invoke];  
	    }  
 
######2，主动触发orientation相关方法
只要提前设置好想要支持的orientation，然后主动触发orientation机制，使新设置的orientation起作用便能实现将 interface orientation旋转至任意方向的目的。像这样：

	UIViewController *vc = [[UIViewController alloc]init]; 
	[self presentModalViewController:vc animated:NO]; 
	[self dismissModalViewControllerAnimated:NO]; 

######3、旋转view的transform
前两种都是试图触发orientation相关方法，第三种可能会造成一些不可预知的风险不推荐。