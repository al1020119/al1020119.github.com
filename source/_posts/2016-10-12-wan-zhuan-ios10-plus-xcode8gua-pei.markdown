---
layout: post
title: "玩转iOS10+Xcode8适配"
date: 2016-10-12 11:34:34 +0800
comments: true
categories: 

---
最近因为公司App在iOS10上出现很多问题，结果花了一天时间适配了一下，其中也遇到了不少坑，有些网上直接有方法，但是有些却需要细心琢磨。这里整理了一下。

其中有两个比较麻烦的

+ 1：关于导航栏的适配
	- 当导航栏是透明或者半透明的实现，显示不正常，全白。

+ 2：关于tabBar的适配
	- tabbar中第一个子控制器的Item重复出现



下面一个个整理了一下！



<!--more-->


##1.Xcode8运行项目之后，控制台打印了一堆东西;

去除方法：选择Xcode ->Product ->Scheme -> Edit Scheme 或者按command + shift + < 快捷键，

在弹出的窗口中Environment Variables 下添加 0S_ACTIVITY_MODE=disable


{% img /images/ios10shipei001.png Caption %}  

> 注：真机调试不输出NSlog了，所以我真机调试的时候，把此处对号去除，就好了

##2.Xcode8 打开工程后，出现下图，苹果新特性


{% img /images/ios10shipei002.png Caption %}  

我勾选了Automatically manage signing，并且选择配置了Team，就好了。

> 注：或者另外一种方式  点击打开链接

##3.用Xcode8 运行项目在真机上，打开相机相册功能，程序崩溃；

解决办法：项目中访问了隐私数据，需要在info.plist中添加这些权限：

相机权限

	<key>NSCameraUsageDescription</key>
	
	<string>cameraDesciption</string>

相册权限

	<key>NSPhotoLibraryUsageDescription</key>
	
	<string>photoLibraryDesciption</string>

注：
在CODE上查看代码片派生到我的代码片

    <!-- 相册 -->   
    <key>NSPhotoLibraryUsageDescription</key>   
    <string>App需要您的同意,才能访问相册</string>   
    <!-- 相机 -->   
    <key>NSCameraUsageDescription</key>   
    <string>App需要您的同意,才能访问相机</string>   
    <!-- 麦克风 -->   
    <key>NSMicrophoneUsageDescription</key>   
    <string>App需要您的同意,才能访问麦克风</string>   
    <!-- 位置 -->   
    <key>NSLocationUsageDescription</key>   
    <string>App需要您的同意,才能访问位置</string>   
    <!-- 在使用期间访问位置 -->   
    <key>NSLocationWhenInUseUsageDescription</key>   
    <string>App需要您的同意,才能在使用期间访问位置</string>   
    <!-- 始终访问位置 -->   
    <key>NSLocationAlwaysUsageDescription</key>   
    <string>App需要您的同意,才能始终访问位置</string>   
    <!-- 日历 -->   
    <key>NSCalendarsUsageDescription</key>   
    <string>App需要您的同意,才能访问日历</string>   
    <!-- 提醒事项 -->   
    <key>NSRemindersUsageDescription</key>   
    <string>App需要您的同意,才能访问提醒事项</string>   
    <!-- 运动与健身 -->   
    <key>NSMotionUsageDescription</key> <string>App需要您的同意,才能访问运动与健身</string>   
    <!-- 健康更新 -->   
    <key>NSHealthUpdateUsageDescription</key>   
    <string>App需要您的同意,才能访问健康更新 </string>   
    <!-- 健康分享 -->   
    <key>NSHealthShareUsageDescription</key>   
    <string>App需要您的同意,才能访问健康分享</string>   
    <!-- 蓝牙 -->   
    <key>NSBluetoothPeripheralUsageDescription</key>   
    <string>App需要您的同意,才能访问蓝牙</string>   
    <!-- 媒体资料库 -->   
    <key>NSAppleMusicUsageDescription</key>   
    <string>App需要您的同意,才能访问媒体资料库</string>  

