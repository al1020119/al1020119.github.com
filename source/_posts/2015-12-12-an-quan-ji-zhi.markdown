---
layout: post
title: "安全机制"
date: 2015-12-12 22:46:51 +0800
comments: true
categories: 性能相关
---
 

关于安全机制，作为一个程序员必须要时刻记住的，不然你的app不仅没有人用，还会被举报甚至更加严重，所以这里大概的总结了一下。


* 苹果安全机制
* ios开发安全处理

<!--more-->





***




苹果的安全机制


{% img /images/anquanjizhi001.png Caption %}  

客户端开发安全机制


{% img /images/anquanjizhi002.png Caption %}   

其中网络安全是非常重要的，所以总结了几个网络相关技术。



{% img /images/anquanjizhi003.png Caption %}  
***

概述：iOS应用程序因为其特殊性，被攻击的可能也是很高的。在开发过程中，需要从三个方面考虑程序安全性。

* iOS应用程序安全开发须知(一)
* iOS应用程序安全开发须知(二)
* iOS应用程序安全开发须知(三)

###网络安全

######安全地传输用户密码

大 部分的iOS应用都需要连网，通过和服务器端进行通信，获得最新的信息并且将内容展现给用户。由于网络传输过程中有可能经过不安全的中间节点，所以我们应 该对敏感数据加密，用于保证用户信息的安全。黑客可以在受害者的手机上设置网络通信的代理服务器，从而截获所有的网络请求。即使是HTTPS的加密通信， 黑客也可以通过中间人攻击（Man-In-The-Middle Attack，指的是攻击者与通信的两端分别创建独立的联系，并交换其所收到的数据，使通信的两端认为他们正在通过一个私密的连接与对方直接对话，但事实 上，整个会话都被攻击者完全控制）来截取通信内容。

黑客可以在Mac下使用Charles软件（如果在Windows下，可以使用 Fiddler软件）来将自己的电脑设置成代理服务器，从而截取应用的网络请求，分析目标应用在通信协议上是否有安全问题。为了测试，我选取了在国内最大 的两家租车公司（神州租车和一嗨租车）的iOS应用。

{% img /images/anquanjizhixiangjie001.jpg Caption %}  



从图1可以看到，神州租车和一嗨租车在用户登录时，均采用明文的方式，将密码直接发送给服务器。其中一嗨租车不但采用明文方式发送密码，而且在发送 时使用了Http Get的方式，而GET的URL数据一般都会保存在服务器的Access Log中，所以黑客一旦攻破服务器，只需要扫描Acesss Log，则可以轻易获得所有用户的明文密码（在本文发表前，一嗨租车已修改了登录协议，采用了POST的方式来登录，但仍然传递的是明文密码）。

如 果每一个移动应用都像以上两种应用那样，明文传输用户密码，那么我们可以想象这样一个场景：黑客在咖啡馆或机场等一些公共场所，将自己的电脑设置成与该场 所一样名字的免费Wi-Fi，受害者只要不小心使用了该Wi-Fi，则可能泄漏自己的明文密码。对于大多数普通人来说，他们会使用一样的密码登录他的所有 的账号，这就意味着他的其他账号：例如淘宝或网上银行账号也有被盗的风险。

正 确的做法应该是这样：事先生成一对用于加密的公私钥，客户端在登录时，使用公钥将用户的密码加密后，将密文传输到服务器。服务器使用私钥将密码解密，然后 加盐（Salt，在密码学中是指，通过在密码任意固定位置插入特定的字符串，让散列后的结果和使用原始密码的散列结果不相符，这个过程称为“加盐”），之 后再多次求MD5，然后再和服务器原来存储的用同样方法处理过的密码匹配，如果一致，则登录成功。这样的做法保证黑客即使截获了加密后的密文，由于没有私 钥，也无法还原出原始的密码。而服务器即使被黑客攻陷，黑客除了暴力尝试，也无法从加盐和多次MD5后的密码中还原出原始的密码。这就保证了用户密码的安 全。

