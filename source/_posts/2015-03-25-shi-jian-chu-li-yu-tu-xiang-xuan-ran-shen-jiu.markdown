---
layout: post
title: "事件处理与图像渲染深究"
date: 2015-03-25 09:47:11 +0800
comments: true
categories: Performance
---


###iOS 事件处理机制与图像渲染过程

* iOS RunLoop都干了什么
* iOS 为什么必须在主线程中操作UI
* 事件响应
* CALayer
* CADisplayLink 和 NSTimer
* iOS 渲染过程
* 渲染时机
* CPU 和 GPU渲染
* Core Animation
* Facebook Pop介绍
* AsyncDisplay介绍
* 参考文章



<!--more-->




#####iOS RunLoop都干了什么

RunLoop是一个接收处理异步消息事件的循环，一个循环中：等待事件发生，然后将这个事件送到能处理它的地方。
如图1-1所示，描述了一个触摸事件从操作系统层传送到应用内的main runloop中的简单过程。

 
{% img /images/tupianxuanran001.jpg Caption %}  


简单的说，RunLoop是事件驱动的一个大循环，如下代码所示

	int main(int argc, char * argv[]) {
	     //程序一直运行状态
	     while (AppIsRunning) {
	          //睡眠状态，等待唤醒事件
	          id whoWakesMe = SleepForWakingU  p();
	          //得到唤醒事件
	          id event = GetEvent(whoWakesMe);
	          //开始处理事件
	          HandleEvent(event);
	     }
	     return 0;
	}
RunLoop主要处理以下6类事件：

	static void __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__();
	static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__();
	static void __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__();
	static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__();
	static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__();
	static void __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__();


* Observer事件，runloop中状态变化时进行通知。（微信卡顿监控就是利用这个事件通知来记录下最近一次main runloop活动时间，在另一个check线程中用定时器检测当前时间距离最后一次活动时间过久来判断在主线程中的处理逻辑耗时和卡主线程）。这里还需要特别注意，CAAnimation是由RunloopObserver触发回调来重绘，接下来会讲到。


* Block事件，非延迟的NSObject PerformSelector立即调用，dispatch_after立即调用，block回调。


* Main_Dispatch_Queue事件：GCD中dispatch到main queue的block会被dispatch到main loop执行。


* Timer事件：延迟的NSObject PerformSelector，延迟的dispatch_after，timer事件。


* Source0事件：处理如UIEvent，CFSocket这类事件。需要手动触发。触摸事件其实是
* Source1接收系统事件后在回调 __IOHIDEventSystemClientQueueCallback() 内触发的 Source0，Source0 再触发的 _UIApplicationHandleEventQueue()。source0一定是要唤醒runloop及时响应并执行的，如果runloop此时在休眠等待系统的 mach_msg事件，那么就会通过source1来唤醒runloop执行。

> Source1事件：处理系统内核的mach_msg事件。（推测CADisplayLink也是这里触发）。

RunLoop执行顺序的伪代码

	SetupThisRunLoopRunTimeoutTimer(); // by GCD timer
	//通知即将进入runloop__CFRUNLLOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(KCFRunLoopEntry);
	do {
	     __CFRunLoopDoObservers(kCFRunLoopBeforeTimers);
	     __CFRunLoopDoObservers(kCFRunLoopBeforeSources);
	
	     __CFRunLoopDoBlocks();  //一个循环中会调用两次，确保非延迟的NSObject PerformSelector调用和非延迟的dispatch_after调用在当前runloop执行。还有回调block
	     __CFRunLoopDoSource0(); //例如UIKit处理的UIEvent事件
	
	     CheckIfExistMessagesInMainDispatchQueue(); //GCD dispatch main queue
	
	     __CFRunLoopDoObservers(kCFRunLoopBeforeWaiting); //即将进入休眠，会重绘一次界面
	     var wakeUpPort = SleepAndWaitForWakingUpPorts();
	     // mach_msg_trap，陷入内核等待匹配的内核mach_msg事件
	     // Zzz...
	     // Received mach_msg, wake up
	     __CFRunLoopDoObservers(kCFRunLoopAfterWaiting);
	     // Handle msgs
	     if (wakeUpPort == timerPort) {
	          __CFRunLoopDoTimers();
	     } else if (wakeUpPort == mainDispatchQueuePort) {
	          //GCD当调用dispatch_async(dispatch_get_main_queue(),block)时，libDispatch会向主线程的runloop发送mach_msg消息唤醒runloop，并在这里执行。这里仅限于执行dispatch到主线程的任务，dispatch到其他线程的仍然是libDispatch来处理。
	          __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__()
	     } else {
	          __CFRunLoopDoSource1();  //CADisplayLink是source1的mach_msg触发？
	     }
     __CFRunLoopDoBlocks();
	} while (!stop && !timeout);

	//通知observers，即将退出runloop
	__CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBERVER_CALLBACK_FUNCTION__(CFRunLoopExit);
	
