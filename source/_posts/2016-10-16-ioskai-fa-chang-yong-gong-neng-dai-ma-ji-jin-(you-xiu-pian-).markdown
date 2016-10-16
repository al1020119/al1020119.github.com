---
layout: post
title: "iOS开发——常用功能代码集锦（友秀篇）"
date: 2016-10-16 12:47:16 +0800
comments: true
categories: 
---


本次总结，是因为一次上线App被拒之后的冲动，因为有一个功能代码自己之前经常写，但是写多了就快，搞得手速练得超快（不要想污咯哦😂），所以写的时候就没有多想，也没有找找之前的代码，结果导致悲催的结局。

之前没有整理过项目中遇到或者写过，或者经常要用的代码，可能觉得多写几遍就没事了，或者网上一找就有了。可是事实并非如果，首先，网上找的永远不是你的。其次，写得再多还是有粗心或者注意不到的地方。最后，整理成自己的能最快速度的找到并实现，提高效率。何乐而不为呢？

好了，废话不多说，理论也没有，大部分只要两个操作：copy-paste。有些还是需要做小小的改动的，根据项目需求。


<!--more-->



1. 取消tableView头部和底部悬浮效果
2. 获取随机数
3. 去除tableView分组头部多余间距
4. 图片截取
5. 模糊图片
6. 获取文件大小
7. 手机号验证
8. 邮箱验证
9. 网址验证
10. JSON转字典
11. iPhone设备类型判断
12. iPhone系统版本判断
13. 日志打印
14. 颜色获取
15. 弱引用
16. 获取屏幕尺寸
17. 获取view的控制
18. 字典防崩溃
19. 数组防崩溃
20. 本文输入错误提示
21. 获取当前时间
22. 获取当前版本
23. tabBar红点显示
24. Log日志.m
25. MD5加密
26. 按钮背景颜色
27. 判断对象是否为空
28. 键盘退出与隐藏通知
29. 获取设备唯一ID
30. MOV转Mp4
31. 上传图片
32. 上传视频
33. 获取视频帧图
34. 压缩并导出视频
35. 保存视频到相册
36. 获取当前最顶层的ViewController
37. 数组拆分
38. 图片压缩

<!--more-->

##1：取消tableView头部和底部悬浮效果

    - (void)scrollViewDidScroll:(UIScrollView *)scrollView {  
        CGFloat sectionHeaderHeight = 10; //这里是我的headerView和footerView的高度  
        if (_tableView.contentOffset.y<=sectionHeaderHeight&&_tableView.contentOffset.y>=0) {  
            _tableView.contentInset = UIEdgeInsetsMake(-_tableView.contentOffset.y, 0, 0, 0);  
        } else if (_tableView.contentOffset.y>=sectionHeaderHeight) {  
            _tableView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);  
        }  
    }  
    
    
	    -(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	    if (scrollView == self.tableView)
	
	        {
	
	        UITableView *tableview = (UITableView *)scrollView;
	
	        CGFloat sectionHeaderHeight = 64;
	
	        CGFloat sectionFooterHeight = 120;
	
	        CGFloat offsetY = tableview.contentOffset.y;
	
	        if (offsetY >= 0 && offsetY <= sectionHeaderHeight)
	
	        {
	
	            tableview.contentInset = UIEdgeInsetsMake(-offsetY, 0, -sectionFooterHeight, 0);
	
	        }else if (offsetY >= sectionHeaderHeight && offsetY <= tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight)
	
	        {
	
	            tableview.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, -sectionFooterHeight, 0);
	
	        }else if (offsetY >= tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight && offsetY <= tableview.contentSize.height - tableview.frame.size.height)         {
	
	            tableview.contentInset = UIEdgeInsetsMake(-offsetY, 0, -(tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight), 0);
	
	        }
	
	    }
	
	}
##2：获取随机数

	//第一种
	srand((unsigned)time(0)); //不加这句每次产生的随机数不变
	int i = rand() % 5;
	//第二种
	srandom(time(0));
	int i = random() % 5;
	//第三种
	int i = arc4random() % 5 ; 

##3：去除tableView分组头部多余间距

####一：

	- (void)viewDidLoad {
	    [super viewDidLoad];
	    
	    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
	}

####二：

	- (void)viewWillAppear:(BOOL)animated{
	    
	    [super viewWillAppear:animated];
	    
	    CGRect frameH = self.tableView.tableHeaderView.frame;
	    frameH.size.height = 5;
	    UIView *headerView = [[UIView alloc] initWithFrame:frameH];
	    [self.tableView setTableHeaderView:headerView];
	    
	    
	    CGRect frameF = self.tableView.tableHeaderView.frame;
	    frameF.size.height = 1;
	    UIView *footerView = [[UIView alloc] initWithFrame:frameF];
	    [self.tableView setTableFooterView:footerView];
	    
	}

##4：图片截取

    CGSize itemSize = CGSizeMake(self.image.size.width, self.image.size.height);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *dynamicCellImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.cover]]];
                UIGraphicsBeginImageContextWithOptions(itemSize, NO, [UIScreen mainScreen].scale);
                
                //压缩图片
                CGSize newSize;
                CGImageRef imageRef = nil;
                
                if ((dynamicCellImage.size.width / dynamicCellImage.size.height) < (self.image.size.width / self.image.size.height)) {
                    newSize.width = dynamicCellImage.size.width;
                    newSize.height = dynamicCellImage.size.width * self.image.size.height / self.image.size.width;
                    
                    imageRef = CGImageCreateWithImageInRect([dynamicCellImage CGImage], CGRectMake(0, fabs(dynamicCellImage.size.height - newSize.height) / 2, newSize.width, newSize.height));
                    
                } else {
                    newSize.height = dynamicCellImage.size.height;
                    newSize.width = dynamicCellImage.size.height * self.image.size.width / self.image.size.height;
                    
                    imageRef = CGImageCreateWithImageInRect([dynamicCellImage CGImage], CGRectMake(fabs(dynamicCellImage.size.width - newSize.width) / 2, 0, newSize.width, newSize.height));
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image.image = [UIImage imageWithCGImage:imageRef];
                });
                
                UIGraphicsEndImageContext();

    });
    
    