######防止通信协议被轻易破解

除了上面提到的明文传输密码的问题外，移动端应用还要面对黑客对于通信协议的破解的威胁。

在 成功破解了通信协议后，黑客可以模拟客户端登录，进而伪造一些用户行为，可能对用户数据造成危害。例如腾讯出品的消除游戏《天天爱消除》，在淘宝上就有很 多售价仅为1元的代练服务，如果真正是人工代练，是不可能卖这么便宜的，只有可能是该游戏的通信协议被破解，黑客制作出了代练的机器人程序。通信协议被破 解除了对于移动端游戏有严重危害外，对于应用也有很大的危害。例如针对微信，黑客可以制作一些僵尸账号，通过向微信公共账号后台发送垃圾广告，达到赢利的 目的。而iPhone设备上的iMessage通信协议居然也被破解了，所以很多iPhone用户会收到来自iMessage的垃圾广告。

对 于以上提到的问题，开发者可以选择类似ProtoBuf（Google提供的一个开源数据交换格式，其最大的特点是基于二进制，因此比传统的JSON格式 要短小得多）之类的二进制通信协议或自己实现通信协议，对于传输的内容进行一定程度的加密，以增加黑客破解协议的难度。图2是我截取的淘宝客户端的通信数 据，可以看到其中的值都不能直观地猜出内容，所以这对于通信协议是有一定的保护作用。

{% img /images/anquanjizhixiangjie002.jpg Caption %}  



######验证应用内支付的凭证

iOS 应用内支付（IAP）是众多应用赢利的方式，通过先让用户免费试用或试玩，然后提供应用内支付来为愿意付费的用户提供更强大的功能，这种模式特别适合不习 惯一开始就掏钱的中国用户。但国内越狱用户的比例较大，所以我们也需要注意应用内支付环节中的安全问题。简单来说，越狱后的手机由于没有沙盒作为保护，黑 客可对系统进行任意地修改，所以在支付过程中，苹果返回的已付款成功的凭证可能是伪造的。客户端拿到付款凭证后，还需要将凭证上传到自己的服务器上，进行 二次验证，以保证凭证的真实性。

另外，我们发现越狱用户的手机上，很可能被黑客用中间人攻击技术来劫持支付凭证。这对于黑客有什么好处呢？ 因为苹果为了保护用户的隐私，支付凭证中并不包含任何用户的账号信息，所以我们的应用和服务器无法知道这个凭证是谁买的，而只能知道这个凭证是真的还是假 的。所以在验证凭证时，哪个账号发起了验证请求，我们就默认这个凭证是该账号拥有的。如果黑客将凭证截获，就可以伪装成真实用户来验证凭证或者转手出售获 利。

打个比方，这就类似于很多商场的购物卡一样，由于是不记名的，黑客如果将你买的购物卡偷窃然后去刷卡购物，商场是无法简单地区分出来的。因此，对于应用内支付，开发者除了需要仔细地验证购买凭证外，也需要告知用户在越狱手机上进行支付的风险。


###本地文件和数据安全

######程序文件的安全

iOS 应用的大部分逻辑都是在编译后的二进制文件中，但由于近年来混合式（Hybrid）编程方式的兴起，很多应用的部分功能也采用内嵌Web浏览器的方式来实 现。例如腾讯QQ iOS客户端的内部，就有部分逻辑是用Web方式实现的。由于iOS安装文件其实就是一个zip包，所以我们可以通过解压，看到包内的内容。以下是我解开 腾讯QQ客户端，看到的其qqapi.js文件的内容。

{% img /images/anquanjizhixiangjie003.jpg Caption %}  



可以看到，这些文件都有着完整清晰的注释。通过分析这些JavaScript文件，黑客可以很轻松地知道其调用逻辑。在越狱手机上，还可以修改这些JavaScript代码，达到攻击的目的。

