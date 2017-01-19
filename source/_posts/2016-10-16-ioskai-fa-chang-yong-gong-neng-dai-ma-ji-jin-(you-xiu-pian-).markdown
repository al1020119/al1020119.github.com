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
39. 释放timer宏
40. 获取某个view所在的控制器
41. 两种方法删除NSUserDefaults所有记录
42. 打印系统所有已注册的字体名称
43. 获取图片某一点的颜色
44. 字符串反转
45. 禁止锁屏，
46. 模态推出透明界面
47. Xcode调试不显示内存占用
48. 显示隐藏文件
49. iOS跳转到App Store下载应用评分
50. iOS 获取汉字的拼音
51. 手动更改iOS状态栏的颜色
52. 判断当前ViewController是push还是present的方式显示的
53. 获取实际使用的LaunchImage图片
54. iOS在当前屏幕获取第一响应
55. 判断view是不是指定视图的子视图
56. NSArray 快速求总和 最大值 最小值 和 平均值
57. 修改UITextField中Placeholder的文字颜色
58. 关于NSDateFormatter的格式
59. 获取一个类的所有子类
60. 监测IOS设备是否设置了代理，需要CFNetwork.framework
61. 阿拉伯数字转中文格式
62. Base64编码与NSString对象或NSData对象的转换
63. 取消UICollectionView的隐式动画
64. 下面几种方法都可以帮你去除这些动画
65. 让Xcode的控制台支持LLDB类型的打印
66. CocoaPods pod install/pod update更新慢的问题
67. UIImage 占用内存大小
68. GCD timer定时器
69. 图片上绘制文字 写一个UIImage的category
70. 查找一个视图的所有子视图
71. 计算文件大小
72. UIView设置部分圆角
73. 取上整与取下整
74. 计算字符串字符长度，一个汉字算两个字符
75. 给UIView设置图片
76. 防止scrollView手势覆盖侧滑手势
77. 字符串中是否含有中文
78. dispatch_group的使用
79. UITextField每四位加一个空格,实现代理
80. 获取私有属性和成员变量 #import
81. 获取手机安装的应用
82. 判断两个日期是否在同一周 写在NSDate的category里面
83. 应用内打开系统设置界面
84. 可选值如下：
85. 屏蔽触发事件，2秒后取消屏蔽
86. 动画暂停再开始
87. iOS中数字的格式化
88. 如何获取WebView所有的图片地址，
89. 获取到webview的高度
90. navigationBar变为纯透明
91. tabBar同理
92. navigationBar根据滑动距离的渐变色实现
93. iOS 开发中一些相关的路径
94. navigationItem的BarButtonItem如何紧靠屏幕右边界或者左边界？
95. NSString进行URL编码和解码
96. UIWebView设置User-Agent。
97. 获取硬盘总容量与可用容量:
98. 获取UIColor的RGBA值
99. 修改textField的placeholder的字体颜色、大小
100. AFN移除JSON中的NSNull
101. ceil()和floor()
102. 在webView加载完的代理方法里面这样写：
103. NSDateFormat最佳方式（strptime）
104. 毛玻璃
105. tableview下拉刷新停留（不滚到顶部）， 类似QQ，微信拉去历史消息
106. KeyChain隐私信息存储（主要是密码类）
107. 自定义圆角裁剪：搞性能
108. 隐藏tabbar上面的虚线
109. 隐藏导航栏下面的虚线
110. 两个范围的富文本
111. 修改UIAlertController

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

####有个朋友给了一个更好的方案

	直接设置内边距，TableView会直接根据内边距进行相应的缩进！


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
	
##39.释放Timer宏

	/*
	 * 判断这个Timer不为nil则停止并释放
	 * 如果不先停止可能会导致crash
	 */
	#define WVSAFA_DELETE_TIMER(timer) { \
	    if (timer != nil) { \
	        [timer invalidate]; \
	        [timer release]; \
	        timer = nil; \
	    } \
	}



###获取某个view所在的控制器

	- (UIViewController *)viewController
	{
	  UIViewController *viewController = nil;  
	  UIResponder *next = self.nextResponder;
	  while (next)
	  {
	    if ([next isKindOfClass:[UIViewController class]])
	    {
	      viewController = (UIViewController *)next;      
	      break;    
	    }    
	    next = next.nextResponder;  
	  } 
	    return viewController;
	}

###两种方法删除NSUserDefaults所有记录

	//方法一
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
	
	
	//方法二
	- (void)resetDefaults
	{
	    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	    NSDictionary * dict = [defs dictionaryRepresentation];
	    for (id key in dict)
	    {
	        [defs removeObjectForKey:key];
	    }
	    [defs synchronize];
	}

###打印系统所有已注册的字体名称

	#pragma mark - 打印系统所有已注册的字体名称
	void enumerateFonts()
	{
	    for(NSString *familyName in [UIFont familyNames])
	   {
	        NSLog(@"%@",familyName);               
	        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];       
	        for(NSString *fontName in fontNames)
	       {
	            NSLog(@"\t|- %@",fontName);
	       }
	   }
	}

###获取图片某一点的颜色

	- (UIColor*) getPixelColorAtLocation:(CGPoint)point inImage:(UIImage *)image
	{
	
	    UIColor* color = nil;
	    CGImageRef inImage = image.CGImage;
	    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
	
	    if (cgctx == NULL) {
	        return nil; /* error */
	    }
	    size_t w = CGImageGetWidth(inImage);
	    size_t h = CGImageGetHeight(inImage);
	    CGRect rect = {0,0,w,}};
	
	    CGContextDrawImage(cgctx, rect, inImage);
	    unsigned char* data = CGBitmapContextGetData (cgctx);
	    if (data != NULL) {
	        int offset = 4*((w*round(point.y))+round(point.x));
	        int alpha =  data[offset];
	        int red = data[offset+1];
	        int green = data[offset+2];
	        int blue = data[offset+3];
	        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:
	                 (blue/255.0f) alpha:(alpha/255.0f)];
	    }
	    CGContextRelease(cgctx);
	    if (data) {
	        free(data);
	    }
	    return color;
	}