结合上面的Runloop事件执行顺序，思考下面代码逻辑中为什么可以标识tableview是否reload完成
	
	dispatch_async(dispatch_get_main_queue(), ^{
	    _isReloadDone = NO;
	    [tableView reload]; //会自动设置tableView layoutIfNeeded为YES，意味着将会在runloop结束时重绘table
	    dispatch_async(dispatch_get_main_queue(),^{
	        _isReloadDone = YES;
	    });
	});

> 提示：这里在GCD dispatch main queue中插入了两个任务，一次RunLoop有两个机会执行GCD dispatch main queue中的任务，分别在休眠前和被唤醒后。

#####iOS 为什么必须在主线程中操作UI

> 因为UIKit不是线程安全的。试想下面这几种情况：

两个线程同时设置同一个背景图片，那么很有可能因为当前图片被释放了两次而导致应用崩溃。
两个线程同时设置同一个UIView的背景颜色，那么很有可能渲染显示的是颜色A，而此时在UIView逻辑树上的背景颜色属性为B。
两个线程同时操作view的树形结构：在线程A中for循环遍历并操作当前View的所有subView，然后此时线程B中将某个subView直接删除，这就导致了错乱还可能导致应用崩溃。 
iOS4之后苹果将大部分绘图的方法和诸如 UIColor 和 UIFont 这样的类改写为了线程安全可用，但是仍然强烈建议讲UI操作保证在主线程中执行。
######事件响应

苹果注册了一个 Source1 (基于 mach port 的) 用来接收系统事件，其回调函数为 __IOHIDEventSystemClientQueueCallback()。

当一个硬件事件(触摸/锁屏/摇晃等)发生后，首先由 IOKit.framework 生成一个 IOHIDEvent 事件并由 SpringBoard 接收。

* SpringBoard 只接收按键(锁屏/静音等)，触摸，加速，接近传感器等几种 Event，随后用 mach port 转发给需要的App进程。随后苹果注册的那个 Source1 就会触发回调，并调用 _UIApplicationHandleEventQueue() 进行应用内部的分发。

* _UIApplicationHandleEventQueue() 会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发，其中包括识别 UIGesture/处理屏幕旋转/发送给 UIWindow 等。通常事件比如 UIButton 点击、touchesBegin/Move/End/Cancel 事件都是在这个回调中完成的。

######CALayer

在iOS当中，所有的视图都从一个叫做UIVIew的基类派生而来，UIView可以处理触摸事件，可以支持基于Core Graphics绘图，可以做仿射变换（例如旋转或者缩放），或者简单的类似于滑动或者渐变的动画。

CALayer类在概念上和UIView类似，同样也是一些被层级关系树管理的矩形块，同样也可以包含一些内容（像图片，文本或者背景色），管理子图层的位置。它们有一些方法和属性用来做动画和变换。和UIView最大的不同是CALayer不处理用户的交互。CALayer并不清楚具体的响应链。

UIView和CALayer是一个平行的层级关系，每一个UIView都有一个CALayer实例的图层属性，也就是所谓的backing layer，视图的职责就是创建并管理这个图层，以确保当子视图在层级关系中添加或者被移除的时候，他们关联的图层也同样对应在层级关系树当中有相同的操作。实际上这些背后关联的Layer图层才是真正用来在屏幕上显示和做动画，UIView仅仅是对它的一个封装，提供了一些iOS类似于处理触摸的具体功能，以及Core Animation底层方法的高级接口。

######UIView 的 Layer 在系统内部，被维护着三份同样的树形数据结构，分别是：

	图层树（这里是代码可以操纵的，设置属性的最终值会立刻在这里更新）；
	呈现树（是一个中间层，系统就在这一层上更改属性，进行各种渲染操作。比如一个动画是更改alpha值从0到1，那么在逻辑树上此属性会被立刻更新为最终属性1，而在动画树上会根据设置的动画时间从0逐步变化到1）；
	渲染树（其属性值就是当前正被显示在屏幕上的属性值）；
#####CADisplayLink 和 NSTimer

