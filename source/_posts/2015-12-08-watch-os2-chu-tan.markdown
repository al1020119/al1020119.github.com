---
layout: post
title: "Watch OS2 初探"
date: 2015-12-08 17:44:31 +0800
comments: true
categories: 新技术
---



> 这一年的WWDC大会上,苹果公司推出了watchOS 2,这标志着Apple Watch的开发产生了巨大的变化。现在,你可以开发能运行在你手表上原生的app了。 在这篇watchOS 2教程中,你会开发一个简单但是功能齐全的watchOS 2的app。
在这个过程中,你会学到:

* 如何为iOS app添加watchOS 2的target
* 如何在两个target之间共享数据
* 如何添加一个watchOS 2界面控制器到Storyboard,并放置界面对象
* 如何创建WKInterfaceController的子类并连线


正式开始吧

首先下载教程的起始项目吧。

在Xcode中打开它然后编译运行。你应该会看到一个空白界面:

{% img /images/watchOS001.png Caption %}  

这个项目没有太多的文件,只包含一些你需要的最基本的文件。

添加WatchKit App

选择File\New\Target…,在出现的对话框中选择watchOS\Application\WatchKit App然后点击Next:


{% img /images/watchOS002.png Caption %}  

在接下来的界面中,设置项目名字为Watch,确保语言设置为Swift,然后取消选中任何复选框。点击Finish:


{% img /images/watchOS003.png Caption %}  

之后会询问你是否想要激活watch scheme,你需要这么做,所以确保选择了激活:


{% img /images/watchOS004.png Caption %}  

祝贺,你刚刚创建了你的第一个手表app!这真的很容易。

你会注意到,这个操作实际上创建了两个target,而不是一个,在项目导航中看到两个对应的组。这是因为手表app的代码实际是作为一个扩展形式存在的,类似iOS上的Today extensions。

当你在项目导航中点开Watch和Watch Extensions组的时候,你会看到所有storyboard放在Watch组,当前target创建的所有的类文件放在Watch Extensions组中:


{% img /images/watchOS005.png Caption %}  

你需要遵循如下的原则:任何你添加的代码必须放在Watch Extension组中然后添加到Watch Extension target,而所有的assets或者storyboards需要放在Watch组里。


{% img /images/watchOS006.png Caption %}  

在继续前,你需要删掉一些target模板添加的你不需要的文件。

在项目导航里面右键点击InterfaceController.swift然后选择删除。 当弹出提示,选择Move to Trash来确保文件确实从项目中删掉了:


{% img /images/watchOS007.png Caption %}  

下一步,打开Interface.storyboard,选择其中仅有的界面控制器,按下backspace键来删除它。现在就剩下一个空storyboard,或者是我认为的,一个空白画布。

共享数据和代码

起始项目包含一个记录所有Aber航空公司航班信息的JSON文件,一个模型类表示飞行数据。这正是应该共享的数据,因为iOS app和手表app使用相同的模型类和数据-你记得DRY(不要写重复的代码)原则吗?

在项目导航中点开Shared组然后选择Flights.json。之后,在File Inspector中找到Target Membership区域,选中Watch Extension


{% img /images/watchOS008.png Caption %}  

文件现在应该被AirAber和Watch Extensions这两个target所包含。 为其他Shared组的文件重复这个步骤,比如说Flight.swift。 这些都做完后,你可以开始开发航班详情界面了!

构造界面

打开 Watch\Interface.storyboard,从对象库拖一个界面控制器到storyboard里面.选中这个界面控制器,打开属性检查器设置它的Identificer为Flight,然后勾选Is Initial Controller:


{% img /images/watchOS009.png Caption %}  

你设置的这个Identifier让你可以在代码中引用这个界面控制器。选中Is Initial Controller简单告诉WatchKit你希望当应用程序启动的时候首先显示这个界面。

下一步,从对象库中拖动一个组到界面控制器:


{% img /images/watchOS010.png Caption %}  

之后这个组会包含Aber公司的logo,航班号和路线。

选中这个组,在属性检查器的顶部改变它的Insets为Custom。这会显示四个额外的文本框让你可以手动的设置组的上下左右。设置Top为6:


{% img /images/watchOS011.png Caption %}  

这仅仅让你的组到顶部有个额外的空隙。

下一步,拖动Image到组中。组会相应的收缩来改变Top inset(感谢Xcode!),之后在文档大纲中检查来确保Image是组的子节点,而不是同级:


{% img /images/watchOS012.png Caption %}  

现在需要显示一张图片,下载logo图片然后把它拖动到Watch\Assets.xcassets中。这会创建一个新的logo图片,存放在2x的部分。


{% img /images/watchOS013.png Caption %}  

为了给图片染色,选中这张图片,在属性检查器中修改Render As为Template Image。

重新打开 Watch\Interface.storyboard 选中之前的image.使用属性检查器,做如下的改变:

* 设置图片为Logo - 当下拉列表没有出现,你可以自己输入;
* 设置Tint为#FA114F(也可以在颜色面板中输入值);
* 设置Width为Fixed,值为40;
* 设置Height为Fixed,值为40。



属性检查器现在应该像下面这样:


{% img /images/watchOS014.png Caption %}  

不要担心看不到logo,因为Xcode设计时无法给模板图片染色!

下一步,往已经存在的组中拖动另外一个组,确保它出现在image的右侧,使用属性检查器设置Layout属性为Vertical.同样修改Spacing为0、Width为Size to Fit Content。然后拖动两个label到新的组中,放置一个到另一个的下面。


{% img /images/watchOS015.png Caption %}  

选择上面的label,使用属性检查器,设置文本为Flight 123,文字颜色为#FA114F。

选择下面的label,设置文本为MAM to SFO。界面控制器最后看起来像下面这样:


{% img /images/watchOS016.png Caption %}  

这些文本仅仅充当占位符,之后会被控制器中设置的文本取代。

下一步,拖动另一个组到界面控制器中,但是这次确保与第一个组同级。当不能设置组级别关系请使用文档大纲(Document Outline)。


{% img /images/watchOS017.png Caption %}  

选中新的组,设置它的Layout为Vertical、Spacing为0。

现在,拖动三个label到新的组中:


{% img /images/watchOS018.png Caption %}  

确保label都在group中,而不是与group同级!

选择顶部的label使用属性检查器修改它的文本为AA123 Boards。

选中中间的label,修改文本颜色为#FA114F,字体选择System,Regulaer样式和54.0的size.最后,修改Height为Fixed,值是44。

选中底部的label修改文本为On time,文本颜色为#04DE71。 你的界面控制器应该现在像下面这样:


{% img /images/watchOS019.png Caption %}  

从对象库中拖动一个新的组到下面的组,这次确保它是在子节点而不是在同级,之后向其中添加两个label,你完全的界面对象关系应该像这样:


{% img /images/watchOS020.png Caption %}  

使用属性检查器,设置左边的label文本为Gate 1A。右边的label设置为Seat 64A,之后设置它的Horizontal alignment为Right 完全的界面应该像如下这样:


{% img /images/watchOS021.png Caption %}  

恭喜,你已经完成你的第一个watch app界面的布局了,现在是时候给它填充一些真实的数据然后在模拟器上运行。

创建控制器

在项目导航中右击Watch Extensions组,选择New File,在出现的对话框中选择watchOS\Source\WatchKit Class然后点击Next。命名新的类为FlightInterfaceController,确保它为WKInterfaceController的子类,语言设置为Swift:


{% img /images/watchOS022.png Caption %}  

点击Next,之后是Create

可以看到新的文件在代码编辑器中打开了,删除其中的三个空方法,只剩下import语句和类定义。

添加这些Outlets到FlightInterfaceController的顶部:


	@IBOutlet var flightLabel: WKInterfaceLabel!
	@IBOutlet var routeLabel: WKInterfaceLabel!
	@IBOutlet var boardingLabel: WKInterfaceLabel!
	@IBOutlet var boardTimeLabel: WKInterfaceLabel!
	@IBOutlet var statusLabel: WKInterfaceLabel!
	@IBOutlet var gateLabel: WKInterfaceLabel!
	@IBOutlet var seatLabel: WKInterfaceLabel!
这里仅仅为之前的每个label添加一个Outlet。稍后会把他们连接起来。