###字符串反转

	第一种：
	- (NSString *)reverseWordsInString:(NSString *)str
	{    
	    NSMutableString *newString = [[NSMutableString alloc] initWithCapacity:str.length];
	    for (NSInteger i = str.length - 1; i >= 0 ; i --)
	    {
	        unichar ch = [str characterAtIndex:i];       
	        [newString appendFormat:@"%c", ch];    
	    }    
	     return newString;
	}
	
	//第二种：
	- (NSString*)reverseWordsInString:(NSString*)str
	{    
	     NSMutableString *reverString = [NSMutableString stringWithCapacity:str.length];    
	     [str enumerateSubstringsInRange:NSMakeRange(0, str.length) options:NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences  usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) { 
	          [reverString appendString:substring];                         
	      }];    
	     return reverString;
	}

###禁止锁屏，

默认情况下，当设备一段时间没有触控动作时，iOS会锁住屏幕。但有一些应用是不需要锁屏的，比如视频播放器。

	[UIApplication sharedApplication].idleTimerDisabled = YES;
	或
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];

###模态推出透明界面

	UIViewController *vc = [[UIViewController alloc] init];
	UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:vc];
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
	{
	     na.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	}
	else
	{
	     self.modalPresentationStyle=UIModalPresentationCurrentContext;
	}
	
	[self presentViewController:na animated:YES completion:nil];


###Xcode调试不显示内存占用

	editSCheme  里面有个选项叫叫做enable zoombie Objects  取消选中

###显示隐藏文件

	//显示
	defaults write com.apple.finder AppleShowAllFiles -bool true
	killall Finder
	
	//隐藏
	defaults write com.apple.finder AppleShowAllFiles -bool false
	killall Finder
 
###iOS跳转到App Store下载应用评分

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APPID"]];

###iOS 获取汉字的拼音

	+ (NSString *)transform:(NSString *)chinese
	{    
	    //将NSString装换成NSMutableString 
	    NSMutableString *pinyin = [chinese mutableCopy];    
	    //将汉字转换为拼音(带音标)    
	    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);    
	    NSLog(@"%@", pinyin);    
	    //去掉拼音的音标    
	    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);    
	    NSLog(@"%@", pinyin);    
	    //返回最近结果    
	    return pinyin;
	 }

###手动更改iOS状态栏的颜色

	- (void)setStatusBarBackgroundColor:(UIColor *)color
	{
	    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
	
	    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)])
	    {
	        statusBar.backgroundColor = color;    
	    }
	}


###判断当前ViewController是push还是present的方式显示的

	
	NSArray *viewcontrollers=self.navigationController.viewControllers;
	 
	if (viewcontrollers.count > 1)
	{
	    if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self)
	    {
	        //push方式
	       [self.navigationController popViewControllerAnimated:YES];
	    }
	}
	else
	{
	    //present方式
	    [self dismissViewControllerAnimated:YES completion:nil];
	}

###获取实际使用的LaunchImage图片

	
	- (NSString *)getLaunchImageName
	{
	    CGSize viewSize = self.window.bounds.size;
	    // 竖屏    
	    NSString *viewOrientation = @"Portrait";  
	    NSString *launchImageName = nil;    
	    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
	    for (NSDictionary* dict in imagesDict)
	    {
	        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
	        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
	        {
	            launchImageName = dict[@"UILaunchImageName"];        
	        }    
	    }    
	    return launchImageName;
	}

###iOS在当前屏幕获取第一响应

	UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
	UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];

###判断对象是否遵循了某协议

	
	if ([self.selectedController conformsToProtocol:@protocol(RefreshPtotocol)])
	{
	     [self.selectedController performSelector:@selector(onTriggerRefresh)];
	}

###判断view是不是指定视图的子视图

	BOOL isView = [textView isDescendantOfView:self.view];

###NSArray 快速求总和 最大值 最小值 和 平均值

		
	NSArray *array = [NSArray arrayWithObjects:@"2.0", @"2.3", @"3.0", @"4.0", @"10", nil];
	CGFloat sum = [[array valueForKeyPath:@"@sum.floatValue"] floatValue];
	CGFloat avg = [[array valueForKeyPath:@"@avg.floatValue"] floatValue];
	CGFloat max =[[array valueForKeyPath:@"@max.floatValue"] floatValue];
	CGFloat min =[[array valueForKeyPath:@"@min.floatValue"] floatValue];
	NSLog(@"%f\n%f\n%f\n%f",sum,avg,max,min);

###修改UITextField中Placeholder的文字颜色

	
	[textField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];

###关于NSDateFormatter的格式

	
	G: 公元时代，例如AD公元
	yy: 年的后2位
	yyyy: 完整年
	MM: 月，显示为1-12
	MMM: 月，显示为英文月份简写,如 Jan
	MMMM: 月，显示为英文月份全称，如 Janualy
	dd: 日，2位数表示，如02
	d: 日，1-2位显示，如 2
	EEE: 简写星期几，如Sun
	EEEE: 全写星期几，如Sunday
	aa: 上下午，AM/PM
	H: 时，24小时制，0-23
	K：时，12小时制，0-11
	m: 分，1-2位
	mm: 分，2位
	s: 秒，1-2位
	ss: 秒，2位
	S: 毫秒

