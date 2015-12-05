---
layout: post
title: "H5应用实战"
date: 2015-12-10 11:03:23 +0800
comments: true
categories: 项目实战
---


> 前言:
ObjectiveC与Js交互是常见的需求，可对于新手或者所谓的高手而言，其实并不是那么简单明了。


标准通用标记语言下的一个应用HTML标准自1999年12月发布的HTML4.01后，后继的HTML5和其它标准被束之高阁，为了推动Web标准化运动的发展，一些公司联合起来，成立了一个叫做 Web Hypertext Application Technology Working Group （Web超文本应用技术工作组 -WHATWG） 的组织。WHATWG 致力于 Web 表单和应用程序，而W3C（World Wide Web Consortium，万维网联盟） 专注于XHTML2.0。在 2006 年，双方决定进行合作，来创建一个新版本的 HTML。


这段时间在研究H5相关，由于本人主攻的是ios开发，所以后期主要的任务就是，使用H5+Css+JP编写好的代码在OC中使用，或者相互调用。

这里就给大家介绍一下后面的内容，关于前面的内容后期会陆续更新相关文章与总结。



<!--more-->





###OC——调用——HTML

这里有两种方式
直接使用网络链接（接口）
使用本地的html

由于没有完成一个完整的html项目，这里就以链接演示。

先来看看官方链接显示情况
{% img /images/html&oc001.png Caption %}  

1.使用WebView，设置代理，加载对应的Html（略过部分细节），并且增加一个指示器
 
   
    // 加载网页
    NSURL *url = [NSURL URLWithString:@"http://www.xianhua.cn/m/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    self.webView.scrollView.hidden = YES;
    self.webView.backgroundColor = [UIColor grayColor];
    
    UIActivityIndicatorView *displayView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [displayView startAnimating];
    self.displayView = displayView;
    displayView.center = self.view.center;
    [self.webView addSubview:displayView];


2.在WebView加载完成的方法中实现我们想要的功能需求

	#pragma mark -<UIWebViewDelegate>
	- (void)webViewDidFinishLoad:(UIWebView *)webView{
	    
	    // 改变标题
	    NSString *str = @"document.getElementsByTagName('h1')[0].innerText = 'iCocos鲜花网';";
	    [webView stringByEvaluatingJavaScriptFromString:str];
	    
	    // 删除广告
	    NSString *str2 =@"document.getElementsByClassName('detail_btns2')[0].remove();";
	    [webView stringByEvaluatingJavaScriptFromString:str2];
	    
	    // 改变尾部
	    NSString *str3 = @"document.getElementById('xiazaiapp').getElementsByTagName('a')[0].innerText='iCocos鲜花网App';";
	    [webView stringByEvaluatingJavaScriptFromString:str3];
	    
	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	        self.webView.scrollView.hidden = NO;
	        [self.displayView stopAnimating];
	    });
	}


修改后子在手机就是这样的效果


{% img /images/html&oc002.png Caption %}  


###HTML——调用——OC

这里的例子是通过在html中点击一个按钮去调用OC代码，访问系统系相册

######先来看看OC中需要怎么写：

1.使用WebView，设置代理，加载对应的Html（略过部分细节）


    
    // 加载网页
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    
    
2.在Web开始加载请求的代理方法中拼接方法（包装）

	#pragma mark - <UIWebViewDelegate>
	- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	//    NSLog(@"------%@", request.URL.absoluteString);
	    NSString *requestUrl = request.URL.absoluteString;
	    NSRange range = [requestUrl rangeOfString:@"ds3q:///"];
	    NSUInteger location = range.location;
	    if (location != NSNotFound) {
	        NSString *str = [requestUrl substringFromIndex:location + range.length];
	        NSLog(@"%@", str);
	        // 包装SEL
	        SEL method = NSSelectorFromString(str);
	        [self performSelector:method];
	    }
	    
	    return YES;
	}
    
3.实现打开相册的OC方法

	// 打开相册
	- (void)openCamera{
	    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
	    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	    [self presentViewController:vc animated:YES completion:nil];
	}
    
    
4.再来看看html中简单的写法

	<!DOCTYPE html>
	<html>
	<head lang="en">
	    <meta charset="UTF-8">
	    <title></title>
	    <style>
	        body{
	            margin-top: 50px;
	        }
	    </style>
	</head>
	<body>
	    <button onclick="openCamera();">访问相册</button>
	    <script type="text/javascript">
	        function openCamera(){
	            window.location.href = 'ds3q:///openCamera';
	        }
	    </script>
	</body>
	</html>
    
    
 显示效果
 
 
 {% img /images/html&oc003.png Caption %} 
 
 
 ***
 
 
 
  {% img /images/html&oc004.png Caption %}  
    
    
    
