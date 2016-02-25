---
layout: post
title: "图片优化-总结"
date: 2016-01-15 1:21:08 +0800
comments: true
categories: Summary
---




主要针对问题

+ 图片文件比较大

+ 图片文件比较多


####网络图片显示大体步骤:

* 下载图片
* 图片处理（裁剪，边框等)
* 写入磁盘
* 从磁盘读取数据到内核缓冲区
* 从内核缓冲区复制到用户空间(内存级别拷贝)
* 解压缩为位图（耗cpu较高）
* 如果位图数据不是字节对齐的，CoreAnimation会copy一份位图数据并进行字节对齐
* CoreAnimation渲染解压缩过的位图
* 以上4，5，6，7，8步是在UIImageView的setImage时进行的，所以默认在主线程进行(iOS UI操作必须在主线程执行)。


<!--more-->




####一些优化思路：

* 异步下载图片
* image解压缩放到子线程
* 使用缓存 (包括内存级别和磁盘级别)
* 存储解压缩后的图片，避免下次从磁盘加载的时候再次解压缩
* 减少内存级别的拷贝 （针对第5点和第7点）
* 良好的接口（比如SDWebImage使用category）
* Core Data vs 文件存储
* 图片预下载



在IOS下通过URL读一张网络图片并不像其他编程语言那样可以直接把图片路径放到图片路径的位置就ok，而是需要我们通过一段类似流的方式去加载网络图片，接着才能把图片放入图片路径显示。比如：
 
	-(UIImage *) getImageFromURL:(NSString *)fileURL {
	  //NSLog(@"执行图片下载函数");    
	  UIImage * result;    
	  NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
	  result = [UIImage imageWithData:data];    
	  return result;
	}

加载网络图片可以说是网络应用中必备的。如果单纯的去下载图片，而不去做多线程、缓存等技术去优化，加载图片时的效果与用户体验就会很差。

优化思路为：

（1）本地缓存

（2）异步加载

（3）加载完毕前使用占位图片


###优化方法



#####方法1：用NSOperation开异步线程下载图片，当下载完成时替换占位图片

	#import "XNViewController.h"
	#import "XNApp.h"
	 
	@interface XNViewController ()
	@property (nonatomic, strong) NSArray *appList;
	@property (nonatomic, strong) NSOperationQueue *queue;
	@end
	 
	@implementation XNViewController
	#pragma mark - 懒加载
	 
	- (NSOperationQueue *)queue {
	    if (!_queue) _queue = [[NSOperationQueue alloc] init];
	    return _queue;
	}
	 
	//可抽取出来写到模型中
	- (NSArray *)appList {
	    if (!_appList) {
	        //1.加载plist到数组中
	        NSURL *url = [[NSBundle mainBundle] URLForResource:@"apps.plist" withExtension:nil];
	        NSArray *array = [NSArray arrayWithContentsOfURL:url];
	        //2.遍历数组
	        NSMutableArray *arrayM = [NSMutableArray array];
	        [array enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
	            [arrayM addObject:[XNApp appWithDict:obj]];  //数组中存放的是字典, 转换为app对象后再添加到数组
	        }];
	        _appList = [arrayM copy];
	    }
	    return _appList;
	}
	 
	- (void)viewDidLoad {
	    [super viewDidLoad];
	 
	    self.tableView.rowHeight = 88;
	 
	//    NSLog(@"appList-%@",_appList);
	}
	 
	#pragma mark - 数据源方法
	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	    return self.appList.count;
	}
	 
	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	    static NSString *ID = @"Cell";
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
	 
	    //用模型来填充每个cell
	    XNApp *app = self.appList[indexPath.row];
	    cell.textLabel.text = app.name;  //设置文字
	 
	    //设置图像: 模型中图像为nil时用默认图像,并下载图像. 否则用模型中的内存缓存图像.
	    if (!app.image) {
	        cell.imageView.image = [UIImage imageNamed:@"user_default"];
	 
	        [self downloadImg:indexPath];
	    }
	    else {
	        //直接用模型中的内存缓存
	        cell.imageView.image = app.image;
	    }
	//  NSLog(@"cell--%p", cell);
	 
	    return cell;
	}
	 
	/**始终记住, 通过模型来修改显示. 而不要试图直接修改显示*/
	- (void)downloadImg:(NSIndexPath *)indexPath {
	    XNApp *app  = self.appList[indexPath.row]; //取得改行对应的模型
	 
	    [self.queue addOperationWithBlock: ^{
	        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:app.icon]]; //得到图像数据
	        UIImage *image = [UIImage imageWithData:imgData];
	 
	        //在主线程中更新UI
	        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
	            //通过修改模型, 来修改数据
	            app.image = image;
	            //刷新指定表格行
	            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	        }];
	    }];
	}
	 
	@end
上述代码只是做了内存缓存，还没有做本地缓存，因为这里这种方法不是重点，也不是首选方法。上面代码每次重新进入应用时，还会从网上重新下载。如果要继续优化上面的代码，需要自己去实现本地缓存。



#####方法2：使用第三方框架SDWebImage

依赖的库很少，功能全面。

自动实现磁盘缓存：缓存图片名字是以MD5进行加密的后的名字进行命名.(因为加密那堆字串是唯一的)

加载网络图片时直接设置占位图片：

	[imageView sd_setImageWithURL:imageurl  placeholderImage:[UIImage imageNamed:@”xxxxx”]]。

