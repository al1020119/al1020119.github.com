---
layout: post
title: "iOS9-WKWebView+SFSafariViewController"
date: 2015-12-14 19:35:40 +0800
comments: true
categories: 新技术
---

##一：WKWebView简单介绍##

webkit使用WKWebView来代替IOS的UIWebView和OSX的WebView，并且使用Nitro JavaScript引擎，这意味着所有第三方浏览器运行JavaScript将会跟safari一样快。


先来看看WKWebView和UIWebView有什么区别：

######UIWebView：

* 始祖级别，支持的iOS版本比较多
* 可支持打开URL，包括各种URL模式，例如 Https，FTP等
* 可支持打开各种不同文件格式，例如 txt，docx，ppt,，音视频文件等，很多文档阅读器会经常使用这个特性，感兴趣的可以查一下Apple的文档，支持的格式还是挺多，只是不同iOS 版本的支持程度不太一样，使用时请多留意测试确认~
* 占用内存比较多，尤其是网页中包含比较多CSS+DIV之类内容时，很容易出现内存警告（Memory Warning）
* 效率低，不灵活，尤其是和 JavaScript交互时
* 无法清除本地存储数据（Local Storage）
* 代理（delegate）之间的回调比较麻烦，提供的内容比较低级，尤其是UI部分。如果想自己定制一个类似 Safari 的内嵌浏览器（Browser），那就坑爹无极限了，例如我们PDF Reader系列中的内嵌Browser，自己* 手动模拟实现Tab切换，底部Tool及各种Menu等，说多了都是泪~~
 

######WKWebView：

* iOS 8引入的，比较年轻
* 在内存和执行效率上要比UIWebView高很多
* 开放度较高但据说Bug成吨
* 类似UIWebView，UI定制比较麻烦···
* 没具体测试使用过，就不继续列举了 L~



<!--more-->



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



<!--more-->


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


参考 stackoverflow上回答：

[http://stackoverflow.com/questions/26573137/can-i-set-the-cookies-to-be-used-by-a-wkwebview/26577303#26577303](http://stackoverflow.com/questions/26573137/can-i-set-the-cookies-to-be-used-by-a-wkwebview/26577303#26577303) 

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


***



##六：SFSafariViewController：

* iOS 9引入，更加年轻，意味着是Apple的新菜，总是有什么优势的
* 也是用来显示网页内容的
* 这是一个特殊的View Controller，而不是一个单独的 View，和前面两个的区别
* 在当前App中使用Safari的UI框架展现Web内容，包括相同的地址栏，工具栏等，类似一个内置于App的小型Safari
* 共享Safari的一些便利特性，包括：相似的用户体验，和Safari共享Cookie，iCloud Web表单数据，密码、证书自动填充，Safari阅读器（Safari Reader）
* 可定制性比较差，甚至连地址栏都是不可编辑的，只能在init的时候，传入一个URL来指定网页的地址
* 只能用来展示单个页面，并且有一个完成按钮用来退出




{% img /images/safari001.png Caption %}  

 

如果你的App需要显示网页，但是又不想自己去定制浏览器界面的话，可以考虑用SFSafariViewController来试试。从好的方面看，SFSafariViewController也去掉了从App中跳转到Safari的撕裂感，不同App之间切换总是让人感觉麻烦和不舒服。

代码例子:

	- (IBAction)onButtonClick:(id)sender
	
	{
	
	    NSString *urlString = @"http://www.kdanmobile.com";
	
	    SFSafariViewController *sfViewControllr = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
	
	    sfViewControllr.delegate = self;
	
	    [self presentViewController:sfViewControllr animated:YES completion:^{
	
	       //...
	
	    }];
	
	}
	
	 
	
	// Done 按钮
	
	- (void)safariViewControllerDidFinish:(nonnull SFSafariViewController *)controller
	
	{
	
	    [controller dismissViewControllerAnimated:YES completion:nil];
	
	}

 

SFSafariViewController 的接口比较少，就不再继续一一列举了。另外一个定制功能在于SFSafariViewControllerDelegate里面的一个方法：

 

	-(NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL title:(nullable NSString *)title;

 

这个代理会在用户点击动作（Action）按钮（底部工具栏中间的按钮）的时候调用，可以传入UIActivity的数组，创建添加一些自定义的各类插件式的服务，比如分享到微信，微博什么的。



{% img /images/safari001.png Caption %}  

 

> 小细节：
SFSafariViewController有保存Cookies的功能，但是貌似不能和Safari浏览器共享，也可能是Beta版的bug
 

