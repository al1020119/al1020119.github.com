---
layout: post
title: "玩转iOS10+Xcode8适配"
date: 2016-10-12 11:34:34 +0800
comments: true
categories: 

---
最近因为公司App在iOS10上出现很多问题，结果花了一天时间适配了一下，其中也遇到了不少坑，有些网上直接有方法，但是有些却需要细心琢磨。这里整理了一下。

其中有两个比较麻烦的

+ 1：关于导航栏的适配
	- 当导航栏是透明或者半透明的实现，显示不正常，全白。

+ 2：关于tabBar的适配
	- tabbar中第一个子控制器的Item重复出现



下面一个个整理了一下！



<!--more-->


##1.Xcode8运行项目之后，控制台打印了一堆东西;

去除方法：选择Xcode ->Product ->Scheme -> Edit Scheme 或者按command + shift + < 快捷键，

在弹出的窗口中Environment Variables 下添加 0S_ACTIVITY_MODE=disable


{% img /images/ios10shipei001.png Caption %}  

> 注：真机调试不输出NSlog了，所以我真机调试的时候，把此处对号去除，就好了

#####最新Log方式：（会定位某各类，某个方法，某一行）


	#ifdef DEBUG
	#define iCocosLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
	#else
	#define iCocosLog(format, ...)
	#endif




##2.Xcode8 打开工程后，出现下图，苹果新特性


{% img /images/ios10shipei002.png Caption %}  

我勾选了Automatically manage signing(需要在Xcode的偏好设置中，添加苹果账号)，并且选择配置了Team，就好了。

> 注：或者另外一种方式  点击打开链接

##3.用Xcode8 运行项目在真机上，打开相机相册功能，程序崩溃；

解决办法：项目中访问了隐私数据，需要在info.plist中添加这些权限：

相机权限

	<key>NSCameraUsageDescription</key>
	
	<string>cameraDesciption</string>

相册权限

	<key>NSPhotoLibraryUsageDescription</key>
	
	<string>photoLibraryDesciption</string>

注：
在CODE上查看代码片派生到我的代码片

    <!-- 相册 -->   
    <key>NSPhotoLibraryUsageDescription</key>   
    <string>App需要您的同意,才能访问相册</string>   
    <!-- 相机 -->   
    <key>NSCameraUsageDescription</key>   
    <string>App需要您的同意,才能访问相机</string>   
    <!-- 麦克风 -->   
    <key>NSMicrophoneUsageDescription</key>   
    <string>App需要您的同意,才能访问麦克风</string>   
    <!-- 位置 -->   
    <key>NSLocationUsageDescription</key>   
    <string>App需要您的同意,才能访问位置</string>   
    <!-- 在使用期间访问位置 -->   
    <key>NSLocationWhenInUseUsageDescription</key>   
    <string>App需要您的同意,才能在使用期间访问位置</string>   
    <!-- 始终访问位置 -->   
    <key>NSLocationAlwaysUsageDescription</key>   
    <string>App需要您的同意,才能始终访问位置</string>   
    <!-- 日历 -->   
    <key>NSCalendarsUsageDescription</key>   
    <string>App需要您的同意,才能访问日历</string>   
    <!-- 提醒事项 -->   
    <key>NSRemindersUsageDescription</key>   
    <string>App需要您的同意,才能访问提醒事项</string>   
    <!-- 运动与健身 -->   
    <key>NSMotionUsageDescription</key> <string>App需要您的同意,才能访问运动与健身</string>   
    <!-- 健康更新 -->   
    <key>NSHealthUpdateUsageDescription</key>   
    <string>App需要您的同意,才能访问健康更新 </string>   
    <!-- 健康分享 -->   
    <key>NSHealthShareUsageDescription</key>   
    <string>App需要您的同意,才能访问健康分享</string>   
    <!-- 蓝牙 -->   
    <key>NSBluetoothPeripheralUsageDescription</key>   
    <string>App需要您的同意,才能访问蓝牙</string>   
    <!-- 媒体资料库 -->   
    <key>NSAppleMusicUsageDescription</key>   
    <string>App需要您的同意,才能访问媒体资料库</string>  

