---
layout: post
title: "温馨提示"
date: 2016-01-24 13:32:08 +0800
comments: true
categories: Summary
---


首先先给我这困难的语言表达能力道个歉哈，真的尽力了。
本章排版是参照http://bbs.pediy.com/showthread.php?t=205133大神的来排的，第一次写心得文，也把所学到的分享给大家

最近才接触不久的逆向工程,刷夜,爆肝,把《iOS应用逆向工程》这本书的工具，全部看了一遍，并且尝试了一遍，感觉需要点什么。 那就是实践！  最近6s手机出了3DTouch，无奈手中没有这款机型，恰好最近对逆向小有心得，又听说过已经有插件能实现同样的需求，证明确实有可行性，于是开动。根据点击的判断和出现，初步感觉，这应该不需要多少行代码就能搞定，应该只要添加一个手势，或者是更改一个手势的点击事件，让系统认为发生了3DTouch点击事件，就可以了。


* 所需工具: cycript，openSSH，class-dump
* 测试环境：iOS9.0.2，iPhone5s
* 备注：因为自身没有3DTouch，所以需要下载一个插件，让机器拥有3DTouch功能，我使用的是forcy，通过覆盖长按手势，实现

通过查阅官方文档，得到关键词  Shortcut Menu peek pop
这个词将来就是要在找关键方法时刻所要用到的





####现在开始！
通过ssh连接到手机，然后将cycript注入到SpringBoard

	huangjipingde-iPhone:~ root# cycript -p SpringBoard



首先 先隆重介绍1个方法，2个函数

* 1方法 [view recursiveDescription]  该方法可以当做是Reveal的文字版，用来查看当前页面的布局
* 2函数，原理均是runtime，但是第二个没有怎么看懂。。。

1. printMethods 打印出该类所有的方法，后边接的是实现的地址,在这儿补充一下，如果想对某个方法打断点，但是又不想使用ida查看方法偏移，可以直接在这实现的地址处，添加断点，虽然不知道断在什么地方，但是可以肯定一定是在执行该方法的时候。效果如下图：

代码:

	function printMethods(className){
	var count = new new Type("I");
	var methods = class_copyMethodList(objc_getClass(className),count);
	var methodsArray = [];
	for (var i = 0; i < *count; i++){
	var method = methods[i];
	methodsArray.push({selector:method_getName(method), implentation:method_getImplementation(method)});
	}
	free(methods);
	free(count);
	return methodsArray;
	}


{% img /images/nixiangqudong001.png Caption %}  


2. tryPrintIvars打印出对象所有的属性，效果如下图：
代码:

	function tryPrintIvars(a){ 
	var x={}; 
	for(i in *a){ 
	try{ 
	x[i] = (*a)[i]; 
	} catch(e){} 
	}
	 return x;}


{% img /images/nixiangqudong002.png Caption %}  

准备工作都做好了，将两个函数都先输入进去



{% img /images/nixiangqudong003.png Caption %}  

因为最后的目标是应用图标，所以，现在我们从主界面开始着手打印它的UI布局
代码:

    [[UIApplication sharedApplication].keyWindow.rootViewController.view recursiveDescription]


{% img /images/nixiangqudong004.png Caption %}  



然后出来了一大片，红呦呦的代码，看着都眼睛疼，4点钟时看得眼睛都瞎了啊。此时应想，主界面可以滚动，是一个scrollView，是scrollView就得有contentSize，然后一看手机的页面，总共有5页，由于5s机型的宽度是320，所以这时候可以大胆猜测它的contentSize的最大宽度是1600，然后commond+F大法


{% img /images/nixiangqudong005.png Caption %}  



准确命中，同时，还注意到，它的contentOffset是960又此时我的页面正是第4页，基本锁定目标，查找frame的坐标是960，0的view，此时可以得到大量信息了，SBRootIconListView，这个就是用来装一页所有图标的View，SBIconListModel这个里边，我猜是装了该view里边的模型信息，注意，11 icons，正好是我们页面所有的图标数，此时再看后边SBIconView的size 62，62  这和图标尺寸的差距只有2个点，基本锁定，它就是我们要找的目标


{% img /images/nixiangqudong006.png Caption %}  




* 此时，让我们找到是什么在处理SBIconView的事件，我们所知道的，view一般是用来展示的，事件的发生一般都会交给代理来负责。让我们使用nextResponder，或者寻找他们的代理，来定位到一个controller文件，很幸运，直接一步就找到了，就是它：SBIconController！
 

* 此时，我们可以class-dump出SpringBoard的头文件了，去查看一下它的里边都有些什么方法和属性，如果想偷懒，去github直接搜索也行。。。
根据关键词和方法名译的意思大致锁定出来以下几个方法


ps：  这儿的char 是BOOL类型
代码:

	-(void)_handleShortcutMenuPeek:(id)arg1 ;
	-(SBApplicationShortcutMenu *)presentedShortcutMenu;
	-(char)_canRevealShortcutMenu;
	-(id)_aggregateLoggingAppKeyForShortcutMenu:(id)arg1 ;
	-(void)applicationShortcutMenu:(id)arg1 activateShortcutItem:(id)arg2 index:(int)arg3 ;
	-(void)applicationShortcutMenu:(id)arg1 startEditingForIconView:(id)arg2 ;
	-(void)applicationShortcutMenu:(id)arg1 launchApplicationWithIconView:(id)arg2 ;
	-(void)applicationShortcutMenuDidPresent:(id)arg1 ;
	-(void)_revealMenuForIconView:(id)arg1 presentImmediately:(char)arg2 ;



