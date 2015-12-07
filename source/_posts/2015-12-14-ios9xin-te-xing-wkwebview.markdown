---
layout: post
title: "iOS9新特性-WKWebView"
date: 2015-12-14 19:35:40 +0800
comments: true
categories: iOS9新特性
---

##一：WKWebView简单介绍##

webkit使用WKWebView来代替IOS的UIWebView和OSX的WebView，并且使用Nitro JavaScript引擎，这意味着所有第三方浏览器运行JavaScript将会跟safari一样快。
#####第一、WKWebView增加的属性和方法
类比UIWebView，跟UIWebView的API对比，
增加的属性：

	* 1、estimatedProgress 加载进度条，在IOS8之前我们是通过一个假的进度条来实现
	* 2、backForwardList 表示historyList
	* 3、WKWebViewConfiguration *configuration; 初始化webview的配置
增加的方法：

	- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration 
初始化

		- (WKNavigation *)goToBackForwardListItem:(WKBackForwardListItem *)item; 
跳到历史的某个页面
#####第二、相同的属性和方法

- goBack、
- goForward、
- canGoBack、
- canGoForward、
- stopLoading、
- loadRequest、
- scrollView

#####第三、被删去的属性和方法：
	- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
在跟js交互时，我们使用这个API，目前WKWebView完档没有给出实现类似功能的API

* 无法设置缓存
在UIWebView，使用NSURLCache缓存，通过setSharedURLCache可以设置成我们自己的缓存，但WKWebView不支持NSURLCache
#####第四、delegate方法的不同
UIWebView支持的代理是UIWebViewDelegate，WKWebView支持的代理是WKNavigationDelegate和
WKUIDelegate
WKNavigationDelegate主要实现了涉及到导航跳转方面的回调方法
WKUIDelegate主要实现了涉及到界面显示的回调方法：如WKWebView的改变和js相关内容
具体来说WKNavigationDelegate除了有开始加载、加载成功、加载失败的API外，还具有额外的三个代理方法：

		-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
这个代理是服务器redirect时调用
	
		-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
这个代理方法表示当客户端收到服务器的响应头，根据response相关信息，可以决定这次跳转是否可以继续进行。

		-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
根据webView、navigationAction相关信息决定这次跳转是否可以继续进行,这些信息包含HTTP发送请求，如头部包含User-Agent,Accept

***


##二、WKWebView新特性

* 在性能、稳定性、功能方面有很大提升（最直观的体现就是加载网页是占用的内存，模拟器加载百度与开源中国* 网站时，WKWebView占用23M，而UIWebView占用85M）；
* 允许JavaScript的Nitro库加载并使用（UIWebView中限制）；
* 支持了更多的HTML5特性；
* 高达60fps的滚动刷新率以及内置手势；
* 将UIWebViewDelegate与UIWebView重构成了14类与3个协议（查看苹果官方文档）；

***


##三：基本使用

WKWebView相对于UIWebView强大了很多，内存的消耗相对少了，所提供的接口也丰富了。
现在谈一谈WKWebView的基本使用
####1. navigationDelegate

	- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation { // 类似UIWebView的 -webViewDidStartLoad:  
	    NSLog(@"didStartProvisionalNavigation");  
	    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;  
	}  
	  
	- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {  
	    NSLog(@"didCommitNavigation");  
	}  
	  
	- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation { // 类似 UIWebView 的 －webViewDidFinishLoad:  
	    NSLog(@"didFinishNavigation");  
	    [self resetControl];  
	    if (webView.title.length > 0) {  
	        self.title = webView.title;  
	    }  
	  
	}  
	- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {  
	    // 类似 UIWebView 的- webView:didFailLoadWithError:  
	  
	    NSLog(@"didFailProvisionalNavigation");  
	      
	}  
	- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {  
	      
	    decisionHandler(WKNavigationResponsePolicyAllow);  
	}  
	  
	  
	- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {  
	    // 类似 UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:  
	  
	    NSLog(@"4.%@",navigationAction.request);  
	  
	      
	    NSString *url = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  
	  
	      
	      
	    decisionHandler(WKNavigationActionPolicyAllow);  
	  
	}  
	- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {  
	      
	}  

