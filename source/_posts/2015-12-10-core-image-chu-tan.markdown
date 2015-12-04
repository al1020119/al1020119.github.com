---
layout: post
title: "Core Image 初探"
date: 2015-12-10 10:09:37 +0800
comments: true
categories: 
---

> 前言：
> Core Image 是 IOS 的图片处理框架，有使用方便、易于管理，性能优异的特点。
	
>	* 用途 
	* 在照片、视频处理，把滤镜作为最后一步，添加水印
	* 给照相机提供实时效果 
	* 面部检测，自动滤镜增益,图片分析算法
	* 更多


##coreimage framework 组成

apple 已经帮我们把image的处理分类好，来看看它的结构：

{% img /images/coreimage001.png Caption %}  

主要分为三部分：

#####定义部分：
 
 CoreImage 何CoreImageDefines。见名思义，代表了CoreImage 这个框架和它的定义。

#####操作部分：

	滤镜（CIFliter）：CIFilter 产生一个CIImage。典型的，接受一到多的图片作为输入，经过一些过滤操作，产生指定输出的图片。

	检测（CIDetector）：CIDetector 检测处理图片的特性，如使用来检测图片中人脸的眼睛、嘴巴、等等。

	特征（CIFeature）：CIFeature 代表由 detector处理后产生的特征。

#####图像部分：
 
	画布（CIContext）：画布类可被用与处理Quartz 2D 或者 OpenGL。可以用它来关联CoreImage类。如滤镜、颜色等渲染处理。
	
	颜色（CIColor）：   图片的关联与画布、图片像素颜色的处理。
	
	向量（CIVector）： 图片的坐标向量等几何方法处理。
	
	图片（CIImage）： 代表一个图像，可代表关联后输出的图像。　　



{% img /images/coreimage002.jpg Caption %}  




##2.  处理步骤：

	  1）create a ciimage object;
	
	  2) create a cifilter object and set input values
	
	  3)  create a cicontext object.
	
	  4) render the filter output image into a cgimage

　　　　

##3.注意

　　　　a。关注Ciimage 产生的途径：

　　　　　　　　1）通过URL和Data

　　　　　　　　 2）通过其他图片类转换，CGImageRef或其他图片。

　　　　　　　　 3）通过CVpixelBufferRef。

　　　　　　　　 4）一组像素Data。

　　　　b.  图片颜色，KCCImageColorSpace 来重载默认颜色空间。

　　　　c. 图片Metadata。

　　　　

##4. 使用滤镜。

　　　　CISepiaTone、CiColorControls、CIHueBlendMode。

{% img /images/coreimage003.png Caption %}  


处理过程：多个CImage输入 －－ 》 CIHeBlendMode  －－》 CiSepiatone。

{% img /images/coreimage004.jpg Caption %}  

渲染输出：

{% img /images/coreimage005.jpg Caption %}  

流程： 获取context  －》 转成CIimage －》 渲染成CGImageRef  －》 转换为UIimage －》 释放 CGImageRef －》 使用UIImage。



##5.脸部检测

　　自动增强： CIRedEyeCorrection  、CIFaceBalance（调整图片来给出更好的皮肤色调）、CIVibrance（在不扭曲皮肤色调的情况下，增加饱和度）、CIToneCurve（调整图片对比）、高亮阴影调整。
　　
　　
***
----基本使用----
***

#####Core Image 处理图片的工作流程

* 创建新的CIImage 
* 创建新的CIFilter，通过键-值编码设置输入值，一定要给inputImage加入一个值，这个属性是图像数据源
* 从CIFilter中生成输出图片。通过访问CIFilter的outputImage属性，可以得到输出图像，这是一个新的CIImage对象，包含了原始图片的数据以及一个滤镜链。 在得到输出图像后，可以使用滤镜来渲染出最终的效果图像。也可以将其作为一个新滤镜的输入图像，这样会产生出一条滤镜链
* 用CIContext 渲染CIImage 对象，这个CIContext 可以是基于CPU的，输出为CGImageRef，通过 LibDispatch（GCD）渲染 ，更加可靠，也更加易用。也可以是基于GPU的，开发者可通过Open ES 2.0 画出来。使用GPU渲染时CPU没有负担，更好地性能，但无法在后台运行