###获取一个类的所有子类

	
	+ (NSArray *) allSubclasses
	{
	    Class myClass = [self class];
	    NSMutableArray *mySubclasses = [NSMutableArray array];
	    unsigned int numOfClasses;
	    Class *classes = objc_copyClassList(&numOfClasses;);
	    for (unsigned int ci = 0; ci 
	}
###监测IOS设备是否设置了代理，需要CFNetwork.framework

	
	NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
	NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
	NSLog(@"\n%@",proxies);
	 
	NSDictionary *settings = proxies[0];
	NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyHostNameKey]);
	NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
	NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyTypeKey]);
	 
	if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"])
	{
	     NSLog(@"没代理");
	}
	else
	{
	     NSLog(@"设置了代理");
	}

###阿拉伯数字转中文格式

	
	+(NSString *)translation:(NSString *)arebic
	{  
	    NSString *str = arebic;
	    NSArray *arabic_numerals = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
	    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
	    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
	    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chinese_numerals forKeys:arabic_numerals];
	 
	    NSMutableArray *sums = [NSMutableArray array];
	    for (int i = 0; i 
	 
	}

###Base64编码与NSString对象或NSData对象的转换

	
	// Create NSData object
	NSData *nsdata = [@"iOS Developer Tips encoded in Base64"
	  dataUsingEncoding:NSUTF8StringEncoding];
	 
	// Get NSString from NSData object in Base64
	NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
	 
	// Print the Base64 encoded string
	NSLog(@"Encoded: %@", base64Encoded);
	 
	// Let's go the other way...
	 
	// NSData from the Base64 encoded str
	NSData *nsdataFromBase64String = [[NSData alloc]
	  initWithBase64EncodedString:base64Encoded options:0];
	 
	// Decoded NSString from the NSData
	NSString *base64Decoded = [[NSString alloc]
	  initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
	NSLog(@"Decoded: %@", base64Decoded);

###取消UICollectionView的隐式动画

	UICollectionView在reloadItems的时候，默认会附加一个隐式的fade动画，有时候很讨厌，尤其是当你的cell是复合cell的情况下(比如cell使用到了UIStackView)。
###下面几种方法都可以帮你去除这些动画
	
	//方法一
	[UIView performWithoutAnimation:^{
	    [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
	}];
	
	//方法二
	[UIView animateWithDuration:0 animations:^{
	    [collectionView performBatchUpdates:^{
	        [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
	    } completion:nil];
	}];
	
	//方法三
	[UIView setAnimationsEnabled:NO];
	[self.trackPanel performBatchUpdates:^{
	    [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
	} completion:^(BOOL finished) {
	    [UIView setAnimationsEnabled:YES];
	}];
###让Xcode的控制台支持LLDB类型的打印
	
	打开终端输入三条命令:
	touch ~/.lldbinit
	echo display @import UIKit >> ~/.lldbinit
	echo target stop-hook add -o \"target stop-hook disable\" >> ~/.lldbinit

###CocoaPods pod install/pod update更新慢的问题
	
	pod install --verbose --no-repo-update 
	pod update --verbose --no-repo-update
如果不加后面的参数，默认会升级CocoaPods的spec仓库，加一个参数可以省略这一步，然后速度就会提升不少

###UIImage 占用内存大小

	UIImage *image = [UIImage imageNamed:@"aa"];
	NSUInteger size  = CGImageGetHeight(image.CGImage) * CGImageGetBytesPerRow(image.CGImage);

###GCD timer定时器

	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
	dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
	dispatch_source_set_event_handler(timer, ^{
	    //@"倒计时结束，关闭"
	    dispatch_source_cancel(timer); 
	    dispatch_async(dispatch_get_main_queue(), ^{
	 
	    });
	});
	dispatch_resume(timer);

###图片上绘制文字 写一个UIImage的category

	- (UIImage *)imageWithTitle:(NSString *)title fontSize:(CGFloat)fontSize
	{
	    //画布大小
	    CGSize size=CGSizeMake(self.size.width,self.size.height);
	    //创建一个基于位图的上下文
	    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);//opaque:NO  scale:0.0
	
	    [self drawAtPoint:CGPointMake(0.0,0.0)];
	
	    //文字居中显示在画布上
	    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
	    paragraphStyle.alignment=NSTextAlignmentCenter;//文字居中
	
	    //计算文字所占的size,文字居中显示在画布上
	    CGSize sizeText=[title boundingRectWithSize:self.size options:NSStringDrawingUsesLineFragmentOrigin
	                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}context:nil].size;
	    CGFloat width = self.size.width;
	    CGFloat height = self.size.height;
	
	    CGRect rect = CGRectMake((width-sizeText.width)/2, (height-sizeText.height)/2, sizeText.width, sizeText.height);
	    //绘制文字
	    [title drawInRect:rect withAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:[ UIColor whiteColor],NSParagraphStyleAttributeName:paragraphStyle}];
	
	    //返回绘制的新图形
	    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext();
	    UIGraphicsEndImageContext();
	    return newImage;
	}

###查找一个视图的所有子视图

	
	- (NSMutableArray *)allSubViewsForView:(UIView *)view
	{
	    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
	    for (UIView *subView in view.subviews)
	    {
	        [array addObject:subView];
	        if (subView.subviews.count > 0)
	        {
	            [array addObjectsFromArray:[self allSubViewsForView:subView]];
	        }
	    }
	    return array;
	}

###计算文件大小

	//文件大小
	- (long long)fileSizeAtPath:(NSString *)path
	{
	    NSFileManager *fileManager = [NSFileManager defaultManager];
	
	    if ([fileManager fileExistsAtPath:path])
	    {
	        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
	        return size;
	    }
	
	    return 0;
	}
	
	//文件夹大小
	- (long long)folderSizeAtPath:(NSString *)path
	{
	    NSFileManager *fileManager = [NSFileManager defaultManager];
	
	    long long folderSize = 0;
	
	    if ([fileManager fileExistsAtPath:path])
	    {
	        NSArray *childerFiles = [fileManager subpathsAtPath:path];
	        for (NSString *fileName in childerFiles)
	        {
	            NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
	            if ([fileManager fileExistsAtPath:fileAbsolutePath])
	            {
	                long long size = [fileManager attributesOfItemAtPath:fileAbsolutePath error:nil].fileSize;
	                folderSize += size;
	            }
	        }
	    }
	
	    return folderSize;
	}

###UIView设置部分圆角

你是不是也遇到过这样的问题，一个button或者label，只要右边的两个角圆角，或者只要一个圆角。该怎么办呢。这就需要图层蒙版来帮助我们了

	
	CGRect rect = view.bounds;
	CGSize radio = CGSizeMake(30, 30);//圆角尺寸
	UIRectCorner corner = UIRectCornerTopLeft|UIRectCornerTopRight;//这只圆角位置
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:radio];
	CAShapeLayer *masklayer = [[CAShapeLayer alloc]init];//创建shapelayer
	masklayer.frame = view.bounds;
	masklayer.path = path.CGPath;//设置路径
	view.layer.mask = masklayer;

