---
layout: post
title: "图片处理高级篇"
date: 2016-01-14 12:21:08 +0800
comments: true
categories: Summary
---




###一：UIImage的加载方式

上一篇文章的补充中也提到了这个，关于图片的加载方式，但是没有过多的涉及，这里就大概的总结一下，希望能有用！

显示关于图片加载问题，由于正在做的项目用到很多图片，加载后内存问题很是头疼，这里是我的经验，大概说一个下。
     一般加载图片的方式：
第一种： 

	NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"pic@.png" ofType:nil inDirectory:nil];  
	UIImage * image = [UIImage imageWithContentsOfFile:imagePath];  

第二种： 

	UIImage * image = [UIImage imageNamed:picName];  


<!--more-->



这两种是我经常用到的

* 用imageWithContentOfFile 加载图片的时候，图片不会做缓存，这样在加载大的图片和使用率低的图片的时候就可以用到。我建议大家使用这种，对控制内存很有帮助。
* 用imageName的加载的时候，系统会件图像保存在内存中去，下次利用的时候，直接在内存中调用，速度很快，重复利用率高的图片有利于这样做，但是在释放内存的时候比较麻烦，只有程序结束的时候内存才释放，有时候会出现内存警告。。。

###二：图片的混合模式
接下来我们看看图片一下常用的混合模式，我觉得这个最好是先自己玩一玩photoshop，上面有很多混合模式可以自己试验，这里我们用代码进行尝试修改图片的混合模式，这样可以看到不同的图片效果。
这里我们就必须用到绘图。常用的方法是： 
	
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:blendMode alpha:alpha];  
先让大家看看这个代码：
 
	- (UIImage *)drawPiucureFrontImage:(UIImage *)personImage backImage:(UIImage *)hatImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha  
	{  
	    CGSize newSize =[personImage size];  
	    UIGraphicsBeginImageContext(newSize);  
	    [personImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:1];  
	    [hatImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:blendMode alpha:alpha];  
	    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();  
	    UIGraphicsEndImageContext();  
	    _imageV.image = newImage;  
	    num++;  
	    return newImage;  
	}  
 
kCGBlendModeNormal  
这个是混合模式的效果  在ps中是正常，以下是常用的模式

	     kCGBlendModeNormal --ok  正常,
	     kCGBlendModeMultiply,    正片叠底
	     kCGBlendModeScreen,      滤色
	     kCGBlendModeOverlay,     叠加
	     kCGBlendModeDarken,      变暗
	     kCGBlendModeLighten,     变亮
	     kCGBlendModeColorDodge,  颜色减淡
	     kCGBlendModeColorBurn,   颜色加深
	     kCGBlendModeSoftLight,   柔光
	     kCGBlendModeHardLight,   强光
	     kCGBlendModeDifference,  差值
	     kCGBlendModeExclusion,   排除
	     kCGBlendModeHue,         色相
	     kCGBlendModeSaturation,  保护度
	     kCGBlendModeColor,       颜色
	     kCGBlendModeLuminosity   明度,
这几个可以试试，每一种图片的模式都不一样。其中正片叠底 和叠加应该是我经常用到的混合模式。

###三：图片的滤镜

上面我们介绍了图片的混合模式，接下来我们来看看图片滤镜，说道滤镜网上有很多的教程，在code4app中也有很多的教程，大家可以去看看看，这里我们使用一个第三方的类  ImageUtil.h，在后面有下载的链接

将这个类导入到自己的工程中 导入头文件： 

	#import "ImageUtil.h"	  

接下来直接调用里面的放大就可以了，在这个类中ColorMatrix.h的文件中，我们可以看见有13中特效可以自己使用，而且调用也十分简单

	[ImageUtil imageWithImage:_imageV.image withColorMatrix:colormatrix_heibai];  
