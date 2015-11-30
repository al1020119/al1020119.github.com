---

layout: post
title: "切换控制器"
date: 2015-12-02 02:51:10 +0800
comments: true
categories: 项目实战

---


从一个视图控制器切换到另一个视图控制器的几种方式
 
 
####1,模态(modal)画面的显示方法：
例如iphone通讯录管理程序中，追加新的通讯纪录时，就是使用这种模态画面
例：点击一个按钮，进入另一个界面
	- (IBAction)pressAbout:(id)sender {
	
	iCocosViewController *iCocos=[[[iCocosViewController alloc] initWithNibName:@"iCocosViewController" bundle:nil] autorelease];
	
	[self presentModalViewController:aboutanimated:YES];//显示模态画面
	
	关闭模态画面的方法：
	
	[self dissmissModalViewControllerAnimationed:YES];
 

 
####2,SwitchViewController中有2个控制器的属性：BviewController,CViewController

* 使用方法：insertSubview: atIndex:
这种画面跳转方法并非最佳的跳转方法：
* 实际上并非真的实现了两个画面间的跳转，而是同时启动了2个画面，控制其中哪一个画面显示在前台，哪一个画面显示在后台而已。
* 这种画面跳转方式有一个很大的缺点，即当画面数量增加时，画面跳转的实现代码将月来越复杂，而且各个画面间不可避免的有相互依赖关系。
 
 
 
####3,UITabBarController实现并列画面跳转（这里其实就是window的切花）
	//将5个viewController实例放入TabBar的viewcontrollers属性中    

    self.tabBarController.viewControllers = @[navFrist, navSecond,navThird,navFourth,navFifth];   

    self.window.rootViewController = self.tabBarController;

    [self.window addSubview:self.tabBarController.view];//将根控制器的视图加到应用程序主窗口
 

 

####4,UINavigationController实现多层画面跳转，在导航控制器中，载入有层级关系的界面
	
	- (IBAction)addRightAction:(id)sender
	{
	    iCocosViewController *iCocos=[[[iCocosViewController alloc]initWithNibName:@"iCocosViewController" bundle:nil] autorelease];

    [self.navigationController pushViewController:aiCocos animated:YES];
	}