如果没有用，需配置一下


{% img /images/ios10shipei003.png Caption %}  

##4.字体变大，原有的fream需要适配，智能逐一排查啦

##5.Nib问题：警告

在CODE上查看代码片派生到我的代码片

    - (void)awakeFromNib {  
        // Initialization code  
    }  

需要添加：
在CODE上查看代码片派生到我的代码片

    [super awakeFromNib];  


##6.UIApplication对象中openUrl被废弃

在iOS 10以前，我们要想使用应用程序去打开一个网页或者进行跳转，直接使用[[UIApplication sharedApplication] openURL 方法就可以了，但是在iOS 10 已经被废弃了，因为使用这种方式，处理的结果我们不能拦截到也不能获取到，对于开发是非常不利的，在iOS 10全新的退出了 
	
	[[UIApplication sharedApplication] openURL:nil options:nil completionHandler:nil];
	
有一个成功的回调block 可以进行监视。

> 注：仍然可以用，只不过会出现警告


##7.系统判断失效 
现在改用：
在CODE上查看代码片派生到我的代码片

    #define LIOS10_OR_LATER  ([[[UIDevice currentDevice]systemVersion]compare:@"10.0" options:NSNumericSearch] !=NSOrderedAscending)  


##8.代码注释不能用
解决方法：
	
	打开终端，命令运行： sudo /usr/libexec/xpccachectl

然后必须重启电脑后生效

##9.导航栏适配

因为使用了"UINavigationBar+Awesome.h"这个框架，所以，最后找来找去，找到了这个框架的底层，修改代码发现既然可以。

    if (!self.overlay) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + 20)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;    // Should not set `UIViewAutoresizingFlexibleHeight`
        [[self.subviews firstObject] insertSubview:self.overlay atIndex:0];
    }
    self.overlay.backgroundColor = backgroundColor;

##10.导航的图片不显示了,使用的是系统导航,怎么调整都不显示.


解决问题
找到原因了,修改代码就比较容易了,你可以在添加视图时,将bgView指定到UIVisualEffectView,将新的视图添加到UIVisualEffectView上:

	for (UIView  * v in subs)
	    {
	        NSString * classname = NSStringFromClass([v class]);
	        if ([classname isEqualToString:@"_UINavigationBarBackground"] || [classname isEqualToString:@"UINavigationBarBackground"])
	        {
	
	            bgview=v;
	            break;
	        }  else if ([classname isEqualToString:@"_UIBarBackground"]) {
	            //适配iOS10导航
	            for (UIView *vi in v.subviews) {
	
	                NSString *viName = NSStringFromClass([vi class]);
	                if ([viName isEqualToString:@"UIVisualEffectView"]) {
	
	                    bgview = vi;
	                    break;
	                }
	            }
	        }
	    }


也可以还添加到_UIBarBackground上,但是找到UIVisualEffectView,将其隐藏掉:

	if ([classname isEqualToString:@"_UINavigationBarBackground"] || [classname isEqualToString:@"UINavigationBarBackground"])
	        {
	
	            bgview=v;
	            break;
	        } else if ([classname isEqualToString:@"_UIBarBackground"]) {
	
	            bgview = v;
	
	            for (UIView *vi in v.subviews) {
	                // 适配iOS10
	                NSString *viName = NSStringFromClass([vi class]);
	                if ([viName isEqualToString:@"UIVisualEffectView"]) {
	
	                    vi.hidden = YES;
	                    break;
	                }
	            }
	        }

##11.tabBarItem第一个重复出现

这个问题实在没有找到好的方法解决。不过庆幸的是，公司决定将TabBar中的Item四个变成，既然好了，我就想不通。

如果你也遇到了这样的问题，或者已经解决了此问题，欢迎联系我，在此致谢！



===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  