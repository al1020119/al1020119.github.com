---
layout: post
title: "图片处理-常用技巧"
date: 2016-01-14 09:21:08 +0800
comments: true
categories: Performance
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---


iOS开发中关于图片的处理是最常见的，就和你使用TableView的频率一样，本篇文章总结了一下iOS开发中常见的图片处理及相关源码。


这里就结合开发与学习中遇到的一一些图片处理问题，再结合其他大牛的一些干货，做了一系列的总结，希望能最你有实际开发意义！


目录

+ 获取图片
+ 比例缩放
+ 圆角 化
+ 添加阴影
+ 压缩大小
+ 格式的转换
+ 图片上传

	
	

<!--more-->



##获取图片
提到从摄像头/相册获取图片是面向终端用户的，由用户去浏览并选择图片为程序使用。在这里，我们需要过UIImagePickerController类来和用户交互。

使用UIImagePickerController和用户交互，我们需要实现2个协议

	<UIImagePickerControllerDelegate,UINavigationControllerDelegate>。
	
	#pragma mark 从用户相册获取活动图片
	
	- (void)pickImageFromAlbum
	
	{

	    imagePicker = [[UIImagePickerController alloc] init];
	
	    imagePicker.delegate =self;
	
	    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	    imagePicker.allowsEditing =YES;
	
	    
	
	    [self presentModalViewController:imagePicker animated:YES];

	}

我们来看看上面的从相册获取图片，我们首先要实例化UIImagePickerController对象，然后设置imagePicker对象为当前对象，设置imagePicker的图片来源为UIImagePickerControllerSourceTypePhotoLibrary，表明当前图片的来源为相册，除此之外还可以设置用户对图片是否可编辑。
 

	#pragma mark 从摄像头获取活动图片
	
	- (void)pickImageFromCamera
	
	{
	
	    imagePicker = [[UIImagePickerController alloc] init];
	
	    imagePicker.delegate =self;
	
	    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	    imagePicker.allowsEditing =YES;
	
	    
	
	    [self presentModalViewController:imagePicker animated:YES];
	
	}
	
	//打开相机
	
	- (IBAction)touch_photo:(id)sender {
	
	    // for iphone
	
	    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
	
	   if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
	
	        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
	
	        
	
	    }
	
	    pickerImage.delegate =self;
	
	    pickerImage.allowsEditing =YES;//自定义照片样式
	
	    [self presentViewController:pickerImage animated:YES completion:nil];
	
	}

以上是从摄像头获取图片，和从相册获取图片只是图片来源的设置不一样，摄像头图片的来源为UIImagePickerControllerSourceTypeCamera。

在和用户交互之后，用户选择好图片后，会回调选择结束的方法。


	
	
##UIImage 图像 等比例缩放 

	PicAfterZoomWidth:缩放后图片宽  PicAfterZoomHeight:缩放后图片高 (预定义)
	+ (UIImage *)getPicZoomImage:(UIImage *)image {
	
	    UIImage *img = image;
	    
	    int h = img.size.height;
	    int w = img.size.width;
	    if(h <= PicAfterZoomWidth && w <= PicAfterZoomHeight)
	    {
	        image = img;
	    }
	    else 
	    {
	        float b = (float)PicAfterZoomWidth/w < (float)PicAfterZoomHeight/h ? (float)PicAfterZoomWidth/w : (float)PicAfterZoomHeight/h;
	        CGSize itemSize = CGSizeMake(b*w, b*h);
	        UIGraphicsBeginImageContext(itemSize);
	        CGRect imageRect = CGRectMake(0, 0, b*w, b*h);
	        [img drawInRect:imageRect];
	        img = UIGraphicsGetImageFromCurrentImageContext();
	        UIGraphicsEndImageContext();
	    }
	    return img;
	}

或者：

绘图技术改变图片大小缩放方法：

	-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
	{
	    UIGraphicsBeginImageContext(size); //size 为CGSize类型，即你所需要的图片尺寸
	    
	    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	    
	    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	    
	    UIGraphicsEndImageContext();
	    
	    return scaledImage; //返回的就是已经改变的图片
	}