如果没有用，需配置一下


{% img /images/ios10shipei003.png Caption %}  

> 注意，添加的时候，末尾不要有空格，值得说明必须要要写不写也会崩溃


我们需要打开info.plist文件添加相应权限的说明，否则程序在iOS10上会出现崩溃。

##4.字体变大，原有的fream需要适配

经有的朋友提醒，发现程序内原来2个字的宽度是24，现在2个字需要27的宽度来显示了。。我只能试着一个个智能逐一排查!

+ 希望有解决办法的朋友，评论告我一下耶，谢谢啦

##5.Nib问题：警告

在CODE上查看代码片派生到我的代码片

    - (void)awakeFromNib {  
        // Initialization code  
    }  

需要添加：
在CODE上查看代码片派生到我的代码片

    [super awakeFromNib];  


##6.UIApplication对象中openUrl被废弃

在iOS 10以前，我们要想使用应用程序去打开一个网页或者进行跳转，直接使用[[UIApplication sharedApplication] openURL 方法就可以了，但是在iOS 10 已经被废弃了，因为使用这种方式，处理的结果我们不能拦截到也不能获取到，对于开发是非常不利的，在iOS 10全新的退出了 
	
	[[UIApplication sharedApplication] openURL:nil options:nil completionHandler:nil];
	
有一个成功的回调block 可以进行监视。

> 注：仍然可以用，只不过会出现警告


##7.系统判断失效 
现在改用：
在CODE上查看代码片派生到我的代码片

    #define LIOS10_OR_LATER  ([[[UIDevice currentDevice]systemVersion]compare:@"10.0" options:NSNumericSearch] !=NSOrderedAscending)  


##8.代码注释不能用
解决方法：
	
	打开终端，命令运行： sudo /usr/libexec/xpccachectl

然后必须重启电脑后生效

> Xcode8已经不能再使用第三方插件了，但是Xcode8已经完善了一部分第三方插件才能实现的功能（抹杀了第三方插件作者，掠夺别人的劳动成果），比如语法提示、代码注释。


> Xcode8代码注释快捷键为 Command + Option + / 。

##9.导航栏适配

因为使用了"UINavigationBar+Awesome.h"这个框架，所以，最后找来找去，找到了这个框架的底层，修改代码发现既然可以。

    if (!self.overlay) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + 20)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;    // Should not set `UIViewAutoresizingFlexibleHeight`
        [[self.subviews firstObject] insertSubview:self.overlay atIndex:0];
    }
    self.overlay.backgroundColor = backgroundColor;

##10.导航的图片不显示了,使用的是系统导航,怎么调整都不显示.


解决问题
找到原因了,修改代码就比较容易了,你可以在添加视图时,将bgView指定到UIVisualEffectView,将新的视图添加到UIVisualEffectView上:

	for (UIView  * v in subs)
	    {
	        NSString * classname = NSStringFromClass([v class]);
	        if ([classname isEqualToString:@"_UINavigationBarBackground"] || [classname isEqualToString:@"UINavigationBarBackground"])
	        {
	
	            bgview=v;
	            break;
	        }  else if ([classname isEqualToString:@"_UIBarBackground"]) {
	            //适配iOS10导航
	            for (UIView *vi in v.subviews) {
	
	                NSString *viName = NSStringFromClass([vi class]);
	                if ([viName isEqualToString:@"UIVisualEffectView"]) {
	
	                    bgview = vi;
	                    break;
	                }
	            }
	        }
	    }


