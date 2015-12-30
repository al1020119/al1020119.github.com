---

layout: post
title: "性能优化小结"
date: 2013-12-25 13:53:19 +0800
comments: true
categories: Projects 

--- 




1. 用ARC管理内存
	ARC(Automatic Reference Counting, 自动引用计数)和iOS5一起发布，它避免了最常见的也就是经常是由于我们忘记释放内存所造成的内存泄露。它自动为你管理retain和release的过程，所以你就不必去手动干预了。
	除了帮你避免内存泄露，ARC还可以帮你提高性能，它能保证释放掉不再需要的对象的内存
2. 在正确的地方使用reuseIdentifier
	这个方法把那些已经存在的cell从队列中排除，或者在必要时使用先前注册的nib或者class创造新的cell。如果没有可重用的cell，你也没有注册一个class或者nib的话，这个方法返回nil。
3. 尽可能使Views不透明
	如果你有不透明的Views，你应该设置它们的opaque属性为YES。
	(opaque)这个属性给渲染系统提供了一个如何处理这个view的提示。如果设为YES， 渲染系统就认为这个view是完全不透明的，这使得渲染系统优化一些渲染过程和提高性能。如果设置为NO，渲染系统正常地和其它内容组成这个View。默认值是YES。

<!--more-->


在相对比较静止的画面中，设置这个属性不会有太大影响。然而当这个view嵌在scroll view里边，或者是一个复杂动画的一部分，不设置这个属性的话会在很大程度上影响app的性能。

你可以在模拟器中用Debug\Color Blended Layers选项来发现哪些view没有被设置为opaque。目标就是，能设为opaque的就全设为opaque!


4. 避免庞大的XIB（一次性加载）

	如果你不得不XIB的话，使他们尽量简单。尝试为每个Controller配置一个单独的XIB，尽可能把一个View Controller的view层次结构分散到单独的XIB中去。
	原因是这会使系统用一个最优的方式渲染这些views。这个简单的属性在IB或者代码里都可以设定。


	
	需要注意的是，当你加载一个XIB的时候所有内容都被放在了内存里，包括任何图片。如果有一个不会即刻用到的view，你这就是在浪费宝贵的内存资源了。Storyboards就是另一码事儿了，storyboard仅在需要时实例化一个view controller.
	
	当家在XIB是，所有图片都被chache，如果你在做OS X开发的话，声音文件也是。Apple在相关文档中的记述是：
	当你加载一个引用了图片或者声音资源的nib时，nib加载代码会把图片和声音文件写进内存。在OS X中，图片和声音资源被缓存在named cache中以便将来用到时获取。在iOS中，仅图片资源会被存进named caches。取决于你所在的平台，使用NSImage 或UIImage 的`imageNamed:`方法来获取图片资源。

5. 不要block主线程（主：UI）
	永远不要使主线程承担过多。因为UIKit在主线程上做所有工作，渲染，管理触摸反应，回应输入等都需要在它上面完成
	大部分阻碍主进程的情形是你的app在做一些牵涉到读写外部资源的I/O操作，比如存储或者网络。

你可以使用`NSURLConnection`异步地做网络操作:
或者使用像 AFNetworking这样的框架来异步地做这些操作。

如果你需要做其它类型的需要耗费巨大资源的操作(比如时间敏感的计算或者存储读写)那就用 Grand Central Dispatch，或者 NSOperation 和 NSOperationQueues.
	
6. 在Image Views中调整图片大小(与控件对应)
	如果要在`UIImageView`中显示一个来自bundle的图片，你应保证图片的大小和UIImageView的大小相同。在运行中缩放图片是很耗费资源的，特别是`UIImageView`嵌套在`UIScrollView`中的情况下。

	如果图片是从远端服务加载的你不能控制图片大小，比如在下载前调整到合适大小的话，你可以在下载完成后，最好是用background thread，缩放一次，然后在UIImageView中使用缩放后的图片。
7. 选择正确的Collection（Arrays: 有序的一组值。使用index来lookup很快，使用value lookup很慢， 插入/删除很慢。Dictionaries: 存储键值对。 用键来查找比较快。Sets: 无序的一组值。用值来查找很快，插入/删除很快。）
8. 打开gzip压缩 （服务端和你的app）
	好消息是，iOS已经在NSURLConnection中默认支持了gzip压缩，当然AFNetworking这些基于它的框架亦然。像Google App Engine这些云服务提供者也已经支持了压缩输出
