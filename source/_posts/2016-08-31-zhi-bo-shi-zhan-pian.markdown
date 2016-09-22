---
layout: post
title: "直播-实战篇"
date: 2016-09-20 14:42:57 +0800
comments: true
categories: Audio  Video and Lve Radio
---


前言

在看这篇之前，如果您还不了解直播原理，请查看上篇文章如何快速的开发一个完整的iOS直播app(原理篇)

开发一款直播app，集成ijkplayer成功后，就算完成直播功能一半的工程了，只要有拉流url，就能播放直播啦

本篇主要讲解的是直播app中，需要用到的一个很重要的开源框架ijkplayer，然后集成这个框架可能对大多数初学者还是比较有难度的，所以本篇主要教你解决集成【ijkplayer】遇见的各种坑。



<!--more-->	



很多文章，可能讲解的是如何做，我比较注重讲解为什么这样做,大家有什么不明白，还可以多多提出来。

效果

{% img /images/zhiboshizhan001.gif Caption %} 
###一、基本知识

README.md文件：框架的描述文件，描述这个框架怎么使用

编译语言:程序在被执行之前，需要一个专门的编译过程，把程序编译成为机器语言的文件，运行时不需要翻译，所以编译型语言的程序执行效率高，比如OC,C,C++

解释性语言:解释性语言的程序不需要编译，在运行程序的时候才翻译，每个语句都是执行的时候才翻译。这样解释性语言每执行一次就需要逐行翻译一次，效率比较低

解释性语言执行和编译语言执行的区别：

    解释性语言一行一行的解析，如果有错误，就不会执行，直接执行下一行。
    编译语言，只要有错，就不能编译，一行都不能执行。

脚本语言:属于解析语言，必须通过解释器解析，将其一条条的翻译成机器可识别的指令，并按程序顺序执行。

    python：脚本语言，适合网络应用程序的开发，有利于开发效率，现在显得越来越强大
    PHP：服务器端脚本语言，适合做动态网站
    JS：作为客户端的脚本语言，在浏览中解释执行，
    shell：操作系统脚本语言，一般指Unix/Linux中使用的命令行
    编译语言，执行文件是二进制。脚本语言是解释执行的，执行文件是文本

shell解释器:shell是一个命令行解释器，相当于windows的cmd,处于内核和用户之间，负责把用户的指令传递给内核并且把执行结果回显给用户.

    默认Unix都有shell,OS基于Unix,因此OS自带shell。

bash: bash是一种shell解释器版本，shell有很多种版本，就像人，也分不同国家的人。

    牛程序员看到不爽的Shell解释器，就会自己重新写一套，慢慢形成了一些标准，常用的Shell解释器有这么几种，sh、bash、csh等

shell:通常我们说的shell,指的是shell脚本语言，而不是shell解释器。

    在编写shell时，第一行一定要指明系统需要哪种shell解释器解释你的shell脚本，如：#! /bin/bash，使用bash解析脚本语言
    什么时候使用shell命令，比如有些系统命令经常需要用到，可以把命令封装到一个脚本文件，以后就不用再敲一遍了，直接执行脚本语言。
    比如ijkplayer,就用脚本文件下载ffmpeg,因为下载ffmpeg需要执行很多命令，全部封装到脚本文件中。
    在导入一些第三方框架的时候，经常需要用到一些命令，所以一般都会封装到一个脚本文件中，以后只要执行脚本，就会自动执行集成第三方框架的命令。

sh:sheel脚本文件后缀名
###二、下载ijkPlayer

    去到B站得github主页，找到ijkplayer项目，下载源码 ijkplayer下载地址
    打开Demo，查看用法，一般学习第三方库，都是先查看Demo

{% img /images/zhiboshizhan002.png Caption %} 

###三、编译ijkPlayer的步骤
1、找到ijkPlayerMediaDemo并运行

    提示'libavformat/avformat.h' file not found


{% img /images/zhiboshizhan003.png Caption %} 