##5：模糊图片

	//加模糊效果，image是图片，blur是模糊度
	+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
	    //模糊度,
	    if ((blur < 0.1f) || (blur > 2.0f)) {
	        blur = 0.5f;
	    }
	    
	    //boxSize必须大于0
	    int boxSize = (int)(blur * 100);
	    boxSize -= (boxSize % 2) + 1;
	//    iCocosLog(@"boxSize:%i",boxSize);
	    //图像处理
	    CGImageRef img = image.CGImage;
	    
	    //图像缓存,输入缓存，输出缓存
	    vImage_Buffer inBuffer, outBuffer;
	    vImage_Error error;
	    //像素缓存
	    void *pixelBuffer;
	    
	    //数据源提供者，Defines an opaque type that supplies Quartz with data.
	    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
	    // provider’s data.
	    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
	    
	    //宽，高，字节/行，data
	    inBuffer.width = CGImageGetWidth(img);
	    inBuffer.height = CGImageGetHeight(img);
	    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
	    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
	    
	    //像数缓存，字节行*图片高
	    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
	    
	    outBuffer.data = pixelBuffer;
	    outBuffer.width = CGImageGetWidth(img);
	    outBuffer.height = CGImageGetHeight(img);
	    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
	    
	    
	    // 第三个中间的缓存区,抗锯齿的效果
	    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
	    vImage_Buffer outBuffer2;
	    outBuffer2.data = pixelBuffer2;
	    outBuffer2.width = CGImageGetWidth(img);
	    outBuffer2.height = CGImageGetHeight(img);
	    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
	    
	    
	    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
	    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
	    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
	    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
	    
	    if (error) {
	        iCocosLog(@"error from convolution %ld", error);
	    }
	    
	    //    iCocosLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
	    //颜色空间DeviceRGB
	    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
	    CGContextRef ctx = CGBitmapContextCreate(
	                                             outBuffer.data,
	                                             outBuffer.width,
	                                             outBuffer.height,
	                                             8,
	                                             outBuffer.rowBytes,
	                                             colorSpace,
	                                             CGImageGetBitmapInfo(image.CGImage));
	    
	    //根据上下文，处理过的图片，重新组件
	    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
	    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
	    
	    //clean up
	    CGContextRelease(ctx);
	    CGColorSpaceRelease(colorSpace);
	    
	    free(pixelBuffer);
	    free(pixelBuffer2);
	    CFRelease(inBitmapData);
	    
	    CGColorSpaceRelease(colorSpace);
	    CGImageRelease(imageRef);
	    
	    return returnImage;
	}

##6：文件大小

	/**
	 *  通常用于删除缓存的时，计算缓存大小
	 */
	//单个文件的大小
	+ (long long) fileSizeAtPath:(NSString*) filePath{
	    NSFileManager* manager = [NSFileManager defaultManager];
	    if ([manager fileExistsAtPath:filePath]){
	        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
	    }
	    return 0;
	}
	
##7：手机号

	/**
	 *  手机号判断
	 *
	 *  @param mobileNum 号码字符串
	 *
	 *  @return BOOL
	 */
	+ (BOOL)isMobileNumber:(NSString *)mobileNum
	{
	        /**
	         * 移动号段正则表达式
	         */
	        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
	        /**
	         * 联通号段正则表达式
	         */
	        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
	        /**
	         * 电信号段正则表达式
	         */
	        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
	    
	        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
	        BOOL isMatch1 = [pred1 evaluateWithObject:mobileNum];
	        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
	        BOOL isMatch2 = [pred2 evaluateWithObject:mobileNum];
	        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
	        BOOL isMatch3 = [pred3 evaluateWithObject:mobileNum];
	        
	        if (isMatch1 || isMatch2 || isMatch3) {
	            return YES;
	        }else{
	            return NO;
	        }
	}

##8：邮箱


####通过区分字符串
	
	-(BOOL)validateEmail:(NSString*)email
	
	{
	
	    if((0 != [email rangeOfString:@"@"].length) &&
	
	       (0 != [email rangeOfString:@"."].length))
	
	    {
	
	        NSCharacterSet* tmpInvalidCharSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	
	        NSMutableCharacterSet* tmpInvalidMutableCharSet = [[tmpInvalidCharSet mutableCopy] autorelease];
	
	        [tmpInvalidMutableCharSet removeCharactersInString:@"_-"];
	
	        
	
	       
	
	        NSRange range1 = [email rangeOfString:@"@"
	
	                                      options:NSCaseInsensitiveSearch];
	
	        
	
	        //取得用户名部分
	
	        NSString* userNameString = [email substringToIndex:range1.location];
	
	        NSArray* userNameArray   = [userNameString componentsSeparatedByString:@"."];
	
	        
	
	        for(NSString* string in userNameArray)
	
	        {
	
	            NSRange rangeOfInavlidChars = [string rangeOfCharacterFromSet: tmpInvalidMutableCharSet];
	
	            if(rangeOfInavlidChars.length != 0 || [string isEqualToString:@""])
	
	                return NO;
	
	        }
	
	        
	
	        //取得域名部分
	
	        NSString *domainString = [email substringFromIndex:range1.location+1];
	
	        NSArray *domainArray   = [domainString componentsSeparatedByString:@"."];
	
	        
	
	        for(NSString *string in domainArray)
	
	        {
	
	            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:tmpInvalidMutableCharSet];
	
	            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
	
	                return NO;
	
	        }
	
	        
	
	        return YES;
	
	    }
	
	    else {
	
	       return NO;
	
	    }
	
	}


####利用正则表达式验证

	-(BOOL)isValidateEmail:(NSString *)email {
	
	    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
	
	    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
	    return [emailTest evaluateWithObject:email];
	
	}

##9：网址
####1.首先进行第一步判断传入的字符串是否符合HTTP路径的语法规则,即”HTTPS://” 或 “HTTP://” ,从封装的一个函数,传入即可判断

	- (NSURL *)smartURLForString:(NSString *)str
	{
	    NSURL *     result;
	    NSString *  trimmedStr;
	    NSRange     schemeMarkerRange;
	    NSString *  scheme;
	
	    assert(str != nil);
	
	    result = nil;
	
	    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
	        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
	
	        if (schemeMarkerRange.location == NSNotFound) {
	            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
	        } else {
	            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
	            assert(scheme != nil);
	
	            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
	                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
	                result = [NSURL URLWithString:trimmedStr];
	            } else {
	                // It looks like this is some unsupported URL scheme.
	            }
	        }
	    }
	
	    return result;
	}

####第二步,判断此路径是否能够请求成功,直接进行HTTP请求,观察返回结果->

	//判断
	-(void) validateUrl: (NSURL *) candidate {
	    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:candidate];
	    [request setHTTPMethod:@"HEAD"];
	    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
	        NSLog(@"error %@",error);
	        if (error) {
	            NSLog(@"不可用");
	        }else{
	            NSLog(@"可用");
	        }
	    }];
	    [task resume];
	}
##10：JSON转字典


	/*!
	 * @brief 把格式化的JSON格式的字符串转换成字典
	 * @param jsonString JSON格式的字符串
	 * @return 返回字典
	 */
	- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
	    if (jsonString == nil) {
	        return nil;
	    }
	    iCocosLog(@"%@", jsonString);
	    
	    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	    NSError *err;
	    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
	                                                        options:NSJSONReadingMutableContainers
	                                                          error:&err];
	    if(err) {
	        iCocosLog(@"json解析失败：%@",err);
	        return nil;
	    }
	    return dic;
	}

