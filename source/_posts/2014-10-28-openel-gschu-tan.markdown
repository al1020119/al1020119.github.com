---
layout: post
title: "OpenEL GS初探"
date: 2014-10-28 17:43:44 +0800
comments: true
categories: Advanced
---


> 写在前头，好久没有更新博客，感谢老朋友的再次来访，同时也欢迎新朋友~

说起OpenGL，相信大不多数朋友都不会陌生，或多或少都有接触。本文不属于OpenGL提高篇，主要目的在于帮助新手更快熟悉iOS中如何使用OpenGL，关于这方面的介绍，网上也有很多，本文主要任务在于整理，介绍稍有偏重。这里有比较完整的Demo，可以协助大家更快上手



<!--more-->




OpenGL版本

iOS系统默认支持OpenGl ES1.0、ES2.0以及ES3.0 3个版本，三者之间并不是简单的版本升级，设计理念甚至完全不同，在开发OpenGL项目前，需要根据业务需求选择合适的版本。这方面的介绍不少，不再展开。在学习OpenGL代码的时候也需要知道它对应着哪个版本，在ES1中执行ES2代码是看不到任何效果的，你可以在初始化EAGLContext时指定ES版本号

	EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
OpenGL坐标系

OpenGL坐标系不同于UIKit坐标系，其实它是这样的


 
{% img /images/openEL001.png Caption %}  

除了方向，还有一点需要注意，默认情况各个方向坐标值范围为（-1，1），而不是UIKit中的（0，320）。当绘制点(320，0)，它并不会出现在屏幕右上角。在ES1中，可以通过以下代码将坐标系转化为熟悉的（320，480）

	- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	    glViewport(0, 0, rect.size.width * 2, rect.size.height * 2);
	    glMatrixMode(GL_PROJECTION);
	    glLoadIdentity();
	    glOrthof(0, 320, 0, 480, -1024, 1024);
	    glMatrixMode(GL_MODELVIEW);
	    glLoadIdentity();
	}
接下来说说iOS中如何使用OpenGL

	GLKViewController & GLKView

机智的码农是不是已经发现这两个对象， 为了方便大家更快的开发，系统为OpenGL提供了简单的封装，继承GLKViewController定义自己的ViewController，GLKViewController的view为GLKView类，GLKView的delegate定义了绘制回调函数

	- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
GLKViewController定义数据刷新函数，当子类实现-(void)update方法，glkViewControllerUpdate方法将不再被调用

	- (void)glkViewControllerUpdate:(GLKViewController *)controller
HJGLKViewControllerDemo模拟了GLKViewController方法实现，有兴趣的童鞋可以查看GLKViewController内部实现机制。需要补充一点，默认情况下，GLKViewController渲染RunLoop并非NSRunLoopCommonModes，而是NSDefaultRunLoopMode，因此在UIKit中使用GLKViewController，当滑动界面时，OpenGL是不会渲染的，为了解决这个问题，可以使用HJGLKViewController替换GLKViewController，HJGLKViewController中默认渲染RunLoop使用NSRunLoopCommonModes模式

###EAGLContext

在介绍选择版本时已经提到EAGLContext，与UIKit中CGContextRef相似，EAGLContext相当于OpenGL绘制句柄或者上下文，在绘制试图之前，需要指定使用创建的上下文绘制

[EAGLContext setCurrentContext:view.context];
当一个APP可能存在多个EAGLContext时，需要处理并存冲突等问题，比如大家所熟知的GPUImage，都会使用到EAGLContext。因此，在使用中要记得及时释放。有兴趣的朋友可以看看这篇文章

###Draw

OpenGL绘制本文就不做介绍，HJGLKViewControllerDemo中有大量的示例，顺便推荐几篇相关文章

详解第一个OpenGL程序
西蒙iPhone-OpenGL ES 中文教程专题
Cocos2d源码
小贴士：当App退到后台时， 切记暂停OpenGL绘制，否则可能导致crash