colormatrix_heibai 这个就是他的调用样式，这里是黑白，大家可以替换修改在ColorMatrix.h名字，已达到自己想要的效过，这个方法同时也返回一个UIimage，这样就可以加载到自己想要的UIImageView上了。
下面是特效 

	//LOMO  
	const float colormatrix_lomo[] = {  
	    1.7f,  0.1f, 0.1f, 0, -73.1f,  
	    0,  1.7f, 0.1f, 0, -73.1f,  
	    0,  0.1f, 1.6f, 0, -73.1f,  
	    0,  0, 0, 1.0f, 0 };  
	  
	//黑白  
	const float colormatrix_heibai[] = {  
	    0.8f,  1.6f, 0.2f, 0, -163.9f,  
	    0.8f,  1.6f, 0.2f, 0, -163.9f,  
	    0.8f,  1.6f, 0.2f, 0, -163.9f,  
	    0,  0, 0, 1.0f, 0 };  
	//复古  
	const float colormatrix_huajiu[] = {   
	    0.2f,0.5f, 0.1f, 0, 40.8f,  
	    0.2f, 0.5f, 0.1f, 0, 40.8f,   
	    0.2f,0.5f, 0.1f, 0, 40.8f,   
	    0, 0, 0, 1, 0 };  
	  
	//哥特  
	const float colormatrix_gete[] = {   
	    1.9f,-0.3f, -0.2f, 0,-87.0f,  
	    -0.2f, 1.7f, -0.1f, 0, -87.0f,   
	    -0.1f,-0.6f, 2.0f, 0, -87.0f,   
	    0, 0, 0, 1.0f, 0 };  
	  
	//锐化  
	const float colormatrix_ruise[] = {   
	    4.8f,-1.0f, -0.1f, 0,-388.4f,  
	    -0.5f,4.4f, -0.1f, 0,-388.4f,   
	    -0.5f,-1.0f, 5.2f, 0,-388.4f,  
	    0, 0, 0, 1.0f, 0 };  
	  
	  
	//淡雅  
	const float colormatrix_danya[] = {   
	    0.6f,0.3f, 0.1f, 0,73.3f,  
	    0.2f,0.7f, 0.1f, 0,73.3f,   
	    0.2f,0.3f, 0.4f, 0,73.3f,  
	    0, 0, 0, 1.0f, 0 };  
	  
	//酒红  
	const float colormatrix_jiuhong[] = {   
	    1.2f,0.0f, 0.0f, 0.0f,0.0f,  
	    0.0f,0.9f, 0.0f, 0.0f,0.0f,   
	    0.0f,0.0f, 0.8f, 0.0f,0.0f,  
	    0, 0, 0, 1.0f, 0 };  
	  
	//清宁  
	const float colormatrix_qingning[] = {   
	    0.9f, 0, 0, 0, 0,   
	    0, 1.1f,0, 0, 0,   
	    0, 0, 0.9f, 0, 0,   
	    0, 0, 0, 1.0f, 0 };  
	  
	//浪漫  
	const float colormatrix_langman[] = {   
	    0.9f, 0, 0, 0, 63.0f,   
	    0, 0.9f,0, 0, 63.0f,   
	    0, 0, 0.9f, 0, 63.0f,   
	    0, 0, 0, 1.0f, 0 };  
	  
	//光晕  
	const float colormatrix_guangyun[] = {   
	    0.9f, 0, 0,  0, 64.9f,  
	    0, 0.9f,0,  0, 64.9f,  
	    0, 0, 0.9f,  0, 64.9f,  
	    0, 0, 0, 1.0f, 0 };  
	  
	//蓝调  
	const float colormatrix_landiao[] = {  
	    2.1f, -1.4f, 0.6f, 0.0f, -31.0f,   
	    -0.3f, 2.0f, -0.3f, 0.0f, -31.0f,  
	    -1.1f, -0.2f, 2.6f, 0.0f, -31.0f,   
	    0.0f, 0.0f, 0.0f, 1.0f, 0.0f  
	};  
	  
	//梦幻  
	const float colormatrix_menghuan[] = {  
	    0.8f, 0.3f, 0.1f, 0.0f, 46.5f,   
	    0.1f, 0.9f, 0.0f, 0.0f, 46.5f,   
	    0.1f, 0.3f, 0.7f, 0.0f, 46.5f,   
	    0.0f, 0.0f, 0.0f, 1.0f, 0.0f  
	};  
	  
	//夜色  
	const float colormatrix_yese[] = {  
	    1.0f, 0.0f, 0.0f, 0.0f, -66.6f,  
	    0.0f, 1.1f, 0.0f, 0.0f, -66.6f,   
	    0.0f, 0.0f, 1.0f, 0.0f, -66.6f,   
	    0.0f, 0.0f, 0.0f, 1.0f, 0.0f  
	};  


###四：图片的饱和度，亮度，对比度。