####数组转JSON

    	NSArray *uids = [self.allModelUID objectAtIndexCheck:range];

        NSError *error = nil;
        NSData *picsJsonData = [NSJSONSerialization dataWithJSONObject:uids
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
        NSString *JSONString = [[NSString alloc] initWithData:picsJsonData encoding:NSUTF8StringEncoding];


##11：iPhone设备类型

	typedef NS_ENUM(char, iPhoneModel){//0~3
	    iPhone4,//320*480
	    iPhone5,//320*568
	    iPhone6,//375*667
	    iPhone6Plus,//414*736
	    UnKnown
	};
	
	
	
	/**
	 *  return current running iPhone model
	 *
	 *  @return iPhone model
	 */
	+ (iPhoneModel)iPhonesModel {
	    //bounds method gets the points not the pixels!!!
	    CGRect rect = [[UIScreen mainScreen] bounds];
	    
	    CGFloat width = rect.size.width;
	    CGFloat height = rect.size.height;
	    
	    //get current interface Orientation
	    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	    //unknown
	    if (UIInterfaceOrientationUnknown == orientation) {
	        return UnKnown;
	    }
	    /**
	     //    portrait   width * height
	     //    iPhone4:320*480
	     //    iPhone5:320*568
	     //    iPhone6:375*667
	     //    iPhone6Plus:414*736
	     */
	    
	    //portrait
	    if (UIInterfaceOrientationPortrait == orientation) {
	        if (width ==  320.0f) {
	            if (height == 480.0f) {
	                return iPhone4;
	            } else {
	                return iPhone5;
	            }
	        } else if (width == 375.0f) {
	            return iPhone6;
	        } else if (width == 414.0f) {
	            return iPhone6Plus;
	        }
	    } else if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {//landscape
	        if (height == 320.0) {
	            if (width == 480.0f) {
	                return iPhone4;
	            } else {
	                return iPhone5;
	            }
	        } else if (height == 375.0f) {
	            return iPhone6;
	        } else if (height == 414.0f) {
	            return iPhone6Plus;
	        }
	    }
	    
	    return UnKnown;
	}


##12：iPhone系统版本

	//获取当前系统版本
	#define __ios10_0__ ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)
	#define __ios9_0__ ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
	#define __ios8_0__ ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

##13：日志

	// 日志输出
	#ifdef DEBUG // 开发阶段-DEBUG阶段:使用Log
	#define iCocosLog(...) NSLog(__VA_ARGS__)
	#else // 发布阶段-上线阶段:移除Log
	#define iCocosLog(...)
	#endif

详细


	#ifdef DEBUG
	#define iCocosLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
	#else
	#define iCocosLog(format, ...)
	#endif


##14：颜色

	// 颜色
	#define iCocosARGBColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
	#define iCocosColor(r, g, b) iCocosARGBColor((r), (g), (b), 255)


	#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
	#define iCocosRandomColor (random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256)))

##15：弱引用

	// 弱引用
	#define iCocosWeakSelf __weak typeof(self) weakSelf = self;
##16：屏幕尺寸

	// 屏幕尺寸
	#define iCocosScreenH [UIScreen mainScreen].bounds.size.height
	#define iCocosScreenW [UIScreen mainScreen].bounds.size.width
	
	
##17：获取view的控制

	/** 获取当前View的控制器对象 */
	-(UIViewController *)getCurrentViewController{
	    UIResponder *next = [self nextResponder];
	    do {
	        if ([next isKindOfClass:[UIViewController class]]) {
	            return (UIViewController *)next;
	        }
	        next = [next nextResponder];
	    } while (next != nil);
	    return nil;
	}


##18：字典防蹦

####不可变

	/*!
	 @method objectAtIndexCheck:
	 @abstract 检查是否越界和NSNull如果是返回nil
	 @result 返回对象
	 */
	- (id)objectStringForKey:(NSString *)key
	{
	    if ([self objectForKey:key] == nil) {
	//        iCocosLog(@"键值对不存在");
	        return nil;
	    }
	    id value = [self objectForKey:key];
	      
	    return value;
	}


####可变

	/*!
	 @method objectAtIndexCheck:
	 @abstract 检查是否越界和NSNull如果是返回nil
	 @result 返回对象
	 */
	- (id)objectStringForKey:(NSString *)key
	{
	    if ([self objectForKey:key] == nil) {
	        
	//        iCocosLog(@"键值对不存在");
	        
	        return nil;
	//        return 0;
	    }
	    id value = [self objectForKey:key];
	    
	    return value;
	}


##19：数组防蹦

####不可变

	/*!
	 @method objectAtIndexCheck:
	 @abstract 检查是否越界和NSNull如果是返回nil
	 @result 返回对象
	 */
	- (id)objectAtIndexCheck:(NSUInteger)index  {
	    
	    if (index >= [self count]) {
	        iCocosLog(@"数组越界");
	        return nil;
	    }
	    id value = [self objectAtIndex:index];
	    if (value == [NSNull null]) {
	        iCocosLog(@"数组为空");
	        return nil;
	    }
	    return value;
	}


####可变

	/*!
	 @method objectAtIndexCheck:
	 @abstract 检查是否越界和NSNull如果是返回nil
	 @result 返回对象
	 */
	- (id)objectAtIndexCheck:(NSUInteger)index  {
	    
	    if (index >= [self count]) {
	        iCocosLog(@"数组越界");
	        return nil;
	    }
	    id value = [self objectAtIndex:index];
	    if (value == [NSNull null]) {
	        iCocosLog(@"数组为空");
	        return nil;
	    }
	    return value;
	}



	- (void)removeObjectAtCheckIndex:(NSInteger)index
	{
	    if (index >= [self count]) {
	        iCocosLog(@"数组越界");
	        return ;
	    }
	    id value = [self objectAtIndex:index];
	    if (value == [NSNull null]) {
	        iCocosLog(@"数组为空");
	        return ;
	    }
	    
	    [self removeObjectAtIndex:index];
	    
	}

##20：本文输入错误提示

	- (void)shake {
	    CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
	    keyFrame.duration = 0.3;
	    CGFloat x = self.layer.position.x;
	    keyFrame.values = @[@(x - 30), @(x - 30), @(x + 20), @(x - 20), @(x + 10), @(x - 10), @(x + 5), @(x - 5)];
	    [self.layer addAnimation:keyFrame forKey:@"shake"];
	
	}


##21：当前时间

	+ (NSString *)nowTimes{
	    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
	    int a=(int)([dat timeIntervalSince1970] + 0.5);
	    NSString *timeString = [NSString stringWithFormat:@"%d", a];//转为字符型
	    return timeString;
	}


##22:当前版本

	/*
	 *  当前程序的版本号
	 */
	-(NSString *)version{
	    //系统直接读取的版本号
	    NSString *versionValueStringForSystemNow=[[NSBundle mainBundle].infoDictionary valueForKey:(NSString *)kCFBundleVersionKey];
	    return versionValueStringForSystemNow;
	}

##23:tabBar红点


	- (void)showBadgeOnItemIndex:(int)index{
	    
	    //移除之前的小红点
	    [self removeBadgeOnItemIndex:index];
	    
	    //新建小红点
	    UIView *badgeView = [[UIView alloc]init];
	    badgeView.tag = 888 + index;
	    badgeView.backgroundColor = [UIColor redColor];
	    CGRect tabFrame = self.frame;
	    
	    //确定小红点的位置
	    float percentX = (index +0.6) / TabbarItemNums;
	    CGFloat x = ceilf(percentX * tabFrame.size.width);
	    CGFloat y = ceilf(0.1 * tabFrame.size.height);
	    badgeView.frame = CGRectMake(x, y, 8, 8);
	    badgeView.layer.cornerRadius = badgeView.frame.size.width/2;
	    
	    [self addSubview:badgeView];
	    
	}
	
	- (void)hideBadgeOnItemIndex:(int)index{
	    
	    //移除小红点
	    [self removeBadgeOnItemIndex:index];
	    
	}
	
	- (void)removeBadgeOnItemIndex:(int)index{
	    
	    //按照tag值进行移除
	    for (UIView *subView in self.subviews) {
	        if (subView.tag == 888+index) {
	            [subView removeFromSuperview];
	        }
	    }
	}


##24:Log日志.m

	@implementation UIView(Log)
	+ (NSString *)searchAllSubviews:(UIView *)superview
	{
	    NSMutableString *xml = [NSMutableString string];
	    
	    NSString *class = NSStringFromClass(superview.class);
	    class = [class stringByReplacingOccurrencesOfString:@"_" withString:@""];
	    [xml appendFormat:@"<%@ frame=\"%@\">\n", class, NSStringFromCGRect(superview.frame)];
	    for (UIView *childView in superview.subviews) {
	        NSString *subviewXml = [self searchAllSubviews:childView];
	        [xml appendString:subviewXml];
	    }
	    [xml appendFormat:@"</%@>\n", class];
	    return xml;
	}
	
	- (NSString *)description
	{
	    return [UIView searchAllSubviews:self];
	}
	@end
	
	@implementation NSDictionary (Log)
	- (NSString *)descriptionWithLocale:(id)locale
	{
	    NSMutableString *str = [NSMutableString string];
	    
	    [str appendString:@"{\n"];
	    
	    // 遍历字典的所有键值对
	    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
	        [str appendFormat:@"\t%@ = %@,\n", key, obj];
	    }];
	    
	    [str appendString:@"}"];
	    
	    // 查出最后一个,的范围
	    NSRange range = [str rangeOfString:@"," options:NSBackwardsSearch];
	    if (range.length) {
	        // 删掉最后一个,
	        [str deleteCharactersInRange:range];
	    }
	    
	    return str;
	}
	@end
	
	@implementation NSArray (Log)
	- (NSString *)descriptionWithLocale:(id)locale
	{
	    NSMutableString *str = [NSMutableString string];
	    
	    [str appendString:@"[\n"];
	    
	    // 遍历数组的所有元素
	    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
	        [str appendFormat:@"%@,\n", obj];
	    }];
	    
	    [str appendString:@"]"];
	    
	    // 查出最后一个,的范围
	    NSRange range = [str rangeOfString:@"," options:NSBackwardsSearch];
	    if (range.length) {
	        // 删掉最后一个,
	        [str deleteCharactersInRange:range];
	    }
	    
	    return str;
	}
	@end

