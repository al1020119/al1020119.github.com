---
layout: post
title: "iOS装逼篇——APO编程"
date: 2016-10-14 11:45:17 +0800
comments: true
categories: 

---


####实现原理

+ 用Objective-C强大的runtime.

我们知道当给一个对象发送一个方法的时候, 如果当前类和父类都没实现该方法的时候就会走转发流程

    动态方法解析 -> 快速消息转发 -> 标准消息转发



<!--more-->


##准备知识

     
###准备知识一：Method,SEL,IMP概念

######SEL

     先看一下SEL的概念，Objective-C在编译时，会依据每一个方法的名字、参数序列，生成一个唯一的整型标识(Int类型的地址)，这个标识就是SEL。
     
     SEL也是@selector的类型，用来表示OC运行时的方法的名字。来看一下OC中的定义
     

{% img /images/iosapo001.png Caption %}  

      本质上，SEL只是一个指向方法的指针（准确的说，只是一个根据方法名hash化了的KEY值，能唯一代表一个方法），它的存在只是为了加快方法的查询速度。这个查找过程我们将在下面说明。
      我们可以在运行时添加新的selector，也可以在运行时获取已存在的selector。

######IMP

      实际上是一个函数指针，指向方法实现的首地址，定义如下：
      

{% img /images/iosapo002.png Caption %}  

######关于IMP的几点说明：

使用当前CPU架构实现的标准的C调用约定
    
    第一个参数是指向self的指针（如果是实例方法，则是类实例的内存地址；如果是类方法，则是指向元类的指针）
    第二个参数是方法选择器(selector)，
    第三个参数开始是方法的实际参数列表。

通过取得IMP，我们可以跳过Runtime的消息传递机制，直接执行IMP指向的函数实现，这样省去了Runtime消息传递过程中所做的一系列查找操作，会比直接向对象发送消息高效一些，当然必须说明的是，这种方式只适用于极特殊的优化场景，如效率敏感的场景下大量循环的调用某方法。

######Method

      直接上定义：
      

{% img /images/iosapo003.png Caption %}  

      Method = SEL + IMP + method_types，相当于在SEL和IMP之间建立了一个映射

相关方法：

    // 给 cls 添加一个新方法  
    BOOL class_addMethod (  
       Class cls,  
       SEL name,  
       IMP imp,  
       const charchar *types  
    );  
      
    // 替换 cls 里的一个方法的实现  
    IMP class_replaceMethod (  
       Class cls,  
       SEL name,  
       IMP imp,  
       const charchar *types  
    );  
      
    // 返回 cls 的指定方法  
    Method class_getInstanceMethod (  
       Class cls,  
       SEL name  
    );  
      
    // 设置一个方法的实现  
    IMP method_setImplementation (  
       Method m,  
       IMP imp  
    );  
      
    // 返回 cls 里的 name 方法的实现  
    IMP class_getMethodImplementation (  
       Class cls,  
       SEL name  
    );  


###准备知识二：iOS方法调用流程

######方法调用的核心是objc_msgSend方法：
             objc_msgSend(receiver, selector, arg1,arg2,…)
具体的过程如下：

			先找到selector 对应的方法实现(IMP)，因为同一个方法可能在不同的类中有不同的实现，所以需要receiver的类来找到确切的IMP
            
            IMP class_getMethodImplementation(Class class, SEL selector)
如同其文档所说：
	
	The function pointer returned may be a function internal to the runtime instead of an actual method implementation. For example, if instances of the class do not respond to the selector, the function pointer returned will be part of the runtime's message forwarding machinery.

具体来说，当找不到IMP的时候，方法返回一个 _objc_msgForward 对象，用来标记需要转入消息转发流程，我们现在用的AOP框架也是利用了这个机制来人为的制造找不到IMP的假象来触发消息转发的流程
        

{% img /images/iosapo004.png Caption %}  
        
        如果实在对_objc_msgFroward的内部实现感兴趣，只能看看源码了，只不过都是汇编实现的....感兴趣的同学可以想想为什么是用汇编来实现
        这里有个源码的镜像https://github.com/opensource-apple ，如果翻墙费劲的话
根据查找结果

        找到了IMP，调用找到的IMP，传入参数
        没找到IMP，转入消息转发流程
    	将IMP的返回值作为自己的返回值


补充说明一下IMP的查找过程，消息传递的关键在于objc_class结构体中的以下几个东西：

    Class *isa
    Class *super_class
    objc_method_list **methodLists
    objc_cache *cache