###取上整与取下整

	
	floor(x),有时候也写做Floor(x)，其功能是“下取整”，即取不大于x的最大整数 例如：
	x=3.14，floor(x)=3
	y=9.99999，floor(y)=9
	 
	与floor函数对应的是ceil函数，即上取整函数。
	 
	ceil函数的作用是求不小于给定实数的最小整数。
	ceil(2)=ceil(1.2)=cei(1.5)=2.00
	 
	floor函数与ceil函数的返回值均为double型

###计算字符串字符长度，一个汉字算两个字符

	
	//方法一：
	- (int)convertToInt:(NSString*)strtemp
	{
	    int strlength = 0;
	    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
	    for (int i=0 ; i
	}

###给UIView设置图片

	UIImage *image = [UIImage imageNamed:@"image"];
	self.MYView.layer.contents = (__bridge id _Nullable)(image.CGImage);
	self.MYView.layer.contentsRect = CGRectMake(0, 0, 0.5, 0.5);

###防止scrollView手势覆盖侧滑手势
	
	[scrollView.panGestureRecognizerrequireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];

###去掉导航栏返回的back标题

	[[UIBarButtonItemappearance]setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)forBarMetrics:UIBarMetricsDefault];

###字符串中是否含有中文

	
	+ (BOOL)checkIsChinese:(NSString *)string
	{
	    for (int i=0; i
	}


###dispatch_group的使用

	
	 dispatch_group_t dispatchGroup = dispatch_group_create();
	    dispatch_group_enter(dispatchGroup);
	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	        NSLog(@"第一个请求完成");
	        dispatch_group_leave(dispatchGroup);
	    });
	 
	    dispatch_group_enter(dispatchGroup);
	 
	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	        NSLog(@"第二个请求完成");
	        dispatch_group_leave(dispatchGroup);
	    });
	 
	    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
	        NSLog(@"请求完成");
	    });

###UITextField每四位加一个空格,实现代理

	
	- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
	{
	    // 四位加一个空格
	    if ([string isEqualToString:@""])
	    {
	        // 删除字符
	        if ((textField.text.length - 2) % 5 == 0)
	        {
	            textField.text = [textField.text substringToIndex:textField.text.length - 1];
	        }
	        return YES;
	    }
	    else
	    {
	        if (textField.text.length % 5 == 0)
	        {
	            textField.text = [NSString stringWithFormat:@"%@ ", textField.text];
	        }
	    }
	    return YES;
	}

###获取私有属性和成员变量 #import

	
	//获取私有属性 比如设置UIDatePicker的字体颜色
	- (void)setTextColor
	{
	    //获取所有的属性，去查看有没有对应的属性
	    unsigned int count = 0;
	    objc_property_t *propertys = class_copyPropertyList([UIDatePicker class], &count);
	    for(int i = 0;i 
	
		
	//获得成员变量 比如修改UIAlertAction的按钮字体颜色
	    unsigned int count = 0;
	    Ivar *ivars = class_copyIvarList([UIAlertAction class], &count);
	    for(int i =0;i 

###获取手机安装的应用

	
	Class c =NSClassFromString(@"LSApplicationWorkspace");
	id s = [(id)c performSelector:NSSelectorFromString(@"defaultWorkspace")];
	NSArray *array = [s performSelector:NSSelectorFromString(@"allInstalledApplications")];
	for (id item in array)
	{
	    NSLog(@"%@",[item performSelector:NSSelectorFromString(@"applicationIdentifier")]);
	    //NSLog(@"%@",[item performSelector:NSSelectorFromString(@"bundleIdentifier")]);
	    NSLog(@"%@",[item performSelector:NSSelectorFromString(@"bundleVersion")]);
	    NSLog(@"%@",[item performSelector:NSSelectorFromString(@"shortVersionString")]);
	}

###判断两个日期是否在同一周 写在NSDate的category里面

	- (BOOL)isSameDateWithDate:(NSDate *)date
	{
	    //日期间隔大于七天之间返回NO
	    if (fabs([self timeIntervalSinceDate:date]) >= 7 * 24 *3600)
	    {
	        return NO;
	    }
	
	    NSCalendar *calender = [NSCalendar currentCalendar];
	    calender.firstWeekday = 2;//设置每周第一天从周一开始
	    //计算两个日期分别为这年第几周
	    NSUInteger countSelf = [calender ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitYear forDate:self];
	    NSUInteger countDate = [calender ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitYear forDate:date];
	
	    //相等就在同一周，不相等就不在同一周
	    return countSelf == countDate;
	}

###应用内打开系统设置界面
	
	//iOS8之后
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
	//如果App没有添加权限，显示的是设定界面。如果App有添加权限（例如通知），显示的是App的设定界面。
	
	//iOS8之前
	//先添加一个url type如下图，在代码中调用如下代码,即可跳转到设置页面的对应项
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];

###可选值如下：

	About — prefs:root=General&path=About
	Accessibility — prefs:root=General&path=ACCESSIBILITY
	Airplane Mode On — prefs:root=AIRPLANE_MODE
	Auto-Lock — prefs:root=General&path=AUTOLOCK
	Brightness — prefs:root=Brightness
	Bluetooth — prefs:root=General&path=Bluetooth
	Date & Time — prefs:root=General&path=DATE_AND_TIME
	FaceTime — prefs:root=FACETIME
	General — prefs:root=General
	Keyboard — prefs:root=General&path=Keyboard
	iCloud — prefs:root=CASTLE
	iCloud Storage & Backup — prefs:root=CASTLE&path=STORAGE_AND_BACKUP
	International — prefs:root=General&path=INTERNATIONAL
	Location Services — prefs:root=LOCATION_SERVICES
	Music — prefs:root=MUSIC
	Music Equalizer — prefs:root=MUSIC&path=EQ
	Music Volume Limit — prefs:root=MUSIC&path=VolumeLimit
	Network — prefs:root=General&path=Network
	Nike + iPod — prefs:root=NIKE_PLUS_IPOD
	Notes — prefs:root=NOTES
	Notification — prefs:root=NOTIFICATI*****_ID
	Phone — prefs:root=Phone
	Photos — prefs:root=Photos
	Profile — prefs:root=General&path=ManagedConfigurationList
	Reset — prefs:root=General&path=Reset
	Safari — prefs:root=Safari
	Siri — prefs:root=General&path=Assistant
	Sounds — prefs:root=Sounds
	Software Update — prefs:root=General&path=SOFTWARE_UPDATE_LINK
	Store — prefs:root=STORE
	Twitter — prefs:root=TWITTER
	Usage — prefs:root=General&path=USAGE
	VPN — prefs:root=General&path=Network/VPN
	Wallpaper — prefs:root=Wallpaper
	Wi-Fi — prefs:root=WIFI

###屏蔽触发事件，2秒后取消屏蔽
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    [[UIApplication sharedApplication] endIgnoringInteractionEvents]
	});