就一个方法就实现了多线程\带缓冲等效果.(可用带参数的方法,具体可看头文件)

	#pragma mark - 数据源方法
	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	    return self.appList.count;
	}
	 
	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	    static NSString *ID = @"Cell";
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
	 
	    //用模型来填充每个cell
	    XNApp *app = self.appList[indexPath.row];
	    cell.textLabel.text = app.name;  //设置文字
	 
	//  //设置图像: 模型中图像为nil时用默认图像,并下载图像. 否则用模型中的内存缓存图像.
	//  if (!cell.imageView.image) {
	//      cell.imageView.image = [UIImage imageNamed:@"user_default"];
	//
	//      [self downloadImg:indexPath];
	//  }
	//  else {
	//      //直接用模型中的内存缓存
	//      cell.imageView.image = app.image;
	//  }
	 
	 
	    //使用SDWebImage来完成上面的功能. 针对ImageView.
	    //一句话, 自动实现了异步下载. 图片本地缓存. 网络下载. 自动设置占位符.
	    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:app.icon] placeholderImage:[UIImage imageNamed:@"user_default"]];
	 
	 
	    return cell;
	}
	 
	/**始终记住, 通过模型来修改显示. 而不要试图直接修改显示*/
	//- (void)downloadImg:(NSIndexPath *)indexPath {
	//  XNApp *app  = self.appList[indexPath.row]; //取得改行对应的模型
	//
	//  [self.queue addOperationWithBlock: ^{
	//      NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:app.icon]]; //得到图像数据
	//      UIImage *image = [UIImage imageWithData:imgData];
	//
	//      //在主线程中更新UI
	//      [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
	//          //通过修改模型, 来修改数据
	//          app.image = image;
	//          //刷新指定表格行
	//          [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	//      }];
	//  }];
	//}
	 
	@end

如果你觉得SDWebImage不好用那么你可以试试FastImageCache这个框架：

FastImageCache是Path团队开发的一个开源库，用于提升图片的加载和渲染速度，让基于图片的列表滑动起来更顺畅，来看看它是怎么做的。

优化点

iOS从磁盘加载一张图片，使用UIImageVIew显示在屏幕上，需要经过以下步骤：

* 从磁盘拷贝数据到内核缓冲区
* 从内核缓冲区复制数据到用户空间
* 生成UIImageView，把图像数据赋值给UIImageView
* 如果图像数据为未解码的PNG/JPG，解码为位图数据
* CATransaction捕获到UIImageView layer树的变化
* 主线程Runloop提交CATransaction，开始进行图像渲染
    
    - 6.1 如果数据没有字节对齐，Core Animation会再拷贝一份数据，进行字节对齐。

    - 6.2 GPU处理位图数据，进行渲染。


FastImageCache分别优化了2,4,6.1三个步骤：

+ 使用mmap内存映射，省去了上述第2步数据从内核空间拷贝到用户空间的操作。
+ 缓存解码后的位图数据到磁盘，下次从磁盘读取时省去第4步解码的操作。
+ 生成字节对齐的数据，防止上述第6.1步CoreAnimation在渲染时再拷贝一份数据。

###常用的开源库对比

 |tip |	SDWebImage	 |AFNetworking |	FastImageCache |
| ------------- |:-------------:| -----:|
 |异步下载图片	 |YES |	YES	 |NO |
 |子线程解压缩	 |YES	 |YES |	YES |
 |子线程图片处理(缩放，圆角等)	 |YES |	YES |	YES |
 |存储解压缩后的位图	 |YES	 |YES	 |YES |
 |内存级别缓存	 |YES	 |YES	YES
 |磁盘级别缓存	 |YES |	YES |	YES |
 |UIImageView category |	YES |	NO |	NO |
 |减少内存级别的拷贝	 |NO	 |NO	 |YES |
 |接口易用性 |	*** |	*** |	* | 


###总结

* 使用低分辨率图：仔细想想，其实没有必要第一时间加载全部图片的高清原图，事先存好每张图配套的低分辨率图，用空间换时间。
先加载所有的图片的低分辨率图, 当用户翻阅到某一张图片时, 即时的加载原始尺寸的高清无码大图. 过程优化为：

* 多线程任务：即使是这样，当照片数量达到一定量时，需要消耗的时间也并非毫秒级，体验无法领人满意,  页面跳转时仍然会出现卡顿现象。
于是考虑使用多线程来进一步拆分任务， 执行跳转的同时再后台执行加载低分辨率图的步骤.

* 优化快速翻阅体验：通过这样的拆分，可以实现立即跳转，体验满意。但是翻阅浏览时，当用户很快左右滑动时, 出现黑屏的几率很高, 因为加载低分辨率图任务的线程可能还在进行大量IO操作，不能及时跟上。 为了完善它，要把加载低分辨率图的步骤再次分解，精益求精。 
在页面跳转时间允许的范围内，加载用户选定的那张图片的高清原图的同时，尽可能多的加载几张左右临近的图片的低分辨率图。


> 尽量减少内存占用.  因为原始图片要比低分辨率图大很多, 所以当用户从一张图片翻阅到另一张图片时,  当前图片加载为原始尺寸的高清大图, 而原来那张就被替换为低分辨率图了。 虽然读写次数增多了, 但内存确实省了不少。