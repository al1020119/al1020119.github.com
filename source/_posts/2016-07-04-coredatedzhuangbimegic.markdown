---

layout: post
title: "MagicalRecord魔法"
date: 2016-07-04 20:59:42 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---


{% img /images/bgHeader.png Caption %}  




正文：

到目前为止，已经将CoreData相关的知识点都讲完了。

在这篇文章中，主要讲一个CoreData第三方库-MagicalRecord。目前为止这个第三方在Github上有9500+的Star，是所有CoreData第三方库中使用最多、功能最全的。在文章的后面还会对CoreData做一个总结，以及对本系列所有文章做一个总结。

文章中如有疏漏或错误，还请各位及时提出，谢谢！

<!--more-->

####MagicalRecord

CoreData是苹果自家推出的一个持久化框架，使用起来更加面向对象。但是在使用过程中会出现大量代码，而且CoreData学习曲线比较陡峭，如果掌握不好，在使用过程中很容易造成其他问题。

国外开发者开源了一个基于CoreData封装的第三方——MagicalRecord，就像是FMDB封装SQLite一样，MagicalRecord封装的CoreData，使得原生的CoreData更加容易使用。并且MagicalRecord降低了CoreData的使用门槛，不用去手动管理之前的PSC、MOC等对象。

根据Github上MagicalRecord的官方文档，MagicalRecord的优点主要有三条：

1. 清理项目中CoreData代码

2. 支持清晰、简单、一行式的查询操作

3. 当需要优化请求时，可以获取NSFetchRequest进行修改

添加MagicalRecord到项目中

将MagicalRecord添加到项目中，和使用其他第三方一样，可以通过下载源码和CocoaPods两种方式添加。

1. 从Github下载MagicalRecord源码，将源码直接拖到项目中，后续需要手动更新源码。

2. 也可以通过CocoaPods安装MagicalRecord，需要在Podfile中加入下面命令，后续只需要通过命令来更新。

######安装
	
	pod "MagicalRecord"

在之前创建新项目时，通过勾选"Use Core Data"的方式添加CoreData到项目中，会在AppDelegate文件中生成大量CoreData相关代码。如果是大型项目，被占用的位置是很重要的。而对于MagicalRecord来说，只需要两行代码即可。

	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// 初始化CoreData堆栈，也可以指定初始化某个CoreData堆栈
	[MagicalRecord setupCoreDataStack];
	return YES;
	}
	- (void)applicationWillTerminate:(UIApplication *)application {
	// 在应用退出时，应该调用cleanUp方法
	[MagicalRecord cleanUp];
	}

MagicalRecord是支持CoreData的.xcdatamodeld文件的，使得CoreData这一优点可以继续使用。建立数据结构时还是像之前使用CoreData一样，通过.xcdatamodeld文件的方式建立。

{% img /images/coredateduoxianchenganquan004.png Caption %} 


####支持iCloud

CoreData是支持iCloud的，MagicalRecord对iCloud相关的操作也做了封装，只需要使用MagicalRecord+iCloud.h类中提供的方法，就可以进行iCloud相关的操作。

例如下面是MagicalRecord+iCloud.h中的一个方法，需要将相关参数传入即可。

	+ (void)setupCoreDataStackWithiCloudContainer:(NSString *)containerID localStoreNamed:(NSString *)localStore;

######创建上下文

MagicalRecord对上下文的管理和创建也比较全面，下面是MagicalRecord提供的部分创建和获取上下文的代码。因为是给NSManagedObjectContext添加的Category，可以直接用NSManagedObjectContext类调用，使用非常方便。

但是需要注意，虽然系统帮我们管理了上下文对象，对于耗时操作仍然要放在后台线程中处理，并且在主线程中进行UI操作。

    + [NSManagedObjectContext MR_context]  设置默认的上下文为它的父级上下文，并发类型为NSPrivateQueueConcurrencyType

    + [NSManagedObjectContext MR_newMainQueueContext]  创建一个新的上下文，并发类型为NSMainQueueConcurrencyType

    + [NSManagedObjectContext MR_newPrivateQueueContext]  创建一个新的上下文，并发类型为NSPrivateQueueConcurrencyType

    + [NSManagedObjectContext MR_contextWithParent:]  创建一个新的上下文，允许自定义父级上下文，并发类型为NSPrivateQueueConcurrencyType

    + [NSManagedObjectContext MR_contextWithStoreCoordinator:]  创建一个新的上下文，并允许自定义持久化存储协调器，并发类型为NSPrivateQueueConcurrencyType

    + [NSManagedObjectContext MR_defaultContext]  获取默认上下文对象，项目中最基础的上下文对象，并发类型是NSMainQueueConcurrencyType

增删改查

MagicalRecord对NSManagedObject添加了一个Category，将增删改查等操作放在这个Category中，使得这些操作可以直接被NSManagedObject类及其子类调用。

1. 增

对于托管模型的创建非常简单，不需要像之前还需要进行上下文的操作，现在这都是MagicalRecord帮我们完成的。

	
	// 创建并插入到上下文中
	Employee *emp = [Employee MR_createEntity];

2. 删

删除数据
	
	
	// 从上下文中删除当前对象
	[emp MR_deleteEntity];

3. 改

修改数据
	
	
	// 获取一个上下文对象
	NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
	// 在当前上下文环境中创建一个新的Employee对象
	Employee *emp = [Employee MR_createEntityInContext:defaultContext];
	emp.name      = @"lxz";
	emp.brithday  = [NSDate date];
	emp.height    = @1.7;
	// 保存修改到当前上下文中
	[defaultContext MR_saveToPersistentStoreAndWait];