##25:MD5

	//16位MD5加密方式
	- (NSString *)getMd5_16Bit_String:(NSString *)srcString{
	    //提取32位MD5散列的中间16位
	    NSString *md5_32Bit_String=[self getMd5_32Bit_String:srcString];
	    NSString *result = [[md5_32Bit_String substringToIndex:24] substringFromIndex:8];//即9～25位
	    
	    return result;
	}
	
	
	//32位MD5加密方式
	- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
	    const char *cStr = [srcString UTF8String];
	    unsigned char digest[CC_MD5_DIGEST_LENGTH];
	    CC_MD5( cStr, strlen(cStr), digest );
	    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
	        [result appendFormat:@"%02x", digest[i]];
	    
	    return result;
	}


##26:按钮背景颜色


	/**
	 *  使用背景颜色设置按钮不同状态的图片
	 *
	 *  @param color 颜色
	 *
	 *  @return 背景图片
	 */
	+ (UIImage *)imageWithColor:(UIColor *)color {
	    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	    UIGraphicsBeginImageContext(rect.size);
	    CGContextRef context = UIGraphicsGetCurrentContext();
	    
	    CGContextSetFillColorWithColor(context, [color CGColor]);
	    CGContextFillRect(context, rect);
	    
	    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	    UIGraphicsEndImageContext();
	    
	    return image;
	}

##27：对象是否为空


	// 判断对象是否为空
	- (BOOL)isBlanceObject:(id)object{
	    if (object == nil || object == NULL) {
	        return YES;
	    }
	    if ([object isKindOfClass:[NSNull class]]) {
	        return YES;
	    }
	    return NO;
	}

##28：键盘退出与隐藏


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

	- (void)keyboardWillShow:(NSNotification *)notification {
	
	    // 获取通知的信息字典
	    NSDictionary *userInfo = [notification userInfo];
	
	    // 获取键盘弹出后的rect
	    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	    CGRect keyboardRect = [aValue CGRectValue];
	
	    // 获取键盘弹出动画时间
	    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	    NSTimeInterval animationDuration;
	    [animationDurationValue getValue:&animationDuration];
	
	}
	
	
	- (void)keyboardWillHide:(NSNotification *)notification {
	
	    // 获取通知信息字典
	    NSDictionary* userInfo = [notification userInfo];
	
	    // 获取键盘隐藏动画时间
	    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	    NSTimeInterval animationDuration;
	    [animationDurationValue getValue:&animationDuration];
	
	
	}

##29：获取设备唯一ID

-(NSString *)getUniqueDeviceIdentifierAsString
{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
 
    NSString *strApplicationUUID =  [SAMKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
 
        NSError *error = nil;
        SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
        query.service = appName;
        query.account = @"incoding";
        query.password = strApplicationUUID;
        query.synchronizationMode = SAMKeychainQuerySynchronizationModeNo;
        [query save:&error];
 
    }
 
    return strApplicationUUID;
}