## 把图片 圆角 化  
设置圆角的方法

    直接使用setCornerRadius

        这种就是最常用的，也是最耗性能的。

    setCornerRadius设置圆角之后，shouldRasterize=YES光栅化

        avatarImageView.clipsToBounds = YES; [avatarImageView.layer setCornerRadius:50]; avatarImageView.layer.shouldRasterize = YES;

        shouldRasterize=YES设置光栅化，可以使离屏渲染的结果缓存到内存中存为位图， 使用的时候直接使用缓存，节省了一直离屏渲染损耗的性能。

        但是如果layer及sublayers常常改变的话，它就会一直不停的渲染及删除缓存重新 创建缓存，所以这种情况下建议不要使用光栅化，这样也是比较损耗性能的。

        问题：我发现UIImageView上加载网络图片使用光栅化会有一点模糊，而UIButton 上使用光栅化没有模糊，不知道为什么？求大神解答！

    直接覆盖一张中间为圆形透明的图片

        这种方法就是多加了一张透明的图片，GPU计算多层的混合渲染blending也是会消耗 一点性能的，但比第一种方法还是好上很多的。

    Core Graphics绘制圆角

        这种方式性能最好，但是UIButton上不知道怎么绘制，可以用UIimageView添加个 点击手势当做UIButton使用。

          UIGraphicsBeginImageContextWithOptions(avatarImageView.bounds.size, NO, [UIScreen mainScreen].scale);
          [[UIBezierPath bezierPathWithRoundedRect:avatarImageView.bounds cornerRadius:50] addClip];
          [image drawInRect:avatarImageView.bounds];
          avatarImageView.image = UIGraphicsGetImageFromCurrentImageContext();
          UIGraphicsEndImageContext();

        这段方法可以写在SDWebImage的completed回调里，也可以在UIImageView+WebCache.h 里添加一个方法，isClipRound判断是否切圆角，把上面绘制圆角的方法封装到里面。

          - (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options isClipRound:(BOOL)isRound progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;

使用Instruments的Core Animation查看性能

    Color Offscreen-Rendered Yellow

        开启后会把那些需要离屏渲染的图层高亮成黄色，这就意味着黄色图层可能存在性能问题。

    Color Hits Green and Misses Red

        如果shouldRasterize被设置成YES，对应的渲染结果会被缓存，如果图层是绿色，就表示这些缓存被复用；如果是红色就表示缓存会被重复创建，这就表示该处存在性能问题了。

用Instruments测试得

    第一种方法，ios9.0之前UIImageView和UIButton都高亮为黄色。ios9.0之后只有UIButton高亮为黄色。

    第二种方法UIImageView和UIButton都高亮为绿色，但UIImageView加载网络图片后会有一点模糊

    第三种方法无任何高亮，说明没离屏渲染

    第四种方法无任何高亮，说明没离屏渲染


这里以一种比较好的方式实现圆角的处理

	static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
	                                 float ovalHeight)
	{
	    float fw, fh;
	    if (ovalWidth == 0 || ovalHeight == 0) {
	        CGContextAddRect(context, rect);
	        return;
	    }
	    CGContextSaveGState(context);
	    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	    CGContextScaleCTM(context, ovalWidth, ovalHeight);
	    fw = CGRectGetWidth(rect) / ovalWidth;
	    fh = CGRectGetHeight(rect) / ovalHeight;
	    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
	    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
	    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
	    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
	    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
	    CGContextClosePath(context);
	    CGContextRestoreGState(context);
	}
	+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size
	{
	    // the size of CGContextRef
	    int w = size.width;
	    int h = size.height;
	    
	    UIImage *img = image;
	    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
	    CGRect rect = CGRectMake(0, 0, w, h);
	    CGContextBeginPath(context);
	    addRoundedRectToPath(context, rect, 10, 10);
	    CGContextClosePath(context);
	    CGContextClip(context);
	    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
	    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	    CGContextRelease(context);
	    CGColorSpaceRelease(colorSpace);
	    return [UIImage imageWithCGImage:imageMasked];
	}
	
##给图片 添加阴影
一直以来，为IOS添加图片的特殊效果都是通过跟美工的配合，比如，要加阴影，就从美工那边获得一张阴影效果图，在界面上画两个UIImageView，将阴影放在下面，图像放上上面，错开一定角度。有比如想做圆角效果，就画一张跟背景一个颜色的图片，中间透明，盖在原图上方。看起来很拙劣，效果还是不错的，直到愚钝的我发现IOS已经帮我们准备好了一切。其实就是几行代码的事情：
 