###动画暂停再开始

	
	-(void)pauseLayer:(CALayer *)layer
	{
	    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
	    layer.speed = 0.0;
	    layer.timeOffset = pausedTime;
	}
	 
	-(void)resumeLayer:(CALayer *)layer
	{
	    CFTimeInterval pausedTime = [layer timeOffset];
	    layer.speed = 1.0;
	    layer.timeOffset = 0.0;
	    layer.beginTime = 0.0;
	    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
	    layer.beginTime = timeSincePause;
	}

###iOS中数字的格式化
	
	//通过NSNumberFormatter，同样可以设置NSNumber输出的格式。例如如下代码：
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	formatter.numberStyle = NSNumberFormatterDecimalStyle;
	NSString *string = [formatter stringFromNumber:[NSNumber numberWithInt:123456789]];
	NSLog(@"Formatted number string:%@",string);
	//输出结果为：[1223:403] Formatted number string:123,456,789
	 
	//其中NSNumberFormatter类有个属性numberStyle，它是一个枚举型，设置不同的值可以输出不同的数字格式。该枚举包括：
	typedef NS_ENUM(NSUInteger, NSNumberFormatterStyle) {
	    NSNumberFormatterNoStyle = kCFNumberFormatterNoStyle,
	    NSNumberFormatterDecimalStyle = kCFNumberFormatterDecimalStyle,
	    NSNumberFormatterCurrencyStyle = kCFNumberFormatterCurrencyStyle,
	    NSNumberFormatterPercentStyle = kCFNumberFormatterPercentStyle,
	    NSNumberFormatterScientificStyle = kCFNumberFormatterScientificStyle,
	    NSNumberFormatterSpellOutStyle = kCFNumberFormatterSpellOutStyle
	};
	//各个枚举对应输出数字格式的效果如下：其中第三项和最后一项的输出会根据系统设置的语言区域的不同而不同。
	[1243:403] Formatted number string:123456789
	[1243:403] Formatted number string:123,456,789
	[1243:403] Formatted number string:￥123,456,789.00
	[1243:403] Formatted number string:-539,222,988%
	[1243:403] Formatted number string:1.23456789E8
	[1243:403] Formatted number string:一亿二千三百四十五万六千七百八十九

###如何获取WebView所有的图片地址，

在网页加载完成时，通过js获取图片和添加点击的识别方式

	
	//UIWebView
	- (void)webViewDidFinishLoad:(UIWebView *)webView
	{
	    //这里是js，主要目的实现对url的获取
	    static  NSString * const jsGetImages =
	    @"function getImages(){\
	    var objs = document.getElementsByTagName(\"img\");\
	    var imgScr = '';\
	    for(var i=0;i
	
	}
		
	//WKWebView
	- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
	{
	    static  NSString * const jsGetImages =
	    @"function getImages(){\
	    var objs = document.getElementsByTagName(\"img\");\
	    var imgScr = '';\
	    for(var i=0;i

###获取到webview的高度

	
	CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];

###navigationBar变为纯透明

	
	//第一种方法
	//导航栏纯透明
	[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	//去掉导航栏底部的黑线
	self.navigationBar.shadowImage = [UIImage new];
	 
	//第二种方法
	[[self.navigationBar subviews] objectAtIndex:0].alpha = 0;

###tabBar同理

	
	[self.tabBar setBackgroundImage:[UIImage new]];
	self.tabBar.shadowImage = [UIImage new];

###navigationBar根据滑动距离的渐变色实现

	
	//第一种
	- (void)scrollViewDidScroll:(UIScrollView *)scrollView
	{
	    CGFloat offsetToShow = 200.0;//滑动多少就完全显示
	    CGFloat alpha = 1 - (offsetToShow - scrollView.contentOffset.y) / offsetToShow;
	    [[self.navigationController.navigationBar subviews] objectAtIndex:0].alpha = alpha;
	}
	
	//第二种
	- (void)scrollViewDidScroll:(UIScrollView *)scrollView
	{
	    CGFloat offsetToShow = 200.0;
	    CGFloat alpha = 1 - (offsetToShow - scrollView.contentOffset.y) / offsetToShow;
	
	    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
	    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[[UIColor orangeColor]colorWithAlphaComponent:alpha]] forBarMetrics:UIBarMetricsDefault];
	}
	
	//生成一张纯色的图片
	- (UIImage *)imageWithColor:(UIColor *)color
	{
	    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	    UIGraphicsBeginImageContext(rect.size);
	    CGContextRef context = UIGraphicsGetCurrentContext();
	    CGContextSetFillColorWithColor(context, [color CGColor]);
	    CGContextFillRect(context, rect);
	    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	    UIGraphicsEndImageContext();
	
	    return theImage;
	}