也可以还添加到_UIBarBackground上,但是找到UIVisualEffectView,将其隐藏掉:

	if ([classname isEqualToString:@"_UINavigationBarBackground"] || [classname isEqualToString:@"UINavigationBarBackground"])
	        {
	
	            bgview=v;
	            break;
	        } else if ([classname isEqualToString:@"_UIBarBackground"]) {
	
	            bgview = v;
	
	            for (UIView *vi in v.subviews) {
	                // 适配iOS10
	                NSString *viName = NSStringFromClass([vi class]);
	                if ([viName isEqualToString:@"UIVisualEffectView"]) {
	
	                    vi.hidden = YES;
	                    break;
	                }
	            }
	        }

##11.Xcode7 8SB兼容问题

控制器报如下错误：
	
	This version does not support documents saved in the Xcode 8 format. Open this document with Xcode 8.0 or later.

右键SB，选择Open As -> Source Code，并删除下面代码即可：
	
	<capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>

{% img /images/ios10shipei004.png Caption %}  



##12.推送

如下图的部分，不要忘记打开。所有的推送平台，不管是极光还是什么的，要想收到推送，这个是必须打开的哟✌️

{% img /images/ios10shipei005.png Caption %}  

之后就应该可以收到推送了。另外，极光推送也推出新版本了，大家也可以更新下。

PS.苹果这次对推送做了很大的变化，希望大家多查阅查阅，处理推送的代理方法也变化了。

// 推送的代理

	[<UNUserNotificationCenterDelegate>]

iOS10收到通知不再是在

	[application: didReceiveRemoteNotification:]

方法去处理， iOS10推出新的代理方法，接收和处理

各类通知（本地或者远程）

	- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler 
	{ 
	//应用在前台收到通知 NSLog(@"========%@", notification);
	}
	
	
	- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler { 
	//点击通知进入应用 NSLog(@"response:%@", response);
	}
UserNotifications(用户通知)

    iOS 10 中将通知相关的 API 都统一了,苹果对这是做了重大改进，变的非常易用。

        iOS 9 以前的通知

    在调用方法时，有些方法让人很难区分，容易写错方法，这让开发者有时候很苦恼。
    应用在运行时和非运行时捕获通知的路径还不一致。
    应用在前台时，是无法直接显示远程通知，还需要进一步处理。
    已经发出的通知是不能更新的，内容发出时是不能改变的，并且只有简单文本展示方式，扩展性根本不是很好。

        iOS 10 开始的通知

    所有相关通知被统一到了UserNotifications.framework框架中。
    增加了撤销、更新、中途还可以修改通知的内容。
    通知不在是简单的文本了，可以加入视频、图片，自定义通知的展示等等。
    iOS 10相对之前的通知来说更加好用易于管理，并且进行了大规模优化，对于开发者来说是一件好事。
    iOS 10开始对于权限问题进行了优化，申请权限就比较简单了(本地与远程通知集成在一个方法中)。
    
    
##13.代码及Api注意

使用Xcode8之后，有些代码可能就编译不过去了，具体我就说说我碰到的问题。

1.UIWebView的代理方法：

> **注意要删除NSError前面的 nullable，否则报错。

	- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
	{
	    [self hideHud];
	}

##14.Xib文件的注意事项

使用Xcode8打开xib文件后，会出现下图的提示。


{% img /images/ios10shipei006.png Caption %}  


大家选择Choose Device即可。
之后大家会发现布局啊，frame乱了，只需要更新一下frame即可。如下图


{% img /images/ios10shipei007.png Caption %}  

    注意：如果按上面的步骤操作后，在用Xcode7打开Xib会报一下错误，



{% img /images/ios10shipei008.png Caption %}  

 
#####解决办法：需要删除Xib里面

    <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>

    这句话，以及把< document >中的toolsVersion和< plugIn >中的version改成你正常的xib文件中的值
    ，不过不建议这么做，在Xcode8出来后，希望大家都快速上手，全员更新。这就跟Xcode5到Xcode6一样，有变动，但是还是要尽早学习，尽快适应哟！