##30：MOV转Mp4


	- (void)movFileTransformToMP4WithSourceUrl:(NSURL *)sourceUrl completion:(void(^)(NSString *Mp4FilePath))comepleteBlock
	{
	    /**
	     *  mov格式转mp4格式
	     */
	    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
	    
	    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
	    
	    NSLog(@"%@",compatiblePresets);
	    
	    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
	        
	        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
	        
	        
	        NSDate *date = [NSDate date];
	        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	        [formatter setDateFormat:@"yyyyMMddHHmmss"];
	        NSString *uniqueName = [NSString stringWithFormat:@"%@.mp4",[formatter stringFromDate:date]];
	        NSString * resultPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:uniqueName];//PATH_OF_DOCUMENT为documents路径
	        
	        NSLog(@"output File Path : %@",resultPath);
	        
	        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
	        
	        exportSession.outputFileType = AVFileTypeMPEG4;//可以配置多种输出文件格式
	        
	        exportSession.shouldOptimizeForNetworkUse = YES;
	        
	        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
	         {
	             switch (exportSession.status) {
	                     
	                 case AVAssetExportSessionStatusUnknown:
	                     
	                     break;
	                     
	                 case AVAssetExportSessionStatusWaiting:
	                     
	                     break;
	                     
	                 case AVAssetExportSessionStatusExporting:
	                     
	                     break;
	                     
	                 case AVAssetExportSessionStatusCompleted:
	                 {
	                     comepleteBlock(resultPath);
	                     
	                     
	                     NSLog(@"mp4 file size:%lf MB",[NSData dataWithContentsOfURL:exportSession.outputURL].length/1024.f/1024.f);
	                 }
	                     break;
	                     
	                 case AVAssetExportSessionStatusFailed:
	                     
	                     break;
	                     
	                 case AVAssetExportSessionStatusCancelled:
	                     
	                     break;
	                     
	             }  
	             
	         }];
	    }  
	}


