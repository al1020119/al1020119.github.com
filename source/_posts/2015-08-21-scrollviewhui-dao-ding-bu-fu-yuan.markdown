---

layout: post
title: "ScrollView回到顶部复原"
date: 2015-08-21 02:33:00 +0800
comments: true
categories: 项目实战

---


相信细心的开发者都会发现scrollView自带一个功能,当用户点击顶部的状态栏时,scrollView的ContentOffset.y轴会自动滚动到初始位置,效果如图所示:


> 单个scrollView单击顶部状态栏系统自带功能展示

这个功能对用户来说非常实用,尤其是在scrollView(TableView, WebView, CollectionView一切继承scrollView的控件)展示的内容很多,当用户翻看很久以后,想回到最顶部时,只需单击一下顶部的状态栏位置就可以轻松返回到顶部(这里吐槽下.貌似很多用户都不知道有这个功能),而不用使劲用手滑动到顶部.


* 可是功能在当前控制器有多个scrollView(TableView, WebView, CollectionView一切继承scrollView的控件)的时候就会失效,效果如下图所示:


当控制器内有多个scrollView时,系统自带的滚动到顶的功能就会失效

实际开发中,我们的产品在同一个控制器经常会有多个scrollView组合在一起的情况,这就意味着系统的方法已经失效了,需要开发人员自己来实现这个效果,下面我们就来搞定这个需求

> 我们分析下原生的方法为什么会失效,当一个控制器内只有一个scrollView时,点击状态栏,系统会遍历当前keyWindow的子控件,发现子控件中只有一个scrollView会调用这个scrollView的setContentOffset: animated:的这个方法,将scrollView的contentOffset.y值修改为初始值,但是当子控件中又多个scrollView时,系统会不知道掉用哪一个scrollView而失效,知道这点我们就知道该如何搞定这个问题了

这里就直接将解决思路一一写出来不将代码分段展示了,在代码中我加了详细的注释objective-c的套路和swift基本一样,在最后会将Swift和objective-c的代码一起放上,如果需要直接解决问题的童鞋可以直接将代码拷贝到工程里即可

* 首先创建一个topWindow继承至NSObject,这里我们考虑将这个功能完全封装起来,所以所有的方法都用的类方法,所以用最基本的类就可以
* 在initialize方法中初始化topWIndow,将topWIndow的级别改成最高的UIWindowLevelAlert级别,设置topWindow位置,并且添加点击手势
* 在topWIndow被点击调用的方法中,我们拿出UIApplication的keyWindow,遍历keyWindow的所有子控件,如果满足是scrollView同时又显示在当前keyWindow条件时,将subView的contentOffset的y值回复到原始
* 然后采用递归的套路在遍历subView内时候有满足条件的子控件,直到没有满足条件时会停止

####Swift的代码
	
	import UIKit
	class TopWindow: UIWindow {
	    private static let window_: UIWindow = UIWindow()
	    ///  类初始化方法,保证window_只被创建一次
	    override class func initialize() {
	        window_.frame = CGRectMake(0, 0, global.appWidth, 20)
	        window_.windowLevel = UIWindowLevelAlert
	        window_.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "topWindowClick"))
	    }
	    class func topWindowClick() {
	        // 遍历当前主窗口所有view,将满足条件的scrollView滚动回原位
	        searchAllowScrollViewInView(UIApplication.sharedApplication().keyWindow!)
	    }
	    private class func searchAllowScrollViewInView(superView: UIView) {
	        for subview: UIView in superView.subviews as! [UIView] {
	            if subview.isKindOfClass(UIScrollView.self) && superView.viewIsInKeyWindow() {
	                // 拿到scrollView的contentOffset
	                var offest = (subview as! UIScrollView).contentOffset
	                // 将offest的y轴还原成最开始的值
	                offest.y = -(subview as! UIScrollView).contentInset.top
	                // 重新设置scrollView的内容
	                (subview as! UIScrollView).setContentOffset(offest, animated: true)
	            }
	            // 递归,让子控件再次调用这个方法判断时候还有满足条件的view
	            searchAllowScrollViewInView(subview)
	        }
	    }
	    ///  添加topWindow,使手势生效
	    class func showTopWindow() {
	        window_.hidden = false
	    }
	    ///  隐藏topWindow,移除手势
	    class func hiddenTopWindow() {
	        window_.hidden = true
	    }
	}
	///  对UIView的一个扩展
	extension UIView {
	    ///  判断调用方法的view是否在keyWindow中
	    func viewIsInKeyWindow() -> Bool {
	        let keyWindow = UIApplication.sharedApplication().keyWindow!
	        // 将当前view的坐标系转换到window.bounds
	        let viewNewFrame = keyWindow.convertRect(self.frame, fromView: self.superview)
	        let keyWindowBounds = keyWindow.bounds
	        // 判断当前view是否在keyWindow的范围内
	        let isIntersects = CGRectIntersectsRect(viewNewFrame, keyWindowBounds)
	        // 判断是否满足所有条件
	        return !self.hidden && self.alpha > 0.01 && self.window == keyWindow && isIntersects
	    }   
	}
	