##15.UIRefreshControl

在iOS 10 中, UIRefreshControl可以直接在UICollectionView和UITableView中使用,并且脱离了UITableViewController.现在RefreshControl是UIScrollView的一个属性.
    使用方法:

	//创建
	 UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	 refreshControl.tintColor = [UIColor redColor];
	 refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"正在刷新"];
	 [refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
	
	 //开始和停止刷新
	 [refreshControl beginRefreshing];
	 [refreshControl endRefreshing];

也可以进去头文件查看

	#import
	
	- (instancetype)init;
	
	@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
	
	@property (null_resettable, nonatomic, strong) UIColor *tintColor;
	@property (nullable, nonatomic, strong) NSAttributedString *attributedTitle UI_APPEARANCE_SELECTOR;
	
	// May be used to indicate to the refreshControl that an external event has initiated the refresh action
	- (void)beginRefreshing NS_AVAILABLE_IOS(6_0);
	// Must be explicitly called when the refreshing has completed
	- (void)endRefreshing NS_AVAILABLE_IOS(6_0);

##16.UICollectionViewCell的的优化

  + 在iOS 10 之前,UICollectionView上面如果有大量cell,当用户活动很快的时候,整个UICollectionView的卡顿会很明显,为什么会造成这样的问题,这里涉及到了iOS 系统的重用机制,当cell准备加载进屏幕的时候,整个cell都已经加载完成,等待在屏幕外面了,也就是整整一行cell都已经加载完毕,这就是造成卡顿的主要原因,专业术语叫做:掉帧.
  	- 要想让用户感觉不到卡顿,我们的app必须帧率达到60帧/秒,也就是说每帧16毫秒要刷新一次.
  + iOS 10 之前UICollectionViewCell的生命周期是这样的:
  	- 用户滑动屏幕,屏幕外有一个cell准备加载进来,把cell从reusr队列拿出来,然后调用prepareForReuse方法,在这个方法里面,可以重置cell的状态,加载新的数据;
  	- 继续滑动,就会调用cellForItemAtIndexPath方法,在这个方法里面给cell赋值模型,然后返回给系统;
  	- 当cell马上进去屏幕的时候,就会调用willDisplayCell方法,在这个方法里面我们还可以修改cell,为进入屏幕做最后的准备工作;
  	- 执行完willDisplayCell方法后,cell就进去屏幕了.当cell完全离开屏幕以后,会调用didEndDisplayingCell方法.
  + iOS 10 UICollectionViewCell的生命周期是这样的:
   	- 用户滑动屏幕,屏幕外有一个cell准备加载进来,把cell从reusr队列拿出来,然后调用prepareForReuse方法,在这里当cell还没有进去屏幕的时候,就已经提前调用这个方法了,对比之前的区别是之前是cell的上边缘马上进去屏幕的时候就会调用该方法,而iOS 10 提前到cell还在屏幕外面的时候就调用;
  	- 在cellForItemAtIndexPath中创建cell，填充数据，刷新状态等操作,相比于之前也提前了;
  	- 用户继续滑动的话,当cell马上就需要显示的时候我们再调用willDisplayCell方法,原则就是:何时需要显示,何时再去调用willDisplayCell方法;
  	- 当cell完全离开屏幕以后,会调用didEndDisplayingCell方法,跟之前一样,cell会进入重用队列.
  + 在iOS 10 之前,cell只能从重用队列里面取出,再走一遍生命周期,并调用cellForItemAtIndexPath创建或者生成一个cell.
  + 在iOS 10 中,系统会cell保存一段时间,也就是说当用户把cell滑出屏幕以后,如果又滑动回来,cell不用再走一遍生命周期了,只需要调用willDisplayCell方法就可以重新出现在屏幕中了.
  + iOS 10 中,系统是一个一个加载cell的,二以前是一行一行加载的,这样就可以提升很多性能;
  + iOS 10 新增加的Pre-Fetching预加载

  	- 这个是为了降低UICollectionViewCell在加载的时候所花费的时间,在 iOS 10 中,除了数据源协议和代理协议外,新增加了一个UICollectionViewDataSourcePrefetching协议,这个协议里面定义了两个

方法:

	- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray *)indexPaths NS_AVAILABLE_IOS(10_0);
	
	- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray *)indexPaths  NS_AVAILABLE_IOS(10_0);

  + 在ColletionView prefetchItemsAt indexPaths这个方法是异步预加载数据的,当中的indexPaths数组是有序的,就是item接收数据的顺序;
  + CollectionView cancelPrefetcingForItemsAt indexPaths这个方法是可选的,可以用来处理在滑动中取消或者降低提前加载数据的优先级.
  
  >注意:这个协议并不能代替之前读取数据的方法,仅仅是辅助加载数据.
  
  Pre-Fetching预加载对UITableViewCell同样适用.