使用例子：

	 CIImage *myCoreImage = [CIImage imageWithCGImage:self.myImageView.image.CGImage options:nil];  
     
    // 创建Filter，@"CISepiaTone"这个名字是系统指定的  
    CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];  
     
    // 设置Filter  
    [sepia setValue:myCoreImage forKey:@"inputImage"];  
     
    NSNumber *intensity = [NSNumber numberWithFloat:.5f];  
    [sepia setValue:intensity forKey:@"inputIntensity"];  
     
    // 生成新的 CIImage  
    CIImage *outputImage = [sepia outputImage];  
     
    // 取出UIImage  
    CGImageRef renderImage = [_imageContext createCGImage:outputImage fromRect:[outputImage extent]];  
    [self.myImageView setImage:[UIImage imageWithCGImage:renderImage]];
    
> DemoCoreImage 是直接从IOS 核心框架拿过来的。
> CoreImageMySelf 是我自己提取的只为实现优化功能的demo
提取的功能模块有，filter的使用、自动优化的使用、脸部检测

再来看看常见的使用方式

* CIImage

保存图像数据的类，可以通过UIImage，图像文件或者像素数据来创建，包括未处理的像素数据如：

	- imageWithCVPixelBuffer:
	
	- imageWithData:

方法等等。

也可以通过图像数据类比如UIImage，CGImageRef等等。


* CIFilter

滤镜类，这个框架中对图片属性进行细节处理的类。它对所有的像素进行操作，用一些键-值设置来决定具体操作的程度。


* CIContext

上下文类，如CoreGraphics以及CoreData中的上下文用于处理绘制渲染以及处理托管对象一样，CoreImage的上下文也是实现对图像处理的具体对象。

这里需要注意的是在Context创建的时候，我们需要给它设定为是基于GPU还是CPU。(这里使用GPU)

> 基于GPU的话，处理速度更快，因为利用了GPU硬件的并行优势。但是GPU受限于硬件纹理尺寸，而且如果你的程序在后台继续处理和保存图片的话，那么需要使用CPU，因为当app切换到后台状态时GPU处理会被打断。

 

###使用步骤：

######0.导入CIImage图片 

    CIImage *ciImage = [[CIImage alloc]initWithImage:[UIImage imageNamed:@"test.jpg"]];
######1.创建出Filter滤镜

    CIFilter *filterOne = [CIFilter filterWithName:@"CIPixellate"];
    [filterOne setValue:ciImage forKey:kCIInputImageKey];
    [filterOne setDefaults];

    CIImage *outImage = [filterOne valueForKey:kCIOutputImageKey];
######2.用CIContext将滤镜中的图片渲染出来

    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef cgImage = [context createCGImage:outImage fromRect:[outImage extent]];
######3.导出图片

    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
######4.加载图片

	 _image.image = showImage;
 

***

###如果要使用组合滤镜

######在步骤1中设置组合滤镜，只需要将上一个滤镜的输出变为下一个滤镜的输入就行了

    //第一个滤镜
    CIFilter *filterOne = [CIFilter filterWithName:@"CIPixellate"];
    [filterOne setValue:ciImage forKey:kCIInputImageKey];
    [filterOne setDefaults];
    CIImage *outImage = [filterOne valueForKey:kCIOutputImageKey];
    //第二个滤镜
    CIFilter *filterTwo = [CIFilter filterWithName:@"CIHueAdjust"];
    [filterTwo setValue:outImage forKey:kCIInputImageKey];
    [filterTwo setDefaults];
    [filterTwo setValue:@(1.f) forKey:kCIInputAngleKey];
    CIImage *outputImage = [filterTwo valueForKey:kCIOutputImageKey];
######记住渲染的时候，步骤2，要将最后输出的CIImage传入

 

    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outImage extent]];
