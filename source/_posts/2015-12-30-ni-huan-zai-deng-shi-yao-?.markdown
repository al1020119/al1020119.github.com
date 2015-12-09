---
layout: post
title: "你还在等什么？"
date: 2015-12-30 16:21:08 +0800
comments: true
categories: 精华
---


最近，一直在寻找灵感，摸索新技术，提高个人的开发能力，比如swift开源代码，也在研究前端开发，但是偶尔看到一个问题，学了这么久，也做了这么久，突然发现很多东西都忘了，或者说搞不太清楚，就是有些相似的弄混了，最后网上到处找。看完之后我也颇有感受，也想了很久，觉得整理一份重要的总结。


宗旨内容如下：

* 1：ios开发中常见技术的总结（主要是区别）
* 2：作为一个iOS程序员必备的常识问题
* 3：作为面试必备的一份宝典
* 4：初学者快速了解相关技术
* 5：老程序员快速回顾混淆，忘记的知识点

后续我也会一直讲本文更新下去，有露点或者错误的地方望指出，或者联系[我](http://al1020119.github.io/other/)，相互交流技术，谢谢！


好了开始吧。。。。。。。。。。。





<!--more-->




#一：weak&strong

* strong表示保留它指向的堆上的内存区域不再指向这块区域了。
也就是说我强力指向了一个区域，我们不再指向它的条件只有我们指向nil或者我自己也不在内存上，没有人strong指向我了。

* weak表示如果还没有人指向它了，它就会被清除内存，同时被指向nil，因为我不能读取不存在的东西。

> weak只在IOS5.0使用

这并不是垃圾回收，我们用reference count表示堆上还有多少strong指针，当它变为0就马上释放。
 
本地变量都是strong，编辑器帮你计算.

#####补充：

* 管理机制：使用了一种叫做引用计数的机制来管理内存中的对象。OC中每个对象都对应着他们自己的引用计数，引用计数可以理解为一个整数计数器，当使用alloc方法创建对象的时候，持有计数会自动设置为1。当你向一个对象发送retain消息 时，持有计数数值会增加1。相反，当你像一个对象发送release消息时，持有计数数值会减小1。当对象的持有计数变为0的时候，对象会释放自己所占用的内存。* retain(引用计数加1)->release（引用计数减1）* alloc（申请内存空间）->dealloc(释放内存空间)* readwrite: 表示既有getter，也有setter   (默认)* readonly: 表示只有getter，没有setter* nonatomic:不考虑线程安全* atomic:线程操作安全   （默认）
线程安全情况下的setter和getter：
	- (NSString*) value  {     	        @synchronized(self) {         	        return [[_value retain] autorelease];    
	         }
	       } 
	-	(void) setValue:(NSString*)aValue {     	   @synchronized(self) {         	   [aValue retain];         	   [_value release];         	   _value = aValue;     
	   }  	 }* retain: release旧的对象，将旧对象的值赋予输入对象，再提高输入对象的索引计数为1* assign: 简单赋值，不更改索引计数    （默认）* copy: 其实是建立了一个相同的对象,地址不同（retain：指针拷贝  copy：内容拷贝）* strong:（ARC下的）和（MRC）retain一样    （默认）* weak:（ARC下的）和（MRC）assign一样， weak当指向的内存释放掉后自动nil化，防止野指针* unsafe_unretained 声明一个弱应用，但是不会自动nil化，也就是说，如果所指向的内存区域被释放了，这个指针就是一个野指针了。* autoreleasing 用来修饰一个函数的参数，这个参数会在函数返回的时候被自动释放。1、	类变量的@protected ,@private,@public,@package，声明各有什么含义？* @private：作用范围只能在自身类* @protected：作用范围在自身类和继承自己的子类  （默认）* @public：作用范围最大，可以在任何地方被访问。* @package：这个类型最常用于框架类的实例变量,同一包内能用，跨包就不能访问



#二：catagory&extension

######类别主要有3个作用：

* (1)可以将类的实现分散到多个不同文件或多个不同框架中，方便代码管理。也可以对框架提供类的扩展（没有源码，不能修改）。

* (2)创建对私有方法的前向引用：如果其他类中的方法未实现，在你访问其他类的私有方法时编译器报错这时使用类别，在类别中声明这些方法（不必提供方法实现），编译器就不会再产生警告

* (3)向对象添加非正式协议：创建一个NSObject的类别称为“创建一个非正式协议”，因为可以作为任何类的委托对象使用。

######他们的主要区别是：

* 1、形式上来看，extension是匿名的category。

* 2、extension里声明的方法需要在mainimplementation中实现，category不强制要求。

* 3、extension可以添加属性（变量），category不可以。

######Category和Extension都是用来给已定义的类增加新的内容的。

* Category和原有类的耦合更低一些，声明和实现都可以写在单独的文件里。但是只能为已定义类增加Method，而不能加入instance variable。

* Extension耦合比较高，声明可以单独写，但是实现必须写在原有类的@implementation中。可以增加Method和instance variable。

* Extension给人感觉更像是在编写类时为了封装之类的特性而设计，和类是同时编写的。而category则是在用到某一个framework中的类时临时增加的特性。

* Extension的一个特性就是可以redeclare一个instance variable，将之从readonly改为对内readwrite.

> 使用Extension可以更好的封装类，在h文件中能看到的都是对外的接口，其余的instance variable和对内的@property等都可以写在Extension，这样类的结构更加清晰。

#三：define&const  

* define在预处理阶段进行替换，const常量在编译阶段使用* 宏不做类型检查，仅仅进行替换，const常量有数据类型，会执行类型检查* define不能调试，const常量可以调试* define定义的常量在替换后运行过程中会不断地占用内存，而const定义的常量存储在数据段只有一份copy，效率更高* define可以定义一些简单的函数，const不可以

#四：synthesize&denamic

* 1：通过@synthesize 指令告诉编译器在编译期间产生getter/setter方法。
* 2：通过@dynamic指令，自己实现方法。

有些存取是在运行时动态创建的，如在CoreData的NSManagedObject类使用的某些。如果你想这些情况下，声明和使用属性，但要避免缺少方法在编译时的警告，你可以使用@dynamic动态指令，而不是@synthesize合成指令。
#五：UIView的setNeedsDisplay和setNeedsLayout方法

* 1、在Mac OS中NSWindow的父类是NSResponder，而在i OS 中UIWindow 的父类是UIVIew。程序一般只有一个窗口但是会又很多视图。

* 2、UIView的作用：描画和动画，视图负责对其所属的矩形区域描画、布局和子视图管理、事件处理、可以接收触摸事件、事件信息的载体、等等。

* 3、UIViewController 负责创建其管理的视图及在低内存的时候将他们从内存中移除。还为标准的系统行为进行响应。
* 
* 4、layOutSubViews 可以在自己定制的视图中重载这个方法，用来调整子视图的尺寸和位置。

* 5、UIView的setNeedsDisplay和setNeedsLayout方法。首先两个方法都是异步执行的。而setNeedsDisplay会调用自动调用drawRect方法，这样可以拿到UIGraphicsGetCurrentContext，就可以画画了。而setNeedsLayout会默认调用layoutSubViews，就可以处理子视图中的一些数据。

综上所述：setNeedsDisplay方便绘图，而layoutSubViews方便出来数据

setNeedDisplay告知视图它发生了改变，需要重新绘制自身，就相当于刷新界面.


#六：UILayer&UIView

UIView是iOS系统中界面元素的基础，所有的界面元素都继承自它。它本身完全是由CoreAnimation来实现的（Mac下似乎不是这样）。它真正的绘图部分，是由一个叫CALayer（Core Animation Layer）的类来管理。UIView本身，更像是一个CALayer的管理器，访问它的跟绘图和跟坐标有关的属性，例如frame，bounds等等，实际上内部都是在访问它所包含的CALayer的相关属性。

1. UIView是iOS系统中界面元素的基础，所有的界面元素都是继承自它。它本身完全是由CoreAnimation来实现的。它真正的绘图部分，是由一个CALayer类来管理。UIView本身更像是一个CALayer的管理器，访问它的跟绘图和跟坐标有关的属性，例如frame，bounds等，实际上内部都是在访问它所包含的CALayer的相关属性。

2. UIView有个重要属性layer，可以返回它的主CALayer实例。



3. UIView的CALayer类似UIView的子View树形结构，也可以向它的layer上添加子layer，来完成某些特殊的表示。即CALayer层是可以嵌套的。



4. UIView的layer树形在系统内部，被维护着三份copy。分别是逻辑树，这里是代码可以操纵的；动画树，是一个中间层，系统就在这一层上更改属性，进行各种渲染操作；显示树，其内容就是当前正被显示在屏幕上得内容。

5. 动画的运作：对UIView的subLayer（非主Layer）属性进行更改，系统将自动进行动画生成，动画持续时间的缺省值似乎是0.5秒。

6. 坐标系统：CALayer的坐标系统比UIView多了一个anchorPoint属性，使用CGPoint结构表示，值域是0~1，是个比例值。



7. 渲染：当更新层，改变不能立即显示在屏幕上。当所有的层都准备好时，可以调用setNeedsDisplay方法来重绘显示。

8. 变换：要在一个层中添加一个3D或仿射变换，可以分别设置层的transform或affineTransform属性。

9. 变形：Quartz Core的渲染能力，使二维图像可以被自由操纵，就好像是三维的。图像可以在一个三维坐标系中以任意角度被旋转，缩放和倾斜。CATransform3D的一套方法提供了一些魔术般的变换效果。

#七：UITableView&UICollection
UICollectionView是iOS6新引进的API，用于展示集合视图，布局更加灵活，其用法类似于UITableView。而UICollectionView、UICollectionViewCell与UITableView、UITableViewCell在用法上有相似的也有不同的，下面是一些基本的使用方法：

对于UITableView，仅需要UITableViewDataSource,UITableViewDelegate这两个协议，使用UICollectionView需要实现UICollectionViewDataSource,
UICollectionViewDelegate，UICollectionViewDelegateFlowLayout这三个协议，这是因为UICollectionViewDelegateFlowLayout实际上是UICollectionViewDelegate的一个子协议，它继承了UICollectionViewDelegate，它的作用是提供一些定义UICollectionView布局模式的函数

#八：NSProxy&NSObject
######NSObjetc：

NSObject协议组对所有的Object－C下的objects都生效。 如果objects遵从该协议，就会被看作是first－class objects（一级类）。 另外，遵从该协议的objects的retain，release，autorelease等方法也服从objects的管理和在Foundation中定义的释放方法。一些容器中的对象也可以管理这些objects，比如 说NSArray 和NSDictionary定义的对象。 Cocoa的根类也遵循该协议，所以所有继承NSObjects的objects都有遵循该协议的特性。

######NSProXY：

NSProxy 是一个虚基类，它为一些表现的像是其它对象替身或者并不存在的对象定义一套API。一般的，发送给代理的消息被转发给一个真实的对象或者代理本身load(或者将本身转换成)一个真实的对象。NSProxy的基类可以被用来透明的转发消息或者耗费巨大的对象的lazy 初始化。

#九：layoutSubViews&drawRects
######layoutSubviews在以下情况下会被调用：

* 1、init初始化不会触发layoutSubviews。
* 2、addSubview会触发layoutSubviews。
* 3、设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化。
* 4、滚动一个UIScrollView会触发layoutSubviews。
* 5、旋转Screen会触发父UIView上的layoutSubviews事件。
* 6、改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件。
* 7、直接调用setLayoutSubviews。



######drawRect在以下情况下会被调用：

* 1、如果在UIView初始化时没有设置rect大小，将直接导致drawRect不被自动调用。drawRect 掉用是在Controller->loadView, Controller->viewDidLoad 两方法之后掉用的.所以不用担心在 控制器中,这些View的drawRect就开始画了.这样可以在控制器中设置一些值给View(如果这些View draw的时候需要用到某些变量 值).
* 2、该方法在调用sizeToFit后被调用，所以可以先调用sizeToFit计算出size。然后系统自动调用drawRect:方法。
* 3、通过设置contentMode属性值为UIViewContentModeRedraw。那么将在每次设置或更改frame的时候自动调用drawRect:。
* 4、直接调用setNeedsDisplay，或者setNeedsDisplayInRect:触发drawRect:，但是有个前提条件是rect不能为0。

######drawRect方法使用注意点：

* 1、 若使用UIView绘图，只能在drawRect：方法中获取相应的contextRef并绘图。如果在其他方法中获取将获取到一个invalidate 的ref并且不能用于画图。drawRect：方法不能手动显示调用，必须通过调用setNeedsDisplay 或 者 setNeedsDisplayInRect，让系统自动调该方法。

* 2、若使用calayer绘图，只能在drawInContext: 中（类似鱼drawRect）绘制，或者在delegate中的相应方法绘制。同样也是调用setNeedDisplay等间接调用以上方法 3、若要实时画图，不能使用gestureRecognizer，只能使用touchbegan等方法来掉用setNeedsDisplay实时刷新屏幕

#十：NSCache&NSDcitionary

NSCache与可变集合有几点不同：

* NSCache类结合了各种自动删除策略，以确保不会占用过多的系统内存。如果其它应用需要内存时，系统自动执行这些策略。当调用这些策略时，会从缓存中删除一些对象，以最大限度减少内存的占用。
* NSCache是线程安全的，我们可以在不同的线程中添加、删除和查询缓存中的对象，而不需要锁定缓存区域。
* 不像NSMutableDictionary对象，一个缓存对象不会拷贝key对象。


NSCache和NSDictionary类似，不同的是系统回收内存的时候它会自动删掉它的内容。

* (1)可以存储(当然是使用内存)
* (2)保持强应用, 无视垃圾回收. =>这一点同 NSMutableDictionary
* (3)有固定客户.
#十一：AFnetworking&ASIHttpRequest&MKNetWorking

 一、底层实现

    1、AFN的底层实现基于OC的NSURLConnection和NSURLSession
    2、ASI的底层实现基于纯C语言的CFNetwork框架
    3、因为NSURLConnection和NSURLSession是在CFNetwork之上的一层封装，因此ASI的运行性能高于AFN

AFNetworking的下载地址: https://github.com/AFNetworking/AFNetworking
二、对服务器返回的数据处理

    1、ASI没有直接提供对服务器数据处理的方式，直接返回的是NSData/NSString
    2、AFN提供了多种对服务器数据处理的方式
    (1)JSON处理-直接返回NSDictionary或者NSArray
    (2)XML处理-返回的是xml类型数据，需对其进行解析
    (3)其他类型数据处理

三、监听请求过程

    1、AFN提供了success和failure两个block来监听请求的过程（只能监听成功和失败）
    * success : 请求成功后调用
    * failure : 请求失败后调用
    2、ASI提供了3套方案，每一套方案都能监听请求的完整过程
    （监听请求开始、接收到响应头信息、接受到具体数据、接受完毕、请求失败）
    * 成为代理，遵守协议，实现协议中的代理方法
    * 成为代理，不遵守协议，自定义代理方法
    * 设置block

四、在文件下载和文件上传的使用难易度

    1、AFN
    *不容易实现监听下载进度和上传进度
    *不容易实现断点续传
    *一般只用来下载不大的文件
    2、ASI
    *非常容易实现下载和上传
    *非常容易监听下载进度和上传进度
    *非常容易实现断点续传
    *下载大文件或小文件均可
    3、实现下载上传推荐使用ASI

五、网络监控

    1、AFN自己封装了网络监控类，易使用
    2、ASI使用的是Reachability，因为使用CocoaPods下载ASI时，会同步下载Reachability，但Reachability作为网络监控使用较为复杂（相对于AFN的网络监控类来说）
    3、推荐使用AFN做网络监控-AFNetworkReachabilityManager

六、ASI提供的其他实用功能

    1、控制信号旁边的圈圈要不要在请求过程中转
    2、可以轻松地设置请求之间的依赖：每一个请求都是一个NSOperation对象
    3、可以统一管理所有请求（还专门提供了一个叫做ASINetworkQueue来管理所有的请求对象）
    * 暂停/恢复/取消所有的请求
    * 监听整个队列中所有请求的下载进度和上传进度

MKNetworkKit 是一个使用十分方便，功能又十分强大、完整的iOS网络编程代码库。它只有两个类, 它的目标是使用像AFNetworking这么简单，而功能像ASIHTTPRequest(已经停止维护)那么强大。它除了拥有AFNetworking和ASIHTTPRequest所有功能以外，还有一些新特色，包括：

* 1、高度的轻量级，仅仅只有2个主类

* 2、自主操作多个网络请求

* 3、更加准确的显示网络活动指标

* 4、自动设置网络速度，实现自动的2G、3G、wifi切换

* 5、自动缓冲技术的完美应用，实现网络操作记忆功能，当你掉线了又上线后，会继续执行未完成的网络请求

* 6、可以实现网络请求的暂停功能

* 7、准确无误的成功执行一次网络请求，摒弃后台的多次请求浪费

* 8、支持图片缓冲

* 9、支持ARC机制

* 10、在整个app中可以只用一个队列（queue），队列的大小可以自动调整



{% img /images/netqubiezongjie001.png Caption %}  


#十二：load&initialize

+ (void)load;
+ (void)initialize;

可以看到这两个方法都是以“+”开头的类方法，返回为空。通常情况下，我们在开发过程中可能不必关注这两个方法。如果有需要定制，我们可以在自定义的NSObject子类中给出这两个方法的实现，这样在类的加载和初始化过程中，自定义的方法可以得到调用。
######load和initialize的共同特点

* 在不考虑开发者主动使用的情况下，系统最多会调用一次

* 如果父类和子类都被调用，父类的调用一定在子类之前

* 都是为了应用运行提前创建合适的运行环境

* 在使用时都不要过重地依赖于这两个方法，除非真正必要

> 它们的相同点在于：方法只会被调用一次。（其实这是相对runtime来说的，后边会做进一步解释）。



***

		The runtime sends initialize to each class in a program exactly one time just before the class, or any class that inherits from it, is sent its first message from within the program. (Thus the method may never be invoked if the class is not used.) The runtime sends the initialize message to classes in a thread-safe manner. Superclasses receive this message before their subclasses.
		
		
***
		
			The load message is sent to classes and categories that are both dynamically loaded and statically linked, but only if the newly loaded class or category implements a method that can respond.


* load是只要类所在文件被引用就会被调用，而initialize是在类或者其子类的第一个方法被调用前调用。所以如果类没有被引用进项目，就不会有load调用；但即使类文件被引用进来，但是没有使用，那么initialize也不会被调用。


文档也明确阐述了方法调用的顺序：父类(Superclass)的方法优先于子类(Subclass)的方法，类中的方法优先于类别(Category)中的方法。

|区别 |  	+(void)load | 	+(void)initialize| 
| ------------- |:-------------:| -----:|
| 执行时机 | 	在程序运行后立即执行 | 	在类的方法第一次被调时执行| 
| 若自身未定义，是否沿用父类的方法？ | 	否 | 	是| 
| 类别中的定义|  	全都执行，但后于类中的方法 | 	覆盖类中的方法，只执行一个| 

#十三：ARC-Block&MRC-Block

block虽然好用，但是里面也有不少坑，最大的坑莫过于循环引用问题。稍不注意，可能就会造成内存泄漏。这节，我将从源码的角度来分析造成循环引用问题的根本原因。并解释变量前加__block，和__weak的区别。


#####明确两点
1,Block可以访问Block函数以及语法作用域以内的外部变量。也就是说:一个函数里定义了个block，这个block可以访问该函数的内部变量(当然还包括静态，全局变量)-即block可以使用和本身定义范围相同的变量。
2,Block其实是特殊的Objective-C对象，可以使用copy,release等来管理内存,但和一般的NSObject的管理方式有些不同，稍后会说明。



######MRC:防止 block 对self的引用 解决办法

	__block typeof(self) weakSelf = self;



######ARC:防止 block 对self的引用 解决办法

	__weak typeof(self) weakSelf = self;

> 对于非ARC下, 为了防止循环引用, 我们使用__block来修饰在Block中使用的对象:


> 对于ARC下, 为了防止循环引用, 我们使用__weak来修饰在Block中使用的对象。原理就是:ARC中，Block中如果引用了__strong修饰符的自动变量，则相当于Block对该变量的引用计数+1。

#十四：MVC&MVVM

* 在MVC里，View是可以直接访问Model的！从而，View里会包含Model信息，不可避免的还要包括一些业务逻辑。 MVC模型关注的是Model的不变，所以，在MVC模型里，Model不依赖于View，但是 View是依赖于Model的。不仅如此，因为有一些业务逻辑在View里实现了，导致要更改View也是比较困难的，至少那些业务逻辑是无法重用的。

* MVVM在概念上是真正将页面与数据逻辑分离的模式，它把数据绑定工作放到一个JS里去实现，而这个JS文件的主要功能是完成数据的绑定，即把model绑定到UI的元素上。

> 有人做过测试：使用Angular（MVVM）代替Backbone（MVC）来开发，代码可以减少一半。

此外，MVVM另一个重要特性，双向绑定。它更方便你同时维护页面上都依赖于某个字段的N个区域，而不用手动更新它们。 

######总结：

* 优点：MVVM就是在MVC的基础上加入了一个视图模型viewModel，用于数据有效性的验证，视图的展示逻辑，网络数据请求及处理，其他的数据处理逻辑集合，并定下相关接口和协议。相比起MVC，MVVM中vc的职责和复杂度更小，对数据处理逻辑的测试更加方便，对bug的原因排查更加方便，代码可阅读性，重用性和可维护性更高。MVVM耦合性更低。MVVM不同层级的职责更加明确，更有利于代码的编写和团队的协作。
缺点：MVVM相比MVC代码量有所增加。MVVM相比MVC在代码编写之前需要有更清晰的模式思路。



#十五：Object&Swift

Obejective-C复杂的语法，更加简单易用、有未来，让许多开发者心动不已，Swift明显的特点有：


* 苹果宣称 Swift 的特点是：快速、现代、安全、互动，而且明显优于 Objective-C 语言

* 可以使用现有的 `Cocoa` 和 `Cocoa Touch` 框架

* Swift 取消了 Objective C 的指针及其他不安全访问的使用

* 舍弃 Objective C 早期应用 `Smalltalk` 的语法，全面改为句点表示法

* 提供了类似 Java 的名字空间(namespace)、泛型(generic)、运算对象重载（operator overloading）

* Swift 被简单的形容为 “没有 C 的 Objective-C”（Objective-C without the C）

* 为苹果开发工具带来了Xcode Playgrounds功能，该功能提供强大的互动效果，能让Swift源代码在撰写过程中实时显示出其运行结果；

* 基于C和Objective-C，而却没有C的一些兼容约束；

* 采用了安全的编程模式；

* 界面基于Cocoa和Cocoa Touch框架；

* 保留了Smalltalk的动态特性。

#十六：TCP&UDP

* TCP（Transmission Control Protocol，传输控制协议）是基于连接的协议，也就是说，在正式收发数据前，必须和对方建立可靠的连接。一个TCP连接必须要经过三次“对话”才能建立起来，其中的过程非常复杂，我们这里只做简单、形象的介绍，你只要做到能够理解这个过程即可。

* UDP（User Data Protocol，用户数据报协议）是与TCP相对应的协议。它是面向非连接的协议，它不与对方建立连接，而是直接就把数据包发送过去！ 
  UDP适用于一次只传送少量数据、对可靠性要求不高的应用环境。

 |  区别| TCP|  UDP | 
| ------------- |:-------------:| -----:|
| 是否连接  |面向连接  |面向非连接  |
| 传输可靠性  |可靠  |不可靠  |
| 应用场合  |传输大量数据  |少量数据  |
| 速度 | 慢 | 快 |
 


#十七：POST&GET
1. get是从服务器上获取数据，post是向服务器传送数据。
2. get是把参数数据队列加到提交表单的ACTION属性所指的URL中，值和表单内各个字段一一对应，在URL中可以看到。post是通过HTTP post机制，将表单内各个字段与其内容放置在HTML HEADER内一起传送到ACTION属性所指的URL地址。用户看不到这个过程。
3. 对于get方式，服务器端用Request.QueryString获取变量的值，对于post方式，服务器端用Request.Form获取提交的数据。
4. get传送的数据量较小，不能大于2KB。post传送的数据量较大，一般被默认为不受限制。但理论上，IIS4中最大量为80KB，IIS5中为100KB。
5. get安全性非常低，post安全性较高。但是执行效率却比Post方法好。 

建议：
1、get方式的安全性较Post方式要差些，包含机密信息的话，建议用Post数据提交方式；
2、在做数据查询时，建议用Get方式；而在做数据添加、修改或删除时，建议用Post方式；
#十八：长链接&短链接

* TCP短连接

我们模拟一下TCP短连接的情况，client向server发起连接请求，server接到请求，然后双方建立连接。client向server 发送消息，server回应client，然后一次读写就完成了，这时候双方任何一个都可以发起close操作，不过一般都是client先发起 close操作。为什么呢，一般的server不会回复完client后立即关闭连接的，当然不排除有特殊的情况。从上面的描述看，短连接一般只会在 client/server间传递一次读写操作

* TCP长连接

接下来我们再模拟一下长连接的情况，client向server发起连接，server接受client连接，双方建立连接。Client与server完成一次读写之后，它们之间的连接并不会主动关闭，后续的读写操作会继续使用这个连接。

######长连接短连接操作过程

* 短连接的操作步骤是：

建立连接——数据传输——关闭连接…建立连接——数据传输——关闭连接

* 长连接的操作步骤是：

建立连接——数据传输…（保持连接）…数据传输——关闭连接

######什么时候用长连接，短连接？

* 长连接多用于操作频繁，点对点的通讯，而且连接数不能太多情况，。每个TCP连接都需要三步握手，这需要时间，如果每个操作都是先连接，再操作的话那么处理速度会降低很多，所以每个操作完后都不断开，次处理时直接发送数据包就OK了，不用建立TCP连接。例如：数据库的连接用长连接， 如果用短连接频繁的通信会造成socket错误，而且频繁的socket 创建也是对资源的浪费。

* 而像WEB网站的http服务一般都用短链接，因为长连接对于服务端来说会耗费一定的资源，而像WEB网站这么频繁的成千上万甚至上亿客户端的连接用短连接会更省一些资源，如果用长连接，而且同时有成千上万的用户，如果每个用户都占用一个连接的话，那可想而知吧。所以并发量大，但每个用户无需频繁操作情况下需用短连好。


######长连接和短连接的优点和缺点

由上可以看出，长连接可以省去较多的TCP建立和关闭的操作，减少浪费，节约时间。对于频繁请求资源的客户来说，较适用长连接。不过这里存在一个问题，存活功能的探测周期太长，还有就是它只是探测TCP连接的存活，属于比较斯文的做法，遇到恶意的连接时，保活功能就不够使了。在长连接的应用场景下，client端一般不会主动关闭它们之间的连接，Client与server之间的连接如果一直不关闭的话，会存在一个问题，随着客户端连接越来越多，server早晚有扛不住的时候，这时候server端需要采取一些策略，如关闭一些长时间没有读写事件发生的连接，这样可 以避免一些恶意连接导致server端服务受损；如果条件再允许就可以以客户端机器为颗粒度，限制每个客户端的最大长连接数，这样可以完全避免某个蛋疼的客户端连累后端服务。

* 短连接对于服务器来说管理较为简单，存在的连接都是有用的连接，不需要额外的控制手段。但如果客户请求频繁，将在TCP的建立和关闭操作上浪费时间和带宽。

* 长连接和短连接的产生在于client和server采取的关闭策略，具体的应用场景采用具体的策略，没有十全十美的选择，只有合适的选择。

#十九：内存泄露&内存溢出

* 内存溢出 out of memory，是指程序在申请内存时，没有足够的内存空间供其使用，出现out of memory；比如申请了一个integer,但给它存了long才能存下的数，那就是内存溢出。

* 内存泄露 memory leak，是指程序在申请内存后，无法释放已申请的内存空间，一次内存泄露危害可以忽略，但内存泄露堆积后果很严重，无论多少内存,迟早会被占光。

> memory leak会最终会导致out of memory！

内存溢出就是你要求分配的内存超出了系统能给你的，系统不能满足需求，于是产生溢出。 

#二十：CoreData&SQLite3

首先，coredata和sqlite的概念不同，core为对象周期管理，而sqlite为dbms。

* 使用方便性。实际上，一个成熟的工程中一定是对数据持久化进行了封装的，因此底层使用的到底是core data还是sqlite，不应该被业务逻辑开发者关心。因此，即使习惯写SQL查询的人，也应该避免在业务逻辑中直接编写SQL语句。
* 存储性能，在写入性能上，因为都是使用的sqlite格式作为磁盘存储格式，因此其性能是一样的，如果你觉得用core data写的慢，很可能是你用sqlite的时候写的每条数据的内容没有core data时多，或者是你批量写入的时候每写入一条就调用了一次save。
* 查询性能，core data因为要兼容多种后端格式，因此查询时，其可用的语句比直接使用sqlite少，因此有些fetch实际上不是在sqlite中执行的。但这样未必会降低查询效率。因为iPhone的flash memory速度还是很快的。我的经验是大部分时候，在内存不是很紧张时，直接fetch一个entity的所有数据然后在内存中做filter往往比使用predicate在fetch时过滤更快。如果你觉的查询慢，很可能是查询方式有问题，可以把core data的debug模式打开，看一下到底执行了多少SQL语句，相信其中大部分是可以通过改写core data的调用方式避免的。
* core data的一个比较大的痛点是多人合作开发的时候，管理coredata的模型需要很小心，尤其是合并的时候，他的data model是XML格式的，手动resolve比较烦心。
* core data还有其他sql所不具备的优点，比如对undo的支持，多个context实现sketchbook类似的功能。为ManagedObject优化的row cash等。
* 另外core data是支持多线程的，但需要thread confinement的方式实现,使用了多线程之后可以最大化的防止阻塞主线程。


#二十一：传值通知&推送通知（本地&远程）

+ 传值通知：类似通知，代理，Block实现值得传递
+ 推送通知：推送到用户手机对应的App上（主要是不再前台的情况）

######本地通知。

local notification，用于基于时间行为的通知，比如有关日历或者todo列表的小应用。另外，应用如果在后台执行，iOS允许它在受限的时间内运行，它也会发现本地通知有用。比如，一个应用，在后台运行，向应用的服务器端获取消息，当消息到达时，比如下载更新版本的提示消息，通过本地通知机制通知用户。

本地通知是UILocalNotification的实例，主要有三类属性：

  * scheduled time，时间周期，用来指定iOS系统发送通知的日期和时间；
  * notification type，通知类型，包括警告信息、动作按钮的标题、应用图标上的badge（数字标记）和播放的声音；
  * 自定义数据，本地通知可以包含一个dictionary类型的本地数据。

对本地通知的数量限制，iOS最多允许最近本地通知数量是64个，超过限制的本地通知将被iOS忽略。

######远程通知（需要服务器）。

流程大概是这样的

  * 1.生成CertificateSigningRequest.certSigningRequest文件

  * 2.将CertificateSigningRequest.certSigningRequest上传进developer，导出.cer文件

  * 3.利用CSR导出P12文件

  * 4.需要准备下设备token值（无空格）

  * 5.使用OpenSSL合成服务器所使用的推送证书
    
一般使用极光推送，步骤是一样的，只是我们使用的服务器是极光的，不需要自己大服务器！

		
#二十二：第三方库&第三方平台
* 第三方库:一般是指大牛封装好的一个框架（库），或者第三方给我们提供的一个库，这里比较笼统
*第三方平台：指第三方提供的一些服务，其实很多方面跟第三方库是一样的，但是还是存在一些区别。

######区别：
* 库：AFN，ASI，Alomofire，MJRefresh，MJExtension，MBProgressHUD
* 平台：极光，百度，友盟，Mob，环信，
#二十三：KVO&KVC

#####底层实现：

* KVC运用了一个isa-swizzling技术。isa-swizzling就是类型混合指针机制。KVC主要通过isa- swizzling，来实现其内部查找定位的。isa指针，如其名称所指，（就是is a kind of的意思），指向维护分发表的对象的类。该分发表实际上包含了指向实现类中的方法的指针，和其它数据。

* 当观察者为一个对象的属性进行了注册，被观察对象的isa指针被修改的时候，isa指针就会指向一个中间类，而不是真实的类。所以isa指 针其实不需要指向实例对象真实的类。所以我们的程序最好不要依赖于isa指针。在调用类的方法的时候，最好要明确对象实例的类名。

######KVO概述

KVO,即：Key-Value Observing，它提供一种机制，当指定的对象的属性被修改后，则对象就会接受到通知。简单的说就是每次指定的被观察的对象的属性被修改后，KVO就会自动通知相应的观察者了。

######使用方法

系统框架已经支持KVO，所以程序员在使用的时候非常简单。

1. 注册，指定被观察者的属性，

2. 实现回调方法

3. 移除观察


######KVC概述

KVC是KeyValueCoding的简称，它是一种可以直接通过字符串的名字(key)来访问类属性(实例变量)的机制。而不是通过调用Setter、Getter方法访问。

当使用KVO、Core Data、CocoaBindings、AppleScript(Mac支持)时，KVC是关键技术。

######使用方法

关键方法定义在：NSKeyValueCodingprotocol

KVC支持类对象和内建基本数据类型。

 

+ 获取值

	- valueForKey:，传入NSString属性的名字。

	- valueForKeyPath:，传入NSString属性的路径，xx.xx形式。

	- valueForUndefinedKey它的默认实现是抛出异常，可以重写这个函数做错误处理。

+ 修改值

	- setValue:forKey:

	- setValue:forKeyPath:

	- setValue:forUndefinedKey:

	- setNilValueForKey:当对非类对象属性设置nil时，调用，默认抛出异常。

+ 一对多关系成员的情况

	- mutableArrayValueForKey：有序一对多关系成员  NSArray

	- mutableSetValueForKey：无序一对多关系成员  NSSet


######补充：KVO与Notification之间的区别：

* notification是需要一个发送notification的对象，一般是notificationCenter，来通知观察者。

* KVO是直接通知到观察对象，并且逻辑非常清晰，实现步骤简单。

#二十四：时间传递&响应者链
######事件的产生和传递过程：

+ 1.发生触摸事件后，系统会将该事件加入到一个由UIApplication管理的队列事件中

+ 2.UIApplication会从事件队列中取出最前面的事件，并将事件分发下去以便处理，通常会先发送事件给应用程序的主窗口(keyWindow)

+ 3.主窗口会在视图层次结构中找到一个最合适的视图来处理触摸事件

+ 4.找到合适的视图控件后，就会调用视图控件的touches方法来作事件的具体处理：touchesBegin... touchesMoved...touchesEnded等

+ 5.这些touches方法默认的做法是将事件顺着响应者链条向上传递，将事件叫个上一个相应者进行处理

> 一般事件的传递是从父控件传递到子控件的



>如果父控件接受不到触摸事件，那么子控件就不可能接收到触摸事件
UIView不能接收触摸事件的三种情况：

* 1.不接受用户交互：userInteractionEnabled = NO;

* 2.隐藏：hidden = YES;

* 3.透明：alpha = 0.0~0.01

        用户的触摸事件首先会由系统截获，进行包装处理等。
        然后递归遍历所有的view，进行碰触测试(hitTest)，直到找到可以处理事件的view。
        - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;   // recursively calls -pointInside:withEvent:. point is in the receiver's coordinate system
        - (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;   // default returns YES if point is in bounds
        大致的过程application –> window –> root view –>……–>lowest view 

######响应者链

响应者链条其实就是很多响应者对象(继承自UIResponder的对象)一起组合起来的链条称之为响应者链条

一般默认做法是控件将事件顺着响应者链条向上传递，将事件交给上一个响应者进行处理。那么如何判断当前响应者的上一个响应者是谁呢？有以下两个规则：

+ 1.判断当前是否是控制器的View，如果是控制器的View，上一个响应者就是控制器

+ 2.如果不是控制器的View，上一个响应者就是父控件

	当有view能够处理触摸事件后，开始响应事件。
        系统会调用view的以下方法：
        - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
        - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
        - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
        - (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
        可以多对象共同响应事件。只需要在以上方法重载中调用super的方法。

        大致的过程initial view –> super view –> …..–> view controller –> window –> Application

        需要特别注意的一点是，传递链中时没有controller的，因为controller本身不具有大小的概念。但是响应链中是有controller的，因为controller继承自UIResponder。

>UIApplication-->UIWindow-->递归找到最合适处理的控件-->控件调用touches方法-->判断是否实现touches方法-->没有实现默认会将事件传递给上一个响应者-->找到上一个响应者-->找不到方法作废

PS：利用响应者链条我们可以通过调用touches的super 方法，让多个响应者同时响应该事件。

#二十五：堆&栈

######一、堆栈空间分配区别：

	* 1、栈（操作系统）：由操作系统自动分配释放 ，存放函数的参数值，局部变量的值等。其操作方式类似于数据结构中的栈；
	
	* 2、堆（操作系统）： 一般由程序员分配释放， 若程序员不释放，程序结束时可能由OS回收，分配方式倒是类似于链表。
######二、堆栈缓存方式区别：


	* 1、栈使用的是一级缓存， 他们通常都是被调用时处于存储空间中，调用完毕立即释放；
	
	* 2、堆是存放在二级缓存中，生命周期由虚拟机的垃圾回收算法来决定（并不是一旦成为孤儿对象就能被回收）。所以调用这些对象的速度要相对来得低一些。

######三、堆栈数据结构区别：
	* 堆（数据结构）：堆可以被看成是一棵树，如：堆排序；
	
	* 栈（数据结构）：一种先进后出的数据结构。 


######内存其他补充：

* 全局区（静态区）（static）—，全局变量和静态变量的存储是放在一块的，初始化的全局变量和静态变量在一块区域， 未初始化的全局变量和未初始化的静态变量在相邻的另一块区域。 - 程序结束后有系统释放
* 文字常量区—常量字符串就是放在这里的。 程序结束后由系统释放
* 程序代码区—存放函数体的二进制代码。

#二十六：UDID&UUID

* UDID是Unique Device Identifier的缩写,中文意思是设备唯一标识.

在很多需要限制一台设备一个账号的应用中经常会用到,在Symbian时代,我们是使用IMEI作为设备的唯一标识的,可惜的是Apple官方不允许开发者获得设备的IMEI. 


	[UIDevice currentDevice] uniqueIdentifier]

但是我们需要注意的一点是,对于已越狱了的设备,UDID并不是唯一的.使用Cydia插件UDIDFaker,可以为每一个应用分配不同的UDID.
所以UDID作为标识唯一设备的用途已经不大了. 


* UUID是Universally Unique Identifier的缩写,中文意思是通用唯一识别码.

由网上资料显示,UUID是一个软件建构的标准,也是被开源软件基金会(Open Software Foundation,OSF)的组织在分布式计算环境(Distributed Computing Environment,DCE)领域的一部份.UUID的目的,是让分布式系统中的所有元素,都能有唯一的辨识资讯,而不需要透过中央控制端来做辨识资讯的指定. 
#二十七：CPU&GPU

* CPU:中央处理器（英文Central Processing Unit）是一台计算机的运算核心和控制核心。CPU、内部存储器和输入/输出设备是电子计算机三大核心部件。其功能主要是解释计算机指令以及处理计算机软件中的数据。

* GPU:英文全称Graphic Processing Unit，中文翻译为“图形处理器”。一个专门的图形核心处理器。GPU是显示卡的“大脑”，决定了该显卡的档次和大部分性能，同时也是2D显示卡和3D显示卡的区别依据。2D显示芯片在处理3D图像和特效时主要依赖CPU的处理能力，称为“软加速”。3D显示芯片是将三维图像和特效处理功能集中在显示芯片内，也即所谓的“硬件加速”功能。


#二十八:点（pt）&像素（px）

* 像素（pixels）是数码显示上最小的计算单位。在同一个屏幕尺寸，更高的PPI（每英寸的像素数目），就能显示更多的像素，同时渲染的内容也会更清晰。

* 点（points）是一个与分辨率无关的计算单位。根据屏幕的像素密度，一个点可以包含多个像素（例如，在标准Retina显示屏上1 pt里有2 x 2个像素）。

当你为多种显示设备设计时，你应该以“点”为单位作参考，但设计还是以像素为单位设计的。这意味着仍然需要以3种不同的分辨率导出你的素材，不管你以哪种分辨率设计你的应用。