---

layout: post
title: "传值方式总结"
date: 2015-07-01 02:32:36 +0800
comments: true
categories: 项目实战

---






+ 简单总结
	- 代理
	- Block
	- 通知

***

+ 简单实用
	- 代理
	- Block
	- 通知



<!--more-->




虽然这一期的主题是关于Foundation Framework的，不过本文中还介绍了一些超出Foundation Framework(KVO和Notification)范围的一些消息传递机制，另外还介绍了delegation，block和target- action。
 
大多数情况下，消息传递该使用什么机制，是很明确的了，当然了，在某些情况下该使用什么机制并没有明确的答案，需要你亲自去尝试一下。
 
 
 
 ***
 
###简单总结
 
 
+ delegation

	- 在苹果的Framework中，delegation模式被广泛的只用着。delegation允许我们定制某个对象的行为，并且可以收到某些 确定的事件。为了使用delegation模式，消息的发送者需要知道消息的接收者(delegate)，反过来就不用了。这里的发送者和接收者是比较松 耦合的，因为发送者只知道它的delegate是遵循某个特定的协议。
 
	- delegate协议可以定义任意的方法，因此你可以准确的定义出你所需要的类型。你可以用函数参数的形式来处理消息内容，delegate还 可以通过返回值的形式给发送者做出回应。如果只需要在相对接近的两个模块之间进行消息传递，那么Delegation是一种非常灵活和直接方式。
 
	- 不过，过渡使用delegation也有一定的风险，如果两个对象的耦合程度比较紧密，相互之间不能独立存在，那么此时就没有必要使用 delegate协议了，针对这种情况，对象之间可以知道相互间的类型，进而直接进行消息传递。例如UICollectionViewLayout和 NSURLSessionConfiguration。
 
+ block
	- Block相对来说，是一种比较新的技术，它首次出现是在OS X 10.6和iOS 4中。一般情况下，block可以满足用delegation实现的消息传递机制。不过这两种机制都有各自的需求和优势。

	- 当不考虑使用block时，一般主要是考虑到block极易引起retain环。如果发送者需要reatain block，而又不能确保这个引用什么时候被nil，这样就会发生潜在的retain环。


+ Notification

	- 在不相关的两部分代码中要想进行消息传递，通知(notifacation)是非常好的一种机制，它可以对消息进行广播。特别是想要传递丰富的信息，并且不一定指望有谁对此消息关心。
 
	- 通知可以用来发送任意的消息，甚至包含一个userInfo字典，或者是NSNotifacation的一个子类。通知的独特之处就在于发送者 和接收者双方并不需要相互知道。这样就可以在非常松耦合的模块间进行消息的传递。记住，这种消息传递机制是单向的，作为接收者是不可以回复消息的。
 
 ***

###简单使用

初始化之后出现下面的界面

 
{% img /images/chuanzhi001.png Caption %}  

 

 

#####准备：

 

这里试试根据本文的实战做相应的介绍，关于拓展只要理解了这里的思路基本是三种传值的使用没有什么问题。

 

首先，由于我们要实现的点击对应的组实现展开分组显示对应组里面的所有行。

我这个项目使用的是多层分组模型，讲每一组合对应的属性还有friends作为组模型，再将friends作为子模型，实现表格数据的现实。


{% img /images/chuanzhi002.png Caption %}  

 

###### 定义一个BOOL值用来记录点击（由于我们需要实现点击对应组做事情，所以先在组模型中定义一个BOOL）


	@property (nonatomic, assign, getter = isOpen) BOOL open; 

 

###### 在相应的点击方法里面是实现取反点击，这里的点击方法是分组View上面一个按钮的点击事件。

	
	self.group.open = !self.group.open; 

 

###### 在numberOfRowsInSection中返回的时候使用三木判断是否点击，并且实现伸缩与展开，

	
	return model.open?model.friends.cout:0; 


 

这里完成之后运行程序点一下试试，你会发现。。。。。。。。。。。。。。。。。什么效果也没有。

当然会没有效果，因为我们没有传值，后面才是本章的重点，学会了这里以后关于通知，代理。Block的使用基本上没有问题。

 

***
/######################代理######################/
***

##方法一：代理

###### 在对应的View中创建一个协议

	@class iCocosView
	
	 
	
	@protocol iCocoDelegate <NSObject>
	
	@optional
	
	-(void)headerView:(iCocosView *)view;
	
	 
	
	@end
 

###### 创建一个代理属性

	 @property (nonatomic, assign) id<iCocoDelegate> delegate; 

 

###### 在这个实现文件中判断有没有实现这个代理方法

	if([self.delegate repondToSelector:selector(headerView)]) {
	 
	[self.delegate headerView];
	 
	}
 

 

###### 先在对应的控制器遵守这个协议，并且设置代理

	 <iCocosDelegate> 

	header.delegate = self; //让控制器充当代理
 

###### 实现代理方法

	－（void）headerView:(iCocosView *)view {[self.tableView reloadData];  }  

 
 
***
/######################Block######################/
***

##方法二：Block

###### 定义一个Block

	typedef void (^iCocosBlock)(id);  

###### 创建一个Block对应的属性（使用Copy）

	 @property （nonatomic， weak）iCocosBlock block; 

###### 实现文件中判读

	  if(self.block) { self.block(self);}  

###### 在控制器中实现

	 header.block = ^(id sender) {  //sender是传过来的参数
	 
	 [self.tableView reloadData];
	
	 };
 

 

 
***
/######################通知######################/
***

##方法三：通知

 注意：通知的使用是前面的反向思维，在控制器里面注册并且实现通知方法，然后在分组View里面发布这个通知。

###### 在控制器中注册一个通知

	[［NSNotificationCenter defaultCenter］ addObserver:self selector:@selector(notiClick) name:@“friends” object:nil]; 2 3  

###### 实现通知方法

	－（void）notiClick
	
	{
	
	[self.tableView reloadData];
	
	}
 

 

###### 同样在Header分组的实现文件中发布一个通知

	[［NSNotificationCenter defaultCenter］postNotificationName: @“friends”object:self userInfo:nil]; 2 3  

###### 移除通知：我们可以在两个方法里面一出通知：ViewDidDidApper和Dealloc

并且使用良种两种方法

@1:移除所有通知

	[［NSNotificationCenter defaultCenter］ removeObserver:self]; 

@2:根据名字移除通知

	[［NSNotificationCenter defaultCenter］removeObserver:self name:@“friedns” object:nil];  

这里需要注意：实际开发中使用完通知之后一定要移除通知，否则如果里面通知太多，当你再次发送一个通知的时候程序就不知道去找那个通知甚至会导致程序奔溃。



 
***
/######################运行结果######################/
***
 

使用上面任何一种方法都可以实现同样的功能，点击每一行的组的时候就会展开相应行并且显示对应组的所有行。


{% img /images/chuanzhi003.png Caption %}  

实现Header左边按钮上面图标的旋转：（这里是一个重点，也是以后以后开发中肯呢过遇到的一个难点，可能不是一样的但是或许思路和原理一样，这里是这篇文章中除了传值的三种方式以后最重要的地方）
	/*****在这个方法里面实现旋转：当View移到父控件的时候，不然旋转也看不到选过，因为刷新实在旋转之后的，旋转之后再刷新，从缓存迟里面取出来********/
	
	-(void)didMoveToSuperview
	{
	    if (self.group.open) {
	        self.nameView.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
	    }else {
	        self.nameView.imageView.transform = CGAffineTransformMakeRotation(0);
	    }
	    
	}
	/ 

但是具体使用说明视情况而定：

总结：。。。。。。。。待续