下一步,在outlets下面添加flight属性和对应的属性观察器:


	// 1
	var flight: Flight? {
	  // 2
	  didSet {
	    // 3
	    if let flight = flight {
	      // 4
	      flightLabel.setText("Flight \(flight.shortNumber)")
	      routeLabel.setText(flight.route)
	      boardingLabel.setText("\(flight.number) Boards")
	      boardTimeLabel.setText(flight.boardsAt)
	      // 5
	      if flight.onSchedule {
	        statusLabel.setText("On Time")
	      } else {
	        statusLabel.setText("Delayed")
	        statusLabel.setTextColor(UIColor.redColor())
	      }
	      gateLabel.setText("Gate \(flight.gate)")
	      seatLabel.setText("Seat \(flight.seat)")
	    }
	  }
	}
会一步步讲解发生的事情:

* 1.你定义了一个可选的属性类型为Flight。这个类在Flight.swift中定义;

* 2.你添加了一个属性观察器,当属性设值时候会触发它;

* 3.在可选属性中确保有一个真的flight而不是nil,当flight存在才会去设置labels的值;

* 4.使用flight的相关属性去设置labels

* 5.如果航班被延误，那么你就将标签的文本颜色改为红色


在控制器第一次显示时候设置航班。添加以下声明：


	override func awakeWithContext(context: AnyObject?) {
	  super.awakeWithContext(context)
	  flight = Flight.allFlights().first!
	}
本后面的教程会修改为在上下文中传递值给它,但现在你只需要从共享的JSON文件中加载所有的航班,然后使用数组中的第一个。

在后面的教程你将学到更多关于awakeWithContext（_：)的知识,但是现在你仅仅需要知道它是界面控制器生命周期第一环节,一个设置flight值的地方。 现在仅剩最后一步你就可以编译运行了,就是去连接outlets

连接outlets

打开 Watch\Interface.storyboard 选择界面控制器,使用Identity Inspector,设置Class\Custom Class为FlightInterfaceController

下一步,右击界面控制器顶部的黄色图片弹出窗口:

{% img /images/watchOS023.png Caption %}  

现在,按下面的列表连接outlets:

	boardingLabel: AA123 Boards
	boardTimeLabel: 15:06
	flightLabel: Flight 123
	gateLabel: Gate 1A
	routeLabel: MAN to SFO
	seatLabel: Seat 64A
	statusLabel: On time
在运行之前,有一件事情要做。本教程的实例app专为42mm的Apple Watch开发的,所以你需要确保正确设置了模拟器,否则界面元素看起来会有点小。对于一个现实app,需要确保界面能很好运行在两种大小的手表上,但这在本教程的范围之外。

在Xcode中,选择Window\Devices打开设备管理器,点击右下角的 + 图标.在弹出的对话框中,命名模拟器为iPhone 6 - 42mm,设置设备类型为iPhone 6,修改配对的Apple watch为Apple Watch - 42mm (WatchOS 2.0)然后点击Create:


{% img /images/watchOS024.png Caption %}  

关闭设备管理器,选择Watch Scheme,然后选中新的模拟器:


{% img /images/watchOS025.png Caption %}  

编译运行。一段模拟器启动完成你会看到下面界面:


{% img /images/watchOS026.png Caption %}  

> 注意:如果收到一条错误消息,说明安装失败,然后你可以再次尝试使用Xcode,或者在手表模拟器上手动安装app。为此,打开iOS模拟器中的手表app,点击AirAber,在Apple Watch弹出我们的app。一旦这么做了,返回手表模拟器,按Shift + Ctrl + H导航到主界面, 然后点击AirAber图片来启动手表app。

恭喜!你已经完成WatchKit初始界面,并使用真实的数据使它很好运行在手表模拟器上。

稍后会做什么?

下面是这个系列教程完整示例项目。

在这个练习中你已经学会了如何往现有的iOS app中添加手表app，如何创建一个界面控制器和使用嵌套组构造一个非常复杂的界面，以及使用WKInterfaceController类来配合这项工作。那么，接下来呢？

本教程系列的第二部分，你将学习所有关于表和导航WatchKit的使用。