NSTimer 其实就是 CFRunLoopTimerRef。一个 NSTimer 注册到 RunLoop 后，RunLoop 会为其重复的时间点注册好事件。

* RunLoop为了节省资源，并不会在非常准确的时间点回调这个Timer。Timer 有个属性叫做 Tolerance (宽容度)，标示了当时间点到后，容许有多少最大误差。如果某个时间点被错过了，例如执行了一个很长的任务，则那个时间点的回调也会跳过去，不会延后执行。

* RunLoop 是用GCD的 dispatch_source_t 实现的 Timer。 当调用 NSObject 的 performSelecter:afterDelay: 后，实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop，则这个方法会失效。当调用 performSelector:onThread: 时，实际上其会创建一个 Timer 加到对应的线程去，同样的，如果对应线程没有 RunLoop 该方法也会失效。

* CADisplayLink 是一个和屏幕刷新率（每秒刷新60次）一致的定时器（但实际实现原理更复杂，和 NSTimer 并不一样，其内部实际是操作了一个 Source）。如果在两次屏幕刷新之间执行了一个长任务，那其中就会有一帧被跳过去，造成界面卡顿的感觉。

#####iOS 渲染过程


{% img /images/tupianxuanran002.png Caption %}  


通常来说，计算机系统中 CPU、GPU、显示器是以上面这种方式协同工作的。CPU 计算好显示内容提交到 GPU，GPU 渲染完成后将渲染结果放入帧缓冲区，随后视频控制器会按照 VSync 信号如下图1-4所示，逐行读取帧缓冲区的数据，经过可能的数模转换传递给显示器显示。


{% img /images/tupianxuanran003.png Caption %}  

在 VSync 信号到来后，系统图形服务会通过 CADisplayLink 等机制通知 App，App 主线程开始在 CPU 中计算显示内容，比如视图的创建、布局计算、图片解码、文本绘制等。随后 CPU 会将计算好的内容提交到 GPU 去，由 GPU 进行变换、合成、渲染。随后 GPU 会把渲染结果提交到帧缓冲区去，等待下一次 VSync 信号到来时显示到屏幕上。由于垂直同步的机制，如果在一个 VSync 时间内，CPU 或者 GPU 没有完成内容提交，则那一帧就会被丢弃，等待下一次机会再显示，而这时显示屏会保留之前的内容不变。这就是界面卡顿的原因。从上图中可以看到，CPU 和 GPU 不论哪个阻碍了显示流程，都会造成掉帧现象。所以开发时，也需要分别对 CPU 和 GPU 压力进行评估和优化。

{% img /images/tupianxuanran004.png Caption %}  

iOS 的显示系统是由 VSync 信号驱动的，VSync 信号由硬件时钟生成，每秒钟发出 60 次（这个值取决设备硬件，比如 iPhone 真机上通常是 59.97）。iOS 图形服务接收到 VSync 信号后，会通过 IPC 通知到 App 内。App 的 Runloop 在启动后会注册对应的 CFRunLoopSource 通过 mach_port 接收传过来的时钟信号通知，随后 Source 的回调会驱动整个 App 的动画与显示。

Core Animation 在 RunLoop 中注册了一个 Observer，监听了 BeforeWaiting 和 Exit 事件。当一个触摸事件到来时，RunLoop 被唤醒，App 中的代码会执行一些操作，比如创建和调整视图层级、设置 UIView 的 frame、修改 CALayer 的透明度、为视图添加一个动画；这些操作最终都会被 CALayer 标记，并通过 CATransaction 提交到一个中间状态去。当上面所有操作结束后，RunLoop 即将进入休眠（或者退出）时，关注该事件的 Observer 都会得到通知。这时 Core Animation 注册的那个 Observer 就会在回调中，把所有的中间状态合并提交到 GPU 去显示；如果此处有动画，通过 DisplayLink 稳定的刷新机制会不断的唤醒runloop，使得不断的有机会触发observer回调，从而根据时间来不断更新这个动画的属性值并绘制出来。

> 为了不阻塞主线程，Core Animation 的核心是 OpenGL ES 的一个抽象物，所以大部分的渲染是直接提交给GPU来处理。 而Core Graphics/Quartz 2D的大部分绘制操作都是在主线程和CPU上同步完成的，比如自定义UIView的drawRect里用CGContext来画图。

#####渲染时机

上面已经提到过：Core Animation 在 RunLoop 中注册了一个 Observer 监听 BeforeWaiting(即将进入休眠) 和 Exit (即将退出Loop) 事件 。当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次时，或者手动调用了 UIView/CALayer 的 setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去。当Oberver监听的事件到来时，回调执行函数中会遍历所有待处理的UIView/CAlayer 以执行实际的绘制和调整，并更新 UI 界面。