4. 查

 查询数据
	
	// 执行查找操作，并设置排序条件
	NSArray *empSorted = [Employee MR_findAllSortedBy:@"height" ascending:YES];

####自定义NSFetchRequest

下面示例代码中，Employee根据已有的employeeFilter谓词对象，创建了employeeRequest请求对象，并将请求对象做修改后，从MOC中获取请求结果，实现自定义查找条件。

	
	NSPredicate *employeeFilter = [NSPredicate predicateWithFormat:@"name LIKE %@", @"*lxz*"];
	NSFetchRequest *employeeRequest = [Employee MR_requestAllWithPredicate:employeeFilter];
	employeeRequest.fetchOffset = 10;
	employeeRequest.fetchLimit = 10;
	NSArray *employees = [Employee MR_executeFetchRequest:employeeRequest];

######参数设置

1. 可以通过修改MR_LOGGING_DISABLED预编译指令的值，控制log打印。

	- "#defne MR_LOGGING_DISABLED 1".

2.MagicalRecord在DEBUG模式下，对模型文件发生了更改，并且没有创建新的模型文件版本。MagicalRecord默认会将旧的持久化存储删除，创建新的持久化存储。

MagicalRecord的使用方法还有很多，这里只是将一些比较常用的拿出来讲讲，其他就不一一讲解了。在Github上有国人翻译的MagicalRecord官方文档，翻译的非常全面，而且是实时更新的。

这篇文章关于MagicalRecord的部分，也是参考文章来写的，我这里就犯了个懒……

##MagicalRecord中文文档

####CoreData优缺点总结

无论是什么东西，肯定不会是绝对完美的，CoreData也是如此。CoreData被设计出来后，对比其他本地持久化方案有自己独有的优势，也有比较严重的问题。

对于一个本地持久化方案的选取，还是要根据公司业务需求，来选择一个适合项目的方案，并没有哪个方案是万能的。

######优点

    可以设置关联关系，也就是之前讲过的关联属性，关联属性可以和当前对象一起被MOC操作。

    例如Company关联一个Person对象，对Company进行操作时，也可以通过点语法从Company中获取Person，Person的修改会随着Company一起被持久化。

    如果用SQLite实现起来是很麻烦的，但CoreData可以很容易的完成，这也是CoreData更加面向对象的一种体现。

    更加面向对象，将之前Model层的表示和持久化合二为一。把数据库的交互和对象的转换封装起来，使用时不需要接触到任何SQLite相关的代码，直接使用托管对象即可。

    开发效率比较快，可以很快的封装一个基于CoreData实现的Model层，而不需要太多的代码就可以实现。

    可以很好的防范SQL注入的问题。对于SQLite来说，如果是用FMDB并且用?占位符，也可以防范SQL注入的问题。

    可视化化效果好且结构清晰。将模型文件内部的结构，以及实体之间的对应关系等，以可视化的结构展现出来。

    对OC原生编程支持非常好，支持keyPath操作方式。例如设置NSPredicate查找条件时，可以使用keyPath的点语法设置属性。而其他持久化存储对于这点支持的不太好，需要编写很复杂的查找条件，看起来也不太好理解。

    毕竟是Apple自家推出的，所以对OC融合度比较高，可以很好的配合和使用OC对象。

    设置一对一或一对多的关系，设置关系后做存储和查询也非常方便，这是非常便于开发的。如果对于性能没有苛刻的要求，并且持久化对象之间关系比较复杂，比较推荐使用CoreData。

######缺点

    灵活性不如SQLite，CoreData是对SQLite的一个封装，上层不能直接对数据库进行操作。处理任何数据都要按照CoreData内部的实现逻辑执行，而不能自定义执行逻辑，对执行逻辑没有可控性。
	
	进行大量数据处理时比较吃力，性能明显低于直接操作SQLite数据库，而且内存占用非常大，需要手动做内存控制。

    当执行一个操作时涉及的数据比较多，需要将所有相关的托管对象加载到内存中，而且中间还涉及到对象的转换等操作。这样对性能和内存的消耗都是非常大的，和涉及到的数据量成正比。

因为CoreData底层是用SQLite实现的，可以在CoreData的基础上，直接编写SQL语句对数据库进行操作。但是并不推荐这样做，在一个项目中应该只有一种持久化的主体方案。而且如果这两种方式混用的话，对于后期维护是非常困难的。

    如果出现这样的需求，最好直接去用SQLite。

    CoreData入门门槛比较高，很难很好的掌握。

很多人都说CoreData不好用，这个原因很大一部分都是因为使用方式的问题。CoreData框架学习难度比较大，导致很多人都只是简单的使用CoreData，这些用法很多都是不合理的，很多的高级用法并没有用到。

####写在最后

到目前为止CoreData系列的六篇文章就都写完了，文章中可能存在一些没有注意的问题，还请各位提出。博客中包括CoreData在内的所有文章永久更新维护，会不断将新知识添加到对应的文章中，也会对落后的文章进行重写。

在第一篇文章中也说到，我接触CoreData时间也不是很长，这系列文章更像是我学习的一个总结。但是我确实是很认真的在写，文章内容也是检查了很多遍，防止错字或者语法问题。知识点总结的还是比较全面的，在后续我还会更深入的学习CoreData，也可能会推出后续文章。

>许多人对于CoreData有很多意见，认为CoreData有各种各样的问题，这并不是空穴来风。在我学习CoreData的过程中，也发现CoreData确实存在诸多问题，例如查询性能略差、灵活性等。所以在使用CoreData的时候，还是根据公司业务需求来权衡是否使用CoreData。



    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  