9. 重用和延迟加载Views
	这里我们用到的技巧就是模仿`UITableView`和`UICollectionView`的操作: 不要一次创建所有的subview，而是当需要时才创建，当它们完成了使命，把他们放进一个可重用的队列中。
	
	这样的话你就只需要在滚动发生时创建你的views，避免了不划算的内存分配。
	
	创建views的能效问题也适用于你app的其它方面。想象一下一个用户点击一个按钮的时候需要呈现一个view的场景。有两种实现方法：
	
	1. 创建并隐藏这个view当这个screen加载的时候，当需要时显示它；
	2. 当需要时才创建并展示。
	每个方案都有其优缺点。
	
	用第一种方案的话因为你需要一开始就创建一个view并保持它直到不再使用，这就会更加消耗内存。然而这也会使你的app操作更敏感因为当用户点击按钮的时候它只需要改变一下这个view的可见性。
	
	第二种方案则相反-消耗更少内存，但是会在点击按钮的时候比第一种稍显卡顿。


10. Cache, Cache, 还是Cache！（NSCache：系统回收内存的时候它会自动删掉它的内容）
	你可以通过 NSURLConnection 获取一个URL request， AFNetworking也一样的。这样你就不必为采用这条tip而改变所有的networking代码了。
	如果你需要缓存其它不是HTTP Request的东西，你可以用NSCache。
11. 权衡渲染方法（CALayer， CoreGraphics，OpenGL，Metal：性能能&bundle大小）
12. 处理内存警告
	 在app delegate中使用`applicationDidReceiveMemoryWarning:` 的方法
	在你的自定义UIViewController的子类(subclass)中覆盖`didReceiveMemoryWarning`
	注册并接收 UIApplicationDidReceiveMemoryWarningNotification 的通知
一旦收到这类通知，你就需要释放任何不必要的内存使用。
	UIViewController的默认行为是移除一些不可见的view， 它的一些子类则可以补充这个方法，删掉一些额外的数据结构。一个有图片缓存的app可以移除不在屏幕上显示的图片。
	
	这样对内存警报的处理是很必要的，若不重视，你的app就可能被系统杀掉。
	
	然而，当你一定要确认你所选择的object是可以被重现创建的来释放内存。一定要在开发中用模拟器中的内存提醒模拟去测试一下。
13. 重用大开销的对象
	还需要注意的是，其实设置一个NSDateFormatter的速度差不多是和创建新的一样慢的！所以如果你的app需要经常进行日期格式处理的话，你会从这个方法中得到不小的性能提升。
14. 使用Sprite Sheets（渲染速度加快，甚至比标准的屏幕渲染方法节省内存。）
15. 避免反复处理数据（从特定key中取数据，那么就使用键值对的dictionary）
	 你需要数据来展示一个table view,最好直接从服务器取array结构的数据以避免额外的中间数据结构改变。
16. 选择正确的数据格式（JSON和XML）
	解析JSON会比XML更快一些，JSON也通常更小更便于传输。从iOS5起有了官方内建的JSON deserialization 就更加方便使用了。

	但是XML也有XML的好处，比如使用SAX 来解析XML就像解析本地文件一样，你不需像解析json一样等到整个文档下载完成才开始解析。当你处理很大的数据的时候就会极大地减低内存消耗和增加性能
17. 正确地设定Background Images（colorWithPatternImage，UIImageView）
	 如果你使用全画幅的背景图，你就必须使用UIImageView因为UIColor的colorWithPatternImage是用来创建小的重复的图片作为背景的。这种情形下使用UIImageView可以节约不少的内存：
 
	如果你用小图平铺来创建背景，你就需要用UIColor的colorWithPatternImage来做了，它会更快地渲染也不会花费很多内存：
18. 减少使用Web特性（不像驱动Safari的那么快，尽可能移除不必要的javascript，避免使用过大的框架。能只用原生js就更好了）
	另外，尽可能异步加载例如用户行为统计script这种不影响页面表达的javascript。

	最后，永远要注意你使用的图片，保证图片的符合你使用的大小。使用Sprite sheet提高加载速度和节约内存。