当消息发送给一个对象时，objc_msgSend通过对象的isa获取到类的结构体，然后在cache和methodLists中查找，如果没找到就找其父类，以此类推知道找到NSObject类，如果还没找到，就走消息转发流程。

###准备知识三：iOS方法转发流程

      从上文中我们看到当obj无法查找到 IMP时，会返回一个特定的IMP _objc_msgForward , 然后会进入消息转发流程，具体流程如下：

######动态方法解析
        resolveInstanceMethod:解析实例方法 
        resolveClassMethod:解析类方法

通过class_addMethod的方式将缺少的selector动态创建出来，前提是有提前实现好的IMP（method_types一致）
        
        这种方案更多的是位@dynamic属性准备的
        
######备用接受者（AOP中有使用）
如果上一步没有处理，runtime会调用以下方法
            
            -(id)forwardingTargetForSelector:(SEL)aSelector
如果该方法返回非nil的对象，则使用该对象作为新的消息接收者，不能返回self，会出现无限循环

如果不知道该返回什么，应该使用[super forwardingTargetForSelector:aSelector]

这种方法属于单纯的转发，无法对消息的参数和返回值进行处理


######完整转发（AOP中有使用）
       
        - (void)forwardInvocation:(NSInvocation *)anInvocation

对象需要创建一个NSInvocation对象，把消息调用的全部细节封装进去，包括selector, target, arguments 等参数，还能够对返回结果进行处理
为了使用完整转发，需要重写以下方法
            
            -(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector，如果2中return nil,执行methodSignatureForSelector：
  
因为消息转发机制为了创建NSInvocation需要使用这个方法吗获取信息，重写它为了提供合适的方法签名




##AOP核心逻辑解析

        到了有意思的戏肉部分，打算用流程图的方式解析一下核心的两个流程：拦截器(intercepter)注册流程和拦截器(intercepter)执行流程。
   
   
####拦截器(intercepter)注册流程



{% img /images/iosapo005.png Caption %}  


说明：（图中m:代表Method，ClassA是AOP的目标类，X是AOP的目标方法，AOPAspect是AOP处理类-单例）

    1. 将原始的X的IMP拿出来，以特定的命名规则动态加入AOPAspect
    2. 将X的IMP替换为_objc_msgForward，用这种比较tricky的方式来触发消息转发流程
    3. 将ClassA中原有的forwardingTargetForSelector:的IMP以特定的命名规则存入AOPAspect
    4. 将ClassA的forwardingTargetForSelector：的IMP用AOPApect中的baseClassForwardingTargetForSelector替换，其中的具体逻辑见下面的代码

    后边的就是将拦截器的信息和block存入到AOPAspect中，细节就不讲了，有兴趣的同学可以到github上看看原始版



{% img /images/iosapo006.png Caption %}  


####拦截器(intercepter)执行流程




{% img /images/iosapo007.png Caption %}  



说明：（图中m:代表Method，ClassA是AOP的目标类，X是AOP的目标方法，AOPAspect是AOP处理类-单例,IMP是方法对应的实现）

开始调用，objc_msgSend开始查找SEL为X的IMP，查到结果为_objc_msgForward，触发ClassA的转发流程
   
	1. ClassA中转发流程调用forwardingTargetForSelector:，实际会调用替换上去的baseClassForwardingTargetForSelector:的IMP，这个IMP正常情况下会返回AOPAspect的单例作为target（代码见上文图）
	2. 接下来开始在AOPAspect的单例中执行转发流程，经过一系列的3.1-3.5的跳转查找，最终会触发转发流程的forwardingInvocation方法
	
	3. 在forwardingInvocation中触发一系列的interceptors的执行（包括原始的X的IMP），代码见下图
	4. 后边的interceptor的执行细节也略过了，有兴趣的同学可以到github上看看原始版



{% img /images/iCocosPublic.jpg Caption %}  

##AOP案例

这里举个例子,我们有个方法sumA:andB:, 用来返回ab之和的一个字串,我们在这个方法前和方法后都增加个一段代码

    在运行方法前我们把参数改成2和3, 当然这里是演示用,实际用的时候别改参数,不然其他同事真的要骂人了
    在运行方法后我们输出传入的参数和返回值

在CODE上查看代码片派生到我的代码片

    - (void)clickTestAop:(id)sender  
    {  
        AopTestM *test = [[AopTestM alloc] init];  
        NSLog(@"run1");  
        [test sumA:1 andB:2];  
          
        NSString *before = [XYAOP interceptClass:[AopTestM class] beforeExecutingSelector:@selector(sumA:andB:) usingBlock:^(NSInvocation *invocation) {  
            int a = 3;  
            int b = 4;  
              
            [invocation setArgument:&a atIndex:2];  
            [invocation setArgument:&b atIndex:3];  
              
            NSLog(@"berore fun. a = %d, b = %d", a , b);  
        }];  
          
        NSString *after =  [XYAOP interceptClass:[AopTestM class] afterExecutingSelector:@selector(sumA:andB:) usingBlock:^(NSInvocation *invocation) {  
            int a;  
            int b;  
            NSString *str;  
              
            [invocation getArgument:&a atIndex:2];  
            [invocation getArgument:&b atIndex:3];  
            [invocation getReturnValue:&str];  
              
            NSLog(@"after fun. a = %d, b = %d, sum = %@", a , b, str);  
        }];  
          
        NSLog(@"run2");  
        [test sumA:1 andB:2];  
          
        [XYAOP removeInterceptorWithIdentifier:before];  
        [XYAOP removeInterceptorWithIdentifier:after];  
          
        NSLog(@"run3");  
        [test sumA:1 andB:2];  
    }   
      
    - (NSString *)sumA:(int)a andB:(int)b  
    {  
        int value = a + b;  
        NSString *str = [NSString stringWithFormat:@"fun running. sum : %d", value];  
        NSLog(@"%@", str);  
          
        return str;  
    }  



我们执行这段代码的时候,大伙猜猜结果是啥.结果如下


    2014-10-28 22:52:47.215 JoinShow[3751:79389] run1  
    2014-10-28 22:52:52.744 JoinShow[3751:79389] fun running. sum : 3  
    2014-10-28 22:52:52.745 JoinShow[3751:79389] run2  
    2014-10-28 22:52:52.745 JoinShow[3751:79389] berore fun. a = 3, b = 4  
    2014-10-28 22:52:52.745 JoinShow[3751:79389] fun running. sum : 7  
    2014-10-28 22:52:52.745 JoinShow[3751:79389] after fun. a = 3, b = 4, sum = fun running. sum : 7  
    2014-10-28 22:52:52.746 JoinShow[3751:79389] run3  
    2014-10-28 22:52:52.746 JoinShow[3751:79389] fun running. sum : 3  
  
##AOP库  
    
一个简洁高效的用于使iOS支持AOP面向切面编程的库.它可以帮助你在不改变一个类或类实例的代码的前提下,有效更改类的行为.比iOS传统的 AOP方法,更加简单高效.支持在方法执行的前/后或替代原方法执行.曾经是 PSPDFKit 的一部分,PSPDFKit,在Dropbox和Evernote中都有应用,现在单独单独开源出来给大家使用.

####项目主页: Aspects

最新实例:[点击下载](https://github.com/steipete/Aspects/archive/master.zip)

> 注: AOP是一种完全不同于OOP的设计模式.更多信息,可以参考这里: AOP 百度百科

#####安装使用

CocoaPods 安装

	pod "Aspects"

手动安装

	把文件 Aspects.h/m 拖到工程中即可.

#####使用

Aspects 用于支持AOP(面向切面编程)模式,用于部分解决OOP(面向对象)模式无法解决的特定问题.具体指的是那些在多个方法有交叉,无法或很难被有效归类的操作,比如:

	不论何时用户通过客户端获取服务器端数据,权限检查总是必须的.
	不论何时用户和市场交互,总应该更具用户的操作提供相应地购买参考或相关商品.
	所有需要日志记录的操作.

#####接口概述

Aspects 给 NSObject 扩展了下面的方法:

	/// 为一个指定的类的某个方法执行前/替换/后,添加一段代码块.对这个类的所有对象都会起作用.
	///
	/// @param block  方法被添加钩子时,Aspectes会拷贝方法的签名信息.
	/// 第一个参数将会是 `id<AspectInfo>`,余下的参数是此被调用的方法的参数.
	/// 这些参数是可选的,并将被用于传递给block代码块对应位置的参数.
	/// 你甚至使用一个没有任何参数或只有一个`id<AspectInfo>`参数的block代码块.
	///
	/// @注意 不支持给静态方法添加钩子.
	/// @return 返回一个唯一值,用于取消此钩子.
	+ (id<AspectToken>)aspect_hookSelector:(SEL)selector
	                      withOptions:(AspectOptions)options
	                       usingBlock:(id)block
	                            error:(NSError **)error;
	
	/// 为一个指定的对象的某个方法执行前/替换/后,添加一段代码块.只作用于当前对象.
	 - (id<AspectToken>)aspect_hookSelector:(SEL)selector withOptions:(AspectOptions)options usingBlock:(id)block error:(NSError **)error; - (id<AspectToken>)aspect_hookSelector:(SEL)selector withOptions:(AspectOptions)options usingBlock:(id)block error:(NSError **)error; 
	/// 撤销一个Aspect 钩子.
	/// @return YES 撤销成功, 否则返回 NO. 
	id<AspectToken> aspect = ...; 
	[aspect remove];

所有的调用,都会是线程安全的.Aspects 使用了Objective-C 的消息转发机会,会有一定的性能消耗.所有对于过于频繁的调用,不建议使用 Aspects.Aspects更适用于视图/控制器相关的等每秒调用不超过1000次的代码.

可以在调试应用时,使用Aspects动态添加日志记录功能.

	[UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
	    NSLog(@"控制器 %@ 将要显示: %tu", aspectInfo.instance, animated);
	} error:NULL];

使用它,分析功能的设置会很简单:

	https://github.com/orta/ARAnalytics

你可以在你的测试用例中用它来检查某个方法是否被真正调用(当涉及到继承或类目扩展时,很容易发生某个父类/子类方法未按预期调用的情况):

	- (void)testExample {
	    TestClass *testClass = [TestClass new];
	    TestClass *testClass2 = [TestClass new];
	
	    __block BOOL testCallCalled = NO;
	    [testClass aspect_hookSelector:@selector(testCall) withOptions:AspectPositionAfter usingBlock:^{
	        testCallCalled = YES;
	    } error:NULL];
	
	    [testClass2 testCallAndExecuteBlock:^{
	        [testClass testCall];
	    } error:NULL];
	    XCTAssertTrue(testCallCalled, @"调用testCallAndExecuteBlock 必须调用 testCall");
	}

它对调试应用真的会提供很大的作用.这里我想要知道究竟何时轻击手势的状态发生变化(如果是某个你自定义的手势的子类,你可以重写setState:方法来达到类似的效果;但这里的真正目的是,捕捉所有的各类控件的轻击手势,以准确分析原因):

	[_singleTapGesture aspect_hookSelector:@selector(setState:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
	    NSLog(@"%@: %@", aspectInfo.instance, aspectInfo.arguments);
	} error:NULL];

下面是一个你监测一个模态显示的控制器何时消失的示例.通常,你也可以写一个子类,来实现相似的效果,但使用 Aspects 可以有效减小你的代码量:

	@implementation UIViewController (DismissActionHook)
	
	// Will add a dismiss action once the controller gets dismissed.
	- (void)pspdf_addWillDismissAction:(void (^)(void))action {
	    PSPDFAssert(action != NULL);
	
	    [self aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
	        if ([aspectInfo.instance isBeingDismissed]) {
	            action();
	        }
	    } error:NULL];
	}
	
	@end

#####对调试的好处

Aspectes 会自动标记自己,所有很容易在调用栈中查看某个方法是否已经调用:

在返回值不为void的方法上使用 Aspects

你可以使用 NSInvocation 对象类自定义返回值:

    [PSPDFDrawView aspect_hookSelector:@selector(shouldProcessTouches:withEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, NSSet *touches, UIEvent *event) {
        // 调用方法原来的实现.
        BOOL processTouches;
        NSInvocation *invocation = info.originalInvocation;
        [invocation invoke];
        [invocation getReturnValue:&processTouches];

        if (processTouches) {
            processTouches = pspdf_stylusShouldProcessTouches(touches, event);
            [invocation setReturnValue:&processTouches];
        }
    } error:NULL];

#####兼容性与限制

当应用于某个类时(使用类方法添加钩子),不能同时hook父类和子类的同一个方法;否则会引起循环调用问题.但是,当应用于某个类的示例时(使用实例方法添加钩子),不受此限制.
使用KVO时,最好在 aspect_hookSelector: 调用之后添加观察者;否则可能会引起崩溃.
    
    
===


    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  