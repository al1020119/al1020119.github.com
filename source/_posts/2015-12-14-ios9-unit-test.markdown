---
layout: post
title: "iOS9-Unit Test"
date: 2015-12-14 00:59:07 +0800
comments: true
categories: 新技术 
---

 
 XCode7(iOS9)中新增了跟多特性，包括：

* WKWebView+SFSafariViewController
* UI Test
* Multitasking
* watchOS 2
* Swift 2
* App Thinning
* 人工智能和搜索 API
* HomeKit，CloudKit，HealthKit 等等杂七杂八的框架
 
 前面的文章中我们已经将WKWebView+SFSafariViewController完整的介绍了一遍，现在我们就开始着手探究一下单元测试（后面的文章中我将会集中介绍一下常用功能新特性），敬请关注：[iOS梦工厂](http://al1020119.github.io/)
 
 
###UI Tests是什么？
UI Tests是一个自动测试UI与交互的Testing组件




<!--more-->




###UI Tests有什么用？
它可以通过编写代码、或者是记录开发者的操作过程并代码化，来实现自动点击某个按钮、视图，或者自动输入文字等功能。

###UI Tests的重要性
在实际的开发过程中，随着项目越做越大，功能越来越多，仅仅靠人工操作的方式来覆盖所有测试用例是非常困难的，尤其是加入新功能以后，旧的功能也要重新测试一遍，这导致了测试需要花非常多的时间来进行回归测试，这里产生了大量重复的工作，而这些重复的工作有些是可以自动完成的，这时候UI Tests就可以帮助解决这个问题了

##使用方法
######第一步：添加UI Tests
如果是新项目，则创建工程的时候可以直接勾选选项，如下图


{% img /images/unittest001.png Caption %}  
 

如果是已有的项目，可以通过添加target的方式添加一个UI Tests，点击xcode的菜单，找到target栏


{% img /images/unittest002.png Caption %}  

 
在Test选项中选择Cocoa Touch UI Testing Bundle


{% img /images/unittest003.png Caption %}  
 
这时候test组件添加成功，它在项目中的位置如下图所示


{% img /images/unittest004.png Caption %}  
 
######第二步：创建测试代码
手动创建测试代码
打开测试文件，在testExample()方法中添加测试代码


{% img /images/unittest005.png Caption %}  
 
如果不知道如何写测试代码，则可以参考自动生成的代码样式

#####自动生成测试步骤

选择测试文件后，点击录制按钮

{% img /images/unittest006.png Caption %}  
 
这时候开始进行操作，它会记录你的操作步骤，并生成测试代码
下图就是在一些操作后自动生成的测试代码



{% img /images/unittest007.png Caption %}  

这时候可以分析测试代码的语法，以便你自己手动修改或者手写测试代码

######第三步：开始测试
点击testExample方法旁边的播放按钮，它就开始进行自动测试了，这时候你会看到app在自动操作



{% img /images/unittest008.png Caption %}  

######下面介绍一下测试元素的语法
XCUIApplication：
继承XCUIElement，这个类掌管应用程序的生命周期，里面包含两个主要方法

	launch():
启动程序

	terminate():
终止程序

######XCUIElement: 
继承NSObject，实现协议XCUIElementAttributes, XCUIElementTypeQueryProvider
可以表示系统的各种UI元素

	exist:
可以让你判断当前的UI元素是否存在，如果对一个不存在的元素进行操作，会导致测试组件抛出异常并中断测试

	descendantsMatchingType(type:XCUIElementType)->XCUIElementQuery:
取某种类型的元素以及它的子类集合

	childrenMatchingType(type:XCUIElementType)->XCUIElementQuery:
取某种类型的元素集合，不包含它的子类

这两个方法的区别在于，你仅使用系统的UIButton时，用childrenMatchingType就可以了，如果你还希望查询自己定义的子Button，就要用descendantsMatchingType

另外UI元素还有一些交互方法

	tap():
点击
	
	doubleTap():
双击

	pressForDuration(duration: NSTimeInterval):
长按一段时间，在你需要进行延时操作时，这个就派上用场了

	swipeUp():
这个响应不了pan手势，暂时没发现能用在什么地方，也可能是beta版的bug，先不解释

	typeText(text: String):
用于textField和textView输入文本时使用，使用前要确保文本框获得输入焦点，可以使用tap()函数使其获得焦点

######XCUIElementAttributes协议
里面包含了UIAccessibility中的部分属性
如下图



{% img /images/unittest009.png Caption %}  


可以方便你查看当前元素的特征，其中identifier属性可用于直接读取元素，不过该属性在UITextField中有bug，暂时不清楚原因

XCUIElementTypeQueryProvider协议
里面包含了系统中大部分UI控件的类型，可通过读属性的方式取得某种类型的UI集合
部分属性截图如下



{% img /images/unittest010.png Caption %}  
###创建Demo
首先创建一个登录页面



{% img /images/unittest011.png Caption %}  

点击login按钮进行登录验证，点击clear按钮会清除文本
登录成功后可以去到个人信息页面

个人信息页面如下



{% img /images/unittest012.png Caption %}  

点击modify按钮可以修改个人信息，点击Message按钮可以查看个人消息

最后是消息界面



{% img /images/unittest013.png Caption %}  

####登录页面的测试

* 输入一个错误的账号
* 验证结果
* 关闭警告窗
* 清除输入记录
* 输入一个正确的账号
* 验证结果
* 进入个人信息页面

测试代码如下:

    func testLoginView() {
        let app = XCUIApplication()

        // 由于UITextField的id有问题，所以只能通过label的方式遍历元素来读取
        let nameField = self.getFieldWithLbl("nameField")
        if self.canOperateElement(nameField) {
            nameField!.tap()
            nameField!.typeText("xiaoming")
        }

        let psdField = self.getFieldWithLbl("psdField")
        if self.canOperateElement(psdField) {
            psdField!.tap()
            psdField!.typeText("1234321")
        }

        // 通过UIButton的预设id来读取对应的按钮
        let loginBtn = app.buttons["Login"]
        if self.canOperateElement(loginBtn) {
            loginBtn.tap()
        }

        // 开始一段延时，由于真实的登录是联网请求，所以不能直接获得结果，demo通过延时的方式来模拟联网请求
        let window = app.windows.elementAtIndex(0)
        if self.canOperateElement(window) {
            // 延时3秒, 3秒后如果登录成功，则自动进入信息页面，如果登录失败，则弹出警告窗
            window.pressForDuration(3)
        }

        // alert的id和labe都用不了，估计还是bug，所以只能通过数量判断
        if app.alerts.count > 0 {
            // 登录失败
            app.alerts.collectionViews.buttons["确定"].tap()

            let clear = app.buttons["Clear"]
            if self.canOperateElement(clear) {
                clear.tap()

                if self.canOperateElement(nameField) {
                    nameField!.tap()
                    nameField!.typeText("sun")
                }

                if self.canOperateElement(psdField) {
                    psdField!.tap()
                    psdField!.typeText("111111")
                }

                if self.canOperateElement(loginBtn) {
                    loginBtn.tap()
                }
                if self.canOperateElement(window) {
                    // 延时3秒, 3秒后如果登录成功，则自动进入信息页面，如果登录失败，则弹出警告窗
                    window.pressForDuration(3)
                }
                self.loginSuccess()
            }
        } else {
            // 登录成功
            self.loginSuccess()
        }
    }


> 这里有几个需要特别注意的点：
当你的元素不存在时，它仍然可能返回一个元素对象，但这时候不能对其进行操作
当你要点击的元素被键盘或者UIAlertView遮挡时，执行tap方法会抛异常
详细实现可参照demo:
[https://github.com/sunljz/demo/tree/master/iOS9/UITestDemo](https://github.com/sunljz/demo/tree/master/iOS9/UITestDemo)

####个人信息页测试

* 修改性别
* 修改年龄
* 修改心情
* 保存修改

测试代码如下：

	    func testInfo() {
	        let app = XCUIApplication()
	        let window = app.windows.elementAtIndex(0)
	        if self.canOperateElement(window) {
	            // 延时2秒, 加载数据需要时间
	            window.pressForDuration(2)
	        }
	
	        let modifyBtn = app.buttons["modify"];
	        modifyBtn.tap()
	
	        let sexSwitch = app.switches["sex"]
	        sexSwitch.tap()
	
	        let incrementButton = app.buttons["Increment"]
	        incrementButton.tap()
	        incrementButton.tap()
	        incrementButton.tap()
	        app.buttons["Decrement"].tap()
	
	        let textView = app.textViews["feeling"]
	        textView.tap()
	        app.keys["Delete"].tap()
	        app.keys["Delete"].tap()
	        textView.typeText(" abc ")
	
	        // 点击空白区域
	        let clearBtn = app.buttons["clearBtn"]
	        clearBtn.tap()
	
	        // 保存数据
	        modifyBtn.tap()
	        window.pressForDuration(2)
	
	        let messageBtn = app.buttons["message"]
	        messageBtn.tap();
	
	        // 延时1秒, push view需要时间
	        window.pressForDuration(1)
	
	        self.testMessage()
	    }

> 这里需要特别注意以下两点：
textview获取焦点时无法选择焦点的位置
tap事件的触发位置是view的中心，所以当view的中心被遮挡时，要考虑使用其他view来代替


####个人消息界面测试
单元格的点击
测试代码如下：

	    func testMessage() {
	        let app = XCUIApplication()
	        let window = app.windows.elementAtIndex(0)
	        if self.canOperateElement(window) {
	            // 延时2秒, 加载数据需要时间
	            window.pressForDuration(2)
	        }
	
	        let table = app.tables
	        table.childrenMatchingType(.Cell).elementAtIndex(8).tap()
	        table.childrenMatchingType(.Cell).elementAtIndex(1).tap()
	
	    }

> 这里需要注意一点：
暂时无法获取到tableView的元素指针


###总结
总的来说，UI Tests只能用于一些基础功能的测试，验证app的功能是否可以正常使用，是否存在崩溃问题。但它也有很多不足之处，编写测试用例的过程非常繁琐，自动生成的代码几乎无法运行，功能单一，很多用例无法覆盖，而且bug很多，大大地限制了UI Tests在实际开发中的应用。希望正式版出来的时候能够修复这些问题，并开放更多的功能。

demo地址：

[https://github.com/sunljz/demo/tree/master/iOS9/UITestDemo](https://github.com/sunljz/demo/tree/master/iOS9/UITestDemo)

最后介绍几个常见的第三方测试框架：

Frank， KIF， Subliminal， Apple 的 UIAutomation，我把他们都试了一遍。你要是希望了解更多可以访问我的故障特征测试框架。它不是开发者的失败，而是因为 Apple 对待测试只有有限的开放性。这使得这些框架有一系列的补丁，而在这些补丁之上，这些框架不外乎都成为了一堆破碎的工具。
没有涉及到的更多细节：

* Frank 一直被遗弃。
* KIF 已经与主要的 iOS 修订版本决裂。
* Subliminal 不能在命令行中可靠地运行。
* UIAutomation 是用 JavaScript 和 clunky 写的。
