---

layout: post
title: "网络开发总结"
date: 2014-07-25 13:53:19 +0800
comments: true
categories: 高级开发 

--- 
 
###一、一个HTTP请求的基本要素

1.请求URL：客户端通过哪个路径找到服务器

2.请求参数：客户端发送给服务器的数据

* 比如登录时需要发送的用户名和密码

3.返回结果：服务器返回给客户端的数据

* 一般是JSON数据或者XML数据

###二、基本的HTTP请求的步骤（移动客户端）
1.拼接"请求URL" + "?" + "请求参数"

* 请求参数的格式：参数名=参数值
* 多个请求参数之间用&隔开：参数名1=参数值1&参数名2=参数值2
* 比如：http://localhost:8080/MJServer/login?username=123&pwd=456

2.发送请求

3.解析服务器返回的数据

###三、JSON解析
1.利用NSJSONSerialization类解析

* JSON数据（NSData） --> Foundation-OC对象（NSDictionary、NSArray、NSString、NSNumber）
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

2.JSON解析规律

* { } --> NSDictionary @{ }
* [ ] --> NSArray @[ ]
* " " --> NSString @" "
* 10 --> NSNumber @10

###四、NSURLConnection
1.发布异步请求01--block回调

	+ (void)sendAsynchronousRequest:(NSURLRequest*) request
	    queue:(NSOperationQueue*) queue
	    completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler
* request : 需要发送的请求
* queue : 一般用主队列，存放handler这个任务
* handler : 当请求完毕后，会自动调用这个block

2.利用NSURLConnection发送请求的基本步骤
1> 创建URL

	NSURL *url = [NSURL URLWithString:@"http://4234324/5345345"];

2> 创建request

	NSURLRequest *request = [NSURLRequest requestWithURL:url];

3> 发送请求

	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:
	 ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	4> 处理服务器返回的数据
	
	 }];

###五、XML
1.语法
1> 文档声明

	<?xml version="1.0" encoding="UTF-8" ?>

2> 元素
3> 属性

	<videos>
	    <video name="小黄人 第01部" length="10"/>
	    <video name="小黄人 第01部" length="10"/>
	</videos>
	
* videos和video是元素（节点）
* name和length叫做元素的属性
* video元素是videos元素的子元素

2.解析
1> SAX解析：逐个元素往下解析，适合大文件

* NSXMLParser

2> DOM解析：一口气将整个XML文档加载进内存，适合小文件，使用最简单

* GDataXML

###六、HTTP的通信过程
1.请求
1> 请求行 : 请求方法、请求路径、HTTP协议的版本

	GET /MJServer/resources/images/1.jpg HTTP/1.1

2> 请求头 : 客户端的一些描述信息

* User-Agent : 客户端的环境（软件环境）

3> 请求体 : POST请求才有这个东西

* 请求参数，发给服务器的数据

2.响应
1> 状态行（响应行）: HTTP协议的版本、响应状态码、响应状态描述

HTTP/1.1 200 OK

2> 响应头：服务器的一些描述信息

* Content-Type : 服务器返回给客户端的内容类型
* Content-Length : 服务器返回给客户端的内容的长度（比如文件的大小）

3> 实体内容（响应体）

* 服务器返回给客户端具体的数据，比如文件数据

七、HTTP的请求方法
1.GET
1> 特点

* 所有请求参数都拼接在url后面

2> 缺点

* 在url中暴露了所有的请求数据，不太安全
* url的长度有限制，不能发送太多的参数

3> 使用场合

* 如果仅仅是向服务器索要数据，一般用GET请求

4> 如何发送一个GET请求

	* 默认就是GET请求
	// 1.URL
	
	NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
	// 2.请求
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	// 3.发送请求
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	}];

2.POST
1> 特点

* 把所有请求参数放在请求体（HTTPBody）中
* 理论上讲，发给服务器的数据的大小是没有限制

2> 使用场合

* 除开向服务器索要数据以外的请求，都可以用POST请求
* 如果发给服务器的数据是一些隐私、敏感的数据，绝对要用POST请求

3> 如何发送一个POST请求
	// 1.创建一个URL ： 请求路径
	
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/MJServer/login"];
	
	// 2.创建一个请求

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	// 设置请求方法
	request.HTTPMethod = @"POST";
	// 设置请求体 : 请求参数
	NSString *param = [NSString stringWithFormat:@"username=%@&pwd=%@", usernameText, pwdText];
	// NSString --> NSData
	request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];

###八、NSMutableURLRequest的常用方法
1.设置超时
	request.timeoutInterval = 5;
	// NSURLRequest是不能设置超时的，因为这个对象是不可变的

###九、URL转码
1.URL中不能包含中文，得对中文进行转码(加上一堆的%)

	NSString *urlStr = [NSString stringWithFormat:@"http://localhost/login?username=喝喝&pwd=123"];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	// urlStr == @"http://localhost/login?username=%E5%96%9D%E5%96%9D&pwd=123"

###十、数据安全
1.网络数据加密
1> 加密对象：隐私数据，比如密码、银行信息
2> 加密方案

* 提交隐私数据，必须用POST请求
* 使用加密算法对隐私数据进行加密，比如MD5
3> 加密增强：为了加大破解的难度

* 对明文进行2次MD5 ： MD5(MD5($pass))
* 先对明文撒盐，再进行MD5 ： MD5($pass.$salt)

2.本地存储加密


1> 加密对象：重要的数据，比如游戏数据

3.代码安全问题

1> 现在已经有工具和技术能反编译出源代码：逆向工程

* 反编译出来的都是纯C语言的，可读性不高
* 最起码能知道源代码里面用的是哪些框架