請先添加库 import QuartzCore.framework
然后要导入头文件 #import <QuartzCore/QuartzCore.h>

	[[myView layer] setShadowOffset:CGSizeMake(5, 5)]; //设置阴影起点位置
	[[myView layer] setShadowRadius:6];                       //设置阴影扩散程度
	[[myView layer] setShadowOpacity:1];                      //设置阴影透明度
	[[myView layer] setShadowColor:[UIColor blueColor].CGColor]; //设置阴影颜色
	 ========== (Four) UIImage 图像 旋转==================================
	- (UIImage *)imageRotatedByRadians:(CGFloat)radians
	{
	    return [self imageRotatedByDegrees:radians * 180/M_PI];
	}
	- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
	{   
	    // calculate the size of the rotated view's containing box for our drawing space
	    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
	    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	    rotatedViewBox.transform = t;
	    CGSize rotatedSize = rotatedViewBox.frame.size;
	    [rotatedViewBox release];
	    // Create the bitmap context
	    UIGraphicsBeginImageContext(rotatedSize);
	    CGContextRef bitmap = UIGraphicsGetCurrentContext();
	    // Move the origin to the middle of the image so we will rotate and scale around the center.
	    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	    
	    //   // Rotate the image context
	    CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	    // Now, draw the rotated/scaled image into the context
	    CGContextScaleCTM(bitmap, 1.0, -1.0);
	    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	    UIGraphicsEndImageContext();
	    return newImage;
	}
	
	 
##图片压缩大小
对于移动端的Jpg文件，有这样的结论：

  * a.使用大尺寸大有损压缩比的jpg

  * b.使用jpegtran进行无损压缩
  
而对于png有以下结论：

  * a.多彩图片使用png24

  * b.低彩图片使用png8

  * c.推荐使用pngquant
  

在Iphone上有两种读取图片数据的简单方法: UIImageJPEGRepresentation和UIImagePNGRepresentation. 

* UIImageJPEGRepresentation函数需要两个参数:图片的引用和压缩系数.而UIImagePNGRepresentation只需要图片引用作为参数.通过在实际使用过程中,比较发现: UIImagePNGRepresentation(UIImage* image) 要比


* UIImageJPEGRepresentation(UIImage* image, 1.0) 返回的图片数据量大很多.譬如,同样是读取摄像头拍摄的同样景色的照片, UIImagePNGRepresentation()返回的数据量大小为199K ,而 UIImageJPEGRepresentation(UIImage* image, 1.0)返回的数据量大小只为140KB,比前者少了50多KB.如果对图片的清晰度要求不高,还可以通过设置 UIImageJPEGRepresentation函数的第二个参数,大幅度降低图片数据量.譬如,刚才拍摄的图片, 通过调用UIImageJPEGRepresentation(UIImage* image, 1.0)读取数据时,返回的数据大小为140KB,但更改压缩系数后,通过调用

* UIImageJPEGRepresentation(UIImage* image, 0.5)读取数据时,返回的数据大小只有11KB多,大大压缩了图片的数据量 ,而且从视角角度看,图片的质量并没有明显的降低.因此,在读取图片数据内容时,建议优先使用UIImageJPEGRepresentation,并可根据自己的实际使用场景,设置压缩系数,进一步降低图片数据量大小.


####这里我们以一个常用的框架演示

提到从摄像头/相册获取图片是面向终端用户的，由用户去浏览并选择图片为程序使用。在这里，我们需要过UIImagePickerController类来和用户交互。
使用UIImagePickerController和用户交互，我们需要实现2个协议<UIImagePickerControllerDelegate,UINavigationControllerDelegate>。 
代码如下 复制代码


	#pragma mark 从用户相册获取活动图片
	- (void)pickImageFromAlbum
	{
	    imagePicker = [[UIImagePickerController alloc] init];
	    imagePicker.delegate =self;
	    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	    imagePicker.allowsEditing =YES;
	    
	    [self presentModalViewController:imagePicker animated:YES];
	}
