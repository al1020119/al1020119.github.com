---
layout: post
title: "Block实战"
date: 2015-12-06 17:42:57 +0800
comments: true
categories: 项目实战
---

 
说到block，相信大部分iOS开发者都会想到retain cycle或是__block修饰的变量。但是本文将忽略这些老生常谈的讨论，而是将重点放在美团iOS在实践中对block的应用，希望能对同行有所助益。本文假设读者对block有一定的了解。

从闭包说起
在Lisp这样的语言中，有一个概念叫做闭包（closure1），指的是一个函数以及它所处的词法作用域（lexical scope2）构成的整体。为了理解闭包，我们首先来看看什么是词法作用域。

所谓词法作用域，顾名思义，是指一个符号引用的是其词法环境中的变量，而无关程序在运行时的状态。这么说可能有点抽象，让我来看一段Common Lisp3代码：

	(defvar printer (let ((x 42))
	          (lambda () (format t "~a" x))))
这里我们定义了一个变量printer，它的值是一个函数，这个函数会打印词法作用域中的变量x（其值为42）。
现在我们来调用这个函数：

	CL-USER> (funcall printer)
42
可以看到，我们调用了printer中存放的函数之后，打印出来的数字是42，跟我们的预期相符。

接下来再让我们看一个可能会出乎意料的结果：

	CL-USER> (let ((x 1))
	       (funcall printer))
42
我们在调用之前把x设置为了1，但是打印的结果仍然是42。

为什么？因为printer中存放的函数在被调用时所引用的变量位于其词法作用域中， 即该函数被定义时所处的词法环境中，所以程序在运行时设置的变量x对函数不起作用。

前面我们讲过，所谓闭包，就是函数及其词法作用域的合称，具体到上例，那么匿名函数和x就构成了一个闭包，它会为函数保存一种状态，有点类似于全局变量，不过除了那个匿名函数，其他函数无法访问到x。

说了这么多，似乎跟block毫无关系？事实上，block为C带来了闭包。

Block
Apple从OS X 10.6和iOS 4以后开始支持block，让我们用C把上面的例子重写一下：

	#include <stdio.h>
	
	int main ()
	{
	    int x = 42;
	    void (^block)() = ^() {
	        printf("%d\n", x);
	    };
	    block();
	    x = 1;
	    block();
	
	    return 0;
	}
编译运行后得到的输出同样是两个42。

到了这里，相信读者对闭包已经有一个直观的认识了，但是它有什么用？有什么好处？
设想如下场景，我们要请求一个URL，并以block的形式传入回调函数，并在回调函数中用到刚才这个URL：

	NSURL *someURL = …;
	[SomeClass getURL:someURL finished:^(id responseObject) {
	    // process responseObject with someURL
	}];
这里网络请求是异步的，所以当block中代码执行时，getURL:finished:方法调用所在的栈很可能已经不存在了，但是因为回调block和someURL构成了closure，所以即使栈不存在，block仍然可以引用到someURL。

可能你会说，“我在block中增加一个NSURL类型的参数，把someURL传回来不也可以实现同样的目的吗？”不妨设想如果我们在block中要引用的对象有10个之多，用参数列表传递明显不再现实，用容器类或者专门定义一个类来传递虽然可以，但是前者没有编译器为我们检查错误，后者则相当繁琐。而利用闭包，可以轻易达到灵活性和简洁性的平衡。事实上，美团客户端就大量利用了闭包，在UI层发出请求，在回调中更新某些UI组件。

函数式编程4
在Lisp中，函数是一等公民，可以随时创建、作为参数传递、作为返回值返回，Objective C在没有block之前，没有类似的机制，有了block，Objective C也就具备了函数式编程的能力，block是对象，有自己的ISA指针，可以随时创建，作为参数传递，作为返回值返回。

先来看看block的经典用法：

	[UIView animateWithDuration:0.25 animations:^{
	            self.view.alpha = 1.0f;
	        }];
UIView的animateWithDuration:animations:方法的第二个参数是一个block，它把跟动画相关的操作封装起来传递进去，以实现动画效果。