原因：因为libavformat是ffmpeg中的库，而ijkplayer是基于ffmpeg这个库的，因此需要导入ffmpeg

解决：查看ijkplayer的README.md，一般都会有说明。

{% img /images/zhiboshizhan004.png Caption %} 

init-ios.sh脚本的作用：下载ffmpeg源码

    想了解脚本具体怎么做的，可以查看之前写的文章带你走进脚本世界，ijkplayer之【init-ios.sh】脚本分析，全面剖析了init-ios.sh这个脚本做了哪些事情。

如何执行init-ios.sh脚本文件

    步骤一：找到init-ios.sh脚本文件


{% img /images/zhiboshizhan005.png Caption %} 

    步骤二：打开终端，cd进入到ijkplayer-master的目录中


{% img /images/zhiboshizhan006.png Caption %} 

    注意是 cd 这个文件夹


{% img /images/zhiboshizhan007.png Caption %} 

    步骤三：输入./init-ios.sh，就会执行当前脚本了。


{% img /images/zhiboshizhan008.png Caption %} 

    执行完脚本后，就会发现ijkplayer中有ffmpeg了


{% img /images/zhiboshizhan009.png Caption %} 
2、下载好ffmpeg源码后，再次运行Demo

    发现还是报'libavformat/avformat.h' file not found错误
    原因:执行init-ios.sh，仅仅是下载源码，但是源码并没有参与编译，需要把源码编译成.a文件
        Demo依赖于IJKMediaPlayer库


{% img /images/zhiboshizhan010.png Caption %} 

    打开 IJKMediaPlayer库，查看下源码


{% img /images/zhiboshizhan011.png Caption %} 

    打开 IJKMediaPlayer库

{% img /images/zhiboshizhan012.png Caption %} 

    右击，发现FFMPEG中的库都是红的，表示不存在

{% img /images/zhiboshizhan013.png Caption %} 

    解决:查看ijkplayer的README.md


{% img /images/zhiboshizhan014.png Caption %} 
编译ffmpeg库

    步骤一：进入到脚本文件的目录下

{% img /images/zhiboshizhan015.png Caption %} 

    步骤二：执行./compile-ffmpeg.sh clean
        步骤二功能：删除一些文件和文件夹，为编译ffmpeg.sh做准备，在编译ffmpeg.sh的时候，会自动创建刚刚删除的那些文件，为避免文件名冲突，因此在编译ffmpeg.sh之前先删除等会会自动创建的文件夹或者文件


{% img /images/zhiboshizhan016.png Caption %} 

    步骤三：执行./compile-ffmpeg.sh all,真正的编译各个平台的ffmpeg库，并生成所以平台的通用库.

{% img /images/zhiboshizhan017.png Caption %} 

执行./compile-ffmpeg.sh all
执行compile-ffmpeg.sh all前

{% img /images/zhiboshizhan018.png Caption %} 
执行compile-ffmpeg.sh all后

{% img /images/zhiboshizhan019.png Caption %} 
3.再次运行Demo,就能成功了,因为IJKMediaPlayer库获取到ffmpeg库了

    编译完ffmpeg后，IJKMediaPlayer库中显示

{% img /images/zhiboshizhan020.png Caption %} 

    cmd+r,Demo运行成功


{% img /images/zhiboshizhan021.png Caption %} 
###四、如何集成到ijkplayer到自己的项目中

    注意：ijkplayer的README中的方法比较麻烦，不方便携带，不推荐。


{% img /images/zhiboshizhan022.png Caption %} 
1.推荐自己把IJKMediaPlayer打包成静态库,在导入到自己的项目中。

    如何打包，请参考，iOS中集成ijkplayer视频直播框架，写的非常不错，就不一一详细介绍了,但是只有发布版本的库。
    我自己打包了ijkplayer两个版本库，分别用于调试和发布(DEBUG和Release),点击下载
    由于文件太大上传不了GitHUb,就上传到百度云了