我们来看看上面的从相册获取图片，我们首先要实例化UIImagePickerController对象，然后设置imagePicker对象为当前对象，设置imagePicker的图片来源为UIImagePickerControllerSourceTypePhotoLibrary，表明当前图片的来源为相册，除此之外还可以设置用户对图片是否可编辑。 
代码如下 复制代码

		#pragma mark 从摄像头获取活动图片
		- (void)pickImageFromCamera
		{
		    imagePicker = [[UIImagePickerController alloc] init];
		    imagePicker.delegate =self;
		    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		    imagePicker.allowsEditing =YES;
		    
		    [self presentModalViewController:imagePicker animated:YES];
		}
		//打开相机
		- (IBAction)touch_photo:(id)sender {
		    // for iphone
		    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
		   if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
		        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
		        
		    }
		    pickerImage.delegate =self;
		    pickerImage.allowsEditing =YES;//自定义照片样式
		    [self presentViewController:pickerImage animated:YES completion:nil];
		}


以上是从摄像头获取图片，和从相册获取图片只是图片来源的设置不一样，摄像头图片的来源为UIImagePickerControllerSourceTypeCamera。
在和用户交互之后，用户选择好图片后，会回调选择结束的方法。
	
			-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
			{
			    //初始化imageNew为从相机中获得的--
			    UIImage *imageNew = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
			    //设置image的尺寸
			    CGSize imagesize = imageNew.size;
			    imagesize.height =626;
			    imagesize.width =413;
			    //对图片大小进行压缩--
			    imageNew = [self imageWithImage:imageNew scaledToSize:imagesize];
			    NSData *imageData = UIImageJPEGRepresentation(imageNew,0.00001);
			   if(m_selectImage==nil)
			    {
			        m_selectImage = [UIImage imageWithData:imageData];
			        NSLog(@"m_selectImage:%@",m_selectImage);
			        [self.TakePhotoBtn setImage:m_selectImage forState:UIControlStateNormal];
			        [picker dismissModalViewControllerAnimated:YES];
			       return ;
			    }
			    [picker release];
			}
			//对图片尺寸进行压缩--
			-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
			{
			    // Create a graphics image context
			    UIGraphicsBeginImageContext(newSize);
			    
			    // Tell the old image to draw in this new context, with the desired
			    // new size
			    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
			    
			    // Get the new image from the context
			    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
			    
			    // End the context
			    UIGraphicsEndImageContext();
			    
			    // Return the new image.
			   return newImage;
			}
			
####你还可以使用专门的压缩框架（ZipArchive）实现图片的压缩

将第三方倒入到工程中就可以

调用头文件

	#import "ZipArchive.h"  


首先是压缩文件
 
	- (void)zipFunction  
	{  
	    zip = [[ZipArchive alloc] init];  
	    NSString *documentPath = [self documentsPath];  
	    NSString * zipFile = [documentPath stringByAppendingString:@"/images.zip"] ;  
	      
	    NSString * image1 = [[NSBundle mainBundle] pathForResource:@"a" ofType:@"jpg" inDirectory:nil];  
	    NSString * image2 = [[NSBundle mainBundle] pathForResource:@"b" ofType:@"jpg" inDirectory:nil];  
	    BOOL result = [zip CreateZipFile2:zipFile];  
	    result = [zip addFileToZip:image1 newname:@"a.jpg"];  
	    result = [zip addFileToZip:image2 newname:@"b.jpg"];  
	    if( ![zip CloseZipFile2] ){  
	        zipFile = @"";  
	    }  
	    [zip release];  
	    NSLog(@"%@",NSHomeDirectory());  
	}  

然后解压函数 

	- (void)unzip  
	{  
	    zip = [[ZipArchive alloc] init];  
	    NSString *documentPath = [self documentsPath];  
	    NSString* zipFile = [documentPath stringByAppendingString:@"/images.zip"] ;  
	    NSString* unZipTo = [documentPath stringByAppendingString:@"/images"] ;  
	    if( [zip UnzipOpenFile:zipFile] ){  
	        BOOL result = [zip UnzipFileTo:unZipTo overWrite:YES];  
	        if( NO==result ){  
	            //添加代码  
	        }  
	        [zip UnzipCloseFile];  
	  
	        NSString * imageField = [unZipTo stringByAppendingPathComponent:@"a.jpg"];  
	        NSData * imagedata = [NSData dataWithContentsOfFile:imageField];  
	        UIImage * image = [UIImage imageWithData:imagedata];  
	          
	        UIImageView * iamgePic = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];  
	          
	        [iamgePic setImage:image];  
	          
	        [self.view addSubview:iamgePic];  
	  
	    }  
	    [zip release];  
	}  