这个函数内部的调用栈大概是这样的：

	_ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv()
	    QuartzCore:CA::Transaction::observer_callback:
	        CA::Transaction::commit();
	            CA::Context::commit_transaction();
	                CA::Layer::layout_and_display_if_needed();
	                    CA::Layer::layout_if_needed();
	                          [CALayer layoutSublayers];
	                          [UIView layoutSubviews];
	                    CA::Layer::display_if_needed();
	                          [CALayer display];
	                          [UIView drawRect];
#####CPU 和 GPU渲染

OpenGL中，GPU屏幕渲染有以下两种方式：

* On-Screen Rendering 

意为当前屏幕渲染，指的是GPU的渲染操作是在当前用于显示的屏幕缓冲区中进行。

* Off-Screen Rendering 

意为离屏渲染，指的是GPU在当前屏幕缓冲区以外新开辟一个缓冲区进行渲染操作。 


> 按照这样的说法，如果将不在GPU的当前屏幕缓冲区中进行的渲染都称为离屏渲染，那么就还有另一种特殊的“离屏渲染”方式：CPU渲染。如果我们重写了drawRect方法，并且使用任何Core Graphics的技术进行了绘制操作，就涉及到了CPU渲染。整个渲染过程由CPU在App内同步地完成，渲染得到的bitmap最后再交由GPU用于显示。


相比于当前屏幕渲染，离屏渲染的代价是很高的，主要体现在两个方面：

	创建新缓冲区 
	要想进行离屏渲染，首先要创建一个新的缓冲区。
	上下文切换 
	
	
离屏渲染的整个过程，需要多次切换上下文环境：

* 先是从当前屏幕（On-Screen）切换到离屏（Off-Screen）
* 等到离屏渲染结束以后，将离屏缓冲区的渲染结果显示到屏幕上有需要将上下文环境从离屏切换到当前屏幕
* 而上下文环境的切换是要付出很大代价的。

* 设置了以下属性时，都会触发离屏绘制：

***

	shouldRasterize（光栅化）
	masks（遮罩）
	shadows（阴影）
	edge antialiasing（抗锯齿）
	group opacity（不透明） 

> 需要注意的是，如果shouldRasterize被设置成YES，在触发离屏绘制的同时，会将光栅化后的内容缓存起来，如果对应的layer及其sublayers没有发生改变，在下一帧的时候可以直接复用。这将在很大程度上提升渲染性能。 


而其它属性如果是开启的，就不会有缓存，离屏绘制会在每一帧都发生。
在开发时需要根据实际情况来选择最优的实现方式，尽量使用On-Screen Rendering。简单的Off-Screen Rendering可以考虑使用Core Graphics让CPU来渲染。

#####Core Animation

1. 隐式动画

隐式动画是系统框架自动完成的。Core Animation在每个runloop周期中自动开始一次新的事务，即使你不显式的用[CATransaction begin]开始一次事务，任何在一次runloop循环中属性的改变都会被集中起来，然后做一次0.25秒的动画。 

	在iOS4中，苹果对UIView添加了一种基于block的动画方法：+animateWithDuration:animations:。 
这样写对做一堆的属性动画在语法上会更加简单，但实质上它们都是在做同样的事情。 
CATransaction的+begin和+commit方法在+animateWithDuration:animations:内部自动调用，这样block中所有属性的改变都会被事务所包含。

Core Animation通常对CALayer的所有属性（可动画的属性）做动画，但是UIView是怎么把它关联的图层的这个特性关闭了呢？ 
每个UIView对它关联的图层都扮演了一个委托，并且提供了-actionForLayer:forKey的实现方法。当不在一个动画块的实现中，UIView对所有图层行为返回nil，但是在动画block范围之内，它就返回了一个非空值。

	@interface ViewController ()
	
	@property (nonatomic, weak) IBOutlet UIView *layerView;
	
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    //test layer action when outside of animation block
	    NSLog(@"Outside: %@", [self.layerView actionForLayer:self.layerView.layer forKey:@"backgroundColor"]);
	    //begin animation block
	    [UIView beginAnimations:nil context:nil];
	    //test layer action when inside of animation block
	    NSLog(@"Inside: %@", [self.layerView actionForLayer:self.layerView.layer forKey:@"backgroundColor"]);
	    //end animation block
	    [UIView commitAnimations];
	}
	
	@end