我也曾尝试查看支付宝客户端中的彩票功能，通过分析，也可以找到其完整的、带着清晰注释的JavaScript代码，如图3所示（支付宝现在已对相应代码进行了加密）。

支付宝应用内的JavaScript文件
图3  支付宝应用内的JavaScript文件

{% img /images/anquanjizhixiangjie004.jpg Caption %}  


通过将JavaScript源码进行混淆和加密，可以防止黑客轻易地阅读和篡改相关的逻辑，也可以防止自己的Web端与Native端的通信协议泄漏。

######本地数据安全

iOS 应用的数据在本地通常保存在本地文件或本地数据库中。如果对本地的数据不进行加密处理，很可能被黑客篡改。比如一款名为《LepsWorld 3》的游戏，打开它的本地文件，可以很容易地找到，它使用了一个名为ItempLifes的变量保存生命数值（如图4所示）。于是我们可以简单修改该值， 达到修改游戏参数的目的。而在某宝上，也可以找到许多以此挣钱的商家。对于本地的重要数据，我们应该加密存储或将其保存到keychain中，以保证其不被篡改。

{% img /images/anquanjizhixiangjie005.jpg Caption %}  


 
 
###源代码安全

通过file、class-dump、theos、otool等工具，黑客可以分析编译之后的二进制程序文件，不过相对于这些工具来说，IDA的威胁最大。 IDA是一个收费的反汇编工具，对于Objective-C代码，它常常可以反汇编到可以方便阅读的程度，这对于程序的安全性，也是一个很大的危害。因为 通过阅读源码，黑客可以更加方便地分析出应用的通信协议和数据加密方式。

下面分别示例了一段代码的原始内容和通过IDA反汇编之后的结果。可以看到，IDA几乎还原了原本的逻辑，而且可读性也非常高。

原始代码：

{% img /images/anquanjizhixiangjie006.jpg Caption %}  



反汇编后：


{% img /images/anquanjizhixiangjie007.jpg Caption %}  


反 汇编的代码被获得后，由于软件内部逻辑相比汇编代码来说可读性高了很多。黑客可以用来制作软件的注册机，也可以更加方便地破解网络通信协议，从而制作出机 器人（“僵尸”）账号。最极端的情况下，黑客可以将反汇编的代码稍加修改，植入木马，然后重新打包发布在一些越狱渠道上，这将对用户产生巨大的危害。

对于IDA这类工具，我们的应对措施就比较少了。除了可以用一些宏来简单混淆类名外，也可以通过市面上收费的加密工具来实现，如：.NET Reactor v4.9  Dotfuscator DashO Pro v7.3 Zend Guard等，也达到复用的目的。

总结

由于移动互联网的快速发展，人们的购物、理财等需求也在移动端出现，使得移动应用的安全性越来越重要。由于部署在用户终端上，移动应用比服务器应用更容易被攻击，大家也需要在移动应用的网络通信、本地文件和数据、源代码三方面做好防范，只有这样才能保证应用安全。