在做图片处理的时候，会遇到调节图片的饱和度的问题，这里就要用到Core Image这个框架，Core Image是一个很强大的框架。它可以让你简单地应用各种滤镜来处理图像，比如修改鲜艳程度, 色泽, 或者曝光。它利用GPU（或者CPU，取决于客户）来非常快速、甚至实时地处理图像数据和视频的帧。多个CoreImage滤镜可以叠加在一起，从而可以一次性地产生多重滤镜效果。这种多重滤镜的优点在于它可以生成一个改进的滤镜，从而一次性的处理图像达到目标效果，而不是对同一个图像顺序地多次应用单个滤镜。每一个滤镜都有属于它自己的参数。这些参数和滤镜信息，比如功能、输入参数等都可以通过程序来查询。用户也可以来查询系统从而得到当前可用的滤镜信息。到目前为止，Mac上只有一部分CoreImage滤镜可以在iOS上使用。但是随着这些可使用滤镜的数目越来越多，API可以用来发现新的滤镜属性。
下面是这个框架下的几个重要的类

* CIContext:所有的图像处理都是在一个CIContext中完成的。
* CIImage 这个类保存图像数据，它可以从UIImage，图像文件或者是像素数据中构造出来。
* CIFilter：滤镜类总保函一个字典结构，对各种滤镜定义了属于他们各自的属性，滤镜有很多种，比如鲜艳程度的滤镜，色彩反转滤镜，剪裁滤镜等等。

用下面的我们来试试修改一张图片的饱和度，亮度，对比度。
首先用到的是CIFilter 我们可以通过字典来看看里面所有的 

	NSArray *cifilter = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];  
	  
	NSLog(@"FilterName:\n%@,,,===%ld", cifilter,cifilter.count);//显示所有过滤器名字  
	  
	for (NSString *filterName in cifilter) {  
	      
	    CIFilter *fltr = [CIFilter filterWithName:filterName];//用一个过滤器名字生成一个过滤器CIFilter对象  
	      
	    NSLog(@"%@:\n%@", filterName, [fltr attributes]);//这个过滤器支持的属性  
	      
	}  
	
可以看见多有的属性
今天我们用到是滤镜名称是CIColorControls

	/////////////////////////////////////
	    CIAttributeFilterDisplayName = "Color Controls";
	    CIAttributeFilterName = CIColorControls;
	    inputBrightness =     {
	        CIAttributeClass = NSNumber;
	        CIAttributeDefault = 0;
	        CIAttributeIdentity = 0;
	        CIAttributeSliderMax = 1;
	        CIAttributeSliderMin = "-1";
	        CIAttributeType = CIAttributeTypeScalar;
	    };
	    inputContrast =     {
	        CIAttributeClass = NSNumber;
	        CIAttributeDefault = 1;
	        CIAttributeIdentity = 1;
	        CIAttributeSliderMax = 4;
	        CIAttributeSliderMin = 0;
	        CIAttributeType = CIAttributeTypeScalar;
	    };
	    inputImage =     {
	        CIAttributeClass = CIImage;
	        CIAttributeType = CIAttributeTypeImage;
	    };
	    inputSaturation =     {
	        CIAttributeClass = NSNumber;
	        CIAttributeDefault = 1;
	        CIAttributeIdentity = 1;
	        CIAttributeSliderMax = 2;
	        CIAttributeSliderMin = 0;
	        CIAttributeType = CIAttributeTypeScalar;
	    };
	/////////////////////////////////////
上面是这个滤镜的名称和属性
下面是具体的修改图片的饱和度亮度和对比度的代码

	CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];  
	CIFilter * filter = [CIFilter filterWithName:@"CIColorControls"];  
	[filter setValue:beginImage forKey:kCIInputImageKey];  
	//  饱和度      0---2  
	[filter setValue:[NSNumber numberWithFloat:0.5] forKey:@"inputSaturation"];  
	//  亮度  10   -1---1  
	[filter setValue:[NSNumber numberWithFloat:0.5] forKey:@"inputBrightness"];  
	//  对比度 -11  0---4  
	[filter setValue:[NSNumber numberWithFloat:2] forKey:@"inputContrast"];  
	  
	// 得到过滤后的图片  
	CIImage *outputImage = [filter outputImage];  
	// 转换图片, 创建基于GPU的CIContext对象  
	CIContext *context = [CIContext contextWithOptions: nil nil];  
	CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];  
	UIImage *newImg = [UIImage imageWithCGImage:cgimg];  
	// 显示图片  
	[_imageV setImage:newImg];  
	// 释放C对象  
	CGImageRelease(cgimg);  



有兴趣的可以去看看关于CoreImage的源码