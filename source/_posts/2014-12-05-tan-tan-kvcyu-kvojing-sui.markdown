---
layout: post
title: "谈谈KVC与KVO精髓"
date: 2014-12-05 23:11:52 +0800
comments: true
categories: Low-Level 
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

 

Swift中使用KVC和KVO的类都必须必须继承自NSObject


由于ObjC主要基于Smalltalk进行设计，因此它有很多类似于Ruby、Python的动态特性，例如动态类型、动态加载、动态绑定等。今天我们着重介绍ObjC中的键值编码（KVC）、键值监听（KVO）特性：

* 键值编码KVC
* 键值监听KVO



<!--more-->




#####键值编码KVC
我们知道在C#中可以通过反射读写一个对象的属性，有时候这种方式特别方便，因为你可以利用字符串的方式去动态控制一个对象。其实由于ObjC的语言特性，你根部不必进行任何操作就可以进行属性的动态读写，这种方式就是Key Value Coding（简称KVC）。

KVC的操作方法由NSKeyValueCoding协议提供，而NSObject就实现了这个协议，也就是说ObjC中几乎所有的对象都支持KVC操作，常用的KVC操作方法如下：

* 动态设置： setValue:属性值 forKey:属性名（用于简单路径）、setValue:属性值 forKeyPath:属性路径（用于复合路径，例如Person有一个Account类型的属性，那么person.account就是一个复合属性） 
动态读取： valueForKey:属性名 、valueForKeyPath:属性名（用于复合路径）

#####键值监听KVO
我们知道在WPF、Silverlight中都有一种双向绑定机制，如果数据模型修改了之后会立即反映到UI视图上，类似的还有如今比较流行的基于MVVM设计模式的前端框架，例如Knockout.js。其实在ObjC中原生就支持这种机制，它叫做Key Value Observing（简称KVO）。

KVO其实是一种观察者模式，利用它可以很容易实现视图组件和数据模型的分离，当数据模型的属性值改变之后作为监听器的视图组件就会被激发，激发时就会回调监听器自身。在ObjC中要实现KVO则必须实现NSKeyValueObServing协议，不过幸运的是NSObject已经实现了该协议，因此几乎所有的ObjC对象都可以使用KVO。

在ObjC中使用KVO操作常用的方法如下：

* 注册指定Key路径的监听器： addObserver: forKeyPath: options:  context:
* 删除指定Key路径的监听器： removeObserver: forKeyPath、removeObserver: forKeyPath: context:
* 回调监听： observeValueForKeyPath: ofObject: change: context:


> KVO的使用步骤也比较简单：
通过addObserver: forKeyPath: options: context:为被监听对象（它通常是数据模型）注册监听器 
重写监听器的observeValueForKeyPath: ofObject: change: context:方法


***

###KVC

key-value coding
是1种间接访问对象的机制
key的值就是属性名称的字符串，返回的value是任意类型，需要自己转化为需要的类型
KVC主要就是两个方法
	
* （1）通过key设置对应的属性
* （2）通过key获得对应的属性

举例

	class TestForKVC:NSObject{ var hwcCSDN = "hello world" } var instance = TestForKVC() var value = instance.valueForKey("hwcCSDN") as String instance.setValue("hello hwc",forKey:"hwcCSDN")
###KVO

key-value observing
建立在KVC之上的的机制
主要功能是检测对象属性的变化
这是1个完善的机制，不需要用户自己设计复杂的视察者模式
对需要视察的属性要在前面加上dynamic关键字
举例
#####第1步，对要视察的对象的属性加上dynamic关键字

	class ToObserver:NSObject{ dynamic var hwcDate = NSDate() func updateDate(){ hwcDate = NSDate() } }

#####第2步，声明1个全局的用来辨别是哪一个被视察属性的变量

	private var mycontext = 0

#####第3步，在要视察的类中addObserver,在析构中removeObserver，重写observerValueForKeyPath

	class TestForCSDN:UIViewController{ var testVariable = ToObserver() override func viewDidLoad(){ super.viewDidLoad() testVariable.addObserver(self,forKeyPath:"hwcDate",options:.New,context:&mycontext) } deinit{ testVariable.removeObserver(self,forKeyPath:"hwcDate") } overfide func observeValueForKeyPath(keyPath:String,ofObject:AnyObject,change:[NSObject:AnyObject],context:UnsafeMutablePointer<Void>){ if(context == &mycontext){ println("Changed to:(change[NSKeyValueChangeNewKey]!)") } } }
 
这样，就能够在函数observeValueForKeyPath检测到变化了
 
 
下面来看看OC是怎么实现KVO和KVC的
###1、KVC

KVC(KeyValueCoding)　“键-值-编码”是一种可以直接通过字符串的名字（key）来访问类实例变量的机制，是通过setter、getter方法访问。
属性的访问和设置
KVC可以用来访问和设置实例变量的值。key是属性名称

	设置方式：[self setValue:aName forKey:@"name"]
	等同于　self.name = aName;

***

	访问方式： aString　=　[self valueForKey:@"name"]
	等同于　aString = self.name;

###2、KVO 观察者

KVO(KeyValueObserver)　“键-值-监听”定义了这样一种机制，当对象的属性值发生变化的时候，我们能收到一个“通知”。观察者更准确
NSObject提供了监听机制。所有子类也就全都能进行监听
KVO是基于KVC来实现的。 实现监听步骤

* （1）注册监听对象。

anObserver指监听者，keyPath就是要监听的属性值，而context方便传输你需要的数据，它是个指针类型。
 

	-(void)addObserver:(NSObject *)anObserver
	　　　　forKeyPath:(NSString *)keyPath
	　　　　　　options:(NSKeyValueObservingOptio
	 
	
	ns)options            
	　　　　　　context:(void *)context//（void*）是任何指针类型
其中， options是监听的选项，也就是说明监听返回的字典包含什么值。有两个常用的选项：
NSKeyValueObservingOptionNew　指返回的字典包含新值。
NSKeyValueObservingOptionOld    指返回的字典包含旧值。

* （2）实现监听方法。



监听方法在Value（属性的值）发生变化的时候自动调用。

	-(void) observeValueForKeyPath:(NSString *)keyPath
	                      ofObject:(id)object
	                        change:(NSDictionary *)change
	                       context:(void *)context
	                       
其中，object指被监听的对象。change里存储了一些变化的数据，比如变化前的数据，变化后的数据。


###3、通知
通知是iOS开发框架中的一种设计模式，内部的实现机制由Cocoa框架支持。
通知一般用于M、V、C的间的信息传递。像我在设置页面设置App皮肤。
M是modol模型 V是view视图 C是control控制器。
系统通知


	//注册通知
	[[NSNotificationCenter defaultCenter] addObserver:self
	selector:@selector(didFinish:) //didFinish:是方法名   self （谁的）和  didFinish:确定方法
	name:MPMoviePlayerPlaybackDidFinishNotification
	　object:nil];
	selector是方法名     class是描述类的类    SEL method=@selector（方法名）
	通知用完要移除
	//移除通知
	[[NSNotificationCenter defaultCenter] removeObserver:self
	         name:MPMoviePlayerPlaybackDidFinishNotification
	                                              object:nil];
	                                              
> 总结:这一篇就介绍了iOS开发中比较有特色的两个机制：KVC和KVO

		KVC：就是可以暴力的去get/set类的私有属性，同时还有强大的键值路径对数组类型的属性进行操作

		KVO：监听类中属性值变化的






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