##31:上传图片


	+ (void)uploadImage:(UIImage *)imageIcon successUpload:(void (^)(id responseObject))successUpload failureUpload:(void (^)(NSError *error))failureUpload;
	{
	    
	    //    拿到文件
	    NSString *NSDocmentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
	    NSString *iconPath       = [NSDocmentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"faceUrl.png"]];
	    //NSURL *url = [NSURL fileURLWithPath:iconPath];
	    
	    long long size = [iCocosGetSize fileSizeAtPath:iconPath];
	    
	    if (size >= 7000000) {
	        [SVProgressHUD showInfoWithStatus:@"图片过大，请重新上传 \n 请不要上传超过7Mb文件"];
	        NSDictionary *errDict = [NSDictionary dictionaryWithObject:@"big" forKey:@"state"];
	        failureUpload((NSError *)errDict);
	        return;
	    }
	    
	    //1:文件的32位MD5值
	    NSString *strForEight = [iCocosFormatFileGetEight getStringWithEight:iconPath];
	    //2:文件的前8个字节的16位+文件的后8个字节的16位
	    NSString *str32MD5    = [NSString getMd5_32Bit_String:iconPath];
	    
	    NSString *str64       = [NSString stringWithFormat:@"%@%@", str32MD5,strForEight];
	    
	    //存图片
	    //    NSData *imageData = UIImageJPEGRepresentation(imageIcon, 1.0);//将UIImage转为NSData，1.0表示不压缩图片质量。
	    NSData *imageData = [iCocosFileCondenseTools resetSizeOfImageData:imageIcon maxSize:50];
	    
	    
	    [imageData writeToFile:iconPath atomically:YES];
	    
	    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
	    
	    //    NSString *urlStrIF        = [NSString stringWithFormat:@"%@file/exist%@", [iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl, [iCocosURLRequestExtension getURLRequestExtension]];
	    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	    //文件的32位MD5+前8个字节的16位+后8个字节的16位
	    dict[@"file_md5"] = str64;
	    dict[@"is_blur"] = @(1);
	    dict[@"file_size"] = @([iCocosGetSize fileSizeAtPath:iconPath]);
	    dict[@"ext"] = @"png";
	    
	    /**
	     *  超时时间
	     */
	    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
	    manager.requestSerializer.timeoutInterval = 10.f;
	    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
	    
	    //    [manager POST:urlStrIF parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
	    
	    [iCocosAFNPOSTRequestData iCocos_POST_HostSecurity:@"file/exist" hostHeaderValue:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileHost firstRequestWithUrl:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl secondRequestWithIp:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileIp params:dict success:^(id response) {
	        
	        NSString *state = [NSString stringWithFormat:@"%@", [response objectStringForKey:@"state"]];
	        NSString *msg= [NSString stringWithFormat:@"%@", [response objectStringForKey:@"msg"]];
	        if ([state isEqualToString:@"0"]) {
	            NSString *exist = [NSString stringWithFormat:@"%@", [[response objectStringForKey:@"data"] objectStringForKey:@"exist"]];
	            /**
	             *  注意这里需要换成真实服务器地址
	             */
	            if ([exist isEqualToString:@"0"]) { //不存在就需要发送请求
	                NSString *imageUrl          = [NSString stringWithFormat:@"%@file/up%@", [iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl,[iCocosURLRequestExtension getURLRequestExtension]];
	                NSMutableDictionary *params = [NSMutableDictionary dictionary];
	                params[@"blur"]          = @(1);
	                
	                
	                AFHTTPSessionManager *mger = [AFHTTPSessionManager manager];
	                
	                AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
	                response.removesKeysWithNullValues = YES;
	                manager.responseSerializer = response;
	                
	                manager.requestSerializer = [AFHTTPRequestSerializer serializer];//响应
	                
	                
	                
	                mger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"image/png", @"text/html", nil];
	                
	                /**
	                 *  超时时间
	                 */
	                [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
	                manager.requestSerializer.timeoutInterval = 10.f;
	                [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
	                
	                
	                [mger POST:imageUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
	                    // 上传文件
	                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	                    formatter.dateFormat       = @"yyyyMMddHHmmss";
	                    NSString *str              = [formatter stringFromDate:[NSDate date]];
	                    NSString *fileName         = [NSString stringWithFormat:@"%@.png", str];
	                    
	                    [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
	                    
	                } progress:^(NSProgress * _Nonnull uploadProgress) {
	                    
	                    iCocosLog(@"封面图片================%@", uploadProgress);
	                    
	                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
	                    
	                    NSDictionary *dataDic    = [responseObject objectStringForKey:@"data"]; 
	                    
	                    
	                    successUpload(dataDic);
	                    
	                    iCocosLog(@"%@", responseObject);
	                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
	                    iCocosLog(@"上传错误:%@", error);
	                    
	                    failureUpload(error);
	                }];
	                
	            } else {
	                
	                NSDictionary *dataDic    = [response objectStringForKey:@"data"];
	                
	                successUpload(dataDic);
	            }
	            
	        } else {
	            successUpload(response);
	        }
	    } failure:^(NSError *error) {
	        failureUpload(error);
	    }];
	
	}


##32：上传视频

####上传MOV

	+ (void)updateMOVVideo:(NSURL *)url successUpload:(void (^)(id responseObject))successUpload failureUpload:(void (^)(NSError *error))failureUpload;
	{
	    //保存数据
	    //    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
	    //    NSURL *url = [defaults URLForKey:@"RecordVideoUrl"];
	    
	    NSData *videoData = [NSData dataWithContentsOfURL:url];
	    
	    //   NSString *videoUrl = [iCocosUpLoadVideoTools upLoadVideoGetVideoUrlWithFileUrlInSandbox:url];
	    
	    //    NSString *strUrl = [NSString stringWithContentsOfURL:url usedEncoding:0 error:nil];
	    
	    //    //1:文件的32位MD5值
	    //    NSString *strForEight = [iCocosFormatFileGetEight getStringWithEight:strUrl];
	    //
	    //    //2:文件的前8个字节的16位+文件的后8个字节的16位
	    //    NSString *str32MD5 = [NSString getMd5_32Bit_String:strUrl];
	    
	    NSString *str32MD5 = [iCocosRandomSix getSixRandom];
	    
	    NSString *str64 = [NSString stringWithFormat:@"%@%@", str32MD5,str32MD5];
	    
	    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
	    
	    //    NSString *urlStrIF = [NSString stringWithFormat:@"%@file/exist%@", [iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl, [iCocosURLRequestExtension getURLRequestExtension]];
	    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	    dict[@"file_md5"] = str64;
	    dict[@"is_blur"] = 0;
	    dict[@"file_size"] = @([iCocosGetSize fileSizeAtPath:[url absoluteString]]);
	    dict[@"ext"] = @"MOV";
	    
	    /**
	     *  超时时间
	     */
	    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
	    manager.requestSerializer.timeoutInterval = 10.f;
	    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
	    
	    /** 获取视频是否上传 */
	    //    [manager POST:urlStrIF parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
	    
	    [iCocosAFNPOSTRequestData iCocos_POST_HostSecurity:@"file/exist" hostHeaderValue:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileHost firstRequestWithUrl:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl secondRequestWithIp:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileIp params:dict success:^(id response) {
	        
	        NSString *state = [NSString stringWithFormat:@"%@", [response objectStringForKey:@"state"]];
	        if ([state isEqualToString:@"0"]) {
	            NSString *exist = [response objectStringForKey:@"exist"];
	            /**
	             *  注意这里需要换成真实服务器地址
	             */
	            if (exist == 0) { //不存在就需要发送请求
	                NSString *vidUrl = [NSString stringWithFormat:@"%@file/up%@", [iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl, [iCocosURLRequestExtension getURLRequestExtension]];
	                NSMutableDictionary *params = [NSMutableDictionary dictionary];
	                //            params[@"name:file"] = @""; //Content-Disposition: form-data; name="file"; filename="1.txt"
	                params[@"is_blur"] = @0;
	                params[@"need_mp4"] = @1;
	                AFHTTPSessionManager *mger = [AFHTTPSessionManager manager];
	                
	                AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
	                response.removesKeysWithNullValues = YES;
	                manager.responseSerializer = response;
	                
	                manager.requestSerializer = [AFHTTPRequestSerializer serializer];//响应
	                
	                
	                [mger.securityPolicy setAllowInvalidCertificates:YES];
	                
	                /** 上传视频 */
	                [mger POST:vidUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
	                    
	                    // 上传文件
	                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	                    formatter.dateFormat = @"yyyyMMddHHmmss";
	                    NSString *str = [formatter stringFromDate:[NSDate date]];
	                    NSString *fileName = [NSString stringWithFormat:@"%@.mov", str];
	                    
	                    if (videoData != nil) {
	                        [formData appendPartWithFileData:videoData name:@"file" fileName:fileName mimeType:@"video/quicktime"];
	                    } else {
	                        
	                    }
	                    
	                } progress:^(NSProgress * _Nonnull uploadProgress) {
	                    
	//                    iCocosLog(@"%@", uploadProgress);
	                    
	                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
	                    
	                    NSString *state = [NSString stringWithFormat:@"%@", [responseObject objectStringForKey:@"state"]];
	                    if ([state isEqualToString:@"0"]) {
	                        
	                        NSDictionary *dataDic = [responseObject objectStringForKey:@"data"];
	                        
	                        successUpload(dataDic);
	                    }
	                    
	                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
	                    iCocosLog(@"上传错误:%@", error);
	                    failureUpload(error);
	                }];
	                
	            } else {
	                /**
	                 *  已经上传
	                 */
	                NSDictionary *dataDic    = [response objectStringForKey:@"data"];
	                NSString *file_url       = [NSString stringWithFormat:@"%@", [dataDic objectStringForKey:@"file_url"]];
	                NSString *mp4_file_url       = [NSString stringWithFormat:@"%@", [dataDic objectStringForKey:@"mp4_file_url"]];
	                
	                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	                [defaults setValue:file_url forKey:@"video_url"];
	                [defaults setValue:mp4_file_url forKey:@"mp4_file_url"];
	                [defaults synchronize];
	                
	                successUpload(dataDic);
	            }
	            
	        } else {
	            successUpload(response);
	        }
	    } failure:^(NSError *error) { //上传错误
	        failureUpload(error);
	    }];
	}
	
####上传MP4	
	
	+ (void)updateMP4Video:(NSURL *)url successUpload:(void (^)(id responseObject))successUpload failureUpload:(void (^)(NSError *error))failureUpload
	{
	    //保存数据
	    //    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
	    //    NSURL *url = [defaults URLForKey:@"RecordVideoUrl"];
	    
	    NSData *videoData = [NSData dataWithContentsOfURL:url];
	    
	    //   NSString *videoUrl = [iCocosUpLoadVideoTools upLoadVideoGetVideoUrlWithFileUrlInSandbox:url];
	    
	    //    NSString *strUrl = [NSString stringWithContentsOfURL:url usedEncoding:0 error:nil];
	    
	    //    //1:文件的32位MD5值
	    //    NSString *strForEight = [iCocosFormatFileGetEight getStringWithEight:strUrl];
	    //
	    //    //2:文件的前8个字节的16位+文件的后8个字节的16位
	    //    NSString *str32MD5 = [NSString getMd5_32Bit_String:strUrl];
	    
	    NSString *str32MD5 = [iCocosRandomSix getSixRandom];
	    
	    NSString *str64 = [NSString stringWithFormat:@"%@%@", str32MD5,str32MD5];
	    
	    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
	    
	    //    NSString *urlStrIF = [NSString stringWithFormat:@"%@file/exist%@", [iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl, [iCocosURLRequestExtension getURLRequestExtension]];
	    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	    dict[@"file_md5"] = str64;
	    dict[@"is_blur"] = 0;
	    dict[@"file_size"] = @([iCocosGetSize fileSizeAtPath:[url absoluteString]]);
	    dict[@"ext"] = @"mp4";
	    
	    /**
	     *  超时时间
	     */
	    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
	    manager.requestSerializer.timeoutInterval = 10.f;
	    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
	    
	    /** 获取视频是否上传 */
	    //    [manager POST:urlStrIF parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
	    
	    [iCocosAFNPOSTRequestData iCocos_POST_HostSecurity:@"file/exist" hostHeaderValue:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileHost firstRequestWithUrl:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl secondRequestWithIp:[iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileIp params:dict success:^(id response) {
	        
	        NSString *state = [NSString stringWithFormat:@"%@", [response objectStringForKey:@"state"]];
	        if ([state isEqualToString:@"0"]) {
	            NSString *exist = [response objectStringForKey:@"exist"];
	            /**
	             *  注意这里需要换成真实服务器地址
	             */
	            if (exist == 0) { //不存在就需要发送请求
	                NSString *vidUrl = [NSString stringWithFormat:@"%@file/up%@", [iCocosUrlOperationTools shareiCocosUrlOperationTools].iCocosFileUrl, [iCocosURLRequestExtension getURLRequestExtension]];
	                NSMutableDictionary *params = [NSMutableDictionary dictionary];
	                //            params[@"name:file"] = @""; //Content-Disposition: form-data; name="file"; filename="1.txt"
	                params[@"is_blur"] = @0;
	                params[@"need_mp4"] = @1;
	                AFHTTPSessionManager *mger = [AFHTTPSessionManager manager];
	                
	                AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
	                response.removesKeysWithNullValues = YES;
	                manager.responseSerializer = response;
	                
	                manager.requestSerializer = [AFHTTPRequestSerializer serializer];//响应
	                
	                
	                [mger.securityPolicy setAllowInvalidCertificates:YES];
	                
	                /** 上传视频 */
	                [mger POST:vidUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
	                    
	                    // 上传文件
	                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	                    formatter.dateFormat = @"yyyyMMddHHmmss";
	                    NSString *str = [formatter stringFromDate:[NSDate date]];
	                    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", str];
	                    
	                    if (videoData != nil) {
	                        [formData appendPartWithFileData:videoData name:@"file" fileName:fileName mimeType:@"video/mp4"];
	                    } else {
	                        
	                    }
	                    
	                } progress:^(NSProgress * _Nonnull uploadProgress) {
	                    
	                    
	//                    iCocosLog(@"%@", uploadProgress);
	                    
	                    
	                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
	                    
	                    NSString *state = [NSString stringWithFormat:@"%@", [responseObject objectStringForKey:@"state"]];
	                    if ([state isEqualToString:@"0"]) {
	                        
	                        NSDictionary *dataDic = [responseObject objectStringForKey:@"data"];
	                        
	                        successUpload(dataDic);
	                    }
	                    
	                    
	                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
	                    iCocosLog(@"上传错误:%@", error);
	                    failureUpload(error);
	                }];
	                
	            } else {
	                
	                /**
	                 *  已经上传
	                 */
	                NSDictionary *dataDic    = [response objectStringForKey:@"data"];
	                NSString *file_url       = [NSString stringWithFormat:@"%@", [dataDic objectStringForKey:@"file_url"]];
	                NSString *mp4_file_url       = [NSString stringWithFormat:@"%@", [dataDic objectStringForKey:@"mp4_file_url"]];
	                
	                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	                [defaults setValue:file_url forKey:@"video_url"];
	                [defaults setValue:mp4_file_url forKey:@"mp4_file_url"];
	                [defaults synchronize];
	                
	                successUpload(dataDic);
	            }
	            
	        } else {
	            successUpload(response);
	        }
	    } failure:^(NSError *error) { //上传错误
	        failureUpload(error);
	    }];
	}


##33:获取视频帧图

####同步获取帧图

同步获取中间帧，需要指定哪个时间点的帧，当获取到以后，返回来的图片对象是CFRetained过的，需要外面手动CGImageRelease一下，释放内存。通过AVAsset来访问具体的视频资源，然后通过AVAssetImageGenerator图片生成器来生成某个帧图片：
	// Get the video's center frame as video poster image
	- (UIImage *)frameImageFromVideoURL:(NSURL *)videoURL {
	  // result
	  UIImage *image = nil;
	  
	  // AVAssetImageGenerator
	  AVAsset *asset = [AVAsset assetWithURL:videoURL];
	  AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	  imageGenerator.appliesPreferredTrackTransform = YES;
	  
	  // calculate the midpoint time of video
	  Float64 duration = CMTimeGetSeconds([asset duration]);
	  // 取某个帧的时间，参数一表示哪个时间（秒），参数二表示每秒多少帧
	  // 通常来说，600是一个常用的公共参数，苹果有说明:
	  // 24 frames per second (fps) for film, 30 fps for NTSC (used for TV in North America and
	  // Japan), and 25 fps for PAL (used for TV in Europe).
	  // Using a timescale of 600, you can exactly represent any number of frames in these systems
	  CMTime midpoint = CMTimeMakeWithSeconds(duration / 2.0, 600);
	  
	  // get the image from
	  NSError *error = nil;
	  CMTime actualTime;
	  // Returns a CFRetained CGImageRef for an asset at or near the specified time.
	  // So we should mannully release it
	  CGImageRef centerFrameImage = [imageGenerator copyCGImageAtTime:midpoint
	                                                       actualTime:&actualTime
	                                                            error:&error];
	  
	  if (centerFrameImage != NULL) {
	    image = [[UIImage alloc] initWithCGImage:centerFrameImage];
	    // Release the CFRetained image
	    CGImageRelease(centerFrameImage);
	  }
	  
	  return image;
	}

####异步获取帧图

异步获取某个帧的图片，与同步相比，只是调用API不同，可以传多个时间点，然后计算出实际的时间并返回图片，但是返回的图片不需要我们手动再release了。有可能取不到图片，所以还需要判断是否是AVAssetImageGeneratorSucceeded，是才转换图片：

	// 异步获取帧图片，可以一次获取多帧图片
	- (void)centerFrameImageWithVideoURL:(NSURL *)videoURL completion:(void (^)(UIImage *image))completion {
	  // AVAssetImageGenerator
	  AVAsset *asset = [AVAsset assetWithURL:videoURL];
	  AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	  imageGenerator.appliesPreferredTrackTransform = YES;
	  
	  // calculate the midpoint time of video
	  Float64 duration = CMTimeGetSeconds([asset duration]);
	  // 取某个帧的时间，参数一表示哪个时间（秒），参数二表示每秒多少帧
	  // 通常来说，600是一个常用的公共参数，苹果有说明:
	  // 24 frames per second (fps) for film, 30 fps for NTSC (used for TV in North America and
	  // Japan), and 25 fps for PAL (used for TV in Europe).
	  // Using a timescale of 600, you can exactly represent any number of frames in these systems
	  CMTime midpoint = CMTimeMakeWithSeconds(duration / 2.0, 600);
	  
	  // 异步获取多帧图片
	  NSValue *midTime = [NSValue valueWithCMTime:midpoint];
	  [imageGenerator generateCGImagesAsynchronouslyForTimes:@[midTime] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
	    if (result == AVAssetImageGeneratorSucceeded && image != NULL) {
	      UIImage *centerFrameImage = [[UIImage alloc] initWithCGImage:image];
	      dispatch_async(dispatch_get_main_queue(), ^{
	        if (completion) {
	          completion(centerFrameImage);
	        }
	      });
	    } else {
	      dispatch_async(dispatch_get_main_queue(), ^{
	        if (completion) {
	          completion(nil);
	        }
	      });
	    }
	  }];
	}
	 
	 