这样就把a图片解压出来了
很简单吧。。。。。
剩下的就是自己调用了。。。。。。


###把一张图片压缩并截取中间部分

	//这个方法是把一张UIImage压缩成newSize的尺寸
	
	-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
	
	{
	
	    UIGraphicsBeginImageContext(newSize);
	
	    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	
	    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	    UIGraphicsEndImageContext();
	
	    return newImage;
	
	}

 

* 截取中间部分 
	
		- (UIImage *)scaleImage:(UIImage *)image toScale:(CGSize)reSize
		
		{
	
	    //先按要显示的大小去比例缩放下图片，这里压缩成245*245的大小
	
	    UIImage *scaledImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(245, 245)];
	
	    //计算截取位置。这里我们考虑一般拍照边界位置可能存在全白或全黑的情况，多数重要的会在中间位置。所以计算下截取是重绘图片的中间位置
	
	    float drawW = 0.0;
	
	    float drawH = 0.0;
	
	    CGSize size_new = scaledImage.size;
	
	    if (size_new.width > reSize.width) {
	
	        drawW = (size_new.width - reSize.width)/2.0;
	
	    }
	
	    if (size_new.height > reSize.height) {
	
	        drawH = (size_new.height - reSize.height)/2.0;
	
	    }
	
	    NSLog(@"drawW=====w==%f\n--------drawH==%f\n\n",drawW,drawH);    
	
	    //截取截取大小为需要显示的大小。取图片中间位置截取
	
	    CGRect myImageRect = CGRectMake(drawW, drawH, reSize.width, reSize.height);
	
	    UIImage* bigImage= scaledImage;
	
	    scaledImage = nil;
	
	    CGImageRef imageRef = bigImage.CGImage;
	
	    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
	
	    
	
	    UIGraphicsBeginImageContext(reSize);
	
	    CGContextRef context = UIGraphicsGetCurrentContext();
	
	    CGContextDrawImage(context, myImageRect, subImageRef);
	
	    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
	
	    UIGraphicsEndImageContext();
	
	    CGImageRelease(subImageRef);
	
	    return smallImage;
	
	}
			
####我还看到有人这么做过

* 方法一：将图片按照原来的宽高比例压缩到与窗口合适的大小，然后在设置了_imageView.contentMode = UIViewContentModeCenter;  

这个属性的UIImageView中展示压缩后的图片。

 
	//压缩图片  
	- (UIImage *)image:(UIImage*)image scaledToSize:(CGSize)newSize  
	{  
	    // Create a graphics image context  
	    UIGraphicsBeginImageContext(newSize);  
	    // Tell the old image to draw in this new context, with the desired  
	    // new size  
	    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];  
	    // Get the new image from the context  
	    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();  
	    // End the context  
	    UIGraphicsEndImageContext();  
	    // Return the new image.  
	    return newImage;  
	}  
上面方法的参数newSize是和图片显示窗口差不多大的，结果出现了原图清晰，但压缩后图片不清晰的情况。


* 方法二：按照窗口宽高比例，将原图横向或者纵向裁剪掉多余的部分，然后不设置UIImageView的contentMode属性，将裁剪后的图片送进去，使其自动适应窗口。
缩放效果的代码如下


		//裁剪图片  
		- (UIImage *)cutImage:(UIImage*)image  
		{  
		    //压缩图片  
		    CGSize newSize;  
		    CGImageRef imageRef = nil;  
		      
		    if ((image.size.width / image.size.height) < (_headerView.bgImgView.size.width / _headerView.bgImgView.size.height)) {  
		        newSize.width = image.size.width;  
		        newSize.height = image.size.width * _headerView.bgImgView.size.height / _headerView.bgImgView.size.width;  
		          
		        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, fabs(image.size.height - newSize.height) / 2, newSize.width, newSize.height));  
		          
		    } else {  
		        newSize.height = image.size.height;  
		        newSize.width = image.size.height * _headerView.bgImgView.size.width / _headerView.bgImgView.size.height;  
		          
		        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(fabs(image.size.width - newSize.width) / 2, 0, newSize.width, newSize.height));  
		  
		    }  
		  
		    return [UIImage imageWithCGImage:imageRef];  
		}  