19. 设定Shadow Path（QuartzCore：Core Animation不得不先在后台得出你的图形并加好阴影然后才渲染，这开销是很大的。）
	使用shadow path的话iOS就不必每次都计算如何渲染，它使用一个预先计算好的路径。但问题是自己计算path的话可能在某些View中比较困难，且每当view的frame变化的时候你都需要去update shadow path.

20. 优化你的Table View

	正确使用`reuseIdentifier`来重用cells
	尽量使所有的view opaque，包括cell自身
	避免渐变，图片缩放，后台选人
	缓存行高
	如果cell内现实的内容来自web，使用异步加载，缓存请求结果
	使用`shadowPath`来画阴影
	减少subviews的数量
	尽量不适用`cellForRowAtIndexPath:`，如果你需要用到它，只用一次然后缓存结果
	使用正确的数据结构来存储数据
	使用`rowHeight`, `sectionFooterHeight` 和 `sectionHeaderHeight`来设定固定的高，不要请求delegate
21. 选择正确的数据存储选项 


	使用`NSUerDefaults`
	使用XML, JSON, 或者 plist
	使用NSCoding存档
	使用类似SQLite的本地SQL数据库
	使用 Core Data
	NSUserDefaults的问题是什么？虽然它很nice也很便捷，但是它只适用于小数据，比如一些简单的布尔型的设置选项，再大点你就要考虑其它方式了
	
	XML这种结构化档案呢？总体来说，你需要读取整个文件到内存里去解析，这样是很不经济的。使用SAX又是一个很麻烦的事情。
	
	NSCoding？不幸的是，它也需要读写文件，所以也有以上问题。
	
	在这种应用场景下，使用SQLite 或者 Core Data比较好。使用这些技术你用特定的查询语句就能只加载你需要的对象。
	
	在性能层面来讲，SQLite和Core Data是很相似的。他们的不同在于具体使用方法。Core Data代表一个对象的graph model，但SQLite就是一个DBMS。Apple在一般情况下建议使用Core Data，但是如果你有理由不使用它，那么就去使用更加底层的SQLite吧。
	
	如果你使用SQLite，你可以用FMDB(https://github.com/ccgus/fmdb)这个库来简化SQLite的操作，这样你就不用花很多经历了解SQLite的C API了。
	
22. 加速启动时间
尽可能做更多的异步任务，比如加载远端或者数据库数据，解析数据。

还是那句话，避免过于庞大的XIB，因为他们是在主线程上加载的。所以尽量使用没有这个问题的Storyboards吧！

注意，用Xcode debug时watchdog并不运行，一定要把设备从Xcode断开来测试启动速度


23. 使用Autorelease Pool
	
	 你创建很多临时对象，你会发现内存一直在减少直到这些对象被release的时候。这是因为只有当UIKit用光了autorelease pool的时候memory才会被释放。
	 
24. 选择是否缓存图片（一个是用`imageNamed`：当加载时会缓存图片，用一个指定的名字在系统缓存中查找并返回一个图片对象如果它存在的话。如果缓存中没有找到相应的图片，这个方法从指定的文档中加载然后缓存并返回这个对象，二是用`imageWithContentsOfFile`，仅加载图片）

	如果你要加载一个大图片而且是一次性使用，那么就没必要缓存这个图片，用`imageWithContentsOfFile`足矣，这样不会浪费内存来缓存它。
	
	然而，在图片反复重用的情况下`imageNamed`是一个好得多的选择。
25. 尽量避免日期格式转换（尽量选择Unix时间戳）
	许多web API会以微秒的形式返回时间戳，因为这种格式在javascript中更方便使用。记住用`dateFromUnixTimestamp`之前除以1000就好了。


***


tableView优化总结：

>卡顿：重用是否成功（自己写）—是否是多次请求-青花瓷（每次滚动）—github，博客，微博--Instruments三件套(Time Profiler,Core Animation,GPU Driver)—GPU-CPU-代码逻辑-1.cell高度没有缓存。2. refreshData（reloadData）2次。 3.懒加载View 4.圆角问题  5.尺寸对应  6.NSDateFormatter 7.UIImage缓存取舍 8.手动 Drawing（Cell 中 view 的组织复杂）9. UI 线程的时间 10.缓存一切可以缓存的！就是“用空间替换时间”！

1. 最常用的就是cell的重用， 注册重用标识符

	如果不重用cell时，每当一个cell显示到屏幕上时，就会重新创建一个新的cell
	如果有很多数据的时候，就会堆积很多cell。如果重用cell，为cell创建一个ID
	每当需要显示cell 的时候，都会先去缓冲池中寻找可循环利用的cell，如果没有再重新创建cell
	设置正确的reuseIdentifer以重用cell

2. 避免cell的重新布局

	cell的布局填充等操作 比较耗时，一般创建时就布局好
	如可以将cell单独放到一个自定义类，初始化时就布局好

3. 提前计算并缓存cell的属性及内容

	在cellForRowAtIndexPath:中尽量做更少的操作。如果需要做一些处理，那么最好做过一次之后，就将结果缓存起来。
	当我们创建cell的数据源方法时，编译器并不是先创建cell 再定cell的高度
	而是先根据内容一次确定每一个cell的高度，高度确定后，再创建要显示的cell，滚动时，每当cell进入凭虚都会计算高度，提前估算高度告诉编译器，编译器知道高度后，紧接着就会创建cell，这时再调用高度的具体计算方法，这样可以方式浪费时间去计算显示以外的cell

4. 减少cell中控件的数量

	尽量使cell得布局大致相同，不同风格的cell可以使用不用的重用标识符，初始化时添加控件，
	不适用的可以先隐藏

5. 不要使用ClearColor，无背景色，透明度也不要设置为0

	渲染耗时比较长
	尽量将view设置为不透明，包括cell本身。

6. 使用局部更新

	如果只是更新某组的话，使用reloadSection进行局部更新

7. 加载网络数据，下载图片，使用异步加载，并缓存

	如果cell显示的内容来此网络，那么确保这些内容是通过异步来获取的

8. 少使用addView 给cell动态添加view


9. 按需加载cell，cell滚动很快时，只加载范围内的cell

	注意正确使用懒加载

10. 不要实现无用的代理方法，tableView只遵守两个协议

	非必要的代理或者数据源方法可以省略，比如numberofsention

11. 缓存行高：

	如果row的高度不相同，那么将其缓存下来
	estimatedHeightForRow不能和HeightForRow里面的layoutIfNeed同时存在，这两者同时存在才会出现“窜动”的bug。所以我的建议是：只要是固定行高就写预估行高来减少行高调用次数提升性能。如果是动态行高就不要写预估方法了，用一个行高的缓存字典来减少代码的调用次数即可

12. 避免渐变，图像缩放以及离屏绘制

13. 使用shadowPath来设置阴影。

14. 使用适当的数据结构来保存需要的信息。不同的结构会带来不同的操作代价。

15. 使用rowHeight, sectionFooterHeight 和 sectionHeaderHeight 来设置一个恒定 高度，而不要从delegate中获取。

16. 使用富文本标签代价是很昂贵的

费尽周折用富文本标签，代价太昂贵了。尽可能地避免使用这个。问问你自己是否真的需要这个。如果是的话，尽可能的做缓存。


提前计算并缓存好高度（布局），因为heightForRowAtIndexPath:是调用最频繁的方法；
异步绘制，遇到复杂界面，遇到性能瓶颈时，可能就是突破口；
滑动时按需加载，这个在大量图片展示，网络加载的时候很管用！（SDWebImage已经实现异步加载，配合这条性能杠杠的）。
除了上面最主要的三个方面外，还有很多几乎大伙都很熟知的优化点：

* 正确使用reuseIdentifier来重用Cells
* 尽量使所有的view opaque，包括Cell自身
* 尽量少用或不用透明图层
* 如果Cell内现实的内容来自web，使用异步加载，缓存请求结果
* 减少subviews的数量
* 在heightForRowAtIndexPath:中尽量不使用cellForRowAtIndexPath:，如果你需要用到它，只用一次然后缓存结果
* 尽量少用addView给Cell动态添加View，可以初始化时就添加，然后通过hide来控制是否显示
* 尽量设置Cell的view为opaque，避免GPU对Cell下面的内容也进行绘制。
* 避免大量的图片缩放、颜色渐变等。
* 避免同步的从网络、文件获取数据（这个是必须的=。=）
* 用shadowPath创建阴影。
* 尽量减少subview的数量，如多用drawRect绘制元素，替代用view显示。
* 尽量显示“大小刚好合适”的图片资源。 


总的来说，就是：

* 缓存一切可以缓存的！就是“用空间替换时间”！

在UITableView的Delegate、DataSource方法中，减少任何不必要的操作