##17.UITextField(好像作用并不大)

在iOS 10 中,UITextField新增了textContentType字段,是UITextContentType类型,它是一个枚举,作用是可以指定输入框的类型,以便系统可以分析出用户的语义.是电话类型就建议一些电话,是地址类型就建议一些地址.可以在#import 文件中,查看textContentType字段,有以下可以选择的类型:

	UIKIT_EXTERN UITextContentType const UITextContentTypeName                      NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeNamePrefix                NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeGivenName                 NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeMiddleName                NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeFamilyName                NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeNameSuffix                NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeNickname                  NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeJobTitle                  NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeOrganizationName          NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeLocation                  NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeFullStreetAddress         NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeStreetAddressLine1        NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeStreetAddressLine2        NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeAddressCity               NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeAddressState              NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeAddressCityAndState       NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeSublocality               NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeCountryName               NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypePostalCode                NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeTelephoneNumber           NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeEmailAddress              NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeURL                       NS_AVAILABLE_IOS(10_0);
	UIKIT_EXTERN UITextContentType const UITextContentTypeCreditCardNumber          NS_AVAILABLE_IOS(10_0);

##18.UIStatusBar的问题

    在iOS10中,如果还使用以前设置UIStatusBar类型或者控制隐藏还是显示的方法,会报警告,方法过期
    
19970779-665271622c13eb6e

警告中提到从iOS9.0开始就弃用这两个方法了，需要用

	-[UIViewController preferredStatusBarstyle]
	
	-[UIViewController preferredStatusBarHidden]来替换使用，那我们来看看新的替换方法。

新技能见下面

	#if UIKIT_DEFINE_AS_PROPERTIES
	@property(nonatomic, readonly) UIStatusBarStyle preferredStatusBarStyle NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED; // Defaults to UIStatusBarStyleDefault
	@property(nonatomic, readonly) BOOL prefersStatusBarHidden NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED; // Defaults to NO
	// Override to return the type of animation that should be used for status bar changes for this view controller. This currently only affects changes to prefersStatusBarHidden.
	@property(nonatomic, readonly) UIStatusBarAnimation preferredStatusBarUpdateAnimation NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED; // Defaults to UIStatusBarAnimationFade
	#else
	- (UIStatusBarStyle)preferredStatusBarStyle NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED; // Defaults to UIStatusBarStyleDefault
	- (BOOL)prefersStatusBarHidden NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED; // Defaults to NO
	// Override to return the type of animation that should be used for status bar changes for this view controller. This currently only affects changes to prefersStatusBarHidden.
	- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED; // Defaults to UIStatusBarAnimationFade
	#endif

上面这个新方法在UIViewController.h文件中，这说明什么？当然说明这是viewController的属性和方法了，只需要在viewController里调用修改即可


