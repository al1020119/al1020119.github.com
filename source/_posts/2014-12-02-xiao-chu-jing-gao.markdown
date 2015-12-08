---

layout: post
title: "消除警告"
date: 2014-12-02 02:51:46 +0800
comments: true
categories: 性能相关

---

######前言：

现在你维护的项目有多少警告？看着几百条警告觉得心里烦么？你真的觉得警告又不是错误可以完全不管么？ 如果你也被这些问题困惑，可以和我一起进行下面的操作。其实大部分的警告都是很好改的，把自己整个项目的警告撸一遍应该也就耗费半小时的时间，一次麻烦带来之后的清净这样不好么？


本文分为三个部分：

* 1.简单粗暴的消除警告。
* 2.详细科学的消除警告。（包括警告收录） 
* 3.添加警告。



<!--more-->




####一、简单粗暴的消除警告

警告如果是自己项目中的还好直接改了，如果是第三方库，你改了之后，pod下作者更新一下又白改了，所以可以用这种简单粗暴的方法：直接让第三方库的警告不显示

 就是在podfile文件里面加上一行指令 。 
inhibit_all_warnings!
如果某警告实在无法消除，但是又不想让他显示，可以加入预编译指令

比如我已经知道某行会报上面警告了，我就用这个宏把这几行包住，就不会报引号中-Wunused-variable的警告了

	#pragma clang diagnostic push
	#pragma clang diagnostic ignored"-Wunused-variable" //这里是会报警告的代码
	
	#pragma clang diagnostic pop
	
这个-Wunused-variable代表的意思就是 有的东西 你实例化了但是没有使用（同上面第几条）。 但是如何得到一个警告的标示符？

1. 如图选择一个警告，点击右键，reveal in log  就能看到右边有个方括号[]里面的东西就是 这个警告对应的标示符


2. 如果希望整个项目中都忽略 某种很无聊的警告，就在项目中Build Setting里加上这个标示符，可以连着加的。


3. 如果不想整个项目都忽略，只想个别文件忽略，那就找到个别文件加上此指令，这个操作应该使用率不高（一般都是全项目忽略），就不上图了。去Build Phases 里面的 Compile Sources里面改。

####二、详细科学的消除警告

其实笔者本意是想把一些第一眼看不懂比较坑的警告收录进来，但是后来发现那基本没几个需要些写了，所以就采用了全收录的方法，遇到的就记录下以后也会不断更新。 可以直接按command+F 在本页面搜索警告

	Unused variable 'replyURL'

######1.没有使用


	Cannot find protocol definition for 'TencentSessionDelegate'

######2.这种明明都能运行还说我没有定义的警告，是因为你这个协议虽然定义了，但是你这个协议可能还遵守了XX协议，然后这个XX协议没有定义导致会报这种警告，所以遇到这种警告要往“父协议”找。 举个栗子，上面这行就是腾讯授权的库里面报的警告，
	@protocol TencentSessionDelegate
	此协议遵守了TencentApiInterfaceDelegate协议，在TencentOAuth.h类中#import "TencentApiInterface.h" 警告可破


	Null passed to a callee that requires a non-null argument

######3.这个警告比较新，是xcode6.3开始 为了让OC也能有swift的？和！的功能，你在声明一个属性的时候加上 __nullable（？可以为空）与__nonnull（！不能为空） 如果放在@property里面的话不用写下划线
	@property (nonatomic, copy, nonnull) NSString * tickets;
	@property (nonatomic, copy) NSString * __nonnull tickets;
	
	
或者用宏NS_ASSUME_NONNULL_BEGIN和NS_ASSUME_NONNULL_END 包住多个属性全部具备nonnull，然后仅对需要nullable的改下就行，有点类似于f-no-objc-arc那种先整体给个路线在单独改个别文件的思想。 此警告就是某属性说好的不能为空，你又在某地方写了XX = nil 所以冲突了。


	Auto property synthesis will not synthesize property 'privateCacheDirectory'; it will be implemented by its superclass, use @dynamic to acknowledge intention

######4.他说你的父类实现了setget方法，但是如果你什么都不写，就会系统自动生成出最一般的setget方法，请用@dynamic 来承认父类实现的这个getset方法。


	Unsupported Configuration: Scene is unreachable due to lack of entry points and does not have an identifier for runtime access via -instantiateViewControllerWithIdentifier:.

######5.一般是storyboard报的警告，简而言之就是你有的页面没有和箭头所指的控制器连起来，导致最终改页面可能无法显示。


	Deprecated: Push segues are deprecated in iOS 8.0 and later

######6.iOS8之后呢，不要再用push拖线了，统一用show，他会自己根据你是否有导航栏来判断走push还是走modal


	Unsupported Configuration: Plain Style unsupported in a Navigation Item

