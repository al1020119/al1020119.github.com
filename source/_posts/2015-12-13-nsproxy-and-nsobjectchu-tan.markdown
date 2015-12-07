---
layout: post
title: "NSProxy&amp;NSObject初探"
date: 2015-12-13 13:20:37 +0800
comments: true
categories: 高级开发
---

NSObject类属于根类。根类在层级结构中处于最高级，也就是说除此以外没有更高层级。而且Objective-c中还有其他根类，不像Java里只有一个java.lang.Object根类，其他所有的类都直接或间接的继承于它。因此，



Java代码可以依据任何对象来实现它的基本方法。Cocoa有多个根类，除了NSObject还有NSProxy等其他等级的根类。这只是部分原因，NSObject协议定义了一套所有的根类都可以实现的基础方法，这样在编码时就容易找到了。
 
 
NSObject类遵循NSObject协议，这就是说，NSObject类实现了下面这些基础方法：
 
	@interface NSObject  
 
NSProxy同样遵循NSObject协议：
 
	@interface NSProxy  	
	
<!--more-->



NSObject协议包含了hash，isEqual:，description等方法。事实上，NSProxy遵循NSObject协议意味着你可以依靠实现NSProxy来实现NSObject方法。

###NSObjetc：
NSObject协议组对所有的Object－C下的objects都生效。
如果objects遵从该协议，就会被看作是first－class objects（一级类）。
另外，遵从该协议的objects的retain，release，autorelease等方法也服从objects的管理和在Foundation中定义的释放方法。一些容器中的对象也可以管理这些objects，比如
说NSArray 和NSDictionary定义的对象。
Cocoa的根类也遵循该协议，所以所有继承NSObjects的objects都有遵循该协议的特性。

###NSProXY：
NSProxy 是一个虚基类，它为一些表现的像是其它对象替身或者并不存在的对象定义一套API。一般的，发送给代理的消息被转发给一个真实的对象或者代理本身load(或者将本身转换成)一个真实的对象。NSProxy的基类可以被用来透明的转发消息或者耗费巨大的对象的lazy 初始化。

NSProxy实现了包括NSObject协议在内基类所需的基础方法，但是作为一个虚拟的基类并没有提供初始化的方法。它接收到任何自己没有定义的方法他都会产生一个异常，所以一个实际的子类必须提供一个初始化方法或者创建方法，并且重载forwardInvocation:方法和methodSignatureForSelector:方法来处理自己没有实现的消息。一个子类的forwardInvocation:实现应该采取所有措施来处理invocation,比如转发网络消息，或者加载一个真实的对象，并把invocation转发给他。methodSignatureForSelector:需要为给定消息提供参数类型信息，子类的实现应该有能力决定他应该转发消息的参数类型，并构造相对应的NSMethodSignature对象。详细信息可以查看NSDistantObject, NSInvocation, and NSMethodSignature的类型说明。


####简单使用

######NSProxy
	
	// MyProxy.h
	#import<Foundation/Foundation.h>
	
	@interface MyProxy :NSProxy {
	    NSObject *object;
	}
	
	- (id)transformToObject:(NSObject *)anObject;
	
	@end
	
	// MyProxy.m
	#import"MyProxy.h"
	
	@implementation MyProxy
	
	- (void)dealloc
	{
	    [objectrelease];
	    object = nil;
	    [superdealloc];
	}
	
	- (void)fun
	{
	   // Do someting virtual
	    //先做一些代理工作，然后创建一个后台线程，在后台线程中再调用真正的[object fun];
	}
	
	// Stupid transform implementation just by assigning a passed in object as transformation target. You can write your factory here and use passed in object as id for object that need ot be created.
	- (id)transformToObject:(NSObject *)anObject 
	{
	    if(object != anObject) {
	        [objectrelease];
	    }
	    object = [anObject retain];
	    return object;
	}
	
	- (void)forwardInvocation:(NSInvocation *)invocation 
	{
	    if (object != nil) {
	        [invocation setTarget:object];    
	        
	        [invocation invoke];
	    }
	}
	
	- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel 
	{
	   NSMethodSignature *result;
	    if (object != nil) {
	        result = [objectmethodSignatureForSelector:sel];
	    } else {
	       // Will throw an exception as default implementation
	        result = [supermethodSignatureForSelector:sel];
	    }
	    return result;
	}
	
	@end


***

######NSObject

	// RealSubject.h
	#import<Foundation/Foundation.h>
	@implementation RealSubject : NSObject
	
	- (void)fun;
	
	@end
	
	// RealSubject.m
	#import"RealSubject.h"
	
	@implementation RealSubject
	
	- (void)fun
	{
	    //这个方法需要代理进行惰性调用
	   // Do something real
	}
	
	- (void)otherFun
	{
	    //这个方法不需要代理做任何处理，可直接被调用
	   // Do something real
	}
	
	@end
	
	// main.m
	int main(int argc,char *argv[]) 
	{
	   NSAutoreleasePool * pool = [[NSAutoreleasePoolalloc] init];
	
	    MyProxy *myProxy = [MyProxy alloc];
	    RealSubject *realSub = [[RealSubject alloc] init];
	    [myProxytransformToObject:realSub];
	    [myProxyfun]; // 直接调用myProxy的fun，执行代理工作
	    [myProxyotherFun]; // 依次调用myProxy的methodSignatureForSelector和forwardInvocation转发给realSub，realSub调用otherFun
	
	    [realSubject release];
	    [myProxyrelease];
	
	    [pool release];
	    return 0;
	}
	
	
> 注意，调用MyProxy中未定义的方法otherFun会出现'MyProxy' may not respond to 'fun'的警告，可通过使用私有范畴或通过performSelector:withObject:来避免，如果有更好的方法，请告知。