UIStatusBarStyle 和 prefersStatusBarHidden这两个属性是readonly readonly readonly也就是说我们如果调用下面 肯定是报错的：

	//这是错误的写法
	self.preferredStatusBarStyle = UIStatusBarStyleDefault;和
	self.prefersStatusBarHidden = YES;

正确的打开方式在viewController重写我们还没用的新的方法

	//这是正确的
	- (BOOL)prefersStatusBarHidden{
	    return YES;
	}
	
	- (UIStatusBarStyle)preferredStatusBarStyle{
	    return UIStatusBarStyleDefault;
	}

##19.插件取消

Xcode8取消了三方插件的功能，好多教程破解可以继续使用，但是可能app上线可能会被拒。我们最喜爱的VVDocumenter-Xcode也不能使用了.
    
    看来大神都是谦虚的啊（啥时候能成为大神。我还是洗洗睡吧，梦里啥都有\^_^）
    上面也提到了我们可以继续使用注释，快捷键（⌥ Option + ⌘ Command + / ）

##20.真彩色的显示

真彩色的显示会根据光感应器来自动的调节达到特定环境下显示与性能的平衡效果,如果需要这个功能的话,可以在info.plist里配置(在Source Code模式下):

	UIWhitePointAdaptivityStyle

它有五种取值,分别是:

	UIWhitePointAdaptivityStyleStandard // 标准模式
	UIWhitePointAdaptivityStyleReading // 阅读模式
	UIWhitePointAdaptivityStylePhoto // 图片模式
	UIWhitePointAdaptivityStyleVideo // 视频模式
	UIWhitePointAdaptivityStyleStandard // 游戏模式


如果你的项目是游戏类的,就选择UIWhitePointAdaptivityStyleStandard这个模式,五种模式的显示效果是从上往下递减,也就是说如果你的项目是图片处理类的,你选择的是阅读模式,给选择太好的效果会影响性能.

##21.UIColor问题

    官方文档中说:大多数core开头的图形框架和AVFoundation都提高了对扩展像素和宽色域色彩空间的支持.通过图形堆栈扩展这种方式比以往支持广色域的显示设备更加容易。现在对UIKit扩展可以在sRGB的色彩空间下工作，性能更好,也可以在更广泛的色域来搭配sRGB颜色.如果你的项目中是通过低级别的api自己实现图形处理的,建议使用sRGB,也就是说在项目中使用了RGB转化颜色的建议转换为使用sRGB,在UIColor类中新增了两个api:

	+ (UIColor *)colorWithDisplayP3Red:(CGFloat)displayP3Red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha NS_AVAILABLE_IOS(10_0);
	- (UIColor *)initWithDisplayP3Red:(CGFloat)displayP3Red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha NS_AVAILABLE_IOS(10_0);
	
我用新老方法测试两个方法在RGB相同的数值在表现上的区别看下图：

> 可以看出下面的颜色（sRGB方法）比上面的颜色（RGB方法）颜色更深更明显。

##22.系统版本判断方法失效

######我们之前的系统版本方法如下

当系统版本到iOS10.0的时候 9.0和10.0比较的话是降序而不是升序，这样会导致iOS10.0是最早的版本，这样后面要走的iOS10的方法可能都不会走而出现问题

	#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"9.0"] != NSOrderedAscending)
	
	#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending)
	
	#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
	
	#define IOS6_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"] != NSOrderedAscending)

下面这样也不行它会永远返回NO,substringToIndex:1在iOS 10 会被检测成 iOS 1了,

	#define isiOS10 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=10)
	1
		
	#define isiOS10 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=10)

正确的打开方式应该是：

	#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
	
	#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
	
	#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
	
	#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
	
	#define IOS6_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)

##23.tabBarItem第一个重复出现

这个问题实在没有找到好的方法解决。不过庆幸的是，公司决定将TabBar中的Item四个变成，既然好了，我就想不通。

如果你也遇到了这样的问题，或者已经解决了此问题，欢迎联系我，在此致谢！






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