###iOS 开发中一些相关的路径

	
	模拟器的位置:
	/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs 
	 
	文档安装位置:
	/Applications/Xcode.app/Contents/Developer/Documentation/DocSets
	 
	插件保存路径:
	~/Library/ApplicationSupport/Developer/Shared/Xcode/Plug-ins
	 
	自定义代码段的保存路径:
	~/Library/Developer/Xcode/UserData/CodeSnippets/ 
	如果找不到CodeSnippets文件夹，可以自己新建一个CodeSnippets文件夹。
	 
	描述文件路径
	~/Library/MobileDevice/Provisioning Profiles

###navigationItem的BarButtonItem如何紧靠屏幕右边界或者左边界？

一般情况下，右边的item会和屏幕右侧保持一段距离：
下面是通过添加一个负值宽度的固定间距的item来解决，也可以改变宽度实现不同的间隔：
	
	UIImage *img = [[UIImage imageNamed:@"icon_cog"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	//宽度为负数的固定间距的系统item
	UIBarButtonItem *rightNegativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	[rightNegativeSpacer setWidth:-15];
	 
	UIBarButtonItem *rightBtnItem1 = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClicked:)];
	UIBarButtonItem *rightBtnItem2 = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClicked:)];
	self.navigationItem.rightBarButtonItems = @[rightNegativeSpacer,rightBtnItem1,rightBtnItem2];

###NSString进行URL编码和解码

	
	NSString *string = @"http://abc.com?aaa=你好&bbb=tttee";
	 
	//编码 打印：http://abc.com?aaa=%E4%BD%A0%E5%A5%BD&bbb=tttee
	string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
	 
	//解码 打印：http://abc.com?aaa=你好&bbb=tttee
	string = [string stringByRemovingPercentEncoding];

###UIWebView设置User-Agent。

	
	//设置
	NSDictionary *dic = @{@"UserAgent":@"your UserAgent"};
	[[NSUserDefaults standardUserDefaults] registerDefaults:dic];
	//获取
	NSString *agent = [self.WebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];

###获取硬盘总容量与可用容量:

	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDictionary *attributes = [fileManager attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
	 
	NSLog(@"容量%.2fG",[attributes[NSFileSystemSize] doubleValue] / (powf(1024, 3)));
	NSLog(@"可用%.2fG",[attributes[NSFileSystemFreeSize] doubleValue] / powf(1024, 3));

###获取UIColor的RGBA值

	
	UIColor *color = [UIColor colorWithRed:0.2 green:0.3 blue:0.9 alpha:1.0];
	const CGFloat *components = CGColorGetComponents(color.CGColor);
	NSLog(@"Red: %.1f", components[0]);
	NSLog(@"Green: %.1f", components[1]);
	NSLog(@"Blue: %.1f", components[2]);
	NSLog(@"Alpha: %.1f", components[3]);

###修改textField的placeholder的字体颜色、大小

	
	[self.textField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
	[self.textField setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];

###AFN移除JSON中的NSNull

	AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
	response.removesKeysWithNullValues = YES;

###ceil()和floor()

	ceil()功 能：返回大于或者等于指定表达式的最小整数
	floor()功 能：返回小于或者等于指定表达式的最大整数
	UIWebView里面的图片自适应屏幕

###在webView加载完的代理方法里面这样写：

	
	- (void)webViewDidFinishLoad:(UIWebView *)webView
	{
	    NSString *js = @"function imgAutoFit() { \
	    var imgs = document.getElementsByTagName('img'); \
	    for (var i = 0; i < imgs.length; ++i) { \
	    var img = imgs[i]; \
	    img.style.maxWidth = %f; \
	    } \
	    }";
	 
	    js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width - 20];
	 
	    [webView stringByEvaluatingJavaScriptFromString:js];
	    [webView stringByEvaluatingJavaScriptFromString:@"imgAutoFit()"];
	}


###NSDateFormat最佳方式（strptime）

	+ (NSDate *)dateFromISO8601StringDateFormatter:(NSString *)string locale:(NSLocale *)locale{
	    if (!string) {
	        return nil;
	    }
	
	    struct tm tm;
	    time_t t;
	
	    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%d %H:%M:%S", &tm);
	    tm.tm_isdst = -1;
	    t = mktime(&tm);
	
	    return [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
	}
	
	- (NSString *)ISO8601String:(NSDate*)date {
	    struct tm *timeinfo;
	    char buffer[80];
	
	    time_t rawtime = [date timeIntervalSince1970] - [[NSTimeZone localTimeZone] secondsFromGMT];
	    timeinfo = localtime(&rawtime);
	
	    strftime(buffer, 80, "%Y-%m-%d %H:%M:%S", timeinfo);
	
	    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
	}

###毛玻璃


    //创建
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    //图片
    imageView.image = [UIImage imageNamed:@"1.jpeg"];
    //背景颜色
    imageView.backgroundColor = [UIColor yellowColor];
    //设置图片内容模式
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:imageView];
    
    //毛玻璃
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:imageView.bounds];
    //样式
    toolbar.barStyle = UIBarStyleDefault;
    //透明度
    toolbar.alpha = 0.8f;
    [imageView addSubview:toolbar];