######7.导航栏的item 不支持用plain ，那就用Bordered呗。


	The launch image set "LaunchImage" has 2 unassigned images.
	The app icon set "AppIcon" has 2 unassigned images.

######8.几张图标还是启动图找不到自己的位置，可能是一次导入了全部尺寸图片，但是右边的设置只勾了iOS8的 那iOS7尺寸的图标就会报此警告。删掉，或者对照右边匹配。

	
	'sizeWithFont:constrainedToSize:lineBreakMode:' is deprecated: first deprecated in iOS 7.0 - Use -boundingRectWithSize:options:attributes:context:

######9.方法废除，旧的方法sizeWithFontToSize在iOS7后就废除了取而代之是boundingRectWithSize方法


	Undeclared selector 'historyAction'

######10.使用未声明的方法，一般出现在@selector() 括号里写了个不存在的方法或方法名写错了。


	PerformSelector may cause a leak because its selector is unknown

######11.这个和上面类似就是直接把上面那个@SEL拿来用会报这个警告


	'strongify' macro redefined

######12.这个宏声明重复,删一个吧


	'UITextAttributeFont' is deprecated: first deprecated in iOS 7.0 - Use NSFontAttributeName
	'UITextAttributeTextColor' is deprecated: first deprecated in iOS 7.0 - Use NSForegroundColorAttributeName
	'UITextAttributeTextShadowColor' is deprecated: first deprecated in iOS 7.0 - Use NSShadowAttributeName with an NSShadow instance as the value

######13.方法废除,一般一起出现


	Code will never be executed

######14.他说这代码永远也轮不到他执行，估计是有几行代码写在了return之后


	Assigning to 'id' from incompatible type 'SXTabViewController *const __strong'

######15.一般出现在xxx.delegate = self ，应该在上面遵守协议


	Format specifies type 'unsigned long' but the argument has type 'unsigned int'

######16.这个警告一般会出现在NSStringWithFormat里面 前面%d %lu 什么的和后面填进去的参数不匹配就报了警告


	Values of type 'NSInteger' should not be used as format arguments; add an explicit cast to 'long' instead

######17.类似于上面，也是format里面前后写的不匹配


	Method 'dealWithURL:andTitle:andKeyword:' in protocol 'SXPostAdDelegate' not implemented

######18.经典警告，遵守了协议，但是没有实现协议方法。 也可能你实现了只是又加了个参数或是你写的方法和协议方法名字有点轻微不同


	Using integer absolute value function 'abs' when argument is of floating point type

######19.这个可以自动修正，就是说abs适用于整数绝对值，要是float取绝对值要用fabsf


	Attribute Unavailable: Automatic Preferred Max Layout Width is not available on iOS versions prior to 8.0

######20.有的方法你用的太落后了，也有的方法你用的太超前了。 说这个最大宽度在iOS8之前的系统是要坑的


	Too many personality routines for compact unwind to encode

######21.你可以在otherlink 中加入 -Wl,-no_compact_unwind 去掉该警告，根据苹果的解释，这个是由于某些地方 c/c++/oc/oc++混用会造成编译警告。一般没有什么伤害。


	Property 'ssid' requires method 'ssid' to be defined - use @synthesize, @dynamic or provide a method implementation in this class implementation

######22.说这个ssid必须要定义个这个属性的getter方法，如果警告是setSsid就是setter方法， 用@synthesize和@dynamic 都行，一个是让编译器生成getter和setter，一个是自己生成，如果你有模型分发或kvc之类的，选@dynamic就行


	Unknown escape sequence '\)'

######23.未知的转义序列。 一般有个斜杠再加个东西他都会以为是转义字符，一看\）不认识就报警告了，一般正则表达式容易报这种警告


	Property 'LoginPort' not found on object of type 'LoginLvsTestTask *'; did you mean to access property loginPort?

######24.这种可以点击自动修复，是典型的大小写写错了，他提醒了一下。


	Variable 'type' is used uninitialized whenever switch default is taken

######25.这是出现在switch语句中的警告， 一般可能是switch外面定义了个type但是并没有初始化（初始化操作都写在switch的各个分支里），然后在最后return type。 但是switch的有个分支没有对type初始化，他说如果你来到这个分支的话，那还没初始化就要被return。

#####三、添加警告

######1.首先最常用的就是 普通警告，这也没什么好说的了

	#warning TODO
######2.如果是自己写的文件或第三方库，有了新的接口，然后提示旧的接口废除的话需要在方法后加上宏NS_DEPRECATED_IOS和范围
	
	- (void)addTapAction:(SEL)tapAction target:(id)target NS_DEPRECATED_IOS(2_0, 4_0);
######3.如果需要在此方法后加上带信息的警告则需要这么写

	- (void)addTapAction:(SEL)tapAction target:(id)target __attribute((deprecated("这个接口会爆内存 不建议使用")));
显示的效果像这样：