自己写一个tweak，hook所有的这些函数，给他们所有的实现之前加上一个NSLog（），查看调用的顺序，和传进来的值的类型。 以及一次Peek事件所关联到了哪些方法。
代码:

	%hook SBIconController
	
	- (void)_revealMenuForIconView:(id)arg1 presentImmediately:(BOOL)arg2 {
	NSLog(@"ZZT3D _revealMenuForIconView:arg1:%s,%@--arg2:%c",object_getClassName(arg1), arg1, arg2);
	    %orig;
	}
	
	- (void)_handleShortcutMenuPeek:(id)arg1
	{
	NSLog(@"ZZT3D _handleShortcutMenuPeek:%s,%@",object_getClassName(arg1),arg1);
	%orig;
	}
	
	-(char)_canRevealShortcutMenu
	{
	NSLog(@"ZZT3D _canRevealShortcutMenu");
	  return %orig;
	}
	-(id)_aggregateLoggingAppKeyForShortcutMenu:(id)arg1{
	
	 NSLog(@"ZZT3D ggregateLoggingAppKeyForShortcutMenu:%s,%@",object_getClassName(arg1),arg1);
	    return %orig;
	}
	
	-(void)applicationShortcutMenu:(id)arg1 activateShortcutItem:(id)arg2 index:(int)arg3
	{
	NSLog(@"ZZT3D activateShortcutItem:arg1%s,%@—arg2%s,%@--arg3:%d",object_getClassName(arg1),arg1,object_getClassName(arg2),arg2,arg3);
	%orig;
	}
	
	
	-(void)applicationShortcutMenu:(id)arg1 startEditingForIconView:(id)arg2 {
	NSLog(@"ZZT3D startEditingForIconView:arg1%s,%@—arg2%s,%@",object_getClassName(arg1),arg1,object_getClassName(arg2),arg2);
	%orig;
	
	}
	-(void)applicationShortcutMenu:(id)arg1 launchApplicationWithIconView:(id)arg2{
	NSLog(@"ZZT3D launchApplicationWithIconView:arg1%s,%@—arg2%s,%@",object_getClassName(arg1),arg1,object_getClassName(arg2),arg2);
	%orig;
	}
	
	-(void)applicationShortcutMenuDidPresent:(id)arg1{
	NSLog(@"ZZT3D applicationShortcutMenuDidPresent:%s,%@",object_getClassName(arg1),arg1);
	%orig;
	}
	
	%end


此时我们拿手机进行一次长按操作，使其弹出ShotcutMenu菜单，然后在openSSH中查看系统日志grep ZZT3D /var/log/syslog查看一下，该事件处理分别使用了那几个方法。


{% img /images/nixiangqudong007.png Caption %}  


因为是要欺骗系统，所以方法应该是在前方，初步定位到这3个方法，第一个顾名思义返回值就是能不能显示shotcutMenu，第二个，我们可以看到，这里传进来了一个手势，通过这手势的信息，基本可以推断，这个就是插件作者用来欺骗系统的手势，而该方法，就是手势的target方法，第三个，根据意思可以得知，从XXiconView，是否立即显示。核心就在于这儿了。最后，我们再打印一遍SBIconView的所有属性，用来确认一下



{% img /images/nixiangqudong008.png Caption %}  

继续搜索关键词，果然又有大收获_shortcutMenuPeekGesture有一个如此手势，里边的东西的手势。



{% img /images/nixiangqudong009.png Caption %}  

猜测得到了极大的肯定，下面就开始编写tweak了
由于是要给每一个iconView都添加手势，并且只添加一次，所以翻看了iconView头文件，查看他的init方法，选择了在initWithContentType中初始化。
贴上Tweak.xm的源码
关于代码的编写，中间也踩过不少坑，比如_revealMenuForIconView中的yes，no的设置，还好一开始猜的时候就全部手动赋值。
至于手势为什么传值需要如此怪异，因为检测发现原方法只识别长按手势，并不识别轻扫手势，但是因为个人习惯，不想覆盖系统的手势，只想单纯的增加一个功能。耿直的楼主尝试将一个轻扫手势，强行变成长按手势。很多属性都是readonly，但是这个使用kvc轻松搞定，现在轻扫一下手机！出现了意想之中的弹窗！
代码:

	#import "ZZ3DTouch.h"
	
	%hook SBIconView 
	
	- (id)initWithContentType:(id)arg1{
	// 设置3Dtouch手势
	  // 手势传过去的就是手势自己本身,本身拥有所在的view
	  self.shortcutMenuPeekGesture = [[%c(UISwipeGestureRecognizer) alloc] initWithTarget:[%c(SBIconController) sharedInstance] action:@selector(_handleShortcutMenuPeek:)];
	  self.shortcutMenuPeekGesture.direction = UISwipeGestureRecognizerDirectionUp;
	
	  return %orig;
	}
	
	%end
	
	%hook SBIconController
	
	- (void)_revealMenuForIconView:(id)arg1 presentImmediately:(BOOL)arg2 {
	
	  // yes 改为no之后没有显示，或者没有设置也会不显示
	
	  %orig(iconView, YES);
	
	}
	
	- (void)_handleShortcutMenuPeek:(id)arg1
	
	{
	  UISwipeGestureRecognizer *swipe = arg1;
	  UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] init];
	  [press setValue:@(UIGestureRecognizerStateBegan) forKey:@"state"];
	  [press setValue:swipe.view forKey:@"view"];
	
	%orig(press);
	
	}
	%end


{% img /images/nixiangqudong010.png Caption %}  


{% img /images/nixiangqudong011.png Caption %}  