2> 参考书籍：《iOS逆向工程》

3> 解决方案：发布之前对代码进行混淆

 混淆之前

	@interface iCocosPerson :NSObject
	- (void)run;
	- (void)eat;
	@end
 
 混淆之后

	@interface A :NSObject
	- (void)a;
	- (void)b;
	@end

十一、监测网络状态

1.主动监测监测网络状态

	// 是否WIFI
	
	+ (BOOL)isEnableWIFI {
	    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
	}
	 
	
	// 是否3G
	
	+ (BOOL)isEnable3G {
	    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
	}

2.监控网络状态

1> 监听通知

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
 

2> 开始监听网络状态

	// 获得Reachability对象
	self.reachability = [Reachability reachabilityForInternetConnection];
	// 开始监控网络
	[self.reachability startNotifier];
 

3> 移除监听

	[self.reachability stopNotifier];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
 

————————————————————————————————————————————————————————————————————————————————————————

###一、大文件下载
1.方案：利用NSURLConnection和它的代理方法
1> 发送一个请求

	// 1.URL
	
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/MJServer/resources/videos.zip"];
	// 2.请求
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	// 3.下载(创建完conn对象后，会自动发起一个异步请求)
	
	[NSURLConnection connectionWithRequest:request delegate:self];

2> 在代理方法中处理服务器返回的数据

	/**
	 在接收到服务器的响应时：
	 1.创建一个空的文件
	 2.用一个句柄对象关联这个空的文件，目的是：方便后面用句柄对象往文件后面写数据
	 */
	
	- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
	
	{
	
	    // 文件路径
	
	    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	
	    NSString *filepath = [caches stringByAppendingPathComponent:@"videos.zip"];
	
	 
	
	    // 创建一个空的文件 到 沙盒中
	
	    NSFileManager *mgr = [NSFileManager defaultManager];
	
	    [mgr createFileAtPath:filepath contents:nil attributes:nil];
	
	 
	
	    // 创建一个用来写数据的文件句柄
	
	    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
	
	}
	
	
	/**
	 在接收到服务器返回的文件数据时，利用句柄对象往文件的最后面追加数据
	 */
	
	- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
	
	{
	
	    // 移动到文件的最后面
	
	    [self.writeHandle seekToEndOfFile];
	
	 
	
	    // 将数据写入沙盒
	
	    [self.writeHandle writeData:data];
	
	}
	
	
	/**
	 在所有数据接收完毕时，关闭句柄对象
	 */
	
	- (void)connectionDidFinishLoading:(NSURLConnection *)connection
	
	{
	
	    // 关闭文件
	
	    [self.writeHandle closeFile];
	
	    self.writeHandle = nil;
	
	}


2.注意点：千万不能用NSMutableData来拼接服务器返回的数据

###二、NSURLConnection发送异步请求的方法

1.block形式 - 除开大文件下载以外的操作，都可以用这种形式

	[NSURLConnection sendAsynchronousRequest:<#(NSURLRequest *)#> queue:<#(NSOperationQueue *)#> completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	}];

2.代理形式 - 一般用在大文件下载
	
	// 1.URL
	
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/MJServer/login?username=123&pwd=123"];
	// 2.请求
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	// 3.下载(创建完conn对象后，会自动发起一个异步请求)
	
	[NSURLConnection connectionWithRequest:request delegate:self];

###三、NSURLSession
1.使用步骤

1> 获得NSURLSession对象
2> 利用NSURLSession对象创建对应的任务（Task）
3> 开始任务（[task resume]）

2.获得NSURLSession对象

1> [NSURLSession sharedSession]

2>

	NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
	self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
3.任务类型
######1> NSURLSessionDataTask

用途：用于非文件下载的GET\POST请求

	NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
	NSURLSessionDataTask *task = [self.session dataTaskWithURL:url];
	NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
	}];

######2> NSURLSessionDownloadTask

用途：用于文件下载（小文件、大文件）

	NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
	NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:url];
	NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {   
	}];
 ————————————————————————————————————————————————————————————————
##AFN与ASI的区别（面试用）
###一、底层实现
1> AFN的底层基于OC的NSURLConnection和NSURLSession
2> ASI的底层基于纯C语言的CFNetwork框架
3> ASI的运行性能 高于 AFN

###二、对服务器返回的数据处理
1> ASI没有直接提供对服务器数据处理的方式，直接返回data\string
2> AFN提供了多种对服务器数据处理的方式

* JSON处理
* XML处理
* 其他处理

###三、监听请求的过程
1> AFN提供了success和failure两个block来监听请求的过程（只能监听成功和失败）

* success : 请求成功后调用
* failure : 请求失败后调用

2> ASI提供了3套方案，每一套方案都能监听请求的完整过程
（监听请求开始、接收到响应头信息、接受到具体数据、接受完毕、请求失败）

* 成为代理，遵守协议，实现协议中的代理方法
* 成为代理，不遵守协议，自定义代理方法
* 设置block

###四、在文件下载和文件上传的使用难易度
1> AFN

* 不容易监听下载进度和上传进度
* 不容易实现断点续传
* 一般只用来下载不大的文件

2> ASI

* 非常容易实现下载和上传
* 非常容易监听下载进度和上传进度
* 非常容易实现断点续传
* 下载或大或小的文件都行

###五、ASI提供了更多的实用功能
1> 控制圈圈要不要在请求过程中转
2> 可以轻松地设置请求之间的依赖：每一个请求都是一个NSOperation对象
3> 可以统一管理所有请求（还专门提供了一个叫做ASINetworkQueue来管理所有的请求对象）

* 暂停\恢复\取消所有的请求
* 监听整个队列中所有请求的下载进度和上传进度