2.直接把ijkplayer库拖入到自己的工程中，

    调试的话，拖入调试版本的ijkplayer库，发布的话，拖入发布版本的ijkplayer库


{% img /images/zhiboshizhan023.png Caption %} 
3.导入ijkplayer依赖的库，具体可以查看ijkplayer的README

{% img /images/zhiboshizhan024.png Caption %} 
{% img /images/zhiboshizhan025.png Caption %} 
###五、使用ijkplayer直播
1.ijkplayer用法简介

    ijkplayer用法比较简单，其实只要有直播地址，就能直播了
    注意：最好真机测试，模拟器测试比较卡,不流畅，真机就没有问题了

2.抓取数据

    抓了很多直播app的数据，发现映客主播的质量是最高的。
    映客主播url:http://116.211.167.106/api/live/aggregation?uid=133825214&interest=1
        uid=账号ID，这里是我的账号ID
        interest=兴趣 ，1表示只查看女生，哈哈
        上下拉刷新的接口没抓到，就一下加载200条数据，哈哈

	- (void)loadData
	{
	    // 映客数据url
	    NSString *urlStr = @"http://116.211.167.106/api/live/aggregation?uid=133825214&interest=1";
	
	    // 请求数据
	    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
	    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
	    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
	    [mgr GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
	
	        _lives = [YZLiveItem mj_objectArrayWithKeyValuesArray:responseObject[@"lives"]];
	
	        [_tableView reloadData];
	
	    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
	
	        NSLog(@"%@",error);
	
	    }];
	}

3.获取拉流url,直播

IJKFFMoviePlayerController：用来做直播的类

	- (void)viewDidLoad {
	    [super viewDidLoad];
	
	    self.view.backgroundColor = [UIColor whiteColor];
	
	    // 设置直播占位图片
	    NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",_live.creator.portrait]];
	    [self.imageView sd_setImageWithURL:imageUrl placeholderImage:nil];
	
	    // 拉流地址
	    NSURL *url = [NSURL URLWithString:_live.stream_addr];
	
	    // 创建IJKFFMoviePlayerController：专门用来直播，传入拉流地址就好了
	    IJKFFMoviePlayerController *playerVc = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:nil];
	
	    // 准备播放
	    [playerVc prepareToPlay];
	
	    // 强引用，反正被销毁
	    _player = playerVc;
	
	    playerVc.view.frame = [UIScreen mainScreen].bounds;
	
	    [self.view insertSubview:playerVc.view atIndex:1];
	
	}

4.结束播放

    界面不播放，一定要记得结束播放，否则会报内存溢出


{% img /images/zhiboshizhan026.png Caption %} 

	- (void)viewWillDisappear:(BOOL)animated
	{
	    [super viewWillDisappear:animated];
	
	    // 界面消失，一定要记得停止播放
	    [_player pause];
	    [_player stop];
	}

结束语

后续还会更新更多有关直播的资料，希望做到教会每一个朋友从零开始做一款直播app，并且Demo也会慢慢完善.
Demo点击下载

    由于FFMPEG库比较大，大概100M。
    本来想自己上传所有代码了，上传了1个小时，还没成功，就放弃了。
    提供另外一种方案，需要你们自己导入IJKPlayer库
    具体步骤：
    下载Demo后，打开YZLiveApp.xcworkspace问题


打开YZLiveApp.xcworkspace问题

{% img /images/zhiboshizhan027.png Caption %} 

    pod install就能解决


{% img /images/zhiboshizhan028.png Caption %} 

    下载jkplayer库，点击下载
    把jkplayer直接拖入到与Classes同一级目录下，直接运行程序，就能成功了


{% img /images/zhiboshizhan029.png Caption %} 

    注意不需要打开工程，把jkplayer拖入到工程中，而是直接把jkplayer库拷贝到与Classes同一级目录下就可以了。
    错误示范:不要向下面这样操作


{% img /images/zhiboshizhan030.png Caption %} 



===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  