######最后分享一份最近加密的demo，由于公司项目的需要，所以就整了一下这个！


	
	@interface ViewController ()
	@property (weak, nonatomic) IBOutlet UITextField *username;
	@property (weak, nonatomic) IBOutlet UITextField *pwd;
	- (IBAction)login;
	@end
	 
	@implementation ViewController
	 
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    // Do any additional setup after loading the view, typically from a nib.
	}
	 
	- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
	{
	    [self.view endEditing:YES];
	}
	 
	- (IBAction)login {
	    // 1.用户名
	    NSString *usernameText = self.username.text;
	    if (usernameText.length == 0) {
	        [MBProgressHUD showError:@"请输入用户名"];
	        return;
	    }
	 
	    // 2.密码
	    NSString *pwdText = self.pwd.text;
	    if (pwdText.length == 0) {
	        [MBProgressHUD showError:@"请输入密码"];
	        return;
	    }
	 
	    // 增加蒙板
	    [MBProgressHUD showMessage:@"正在拼命登录中...."];
	 
	    // 3.发送用户名和密码给服务器(走HTTP协议)
	    // 创建一个URL ： 请求路径
	    NSURL *url = [NSURL URLWithString:@"http://218.83.161.124:8080/job/login"];
	 
	    // 创建一个请求
	    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	 
	    // 5秒后算请求超时（默认60s超时）
	    request.timeoutInterval = 15;
	 
	    request.HTTPMethod = @"POST";
	 
	#warning 对pwdText进行加密
	    pwdText = [self MD5Reorder:pwdText];
	 
	    // 设置请求体
	    NSString *param = [NSString stringWithFormat:@"username=%@&pwd=%@", usernameText, pwdText];
	 
	    NSLog(@"%@", param);
	 
	    // NSString --> NSData
	    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
	 
	    // 设置请求头信息
	    [request setValue:@"iPhone 6" forHTTPHeaderField:@"User-Agent"];
	 
	    // 发送一个同步请求(在主线程发送请求)
	    // queue ：存放completionHandler这个任务
	    NSOperationQueue *queue = [NSOperationQueue mainQueue];
	    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:
	     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	         // 隐藏蒙板
	         [MBProgressHUD hideHUD];
	 
	        // 这个block会在请求完毕的时候自动调用
	        if (connectionError || data == nil) { // 一般请求超时就会来到这
	            [MBProgressHUD showError:@"请求失败"];
	            return;
	        }
	 
	        // 解析服务器返回的JSON数据
	        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
	        NSString *error = dict[@"error"];
	        if (error) {
	            [MBProgressHUD showError:error];
	        } else {
	            NSString *success = dict[@"success"];
	            [MBProgressHUD showSuccess:success];
	        }
	     }];
	}
	 
	/**
	 *  MD5($pass.$salt)
	 *
	 *  @param text 明文
	 *
	 *  @return 加密后的密文
	 */
	- (NSString *)MD5Salt:(NSString *)text
	{
	    // 撒盐：随机地往明文中插入任意字符串
	    NSString *salt = [text stringByAppendingString:@"aaa"];
	    return [salt md5String];
	}
	 
	/**
	 *  MD5(MD5($pass))
	 *
	 *  @param text 明文
	 *
	 *  @return 加密后的密文
	 */
	- (NSString *)doubleMD5:(NSString *)text
	{
	    return [[text md5String] md5String];
	}
	 
	/**
	 *  先加密，后乱序
	 *
	 *  @param text 明文
	 *
	 *  @return 加密后的密文
	 */
	- (NSString *)MD5Reorder:(NSString *)text
	{
	    NSString *pwd = [text md5String];
	 
	    // 加密后pwd == 3f853778a951fd2cdf34dfd16504c5d8
	    NSString *prefix = [pwd substringFromIndex:2];
	    NSString *subfix = [pwd substringToIndex:2];
	 
	    // 乱序后 result == 853778a951fd2cdf34dfd16504c5d83f
	    NSString *result = [prefix stringByAppendingString:subfix];
	 
	    NSLog(@"\ntext=%@\npwd=%@\nresult=%@", text, pwd, result);
	 
	    return result;
	}




资源分享：

原文地址：http://www.csdn.net/article/2014-05-28/2819994

通信安全工具：

[IP*Works! Internet Toolkit v9.0](http://www.evget.com/product/170)

[IP*Works! EDI/AS2 v9.0](http://www.evget.com/product/178)

[IP*Works! S/MIME v9.0](http://www.evget.com/product/173)      

[IP*Works! SSH](http://www.evget.com/product/1915)      

[IP*Works! SSL](http://www.evget.com/product/171)

代码混淆工具：

[.NET Reactor v4.9](http://www.evget.com/product/2399)

[Dotfuscator](http://www.evget.com/product/676)     

[DashO Pro v7.3](http://www.evget.com/product/1339)

[Zend Guard](http://www.evget.com/product/1339)