##34:压缩并导出视频

压缩视频是因为视频分辨率过高所生成的视频的大小太大了，对于移动设备来说，内存是不能太大的，如果不支持分片上传到服务器，或者不支持流上传、文件上传，而只能支持表单上传，那么必须要限制大小，压缩视频。

就像我们在使用某平台的视频的上传的时候，到现在还没有支持流上传，也不支持文件上传，只支持表单上传，导致视频大一点就会闪退。流上传是上传成功了，但是人家后台不识别，这一次让某平台坑坏了。直接用file上传，也传过去了，上传进度100%了，但是人家那边还是作为失败处理，无奈！

>言归正传，压缩、导出视频，需要通过AVAssetExportSession来实现，我们需要指定一个preset，并判断是否支持这个preset，只有支持才能使用。

我们这里设置的preset为AVAssetExportPreset640x480，属于压缩得比较厉害的了，这需要根据服务器视频上传的支持程度而选择的。然后通过调用异步压缩并导出视频：


	- (void)compressVideoWithVideoURL:(NSURL *)videoURL
	                        savedName:(NSString *)savedName
	                       completion:(void (^)(NSString *savedPath))completion {
	  // Accessing video by URL
	  AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
	  
	  // Find compatible presets by video asset.
	  NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
	  
	  // Begin to compress video
	  // Now we just compress to low resolution if it supports
	  // If you need to upload to the server, but server does't support to upload by streaming,
	  // You can compress the resolution to lower. Or you can support more higher resolution.
	  if ([presets containsObject:AVAssetExportPreset640x480]) {
	    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:videoAsset  presetName:AVAssetExportPreset640x480];
	    
	    NSString *doc = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	    NSString *folder = [doc stringByAppendingPathComponent:@"HYBVideos"];
	    BOOL isDir = NO;
	    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&isDir];
	    if (!isExist || (isExist && !isDir)) {
	      NSError *error = nil;
	      [[NSFileManager defaultManager] createDirectoryAtPath:folder
	                                withIntermediateDirectories:YES
	                                                 attributes:nil
	                                                      error:&error];
	      if (error == nil) {
	        NSLog(@"目录创建成功");
	      } else {
	        NSLog(@"目录创建失败");
	      }
	    }
	    
	    NSString *outPutPath = [folder stringByAppendingPathComponent:savedName];
	    session.outputURL = [NSURL fileURLWithPath:outPutPath];
	    
	    // Optimize for network use.
	    session.shouldOptimizeForNetworkUse = true;
	    
	    NSArray *supportedTypeArray = session.supportedFileTypes;
	    if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
	      session.outputFileType = AVFileTypeMPEG4;
	    } else if (supportedTypeArray.count == 0) {
	      NSLog(@"No supported file types");
	      return;
	    } else {
	      session.outputFileType = [supportedTypeArray objectAtIndex:0];
	    }
	    
	    // Begin to export video to the output path asynchronously.
	    [session exportAsynchronouslyWithCompletionHandler:^{
	      if ([session status] == AVAssetExportSessionStatusCompleted) {
	        dispatch_async(dispatch_get_main_queue(), ^{
	          if (completion) {
	            completion([session.outputURL path]);
	          }
	        });
	      } else {
	        dispatch_async(dispatch_get_main_queue(), ^{
	          if (completion) {
	            completion(nil);
	          }
	        });
	      }
	    }];
	  }
	}
	

