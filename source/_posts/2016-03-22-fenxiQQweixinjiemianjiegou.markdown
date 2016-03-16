---
layout: post
title: "分析QQ-微信界面结构"
date: 2016-03-22 13:32:08 +0800
comments: true
categories: Summary
---


使用Reveal分析其他APP（如微信、qq等）的界面结构 


特别提醒，现已无需按下面的方式注入libReveal.dlib了，只需把libReveal.dylib上传到设备的/Library/MobileSubstrate/DynamicLibraries，然后同时编辑并上传一个libReveal.plist，格式如下：

nixiang0001
 
 
 设定BundleID
注意，此时是可以指定多个BundleID的，也就是说，你可以同时监控任意多的app；再扩大一步说，如果你愿意，不上传这个libReveal.plist，你可以监控所有app，只要你不觉得机器很慢。。。
一定确保手机和电脑端处在同一局域网中，不然看不到界面的
Reveal.app 目前能搞到2.0.3的版本且能用注册机破解，但貌似对ios7.0以上的应用无效，需要Reveal2.0.4版，但又无法破解目前，2.0.3版本百度云下载
http://c.blog.sina.com.cn/profile.php?blogid=cb8a22ea89000gtw&qq-pf-to=pcqq.c2c





<!--more-->





打开XCode创建iOSOpenDev--》Logos Tweak的工程

创建动态加载Reveal的类RevealUtil：

	//
	//  RevealUtil.h
	//  pyu
	//
	//  Created by whe on 6/23/13.
	//
	//
	
	#import
	
	@interface RevealUtil : NSObject {
	    void *_revealLib;
	}
	
	- (void)startReveal;
	- (void)stopReveal;
	
	@end
	
	//
	//  RevealUtil.m
	//  pyu
	//
	//  Created by whe on 6/23/13.
	//
	//
	#import
	#import
	#import "RevealUtil.h"
	
	@implementation RevealUtil
	
	- (void)startReveal {
	    NSString *revealLibName = @"libReveal.dylib";
	    //NSString *revealLibExtension = @"dylib";
	    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	   //此处要先将libReveal.dylib通过iTools上传到需要分析的App的Buldle主目录下（即xxx.app目录）
	    NSString *dyLibPath = [NSString stringWithFormat:@"%@/%@",bundlePath,revealLibName];
	    UIAlertView *alert = [[UIAlertView alloc]
	                          initWithTitle:@"Welcome"  message:[NSString stringWithFormat:@"Loading dynamic library: %@", dyLibPath]
	                          delegate:nil cancelButtonTitle:@"Thanks"
	                          otherButtonTitles:nil];
	    [alert show];
	    [alert release];
	   
	    void *revealLib = NULL;
	    revealLib = dlopen([dyLibPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_NOW);
	   
	    if (revealLib == NULL)
	    {
	        char *error = dlerror();
	        NSLog(@"dlopen error: %s", error);
	    }else {
	        [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:self];
	    }
	}
	
	- (void)stopReveal {
	    if (_revealLib)
	    {
	        [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStop" object:self];
	        if (dlclose(_revealLib) == 0)
	        {
	            NSLog(@"Reveal library unloaded");
	            _revealLib = NULL;
	        }
	        else
	        {
	            char *error = dlerror();
	            NSLog(@"Reveal library could not be unloaded: %s", error);
	        }
	    }
	}
	
	@end

修改工程的xm文件内容如下：

	#import "RevealUtil.h"

%hook MobileAssistAppDelegate //对应分析APP的AppDelegate文件类名，不同的App这个类名可能不同，这可以先通过class-dump  xxx.app这个二进制文件，得出该APP所有的头文件，然后搜索关键字didFinishLaunchingWithOptions，找到对应文件并查看该文件内的类名即是

	- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
	    %orig;
	   
	    RevealUtil *ru = [[RevealUtil alloc] init];
	    [ru startReveal];
	   
	    return YES;
	}
	
	%end

最终项目结构如下：

nixiang0002

注意那个Filter，其实可以不填，但要填一定要是该app的bundle identifier



附：OpenSSH的使用：
       ssh root@192.168.2.5 默认密码alpine
     先通过ssh登录到手机，然后可以通过cycript -p 进程ID   依附在需要分析的应用程序上  ps ax | grep PP