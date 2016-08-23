---
layout: post
title: "Cookie是撒(&session）"
date: 2016-01-22 13:32:08 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---
 
 



引言：

1. 简单说不管是NSURLConnection还是UIWebView都会保留并传递服务端的cookie，重启进程，或重启系统cookie都在应用中。

2. 多个应用间默认是不共亨cookie的

3. 删除重装应用cookie会被清除 


####一. Cookie介绍

Cookie是在客户端存储服务器状态的一种机制,Web服务器可以通过Set-Cookie或者Set-Cookie2 HTTP头部设置Cookie。

Cookie可以分为两类

* 会话Cookie
* 持久Cookie
 
会话Cookie是临时Cookie,当前会话结束(浏览器退出)时Cookie会被删除。

持久Cookie会存储在用户的硬盘上,浏览器退出，然后重新启动后Cookie仍然存在。会话Cookie和持久Cookie的区别在于过期时间，如果设置了Discard参数(Cookie 版本1)或者没有设置Expires(Cookie版本0)或Max-Age(Cookie版本1)设置过期时间，则此Cookie为会话Cookie

Cookie有两个版本,一个是版本0(Netscape Cookies)和版本1(RFC 2965),目前大多数服务器使用的Cookie 0。
  

####二. NSHTTPCookie


<!--more-->



在iOS中使用NSHTTPCookie类封装一条cookie,通过NSHTTPCookie的方法读取到cookie的通用属性。

	- (NSUInteger)version;
	- (NSString *)name;
	- (NSString *)value;
	- (NSString *)domain;
	- (NSString *)path;
	- (BOOL)isSessionOnly;
等


可以通过手工赋值的方式创建Cookie,如

	+ (id)cookieWithProperties:(NSDictionary *)properties;
	- (id)initWithProperties:(NSDictionary *)properties;
也可以从Cookie中读取到所有属性。

	- (NSDictionary *)properties;

使用NSHTTPCookie的类方法可以将NSHTTPCookie实例与HTTP cookie header相互转换.
根据NSHTTPCookie实例数组生成对应的HTTP cookie header

	+ (NSDictionary *)requestHeaderFieldsWithCookies:(NSArray *)cookies;

从headerFileds中读取到Cookie相关内容,生成NSHTTPCookie实例对象数组。
	
	+ (NSArray *)cookiesWithResponseHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)theURL;
该方法会忽略headerFileds中与cookie无关的字段，如果headerFileds中的cookie没有指定domain,则使用theURL的domain,如果没有指定path,则使用”/”.

除非NSURLRequest明确指定不使用cookie(HTTPShouldHandleCookies设为NO),否则URL loading system会自动为NSURLRequest发送合适的存储cookie。从NSURLResponse返回的cookie也会根据当前的cookie访问策略(cookie acceptance policy)接收到系统中。

####三.NSHTTPCookieStorage

NSHTTPCookieStorage单件类提供了管理所有NSHTTPCookie对象的接口，在OS X里,cookie是在所有程序中共享的，而在iOS中,cookie只当当前应用中有效。

通过sharedHTTPCookieStorage方法可获取到共享的NSHTTPCookieStorage单件对象。

	+ (NSHTTPCookieStorage *)sharedHTTPCookieStorage；

使用NSHTTPCookieStorage单件对象可获取到当前存储的所有cookie
	
	- (NSArray *)cookies
或针对特定URL的cookie

	- (NSArray *)cookiesForURL:(NSURL *)theURL;

还可以添加/删除Cookie

	– deleteCookie:
	– setCookie:
	– setCookies:forURL:mainDocumentURL:

通过NSHTTPCookieStorage可读取/修改cookie接收策略,默认为NSHTTPCookieAcceptPolicyAlways.

	- (NSHTTPCookieAcceptPolicy)cookieAcceptPolicy；
	- (void)setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)aPolicy.

一共有三种cookie accept policy,

	typedef enum {
	   NSHTTPCookieAcceptPolicyAlways,
	   NSHTTPCookieAcceptPolicyNever,
	   NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain
	} NSHTTPCookieAcceptPolicy;
	
	NSHTTPCookieAcceptPolicyAlways:接收所有cookie,默认策略.
	NSHTTPCookieAcceptPolicyNever: 拒绝所有cookie
	NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain:只接收main document domain中的cookie.


####四.相关通知

	NSHTTPCookieManagerCookiesChangedNotification
当NSHTTPCookieStorage实例中的cookies变化时发出此通知。

	NSHTTPCookieManagerAcceptPolicyChangedNotification
当NSHTTPCookieStorage实例的cookie acceptance policy变化时发出此通知。

####五：Cookie的三大常见操作
 
######1，获取cookie
获取cookie只能在请求中获取cookie，否则时获取不到的，url就不给出了，大家用自己的url测试一下就行。
获取到cookie后把cookie进行归档保存到userDefaults里 
	
	#pragma mark 获取并保存cookie到userDefaults
	- (void)getAndSaveCookie
	{
	    NSLog(@"=============获取cookie==============");
	    NSString *urlString = @"";
	 
	    //请求一个网址，即可分配到cookie
	    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	    manager.responseSerializer = [AFJSONResponseSerializer new];
	    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
	 
	        //获取cookie
	        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	        for (NSHTTPCookie *tempCookie in cookies) {
	            //打印获得的cookie
	            NSLog(@"getCookie: %@", tempCookie);
	        }
	 
	        /*
	         * 把cookie进行归档并转换为NSData类型
	         * 注意：cookie不能直接转换为NSData类型，否则会引起崩溃。
	         * 所以先进行归档处理，再转换为Data
	         */
	        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
	 
	        //存储归档后的cookie
	        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	        [userDefaults setObject: cookiesData forKey: @"cookie"];
	        NSLog(@"\n");
	 
	        [self deleteCookie];
	 
	        [self setCoookie];
	 
	    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	 
	        nil;
	    }];
	}