###tableview下拉刷新停留（不滚到顶部）， 类似QQ，微信拉去历史消息
 
 关于TableView代理方法和其他一些数据与逻辑处理和平时一样，只是在下啦的时候啦到的数据，放到最前面，同事控制TableView的偏移。
 
 
    self.oldSize = self.tableView.contentSize;
    self.oldPoint = self.tableView.contentOffset;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //                if (self.isfirst) {
        for (int i = 0; i < 15; i++) {
            [self.dataArray insertObject:[NSString stringWithFormat:@"新增加信息%d",i] atIndex:0];
        }
        
        //            }
        //            self.isfirst = YES;
        // 刷新表格
        [self.tableView reloadData];
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView EndRefreshing];
        
        CGSize newSize = self.tableView.contentSize;
        
        
        CGPoint newPoint = CGPointMake(0, self.oldPoint.y+newSize.height - self.oldSize.height);
        self.tableView.contentOffset = newPoint;
    });
    
    
###KeyChain隐私信息存储（主要是密码类）
	 
集成NSObject
	 
	 -(NSMutableDictionary *)getKeychainQuery:(NSString *)service
	{
	    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
	            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
	            service, (__bridge_transfer id)kSecAttrService,
	            service, (__bridge_transfer id)kSecAttrAccount,
	            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
	            nil];
	}
	 
	+ (void)saveKeychainValue:(NSString *)sValue Key:(NSString *)sKey
	{
	    //Get search dictionary
	    NSMutableDictionary *keychainQuery = [self getKeychainQuery:sKey];
	    //Delete old item before add new item
	    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
	    //Add new object to search dictionary(Attention:the data format)
	    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:sValue] forKey:(__bridge_transfer id)kSecValueData];
	    //Add item to keychain with the search dictionary
	    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
	}
	 
	+ (NSString *)readKeychainValue:(NSString *)sKey
	{
	    NSString *ret = nil;
	    NSMutableDictionary *keychainQuery = [self getKeychainQuery:sKey];
	 
	    //Configure the search setting
	    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
	    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
	    CFDataRef keyData = NULL;
	    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
	    <a href="http://www.jobbole.com/members/xyz937134366">@try</a> {
	        ret = (NSString *)[NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
	        } <a href="http://www.jobbole.com/members/wx895846013">@catch</a> (NSException *e) {
	            NSLog(@"Unarchive of %@ failed: %@", sKey, e);
	        } <a href="http://www.jobbole.com/members/finally">@finally</a> {
	        }
	    }
	    return ret;
	}
	 
	+ (void)deleteKeychainValue:(NSString *)sKey {
	    NSMutableDictionary *keychainQuery = [self getKeychainQuery:sKey];
	    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
	}

###自定义圆角裁剪：搞性能




	// ------------------------------------------------------------------
	// --------------------- 以下是自定义图像处理部分 -----------------------
	// ------------------------------------------------------------------
	
	// 自定义裁剪算法
	- (UIImage *)dealImage:(UIImage *)img cornerRadius:(CGFloat)c {
	    // 1.CGDataProviderRef 把 CGImage 转 二进制流
	    CGDataProviderRef provider = CGImageGetDataProvider(img.CGImage);
	    void *imgData = (void *)CFDataGetBytePtr(CGDataProviderCopyData(provider));
	    int width = img.size.width * img.scale;
	    int height = img.size.height * img.scale;
	    
	    // 2.处理 imgData
	//    dealImage(imgData, width, height);
	    cornerImage(imgData, width, height, c);
	    
	    // 3.CGDataProviderRef 把 二进制流 转 CGImage
	    CGDataProviderRef pv = CGDataProviderCreateWithData(NULL, imgData, width * height * 4, releaseData);
	    CGImageRef content = CGImageCreate(width , height, 8, 32, 4 * width, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, pv, NULL, true, kCGRenderingIntentDefault);
	    UIImage *result = [UIImage imageWithCGImage:content];
	    CGDataProviderRelease(pv);      // 释放空间
	    CGImageRelease(content);
	    
	    return result;
	}
	
	void releaseData(void *info, const void *data, size_t size) {
	    free((void *)data);
	}
	
	// 在 img 上处理图片, 测试用
	void dealImage(UInt32 *img, int w, int h) {
	    int num = w * h;
	    UInt32 *cur = img;
	    for (int i=0; i<num; i++, cur++) {
	        UInt8 *p = (UInt8 *)cur;
	        // RGBA 排列
	        // f(x) = 255 - g(x) 求负片
	        p[0] = 255 - p[0];
	        p[1] = 255 - p[1];
	        p[2] = 255 - p[2];
	        p[3] = 255;
	    }
	}
	
	// 裁剪圆角
	void cornerImage(UInt32 *const img, int w, int h, CGFloat cornerRadius) {
	    CGFloat c = cornerRadius;
	    CGFloat min = w > h ? h : w;
	    
	    if (c < 0) { c = 0; }
	    if (c > min * 0.5) { c = min * 0.5; }
	    
	    // 左上 y:[0, c), x:[x, c-y)
	    for (int y=0; y<c; y++) {
	        for (int x=0; x<c-y; x++) {
	            UInt32 *p = img + y * w + x;    // p 32位指针，RGBA排列，各8位
	            if (isCircle(c, c, c, x, y) == false) {
	                *p = 0;
	            }
	        }
	    }
	    // 右上 y:[0, c), x:[w-c+y, w)
	    int tmp = w-c;
	    for (int y=0; y<c; y++) {
	        for (int x=tmp+y; x<w; x++) {
	            UInt32 *p = img + y * w + x;
	            if (isCircle(w-c, c, c, x, y) == false) {
	                *p = 0;
	            }
	        }
	    }
	    // 左下 y:[h-c, h), x:[0, y-h+c)
	    tmp = h-c;
	    for (int y=h-c; y<h; y++) {
	        for (int x=0; x<y-tmp; x++) {
	            UInt32 *p = img + y * w + x;
	            if (isCircle(c, h-c, c, x, y) == false) {
	                *p = 0;
	            }
	        }
	    }
	    // 右下 y~[h-c, h), x~[w-c+h-y, w)
	    tmp = w-c+h;
	    for (int y=h-c; y<h; y++) {
	        for (int x=tmp-y; x<w; x++) {
	            UInt32 *p = img + y * w + x;
	            if (isCircle(w-c, h-c, c, x, y) == false) {
	                *p = 0;
	            }
	        }
	    }
	}
	
	// 判断点 (px, py) 在不在圆心 (cx, cy) 半径 r 的圆内
	static inline bool isCircle(float cx, float cy, float r, float px, float py) {
	    if ((px-cx) * (px-cx) + (py-cy) * (py-cy) > r * r) {
	        return false;
	    }
	    return true;
	}
	
	// 其他图像效果可以自己写函数，然后在 dealImage: 中调用 otherImage 即可
	void otherImage(UInt32 *const img, int w, int h) {
	    // 自定义处理
	}



