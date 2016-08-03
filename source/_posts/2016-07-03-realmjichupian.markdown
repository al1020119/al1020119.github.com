---

layout: post
title: "Realm基础篇"
date: 2016-07-03 02:59:42 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---



介绍

realm是一个跨平台移动数据库引擎，支持iOS、OS X（Objective-C和Swift）以及Android。

2014年7月发布。由YCombinator孵化的创业团队历时几年打造，是第一个专门针对移动平台设计的数据库。目标是取代SQLite。

为了彻底解决性能问题，核心数据引擎C++打造，并不是建立在SQLite之上的ORM。如果对数据引擎实现想深入了解可以查看：Realm 核心数据库引擎探秘。因此得到的收益就是比普通的ORM要快很多，甚至比单独无封装的SQLite还要快。

因为是ORM，本身在设计时也针对移动设备（iOS、Android），所以非常简单易用，学习成本很低。



<!--more-->



碾压级性能

数据引自：introducing-realm

每秒能在20万条数据中进行查询后count的次数。realm每秒可以进行30.9次查询后count。

{% img /images/benchmarks.001b.png Caption %} 

在20万条中进行一次遍历查询，数据和前面的count相似：realm一秒可以遍历20万条数据31次，而coredata只能进行两次查询。

{% img /images/benchmarks.002b.png Caption %} 

这是在一次事务每秒插入数据的对比，realm每秒可以插入9.4万条记录，在这个比较里纯SQLite的性能最好，每秒可以插入17.8万条记录。然而封装了SQLite的FMDB的成绩大概是realm的一半。

{% img /images/benchmarks.003b.png Caption %} 

简单易用

实例代码语言是Objective?C。

Realm对象和其他对象没有太大区别，只是需要继承RLMObject

	
	@interface Dog : RLMObject
	@property NSString *name;
	@property NSInteger age;
	@end
	Dog *mydog = [[Dog alloc] init];

存储起来也非常简单，获取数据库实例，在一个事务中进行写入。

	
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm transactionWithBlock:^{
	    [realm addObject:mydog];
	}];

方便的查询，可以在一个查询结果中再进行查询。查询的条件有着丰富的支持。

	
	RLMResults *r = [Dog objectsWhere:@"age > 8"];
	// Queries are chainable
	r = [r objectsWhere:@"name contains 'Rex' AND  name BEGINSWITH '大'"];

zero-copy和懒加载

在通常的数据库中，数据大多数时间都静静地呆在硬盘当中。当你访问 NSManagedObject 对象中的某个属性的时候，Core Data 会将这个请求转换为一组 SQL 语句，如果还未连接数据库的话则创建一个数据库连接，然后将这个 SQL 语句发送给硬盘，执行检索，从匹配检索的结果中读取所有的数据，然后将它们放到内存当中（也就是内存分配）。然而，这时候你需要对其格式进行反序列化(deserialize)，因为硬盘上存储的格式不能直接在内存中使用，这意味着你需要调整位，以便 CPU 能够对其进行处理。

然而Realm跳过了整个拷贝数据到内存的过程，称之为zero-copy。做到这点是因为文件始终是内存映射的，无论文件是或否在内存当中，你都能够访问文件的任何内容。关于核心文件格式的重要一点就是，确保硬盘上的文件格式都是内存可读的，这样就无需执行任何反序列化操作了。

这样就带来了一个问题，难道数据全加载到内存里了？所以这里懒加载应运而生，比如在查询到一组数据后，只有当你真正访问对象的时候才真正加载进来。

VS SQLite

SQLite第一个版本发布于2000年，至今已16年。以当今的角度来看，它的编程抽象程度非常低。业务上我们其实只想把这些对象存进去，可以查询出来。