##图片格式的转换


图片保存到本地document里面--以及图片格式的转换
IOS开发之保存图片到Documents目录及PNG，JPEG格式相互转换

		- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
		    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
		    if ([mediaType isEqualToString:@"public.image"]){
		        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
		        NSData *data;
		        if (UIImagePNGRepresentation(image) == nil) {
		            data = UIImageJPEGRepresentation(image, 1);
		        } else {
		            data = UIImagePNGRepresentation(image);
		        }
	        
	        NSFileManager *fileManager = [NSFileManager defaultManager];
	        NSString *filePath = [NSString stringWithString:[self getPath:@"image1"]];         //将图片存储到本地documents
	         [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
	         [fileManager createFileAtPath:[filePath stringByAppendingString:@"/image.png"] contents:dataattributes:nil];
	        
	        UIImage *editedImage = [[UIImage alloc] init];
	        editedImage = image;
	        CGRect rect = CGRectMake(0, 0, 64, 96);
	        UIGraphicsBeginImageContext(rect.size);
	        [editedImage drawInRect:rect];
	        editedImage = UIGraphicsGetImageFromCurrentImageContext();
	        
	        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	        imageButton.frame = CGRectMake(10, 10, 64, 96);
	        [imageButton setImage:editedImage forState:UIControlStateNormal];
	        [self.view addSubview:imageButton];
	        [imageButton addTarget:self action:@selector(imageAction:)forControlEvents:UIControlEventTouchUpInside];
	        [ipc dismissModalViewControllerAnimated:YES];
	    } else {
	        NSLog(@"MEdia");
	    }
    
上面的代码是当从相册里面选取图片之后保存到本地程序沙盒，在上面我们得到的图片中不能够得到图片名字，
以及不清楚图片格式，所以这个时候我们需要将其转换成NSdata二进制存储，

	 image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	NSData *data;
	        if (UIImagePNGRepresentation(image) == nil) {
	            data = UIImageJPEGRepresentation(image, 1);
	        } else {
	            data = UIImagePNGRepresentation(image);
	        }
	UIImagePNGRepresentation转换PNG格式的图片为二进制，如果图片的格式为JPEG则返回nil；
	 [fileManager createFileAtPath:[filePath stringByAppendingString:@"/image.png"] contents:data attributes:nil];    将图片保存为PNG格式
	 [fileManager createFileAtPath:[filePath stringByAppendingString:@"/image.jpg"] contents:data attributes:nil];   将图片保存为JPEG格式
	我们也可以写成下面的格式存储图片
	NSString *pngImage = [filePath stringByAppendingPathComponent:@"Documents/image.png"];
	NSString *jpgImage = [filePath stringByAppendingPathComponent:@"Documents/image.jpg"];
	[data writeToFile:pngImage atomically:YES];
	[data writeToFile:jpgImage atomically:YES];

##图片保存&上传


保存：

	- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
	
	　　{
	
	　　NSData* imageData = UIImagePNGRepresentation(tempImage);
	
	　　NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	　　NSString* documentsDirectory = [paths objectAtIndex:0];
	
	　　// Now we get the full path to the file
	
	　　NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
	
	　　// and then we write it out
	
	　　[imageData writeToFile:fullPathToFile atomically:NO];
	
	　　}
	
	
上传：


	- (void) imageUpload:(UIImage *) image{
	
	//把图片转换成imageDate格式
	
	NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
	
	//传送路径
	
	NSString *urlString = @"http://＊＊＊＊＊/test/upload.php";
	
	//建立请求对象
	
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
	
	//设置请求路径
	
	[request setURL:[NSURL URLWithString:urlString]];
	
	//请求方式
	
	[request setHTTPMethod:@"POST"];
	
	//一连串上传头标签
	
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary]dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name="userfile"; filename="vim_go.jpg"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[NSData dataWithData:imageData]];
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary]dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
	
	//上传文件开始
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	//获得返回值
	
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	NSLog(@"%@",returnString);
	
	}