###隐藏tabbar上面的虚线
	
	//隐藏阴影线
	[[UITabBar appearance] setShadowImage:[UIImage new]];
	- (void)setupTabBarBackgroundImage {
	    UIImage *image = [UIImage imageNamed:@"tab_bg"];
	    CGFloat top = 40; // 顶端盖高度
	    CGFloat bottom = 40 ; // 底端盖高度
	    CGFloat left = 100; // 左端盖宽度
	    CGFloat right = 100; // 右端盖宽度
	    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
	    // 指定为拉伸模式，伸缩后重新赋值
	    UIImage *TabBgImage = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
	    self.tabBar.backgroundImage = TabBgImage;
	    [[UITabBar appearance] setShadowImage:[UIImage new]];
	    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
	}
	//自定义TabBar高度
	- (void)viewWillLayoutSubviews {
	    CGRect tabFrame = self.tabBar.frame;
	    tabFrame.size.height = 60;
	    tabFrame.origin.y = self.view.frame.size.height - 60;
	    self.tabBar.frame = tabFrame;
	}
	
	
###隐藏导航栏下面的虚线

#######方法一，世界使用背景图片与阴影

	- (void)viewWillAppear:(BOOL)animated{
	
	    
	
	    // Called when the view is about to made visible. Default does nothing    
	
	    [super viewWillAppear:animated];
	
	  
	
	    //去除导航栏下方的横线
	
	    [navigationBar setBackgroundImage:[UIImage imageWithColor:[self colorFromHexRGB:@"33cccc"]]
	
	                       forBarPosition:UIBarPositionAny
	
	                           barMetrics:UIBarMetricsDefault];
	
	    [navigationBar setShadowImage:[UIImage new]];
	
	    
	
	}
	
	
这是唯一一个隐藏这条线的官方用法，但是有一个缺陷-删除了translucency(半透明)


#######方法二：

1）声明UIImageView变量,存储底部横线

	@interface MyViewController {
	    UIImageView *navBarHairlineImageView;
	}
 
2）在viewDidLoad中加入：

	navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];


3）实现找出底部横线的函数

	- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
	    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
	            return (UIImageView *)view;
	    }
	    for (UIView *subview in view.subviews) {
	        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
	        if (imageView) {
	            return imageView;
	        }
	    }
	    return nil;
	}
 
4）最后在viewWillAppear，viewWillDisappear中处理

	- (void)viewWillAppear:(BOOL)animated {
	    [super viewWillAppear:animated];
	    navBarHairlineImageView.hidden = YES;
	}
	
	- (void)viewWillDisappear:(BOOL)animated {
	    [super viewWillDisappear:animated];
	    navBarHairlineImageView.hidden = NO;
	}
 ###两个范围的富文本

    NSString *times = [NSString stringWithFormat:@"哇塞！本次视频聊天%@", [info objectStringForKey:@"times"]];
    NSString *type = [NSString stringWithFormat:@"%@", [info objectStringForKey:@"type"]];
    NSString *counts = nil;
    if ([type isEqualToString:@"1"]) {
        counts = [NSString stringWithFormat:@"消耗%@能量", [info objectStringForKey:@"counts"]];
    } else {
        counts = [NSString stringWithFormat:@"赚了%@积分", [info objectStringForKey:@"counts"]];
    }
    
    NSString *formatString = [NSString stringWithFormat:@"%@,%@", times, counts];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:formatString];
    NSRange range = [formatString rangeOfString:@","];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#fb455a"] range:NSMakeRange(9, range.location - 9)];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#fb455a"] range:NSMakeRange(range.location + 3, formatString.length - range.location - 5)];
    

###修改UIAlertController


    // 在 viewDidLoad 中创建
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:AttributedStr.string preferredStyle:UIAlertControllerStyleAlert];
    // 用 KVC 修改其 没有暴露出来的
//    [alertVC setValue:AttributedTit forKey:@"attributedTitle"];
    [alertVC setValue:AttributedStr forKey:@"attributedMessage"];
    
    //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [defaultAction setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [alertVC addAction:defaultAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    

上面使用了一种个人比较喜欢的方法，

> 总体来说，第二种办法还是很好地，建议大家使用第二种办法。
 




===
===


######微信号：
	
clpaial10201119（Q Q：2211523682）
    
######微博WB:

[http://weibo.com/u/3288975567?is_hot=1](http://weibo.com/u/3288975567?is_hot=1)

######gitHub：


[https://github.com/al1020119](https://github.com/al1020119)
	
######博客

[http://al1020119.github.io/](http://al1020119.github.io/)

===

{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  