现在让我们发掘一下类似的用法：

	[SAKBaseModel comboRequest:^() {
	 [dealModel fetchDealByID:123456
	               withFields:nil
	               completion:^(MTDeal *deal, NSError *error) {
	                   ...
	               }];
	 [orderModel fetchOrderByID:654321
	             withDealFields:nil
	                 completion:^(MTOrder *order, NSError *error) {
	                ...
	             }];
	}];
这里我们为SAKBaseModel设计了一个类似于UIView的接口叫comboRequest，它会接受一个block作为参数，在这个block中发出的请求都会作为combo请求的一部分。如果dealModel或者orderModel的任何一个请求不是出现在block中，那么它就是一个普通的请求。这样做的好处是dealModel和orderModel的接口不需要关心自己是不是属于一个combo请求，调用者则可以灵活地调整代码。

那么怎么实现这样的接口呢？还是从UIView上获取灵感。我们知道UIView有个方法setAnimationsEnabled:，实际上SAKBaseModel也可以有这么一个方法：setComboRequestEnabled:，而在comboRequest方法的实现中，在调用传进来的block之前先setComboRequestEnabled:YES，调用完后再恢复为原状态。相应的，在实际的model接口中，检查comboRequest是否为YES，如果是，则把自己作为一个combo请求的一部分，否则正常发出请求即可。

Think Big
Lisp最强大的特性之一是condition系统，它可以分离异常的检测、异常的解决和异常解决方式的决策，看一段示例代码：

	(define-condition network-timeout-error (error)
	    ((url :initarg :url :accessor url)))
	
	(defun try-again (condition)
	    (let ((restart (find-restart ‘try-again)))
	      (when restart (invoke-restart restart))))
	
	(defun deal-requester (deal-id)
	    (handler-bind ((network-timeout-error #’try-again))
	      (request-from-url (format nil “http://api.mobile.meituan.com/deal/~a” deal-id)
	        (lambda (deal error)
	        (if error
	            (format t “error: ~a”, error)
	            (process-deal))))))
	(defun request-from-url (url finished)
	    (let ((callback (lambda (response error)
	              (if (network-timeout-error-p error)
	                (error ‘network-timeout-error :url url)
	                (funcall finished (parse-deal response) error)))))
	      (restart-bind
	        ((try-again (lambda () (http-request url callback))))
	        (http-request url callback))))
可以看到，condition系统对于代码的分层提供了良好的支持，请求超时的错误在底层代码被检测到，在发出请求前注册一个restart，而在业务层去决定要不要调用restart。

一直以来，C语言要实现优雅的异常处理就是一件不简单的事情，而Objective-C虽然加入了try-catch支持，但是苹果并不鼓励使用，那么能否实现类似于condition系统这样的异常处理机制呢？

答案是能。让我们来看看接口设计：

	typedef void (^RESTART)(id userInfo);
	typedef void (^HANDLER)(id condition);
	
	void restart_bind(void (^body)(), NSString *restartName, RESTART restart, ...) NS_REQUIRES_NIL_TERMINATION;
	
	void handler_bind(void (^body)(), Class class, HANDLER handler, ...) NS_REQUIRES_NIL_TERMINATION;
	
	void notify(id condition);
	
	RESTART find_restart(NSString *restartName);
如下图所示，handler_bind首先在栈中注册好handler，而restart_bind则在handler有效的环境中注册restart，当有异常发生时，notify函数会在当前环境中寻找handler，找到后，控制会转移到上层的handler代码中，这时handler可以用find_restart在栈中搜索restart，找到之后可以调用，从而实现异常的恢复，做完这一切，控制回到notify发生的点继续向下执行。



完整的代码敬请期待美团iOS的开源项目。

有了SAKCondition，我们可以实现任意底层代码的逻辑穿透到上层代码，比如网络层和UI层，使得上层代码可以在不了解下层代码实现细节的情况下调用恢复机制。事实上，美团的iPhone客户端就是利用SAKCondition实现了美团账户的安全解锁功能。

总结
block给Objective C带来了无穷的可能性。本文只讨论了美团iOS在实践中的一些用法，更多想法还在等待挖掘。