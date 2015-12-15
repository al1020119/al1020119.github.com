---
layout: post
title: "iOS9-CoreSpotlight"
date: 2015-12-25 13:35:30 +0800
comments: true
categories: New features
---

iOS9 Day-by-Day是作者Chris Grant新开的一个系列博客，覆盖了iOS开发者必须知道的关于iOS 9的新技术与API，并且还进行了实际操作演练，每篇文章中相关的代码Chris都会将其托管到GitHub。

在第一篇文章中，Chris介绍了iOS 9的三种搜索API，分别为：

* NSUserActivity，索引用户活动以及App的状态。

* Web Markup，Web内容可被搜索。

* iOS 9新增的CoreSpotlight.framework提供了增、删、改、查等搜索API，可以索引App的内容。
译文如下：

在苹果发布iOS 9之前，你只能在Spotlight中输入名称来寻找App，而随着苹果发布了一套全新的iOS 9 Search APIs之后，开发者不但可以自由选择App的部分内容编入索引，还能对Spotlight上的搜索结果以及点击不同结果显示的内容进行设置。

###三大API


<!--more-->



#####NSUserActivity

- NSUserActivity是iOS 8专为Handoff推出的API，iOS 9之后得到了提升。现在用户只需提供元数据（metadata）就能搜索不同的activity（活动）了。

- 换言之，Spotlight可以将activity编入索引，而NSUserActivity就好比网页浏览器的历史堆栈（history stack），使用户能在Spotlight上搜到最近的活动。

#####Web Markup

- Web Markup在网页上显示App的内容并编入Spotlight索引，如此一来即便没有安装某个App，苹果的索引器也能在网页上搜索特别的标记（markup），在Safari或Spotlight上显示搜索结果。

- 显示未安装App的搜索结果是一大亮点，有望为开发者带来更多潜在用户。公布在搜索API上的App深链接则储存在苹果的cloud index中。更多详情，请参阅苹果的“Web Markup使用指南（Use Web Markup to Make App Content Searchable）”。

#####CoreSpotlight

- NSUserActivity帮助储存用户历史，而全新的Core Spotlight则能将App中的任何内容编入索引，实质是在用户设备上提供基础的Core Spotlight索引渠道，满足用户另外一个需求。

***

至于前面两个这里就不过多介绍，这里只介绍iOS9相关新特性，所以就来说我们应该怎么去学习并使用CoreSpotlight。

> 对于CoreSpotlight可以类比NSUserDefault，都是全局的存储空间。不同的是CoreSpotlight是系统的存储空间，每个App都能访问（可能这个访问有限制，目前还没有时间研究），但是NSUserDefault是每个App私有的。另外对于存储的内容CoreSpotlight存储的是item，即CSSearchableItem，而每个CSSearchableItem又有许多属性，这些属性是通过CSSearchableItemAttributeSet进行设置。具体都有神马属性，大家自己去看头文件吧。

 下面写一下简单得步骤：

* 1 引入CoreSpotlight.framework

* 2 创建CSSearchableItemAttributeSet、CSSearchableItem

* 3 调用CSSearchableIndex.defaultSearchableIndex()的相关的方法对item进行操作。

> 由于本人水平有限，只找到了添加、删除itme的操作，并没有找到更新itme的方法，如果谁清楚了，麻烦告知一下。

 下面贴出本人测试的一个简单例子的代码：
	import UIKit

	@UIApplicationMain
	class AppDelegate: UIResponder, UIApplicationDelegate {
	
	    var window: UIWindow?
	
	    // 从搜索结果点击的时候将会调用这个方法
	    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
	        // 这里能够获取到点击搜索结果的identifier 但是不清楚是不是应该这样做
	        let identifier = userActivity.userInfo?["kCSSearchableItemActivityIdentifier"]
	        print("continueUserActivity \(identifier!)")
	        return true
	    }
	
	
	}



***

	 
	import UIKit
	import CoreSpotlight
	
	class ViewController: UIViewController {
	    let identifier = "com.mxy.test.identifier"
	    var index = 1 // 用于标识添加的itme
	
	    override func viewDidLoad() {
	        super.viewDidLoad()
	        CSSearchableIndex.defaultSearchableIndex().deleteAllSearchableItemsWithCompletionHandler { (error) -> Void in
	            
	        }
	    }
	    
	    
	    @IBAction func insertItem() {
	        let attributeSet = CSSearchableItemAttributeSet(itemContentType: "com.mxy.test")
	        attributeSet.title = "孟祥月 测试 mxy \(index)"
	        attributeSet.contentDescription = "this 这里写点什么好呢 mxy \(index)"
	        // 设置搜索结果的缩略图 不知道 为何就是不生效 我给应用程序添加了icon后，搜索结果那里显示的是icon
	        attributeSet.thumbnailURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("aa", ofType: "png")!)
	        attributeSet.thumbnailData = UIImagePNGRepresentation(UIImage(named: "aa")!)
	        let item = CSSearchableItem(uniqueIdentifier: "\(identifier) \(index)", domainIdentifier: "mxy", attributeSet: attributeSet)
	        let tmpItmes: [CSSearchableItem] = [item]
	        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(tmpItmes) { (error) -> Void in
	            
	        }
	        index++
	    }
	    
	    // 貌似是没有更新操作 所以只好根据identifier先删除，修改后再添加进去。
	    @IBAction func updateItem() {
	        if index > 0 {
	            let tmpIdentifier = "\(identifier) \(index - 1)"
	            CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers([tmpIdentifier], completionHandler: { (error) -> Void in
	                
	            })
	            
	            let attributeSet = CSSearchableItemAttributeSet(itemContentType: "com.mxy.test")
	            attributeSet.title = "孟祥月 测试 mxy \(index - 1)"
	            attributeSet.contentDescription = "this 这里写点更新后 mxy \(index - 1)"
	            let item = CSSearchableItem(uniqueIdentifier: tmpIdentifier, domainIdentifier: "mxy", attributeSet: attributeSet)
	            let tmpItmes: [CSSearchableItem] = [item]
	            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(tmpItmes) { (error) -> Void in
	                
	            }
	            
	        }
	    
	    }
	    
	    @IBAction func deleteItem() {
	        let identifiers = ["\(identifier) \(index)"]
	        index--
	        if index <= 0 {
	            return
	        }
	        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers(identifiers) { (error) -> Void in
	            
	        }
	    }
	
	}


在storyboard中只是添加了三个按钮，关联对应的操作。下面是演示，点击更新的时候会更新最后一个item的内容：




{% img /images/Spotlight001.gif Caption %}  


例子代码的下载地址：[http://download.csdn.net/detail/mengxiangyue/8827141](http://download.csdn.net/detail/mengxiangyue/8827141)