####2 UIDelegate 

	- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {  
	    // 接口的作用是打开新窗口委托  
	    [self createNewWebViewWithURL:webView.URL.absoluteString config:configuration];  
	      
	    return currentSubView.webView;  
	}  
	  
	- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler  
	{    // js 里面的alert实现，如果不实现，网页的alert函数无效  
	    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message  
	                                                                             message:nil  
	                                                                      preferredStyle:UIAlertControllerStyleAlert];  
	    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"  
	                                                        style:UIAlertActionStyleCancel  
	                                                      handler:^(UIAlertAction *action) {  
	                                                          completionHandler();  
	                                                      }]];  
	      
	    [self presentViewController:alertController animated:YES completion:^{}];  
	      
	}  
	  
	  
	- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {  
	    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,   
	  
	    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message  
	                                                                             message:nil  
	                                                                      preferredStyle:UIAlertControllerStyleAlert];  
	    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"  
	                                                        style:UIAlertActionStyleDefault  
	                                                      handler:^(UIAlertAction *action) {  
	                                                          completionHandler(YES);  
	                                                      }]];  
	    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"  
	                                                        style:UIAlertActionStyleCancel  
	                                                      handler:^(UIAlertAction *action){  
	                                                          completionHandler(NO);  
	                                                      }]];  
	      
	    [self presentViewController:alertController animated:YES completion:^{}];  
	      
	}  
	  
	- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {  
	      
	    completionHandler(@"Client Not handler");  
	      
	}  


####3. WKWebView 执行脚本方法 
	- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;  
 
	completionHandler 拥有两个参数，一个是返回错误，一个可以返回执行脚本后的返回值  
####4. WKWebView 的Cookie问题
UIWebView 中会自动保存Cookie，如果登录了一次，下次再次进入的时候，会记住登录状态
而在WKWebView中，并不会这样，WKWebView在初始化的时候有一个方法 

	- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration  
通过这个方法，设置 configuration 让WKWebView知道登录状态，configuration 可以通过已有的Cookie进行设置，也可以通过保存上一次的configuration进行设置
参考 stackoverflow上回答：http://stackoverflow.com/questions/26573137/can-i-set-the-cookies-to-be-used-by-a-wkwebview/26577303#26577303 

	WKWebView * webView = /*set up your webView*/  
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/index.html"]];  
	[request addValue:@"TeskCookieKey1=TeskCookieValue1;TeskCookieKey2=TeskCookieValue2;" forHTTPHeaderField:@"Cookie"];  
	// use stringWithFormat: in the above line to inject your values programmatically  
	[webView loadRequest:request];  
	
	[objc] view plaincopyprint?在CODE上查看代码片派生到我的代码片
	WKUserContentController* userContentController = WKUserContentController.new;  
	WKUserScript * cookieScript = [[WKUserScript alloc]   
	    initWithSource: @"document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';"  
	    injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];  
	// again, use stringWithFormat: in the above line to inject your values programmatically  
	[userContentController addUserScript:cookieScript];  
	WKWebViewConfiguration* webViewConfig = WKWebViewConfiguration.new;  
	webViewConfig.userContentController = userContentController;  
	WKWebView * webView = [[WKWebView alloc] initWithFrame:CGRectMake(/*set your values*/) configuration:webViewConfig];  

***



##四：WKWebView与js通信

iOS 8 引入WKWebView, WKWebView 不支持JavaScriptCore的方式但提供message handler的方式为JavaScript 与Objective-C 通信.
在Objective-C 中使用WKWebView的以下方法调用JavaScript:

	- (void)evaluateJavaScript:(NSString *)javaScriptString
	         completionHandler:(void (^)(id, NSError *))completionHandler
	如果JavaScript 代码出错, 可以在completionHandler 进行处理.
	在Objective-C 中注册 message handler:
	// WKScriptMessageHandler protocol?
	
	- (void)userContentController:(WKUserContentController *)userContentController
	    didReceiveScriptMessage:(WKScriptMessage *)message
	{
	    NSLog(@"Message: %@", message.body);
	}
	
	[userContentController addScriptMessageHandler:handler name:@"myName"];
	在JavaScript 将信息发给Objective-C:
	// window.webkit.messageHandlers.<name>.postMessage();?
	
	function postMyMessage()? {?
	    var message = { 'message' : 'Hello, World!', 'numbers' : [ 1, 2, 3 ] };?
	    window.webkit.messageHandlers.myName.postMessage(message);?
	}


***



##五：常见问题：

32 位的app在使用WKWebView的时候，如果运行在64位的设备上，会出现一下问题：

* （1）iOS8.1 系统，部分网页加载白屏，例如 百度，iOS8.3 似乎没问题
* （2）web输入框输入汉字也会出现白屏

通过搜索得到问题根源：
> WKWebView's WebProcess runs out-of-process as a 64-bit process on hardware supporting 64bit. There is a 32bit/64bit marshalling IPC bug for 32 bit apps using the WKWebView client on such hardware. The bug causes the WebProcess to exit, leaving a blank screen.



* 也就是一个进程间通讯的bug引起的。

######解决方案，可以使app支持arm64，便不会出现问题。