######2，删除cookie
把获取到的cookie删除掉，该步骤可以用在注销或者切换账号里。
当前，我这里删除cookie是为了检测后面的通过本地存储的数据进行设置cookie是否成功 
	
	#pragma mark 删除cookie
	- (void)deleteCookie
	{
	    NSLog(@"============删除cookie===============");
	    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	 
	    //删除cookie
	    for (NSHTTPCookie *tempCookie in cookies) {
	        [cookieStorage deleteCookie:tempCookie];
	    }
	 
	    //把cookie打印出来，检测是否已经删除
	    NSArray *cookiesAfterDelete = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	    for (NSHTTPCookie *tempCookie in cookiesAfterDelete) {
	        NSLog(@"cookieAfterDelete: %@", tempCookie);
	    }
	    NSLog(@"\n");
	}

######3，通过本地存储的数据设置cookie
把本地的cookie取出并反归档，设置到cookie中，并且检测cookie是否设置成功 
	
	#pragma mark 再取出保存的cookie重新设置cookie
	- (void)setCoookie
	{
	    NSLog(@"============再取出保存的cookie重新设置cookie===============");
	    //取出保存的cookie
	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	 
	    //对取出的cookie进行反归档处理
	    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"cookie"]];
	 
	    if (cookies) {
	        NSLog(@"有cookie");
	        //设置cookie
	        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	        for (id cookie in cookies) {
	            [cookieStorage setCookie:(NSHTTPCookie *)cookie];
	        }
	    }else{
	        NSLog(@"无cookie");
	    }
	 
	    //打印cookie，检测是否成功设置了cookie
	    NSArray *cookiesA = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	    for (NSHTTPCookie *cookie in cookiesA) {
	        NSLog(@"setCookie: %@", cookie);
	    }
	    NSLog(@"\n");
	}

看一下运行截图


{% img /images/cookie001.png Caption %}  


####六：Cookie与Session的却别

具体来说cookie机制采用的是在客户端保持状态的方案，而session机制采用的是在服务器端保持状态的方案。


    cookie数据存放在客户的浏览器上，session数据放在服务器上；
    cookie不是很安全，别人可以分析存放在本地的COOKIE并进行COOKIE欺骗，考虑到安全应当使用session；
    session会在一定时间内保存在服务器上。当访问增多，会比较占用你服务器的性能。考虑到减轻服务器性能方面，应当使用COOKIE；
    单个cookie在客户端的限制是3K，就是说一个站点在客户端存放的COOKIE不能超过3K；

Cookie和Session的方案虽然分别属于客户端和服务端，但是服务端的session的实现对客户端的cookie有依赖关系的，上面我讲到服务端执行session机制时候会生成session的id值，这个id值会发送给客户端，客户端每次请求都会把这个id值放到http请求的头部发送给服务端，而这个id值在客户端会保存下来，保存的容器就是cookie，因此当我们完全禁掉浏览器的cookie的时候，服务端的session也会不能正常使用（注意：有些资料说ASP解决这个问题，当浏览器的cookie被禁掉，服务端的session任然可以正常使用，ASP我没试验过，但是对于网络上很多用php和jsp编写的网站，我发现禁掉cookie，网站的session都无法正常的访问）。


######Cookie的优缺点：

* 优点：极高的扩展性和可用性
	- 通过良好的编程，控制保存在cookie中的session对象的大小。
	通过加密和安全传输技术（SSL），减少cookie被破解的可能性。
	只在cookie中存放不敏感数据，即使被盗也不会有重大损失。
	控制cookie的生命期，使之不会永远有效。偷盗者很可能拿到一个过期的cookie。

* 缺点：
	- Cookie数量和长度的限制。每个domain最多只能有20条cookie，每个cookie长度不能超过4KB，否则会被截掉。
安全性问题。如果cookie被人拦截了，那人就可以取得所有的session信息。即使加密也与事无补，因为拦截者并不需要知道cookie的意义，他只要原样转发cookie就可以达到目的了。
有些状态不可能保存在客户端。例如，为了防止重复提交表单，我们需要在服务器端保存一个计数器。如果我们把这个计数器保存在客户端，那么它起不到任何作用。

######Session的优缺点：

* 优点

	- 如果要在诸多Web页间传递一个变量，那么用Session变量要比通过QueryString传递变量可使问题简化。

	- 要使WEb站点具有用户化，可以考虑使用Session变量。你的站点的每位访问者都有用户化的经验，基于此，随着LDAP和诸如MS Site

	- Server等的使用，已不必再将所有用户化过程置入Session变量了，而这个用户化是取决于用户喜好的。

	- 你可以在任何想要使用的时候直接使用session变量，而不必事先声明它，这种方式接近于在VB中变量的使用。使用完毕后，也不必考虑将其释放，因为它将自动释放。

* 缺点

	- Session变量和cookies是同一类型的。如果某用户将浏览器设置为不兼容任何cookie，那么该用户就无法使用这个Session变量！

参考：
[http://my.oschina.net/xianggao/blog/395675](http://my.oschina.net/xianggao/blog/395675)


===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  