##35:保存视频到相册

写入相册可以通过ALAssetsLibrary类来实现，它提供了写入相册的API，异步写入，完成是要回到主线程更新UI：

	NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
	  // 判断相册是否兼容视频，兼容才能保存到相册
	  if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {
	    [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
	      dispatch_async(dispatch_get_main_queue(), ^{
	        // 写入相册
	        if (error == nil) {
	            NSLog(@"写入相册成功");
	        } else {
	           NSLog(@"写入相册失败");
	        }
	      }
	    }];
	  }
	});
	

##36:获取当前最顶层的ViewController
	
		- (UIViewController *)topViewController {
	    UIViewController *resultVC;
	    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
	    while (resultVC.presentedViewController) {
	        resultVC = [self _topViewController:resultVC.presentedViewController];
	    }
	    return resultVC;
	}

	- (UIViewController *)_topViewController:(UIViewController *)vc {
	    if ([vc isKindOfClass:[UINavigationController class]]) {
	        return [self _topViewController:[(UINavigationController *)vc topViewController]];
	    } else if ([vc isKindOfClass:[UITabBarController class]]) {
	        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
	    } else {
	        return vc;
	    }
	    return nil;
	}

使用方法

	UIViewController *topmostVC = [self topViewController];
	


##37:数组拆分
	
	
	/**
	 *  数组拆分
	 *
	 *  @param array   数组
	 *  @param subSize 大小
	 *
	 *  @return 多个数组
	 */
	- (NSMutableArray *)splitArray: (NSArray *)array withSubSize : (int)subSize{
	    //  数组将被拆分成指定长度数组的个数
	    unsigned long count = array.count % subSize == 0 ? (array.count / subSize) : (array.count / subSize + 1);
	    //  用来保存指定长度数组的可变数组对象
	    NSMutableArray *arr = [[NSMutableArray alloc] init];
	    
	    //利用总个数进行循环，将指定长度的元素加入数组
	    for (int i = 0; i < count; i ++) {
	        //数组下标
	        int index = i * subSize;
	        //保存拆分的固定长度的数组元素的可变数组
	        NSMutableArray *arr1 = [[NSMutableArray alloc] init];
	        //移除子数组的所有元素
	        [arr1 removeAllObjects];
	        
	        int j = index;
	        //将数组下标乘以1、2、3，得到拆分时数组的最大下标值，但最大不能超过数组的总大小
	        while (j < subSize*(i + 1) && j < array.count) {
	            [arr1 addObject:[array objectAtIndexCheck:j]];
	            j += 1;
	        }
	        //将子数组添加到保存子数组的数组中
	        [arr addObject:[arr1 copy]];  
	    }  
	    
	    return arr;
	}

##38.图片压缩

用法：UIImage *yourImage= [self imageWithImageSimple:image scaledToSize:CGSizeMake(210.0, 210.0)];
	
	//压缩图片
	- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
	
	{
	
	// Create a graphics image context
	
	UIGraphicsBeginImageContext(newSize);
	
	// Tell the old image to draw in this newcontext, with the desired
	
	// new size
	
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	
	// Get the new image from the context
	
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the context
	
	UIGraphicsEndImageContext();
	
	// Return the new image.
	
	return newImage;
	
	}
	

 
===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  