***

	$ LayerTest[21215:c07] Outside: <null>
	$ LayerTest[21215:c07] Inside: <CABasicAnimation: 0x757f090>

2. 显式动画

Core Animation提供的显式动画类型，既可以直接对退曾属性做动画，也可以覆盖默认的图层行为。 

我们经常使用的CABasicAnimation，CAKeyframeAnimation，CATransitionAnimation，CAAnimationGroup等都是显式动画类型，这些CAAnimation类型可以直接提交到CALayer上。

无论是隐式动画还是显式动画，提交到layer后，经过一系列处理，最后都经过上文描述的绘制过程最终被渲染出来。

#####Facebook Pop介绍

在计算机的世界里面，其实并不存在绝对连续的动画，你所看到的屏幕上的动画本质上都是离散的，只是在一秒的时间里面离散的帧多到一定的数量人眼就觉得是连续的了，

在iOS中，最大的帧率是60帧每秒。 iOS提供了Core Animation框架，只需要开发者提供关键帧信息，比如提供某个animatable属性终点的关键帧信息，然后中间的值则通过一定的算法进行插值计算，从而实现补间动画。 Core Aniamtion中进行插值计算所依赖的时间曲线由CAMediaTimingFunction提供。

> Pop Animation在使用上和Core Animation很相似，都涉及Animation对象以及Animation的载体的概念，不同的是Core Animation的载体只能是CALayer，而Pop Animation可以是任意基于NSObject的对象。当然大多数情况Animation都是界面上显示的可视的效果，所以动画执行的载体一般都直接或者间接是UIView或者CALayer。

但是如果你只是想研究Pop Animation的变化曲线，你也完全可以将其应用于一个普通的数据对象。Pop Animation应用于CALayer时，在动画运行的任何时刻，layer和其presentationLayer的相关属性值始终保持一致，而Core Animation做不到。 Pop Animation可以应用任何NSObject的对象，而Core Aniamtion必须是CALayer。

下面这个例子就是自定义Pop readBlock和writeBlock处理自定义的动画属性：

	prop = [POPAnimatableProperty propertyWithName:@"com.foo.radio.volume" initializer:^(POPMutableAnimatableProperty *prop) {
	    // read value
	    prop.readBlock = ^(id obj, CGFloat values[]) {
	        values[0] = [obj volume];
	    };
	    // write value
	    prop.writeBlock = ^(id obj, const CGFloat values[]) {
	        [obj setVolume:values[0]];
	    };
	    // dynamics threshold
	    prop.threshold = 0.01;
	}];
	
	POPSpringAnimation *anim = [POPSpringAnimation animation];
	anim.property = prop;

Pop实现依赖的核心就是CADisplayLink。

最后附上一篇介绍Facebook Pop如何使用的文章 《Introducing Facebook Pop》

#####AsyncDisplay介绍

阻塞主线程的绘制任务主要是这三大类：

* Layout计算视图布局文本宽高
 
* Rendering文本渲染图片解码图片绘制
 
* UIKit对象创建更新释放。

除了UIKit和CoreAnimation相关操作必须在主线程中进行，其他的都可以挪到后台线程异步执行。

AsyncDisplay通过抽象UIView的关系创建了ASDisplayNode类，ASDisplayNode是线程安全的，它可以在后台线程创建和修改。Node 刚创建时，并不会在内部新建 UIView 和 CALayer，直到第一次在主线程访问 view 或 layer 属性时，它才会在内部生成对应的对象。当它的属性（比如frame/transform）改变后，它并不会立刻同步到其持有的 view 或 layer 去，而是把被改变的属性保存到内部的一个中间变量，稍后在需要时，再通过某个机制一次性设置到内部的 view 或 layer。从而可以实现异步并发操作。

AsyncDisplay实现依赖如同Core Animation在runloop中注册observer事件来触发。 
同样附上一篇介绍AsyncDisplay的好文 《iOS保持界面流畅的技巧和AsyncDisplay介绍》

***

参考文章

[runloop原理](https://github.com/ming1016/study/wiki/CFRunLoop)

[深入理解runloop](http://blog.ibireme.com/2015/05/18/runloop/)

[线程安全类的设计](http://objccn.io/issue-2-4/)

[iOS保持界面流畅的技巧和AsyncDisplay介绍](http://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)

[离屏渲染](http://foggry.com/blog/2015/05/06/chi-ping-xuan-ran-xue-xi-bi-ji/)

[ios核心动画高级技巧](https://zsisme.gitbooks.io/ios-/content/index.html)