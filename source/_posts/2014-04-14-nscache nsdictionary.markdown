---

layout: post
title: "NSCache&NSDcitionary你了解多少？"
date: 2014-04-14 13:53:19 +0800
comments: true
categories: 性能问题 

--- 

NSCache


NSCache是系统提供的一种类似于集合（NSMutableDictionary）的缓存，它与集合的不同如下：

1. NSCache具有自动删除的功能，以减少系统占用的内存；

2. NSCache是线程安全的，不需要加线程锁；

3. 键对象不会像 NSMutableDictionary 中那样被复制。（键不需要实现 NSCopying 协议）。



<!--more-->




#####NSCache的属性以及方法介绍：


	@property NSUInteger totalCostLimit;

设置缓存占用的内存大小，并不是一个严格的限制，当总数超过了totalCostLimit设定的值，系统会清除一部分缓存，直至总消耗低于totalCostLimit的值。

	@property NSUInteger countLimit;

设置缓存对象的大小，这也不是一个严格的限制。

	- (id)objectForKey:(id)key;

获取缓存对象，基于key-value对

	- (void)setObject:(id)obj forKey:(id)key; // 0 cost

存储缓存对象，考虑缓存的限制属性；

	- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)g;

存储缓存对象，cost是提前知道该缓存对象占用的字节数，也会考虑缓存的限制属性，建议直接使用  - (void)setObject:(id)obj forKey:(id)key;

#####NSCacheDelegate代理


代理属性声明如下：

	@property (assign) id<NSCacheDelegate>delegate;

实现了NSCacheDelegate代理的对象，在缓存对象即将被清理的时候，系统回调代理方法如下：

	- (void)cache:(NSCache *)cache willEvictObject:(id)obj;

第一个参数是当前缓存（NSCache），不要修改该对象；

第二个参数是当前将要被清理的对象，如果需要存储该对象，可以在此操作（存入Sqlite or CoreData）;

该代理方法的调用会在缓存对象即将被清理的时候调用，如下场景会调用：

1. - (void)removeObjectForKey:(id)key; 手动删除对象；

2. 缓存对象超过了NSCache的属性限制；（countLimit 和 totalCostLimit ）

3. App进入后台会调用；

4. 系统发出内存警告；


#####NSDiscardableContent协议


NSDiscardableContent是一个协议，实现这个协议的目的是为了让我们的对象在不被使用时，可以将其丢弃，以让程序占用更少的内存。

一个NSDiscardableContent对象的生命周期依赖于一个“counter”变量。一个NSDiscardableContent对象实际是一个可清理内存块，这个内存记录了对象当前是否被其它对象使用。如果这块内存正在被读取，或者仍然被需要，则它的counter变量是大于或等于1的；当它不再被使用时，就可以丢弃，此时counter变量将等于0。当counter变量等于0时，如果当前时间点内存比较紧张的话，内存块就可能被丢弃。这点类似于MRC&ARC，对象内存回收机制。

	- (void)discardContentIfPossible

当counter等于0的时候，为了丢弃这些对象，会调用这个方法。

默认情况下，NSDiscardableContent对象的counter变量初始值为1，以确保对象不会被内存管理系统立即释放。

	- (BOOL)beginContentAccess    (counter++)

调用该方法，对象的counter会加1；

与beginContentAccess相对应的是endContentAccess。如果可丢弃内存不再被访问时调用。其声明如下：

	- (void)endContentAccess  （counter--）

该方法会减少对象的counter变量，通常是让对象的counter值变回为0，这样在对象的内容不再被需要时，就要以将其丢弃。

NSCache类提供了一个属性，来标识缓存是否自动舍弃那些内存已经被丢弃的对象(默认该属性为YES)，其声明如下：

	@property BOOL evictsObjectsWithDiscardedContent

如果设置为YES，则在对象的内存被丢弃时舍弃对象。

个人建议：如果需要使用缓存，直接用系统的NSCache就OK了，不要做死。


####区别：
NSCache
 
* (1)可以存储(当然是使用内存)
* (2)保持强应用, 无视垃圾回收. =>这一点同 NSMutableDictionary
* (3)有固定客户.
***
	+---------------------------+------------------------------+
	| NSCache | NSMutableDictionary |
	+---------------------------+------------------------------+
	| NSDiscardableContent | NSObject |
	+---------------------------+------------------------------+

下面是 UIImageView+AFNetworking的使用:

	@interface AFImageCache :NSCache
	- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
	- (void)cacheImage:(UIImage *)image
	forRequest:(NSURLRequest *)request;
	@end

NSURLCache 

iOS5 之前是不能通过NSURLCache使用硬盘缓存的,所以有SDURLCache这样的library来实现硬盘缓存. iOS5可以使用NSURLCache的硬盘缓存, 只要符合http-cache-control-header即可.
这里有详细的说明:here 
这也就是说不用做任何操作, 系统将自动完成满足缓存条件的request.

映射关系:

	+---------------------------+---------------------------------+
	| NSURLRequest ----|----> NSCachedURLResponse |
	+---------------------------+---------------------------------+

通过这样的映射关系实现缓存. 这里存的是NSCachedURLResponse. 也就是说这里的NSURLCache也是一个类似于NSCache的容器.
只不过data是NSCachedURLResponse对象. 并不是类似于image这样的data.

这篇文章可以的: NSURLCache使用心得here
我测试了一下UIImage->NSData->URL,NSURLConnection, UIWebView不同时候调用 

	- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request;
	-(void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request;
的情况:

	+-------------+---------------------+----------------------+------------------+
	| | UIImage->URL | NSURLConnection | UIWebView |
	+---------+---+---------------------+----------------------+------------------+
	| | c | X | first called | first called | 
	|1’s time |---+---------------------+----------------------+------------------+
	| | s | first called | second called | second called | 
	+---------+---+---------------------+----------------------+------------------+
	| | c | X | first called | first called | 
	|2’s time +---+---------------------+----------------------+------------------+
	| | s | first called | X | X | 
	+---------+---+---------------------+----------------------+------------------+


> 注意

	* c 表示 cachedResponseForRequest
	* s 表示 storeCachedResponse
	* X 表示不被调用
	
	
结果显示: UIImage->URL 是同步的请求. 因为cachedResponseForRequest不能发起同步请求来请求网络.