即便已经是封装过的FMDB，要写这样的代码心里也依旧难受:

	
	FMDatabase *db = [FMDatabase databaseWithPath:@"/tmp/tmp.db"];
	if (![db open]) {
	[db release];
	return;
	}
	NSString *sql = @"create table bulktest1 (id integer primary key autoincrement, x text);"
	"create table bulktest2 (id integer primary key autoincrement, y text);"
	"create table bulktest3 (id integer primary key autoincrement, z text);"
	"insert into bulktest1 (x) values ('XXX');"
	"insert into bulktest2 (y) values ('YYY');"
	"insert into bulktest3 (z) values ('ZZZ');";
	success = [db executeStatements:sql];
	sql = @"select count(*) as count from bulktest1;"
	"select count(*) as count from bulktest2;"
	"select count(*) as count from bulktest3;";
	success = [self.db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
	NSInteger count = [dictionary[@"count"] integerValue];
	XCTAssertEqual(count, 1, @"expected one record for dictionary %@", dictionary);
	return 0;
	}];
	[db close];

VS CoreData

详细的比较推荐看这篇：CoreData VS Realm。

下面给出一个查询的比较：

	
	// Core Data
	let fetchRequest = NSFetchRequest(entityName: "Specimen")
	let predicate = NSPredicate(format: "name BEGINSWITH [c]%@", searchString)
	fetchRequest.predicate = predicate
	let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
	fetchRequest.sortDescriptors = [sortDescriptor]
	let error = NSError()
	let results = managedObjectContext?.executeFetchRequest(fetchRequest, error:&error)

Realm则简单的多：

	
	// Realm
	let predicate = NSPredicate(format: "name BEGINSWITH [c]%@", searchString);
	let specimens = Specimen.objectsWithPredicate(predicate).arraySortedByProperty("name", ascending: true)

###总结一下Realm对CoreData的优势：

    不需要架构Context那种烦人的东西

    CoreData 是一个博大精深的技术，不要妄想几天之内可以用的很溜。


---

    支持 NSPredicate

从 CoreData 转过来并没有太多的不适应。

    CoreData多个持久化文件很麻烦，Realm轻松支持这个功能

#####劣势：

是会增加应用大概1MB的体积。CoreData原生支持，不会增加App体积。

虽然看上去很厉害，但是这么新靠谱吗

Realm大部分源码公开在github上：realm。项目在新建不到两年里，已经得到开源社区大量关注：

{% img /images/benchmarks.004b.png Caption %} 

官方也承诺会持续解决用户反馈的各种问题。也可以直接在他们twitter上去@他们。

就算靠谱，有别人在用吗

推荐阅读这篇博客，作者介绍了他痛下决心抛弃CoreData后，如何安全迁移至Realm：《高速公路换轮胎——为遗留系统替换数据库》（文／凉粉小刀，简书作者）。

在多年以前，人们做了个决策，用CoreData做本地存储，替换掉NSUserDefaults。这之间的历史已经远不可考，但自从我加入项目以来，整个团队已经被它高昂的学习曲线、复杂的数据Migration流程以及过时陈旧的设计折磨的苦不堪言。于是我们决心把CoreData换掉。

再看下SO的情况：

{% img /images/benchmarks.005b.png Caption %} 

已经有大概两万条相关结果，你不是一个人！

需要知道的一些问题

    其实我自己觉得这些是可以接受的问题。技术很多时候就是权衡，为了达到一些目的，总是要牺牲掉一些东西。

所有的存储对象需要继承RealmObject

比如我现在的项目的数据从网络请求回来都会继承自己写的一个方便解析的基类，在这里就需要做出一些适应。

但是该问题在swift中是不存在的。因为swift是天生的面向协议编程范式。

    不能自定义getter、setter

realm会自动生成getter、setter，如果自定义getter、setter存储就会有影响。如果要规避这个问题，可以通过设置这个对象的忽略属性。

比如有个属性id，需要自定义setter。可以在对象属性里把id设置为忽略属性，这样realm就不会为它自动生成getter、setter，但是也不会把id存入数据库。接着自定义一个用于存储的属性比如realm_id。在id的setter中可以把把值也赋给realm_id。

这个问题在swift中也是不存在的，因为swfit中使用的是willset、didset这种通知机制。

    查询的结果不是数组

为了能够支持查询结果的链式查询，realm自定义了一个集合类型。可以枚举，但是不是熟悉的数组了。又因为realm的懒加载机制，所以不建议在数据层把这个枚举转成数组类型。这样的缺点就是上层知道了数据的存储逻辑。严格的说这里不应该让上层知道。但是这样设计也许是为了方便上层进行再次检索，realm有着优越的查询性能。