在AppDelegate里,程序启动完成方法时添加就OK了

	  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	      // 添加顶部的window
	      TopWindow.showTopWindow()
	      return true
	  }
需要注意添加了自定义的window后,控制器的改变状态栏状态方法会失效,可以在info.plist中将改变状态栏的管理权交给UIApplication解决,或者在需要改变状态栏的控制器中调用TopWindow.hiddenTopWindow()即可,或者直接改info.plist,用UIApplication.sharedApplication().setStatusBarStyle来管理


####Objective-C代码

.h文件只暴露显示和隐藏方法
	
	#import @interface WNXTopWindow : NSObject
	+ (void)show;
	+ (void)hide;
	@end
	
	
.m文件
	
	#import "WNXTopWindow.h"
	@implementation WNXTopWindow
	static UIWindow *window_;
	//初始化window
	+ (void)initialize {
	  window_ = [[UIWindow alloc] init];
	  window_.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
	  window_.windowLevel = UIWindowLevelAlert;
	  [window_ addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowClick)]];
	}  
	+ (void)show {
	  window_.hidden = NO;
	}
	+ (void)hide {
	  window_.hidden = YES;
	}
	// 监听窗口点击
	+ (void)windowClick {
	  UIWindow *window = [UIApplication sharedApplication].keyWindow;
	  [self searchScrollViewInView:window];
	}
	+ (void)searchScrollViewInView:(UIView *)superview {
	  for (UIScrollView *subview in superview.subviews) {
	      // 如果是scrollview, 滚动最顶部
	      if ([subview isKindOfClass:[UIScrollView class]] && [subview isShowingOnKeyWindow]) {
	          CGPoint offset = subview.contentOffset;
	          offset.y = - subview.contentInset.top;
	          [subview setContentOffset:offset animated:YES];
	      }
	      // 递归继续查找子控件
	      [self searchScrollViewInView:subview];
	  }
	}
	+ (BOOL)isShowingOnKeyWindow:(UIView *)view {
	  // 主窗口
	  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
	  // 以主窗口左上角为坐标原点, 计算self的矩形框
	  CGRect newFrame = [keyWindow convertRect:view.frame fromView:view.superview];
	  CGRect winBounds = keyWindow.bounds;
	  // 主窗口的bounds 和 self的矩形框 是否有重叠
	  BOOL intersects = CGRectIntersectsRect(newFrame, winBounds);
	  return !view.isHidden && view.alpha > 0.01 && view.window == keyWindow && intersects;
	}
	@end
	
	
同样,也是在程序初始化完成AppDelegate文件中显示topWindow,整个工程这个问题就统统解决了

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	  // 添加一个window, 点击这个window, 可以让屏幕上的scrollView滚到最顶部
	  [WNXTopWindow show];
	  return YES;
	}