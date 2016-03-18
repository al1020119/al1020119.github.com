---
layout: post
title: "ffmpeg+kxmovie"
date: 2016-01-11 16:21:08 +0800
comments: true
categories: Audio-Video
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---



首先申明这里虽然是关于ios开发中视频开发，但是并不会涉及到什么苹果官方的视频框架，这里主要将目前比较主流的两个第三方，如果你需要了解苹果相关请参考：[API预览](http://objccn.io/issue-24-4/)

好了开始吧！

首先介绍两个概念：

* FFmpeg：是一套可以用来记录、转换数字音频、视频，并能将其转化为流的开源计算机程序。采用LGPL或GPL许可证。它提供了录制、转换以及流化音视频的完整解决方案。它包含了非常先进的音频/视频编解码库libavcodec，为了保证高可移植性和编解码质量，libavcodec里很多codec都是从头开发的。

* kxmovie：在FFmpeg基础上封装的一套OC的框架，非常好用么热切很强大！

##一：编译针对iOS平台的ffmpeg库（kxmovie）
近期有一个项目，需要播放各种格式的音频、视频以及网络摄像头实时监控的视频流数据，经过多种折腾之后，最后选择了kxmovie，kxmovie项目已经整合了ffmpeg和简单的播放器，具体可以参考kxmovie主页：https://

+ github.com/kolyvan/kxmovie 
	- 编译kxmovie很简单，已经支持iOS 6.1 和 armv7s，一次成功，编译过程没出现什么问题：
+ git clone git://github.com/kolyvan/kxmovie.git
+ cd kxmovie
+ git submodule update --init 
+ rake




<!--more-->


##二：编译ffmpeg
要使用FFMPEG，首先需要理解FFMPEG的代码结构。根据志哥的提示，ffmpeg的代码是包括两部分的，一部分是library，一部分是tool。api都是在library里面，如果直接调api来操作视频的话，就需要写c或者c++了。另一部分是tool，使用的是命令行，则不需要自己去编码来实现视频操作的流程。实际上tool只不过把命令行转换为api的操作而已。

1. 到https://github.com/gabriel/ffmpeg-iphone-build下载ffmpeg-iphone-build
2. 先将gas-preprocessor.pl拷贝到/usr/sbin/目录中。
3. 到这里下载最新的ffmpeg:http://ffmpeg.org/download.html或者命令行安装：git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg

下载一个事例工程：git clone git://github.com/lajos/iFrameExtractor.git
然后到命令行下到ffmpeg的目录下，执行：
自己修改一下对应自己的SDK就可以了，我这儿是4.2

#####模拟器
 
	./configure –disable-doc –disable-ffmpeg –disable-ffplay –disable-ffserver –disable-avfilter –disable-debug –disable-encoders
	–enable-cross-compile –disable-decoders –disable-armv5te –enable-decoder=h264 –enable-pic
	–cc=/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/gcc –as='gas-preprocessor/gas-preprocessor.pl
	/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/gcc'
	–extra-ldflags=-L/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator4.2.sdk/usr/lib/system
	–sysroot=/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator4.2.sdk –target-os=darwin –arch=i386
	–cpu=i386 –extra-cflags='-arch i386' –extra-ldflags='-arch i386' –disable-asm

 ***
 
 
#####真机
	./configure –
	cc=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/gcc 
	–as='gas-preprocessor.pl 
	/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/gcc' –
	sysroot=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPh
	oneOS4.2.sdk –extra-ldflags=-
	L/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.
	2.sdk/usr/lib/system –target-os=darwin –arch=arm –cpu=cortex-
	a8 –extra-cflags='-arch armv7' –extra-ldflags='-arch armv7' –
	enable-pic –enable-cross-compile –enable-ffmpeg –disable-
	ffplay –disable-ffserver –disable-asm –disable-encoders –
	disable-decoders –enable-decoder=h264 –enable-decoder=mjpeg –
	enable-decoder=mpeg4 –disable-doc


> 注意了，上面有–disable-asm \，这是没办法的，禁用了汇编，这样应该是会影响效率的，如果不禁用就编译不通过。谁有更好的办法不禁用，麻烦分享一下。

一般是ok的，如果提示permission deny，那就chmod 777 configure（这个情况是我同事在windows上改了这个文件）



然后就make,完了再make install一下，如果出现权限不够使用 sudo make install，然后输入密码；
如果给代码做了修改，就先make clean,然后make一下
使用Finder，前往文件夹，输入/usr/local
然后把lib和include放到你的工程中，你可以在你的工程根目录下创建一个叫ffmpeg的文件夹，把lib和linclude里面的东西放进去

+ 工程中制定head file path :"$(SRCROOT)/ffmpeg/include"   这样编译就可以通过了
+ 工程中制定library file path :"$(SRCROOT)/ffmpeg/lib"   这样编译就可以通过了
+ 然后，打开iFrameExtractor这个工程，在ffmpeg这个文件夹建一个lib文件夹，把之前拷贝（就这个cp -rf lib* /src）出来的.a文件全部丢进去。为什么要这么做呢？应为iFrameExtractor里面的ffmpeg版本比较老，所以我没有编译它，没有编译，就不会产生一个lib文件夹。
 
如果编译出现问题，大部分的情况应该是类库没有导入完全，在target里面改入一下类库就可以了。
然后在link binary with library中导入这些.a文件和libbz.2.1.0.dylib。
然后插上真机，运行工程，ok，成功啦！！！看下面的图片。
	 

##三：使用kxmovie

先来看张我这里demo的图片：

{% img /images/kxmovie001.png Caption %}  

所以下面你需要：

+ 1.把kxmovie/output文件夹下文件添加到工程
+ 2.添加框架：MediaPlayer, CoreAudio, AudioToolbox, Accelerate, QuartzCore, OpenGLES and libz.dylib，libiconv.dylib
+ 3.添加lib库：libkxmovie.a, libavcodec.a, libavformat.a, libavutil.a, libswscale.a, libswresample.a
+ 4.播放视频:

列如：

	ViewController *vc;
	    vc = [KxMovieViewController movieViewControllerWithContentPath:path parameters:nil];
	    [self presentViewController:vc animated:YES completion:nil]; 
+ 5.具体使用参考demo工程:KxMovieExample

附上一段作者使用的案例：

	#pragma mark - Table view delegate
	
	- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    NSString *path;
	    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	    
	    if (indexPath.section == 0) {
	        
	        if (indexPath.row >= _remoteMovies.count) return;
	        path = _remoteMovies[indexPath.row];
	        
	    } else {
	
	        if (indexPath.row >= _localMovies.count) return;
	        path = _localMovies[indexPath.row];
	    }
	    
	    // increase buffering for .wmv, it solves problem with delaying audio frames
	    if ([path.pathExtension isEqualToString:@"wmv"])
	        parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
	    
	    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
	    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
	    
	    // disable buffering
	    //parameters[KxMovieParameterMinBufferedDuration] = @(0.0f);
	    //parameters[KxMovieParameterMaxBufferedDuration] = @(0.0f);
	    
	    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:path
	                                                                               parameters:parameters];
	    [self presentViewController:vc animated:YES completion:nil];
	    //[self.navigationController pushViewController:vc animated:YES];    
	
	    LoggerApp(1, @"Playing a movie: %@", path);
	}


##四：碰到的问题

######1.播放本地视频和网络视频正常，播放网络摄像头实时监控视频流（h264）的时候出现错误：

	[rtsp @ 0x906cc00] UDP timeout, retrying with TCP
	[rtsp @ 0x906cc00] Nonmatching transport in server reply
	[rtsp @ 0x906cc00] Could not find codec parameters for stream 0 (Video: h264): unspecified size
	Consider increasing the value for the 'analyzeduration' and 'probesize' options
	Couldn't find stream information
跟踪代码，错误是在avformat_find_stream_info获取流信息失败的时候的时候触发。
 
	if(avformat_find_stream_info(pFormatCtx,NULL) < 0) {
	    av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information\n");
	    goto initError;
	}
经过几天的摸索，最终确定是网络的问题（在模拟器播放一直出错，在3G网络下能播放iOS使用ffmpeg播放rstp实时监控视频数据流），具体原因估计是rstp视频流，程序默认采用udp传输或者组播，导致在私有网络视频流不能正常传输。
解决方法，把视频流的传输模式强制成tcp传输：
 
	// Open video file
	pFormatCtx = avformat_alloc_context();  
	//有三种传输方式：tcp udp_multicast udp，强制采用tcp传输
	AVDictionary* options = NULL;
	av_dict_set(&options, "rtsp_transport", "tcp", 0);
	if(avformat_open_input(&pFormatCtx, [moviePath cStringUsingEncoding:NSASCIIStringEncoding],                              NULL, &options) != 0) {
	    av_log(NULL, AV_LOG_ERROR, "Couldn't open file\n");
	    goto initError;
	}
	// Retrieve stream information
	if(avformat_find_stream_info(pFormatCtx,NULL) < 0) {
	    av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information\n");
	    goto initError;
	    }
 

问题解决。iOS使用ffmpeg播放rstp实时监控视频数据流

######2、time.h重复问题

　　我们知道一般静态库都是搭配头文件使用的，要在项目里面使用FFmpeg库，我们出了需要在xcode的build phases中添加静态库以外，还需要导入该库对应的头文件。FFmpeg库对应的头文件有很多，通常会采用设置header search path的方式来导入头文件，这样做有两个好处: 第一可以避免对我们的工程结构造成干扰。第二可以在一定程序上降低头文件冲突。

　　time.h冲突的问题就是属于头文件冲突，系统的标准库中有time.h文件，FFmpeg应该是在1.1之后也加入了一个time.h文件，路径为libavutil/time.h。所以如果你使用的是FFmpeg1.1之后的版本，那么在使用中就可能会碰到头文件冲突的问题。解决这个问题，网上流传一个方法是修改FFmpeg库中time.h文件的名字，我觉得这太麻烦了，而且也容易出错。后来查看FFmpeg源码的时候偶然发现它自身内部引用这个time.h的时候都有带一层父目录，如#include "libavutil/time.h"。因此想是不是通过指定头文件搜索路径就可以解决这个问题。

　　打开工程设置页面，搜索header search path如下图所示:


{% img /images/kxmovie002.png Caption %}  


　　如果你的FFmpeg库正好是放在当前的路径下，且为了偷懒设置了递归包含头文件的话，那么你很可能就会遇到time.h冲突的问题。因为xcode工程默认的设置是优先查找用户路径，编译时FFmpeg中libavutil下的time.h就会优先被链接，从而导致不会再链接系统time.h文件，最终导致编译失败。

　　解决这个问题有两个办法:

+ a、取消掉Header Search Paths中的递归引用。

+ b、设置Always Search User Paths为NO。

 

######3、gcc c compiletest error问题
　　xcode5下面编译FFmpeg都采用clang，同样也会遇到类似问题。这个问题通常出现在配置文件错误的情况下，一般都是gcc路径错误，当然也可能是其他编译参数错误问题。

　　出现这个问题我们应该首先检查gcc的路径是否正确，如果确认了指定路径上存在gcc程序，但是还是报错的，我们再去检查当前要编译的平台和指定的gcc路径是否一致，如果你使用iPhoneOS.platform下面的gcc去编译i386平台的库那肯定是不会测试通过的。

 

######4、C compiler test failed问题
　　编译i386版本的FFmpeg库和armv版本库可能用到的参数不尽相同，例如我遇到这个问题，我的编译选项中有一项如下:

　　--extra-cflags='-arch i386 -mfloat-abi=softfp -miphoneos-version-min=5.0'

　　在我确认其他参数(如cpu，arch)都正确的情况下，依然提示我们“C compiler test failed.” 后面紧跟着一句查看config.log你可以得到更详细的信息，于是打开该文件，你可以在最开始的地方看到你的配置语句，如果是用脚本，这块儿会显示最终解释后(替换参数为真实值)的配置语句。然后紧跟着一堆具体的配置，通常哭啼的错误信息会在该文件的最末尾。我遇到的问题的信息如下:

{% img /images/kxmovie003.png Caption %}  

　　看到标红的这个区域了没有，提示“-mfloat-abi=softfp”选项不支持，删掉该选项后，在运行时配置就通过了。其他配置问题，都可以通过查看config.log来获取更详细的错误信息。

 
######5、由于未导入libbz动态库的问题

　　如果导入FFmpeg库了，并且配置了头文件搜索路径，遇到"Undefined symbols for architecture armv7s: _BZ2_bzDecompressInit"，如下图所示:


{% img /images/kxmovie004.png Caption %}  

　　这个问题是由于没有导入“libbz2.dylib”库的原因，导入库即可解决该问题。

 

######6、libavcodec/audioconvert.h头文件缺失问题

　　不知道为什么执行make install的时候libavcodec中的audioconvert.h怎么没有拷贝到include目录下的libavcodec中去，查看发现原来libavutil目录下已经有一个audioconvert.h了。解决这个问题只需要从FFmpeg库的libavcodec中拷贝audioconvert.h头文件到include的libavcodec目录中即可解决。

 


##五：国外靠谱的有这几个：
1、[Mooncatventures group](https://github.com/mooncatventures-group) 

2、[KxMoviePlayer (use OpenGLES, Core Audio)](https://github.com/kolyvan/kxmovie) 

3、[FFmpeg for ios (with OpenGLES, AudioQueue)](https://github.com/flyhawk007/FFmpeg-for-iOS.git) 

4、[iFrameExtractor](https://github.com/lajos/iFrameExtractor.git)

当然还有ffmpeg自带的ffplay，如果想学习ffplay可以参考[ffmpeg tutorial](http://dranger.com/ffmpeg/)

中文版连接：[http://download.csdn.net/detail/dayudian/4600783](http://download.csdn.net/detail/dayudian/4600783)（这个好多地方都有，可以自己搜索）


###这里借助objc中国里面的一个篇视频音频汇总：

流媒体，播放在线视频/音频 并且边放边下载


iOS 和 OS X 平台都有一系列操作音频的 API，其中涵盖了从低到高的全部层级。随着时间的推移、平台的增长以及改变，不同 API 的数量可以说有着非常巨大的变化。本文对当前可以使用的 API 以及它们使用的不同目的进行简要的概括。
####Media Player 框架

Media Player 框架是 iOS 平台上一个用于音频和视频播放的高层级接口，它包含了一个你可以在应用中直接使用的默认的用户界面。你可以使用它来播放用户在 iPod 库中的项目，或者播放本地文件以及网络流。

> 另外，这个框架也包括了查找用户媒体库中内容的 API，同时还可以配置像是在锁屏界面或者控制中心里的音频控件。
####AVFoundation

AVFoundation 是苹果的现代媒体框架，它包含了一些不同的用途的 API 和不同层级的抽象。其中有一些是现代 Objective-C 对于底层 C 语言接口的封装。除了少数的例外情况，AVFoundation 可以同时在 iOS 和 OS X 中使用。
####AVAudioSession

AVAudioSession 是用于 iOS 系统中协调应用程序之间的音频播放的 API 的。例如，当有电话打进来时，音频的播放就会被暂停；在用户启动电影时，音乐的播放就会停止。我们需要使用这些 API 来确保一个应用程序能够正确响应并处理这类事件。
####AVAudioPlayer

这个高层级的 API 为你提供一个简单的接口，用来播放本地或者内存中的音频。这是一个无界面的音频播放器 (也就是说没有提供 UI 元素)，使用起来也很直接简单。它不适用于网络音频流或者低延迟的实时音频播放。如果这些问题都不需要担心，那么 AVAudioPlayer 可能就是正确的选择。音频播放器的 API 也为我们带来了一些额外的功能，比如循环播放、获取音频的音量强度等等。
####AVAudioRecorder

作为与 AVAudioPlayer 相对应的 API，AVAudioRecorder 是将音频录制为文件的最简单的方法。除了用一个音量计接受音量的峰值和平均值以外，这个 API 简单粗暴，但要是你的使用场景很简单的话，这可能恰恰就是你想要的方法。
####AVPlayer

AVPlayer 与上面提到的 API 相比，提供了更多的灵活性和可控性。它基于 AVPlayerItem 和 AVAsset，为你提供了颗粒度更细的权限来获取资源，比如选择指定的音轨。它还通过 AVQueuePlayer 子类支持播放列表，而且你可以控制这些资源是否能够通过 AirPlay 发送。

与 AVAudioPlayer 最主要的区别是，AVPlayer 对来自网络的流媒体资源的 “开箱即用” 支持。这增加了处理播放状态的复杂性，但是你可以使用 KVO 来观测所有的状态参数来解决这个问题。
####AVAudioEngine

AVAudioEngine 是播放和录制的 Objective-C 接口。它提供了以前需要深入到 Audio Toolbox 框架的 C API 才能做的控制 (例如一些实时音频任务)。该音频引擎 API 对底层的 API 建立了优秀的接口。如果你不得不处理底层的问题，你仍然可以使用 Audio Toolbox 框架。

这个 API 的基本概念是建立一个音频的节点图，从源节点 (播放器和麦克风) 以及过处理 (overprocessing) 节点 (混音器和效果器) 到目标节点 (硬件输出)。每一个节点都具有一定数量的输入和输出总线，同时这些总线也有良好定义的数据格式。这种结构使得它非常的灵活和强大。而且它集成了音频单元 (audio unit)。
####Audio Unit 框架

Audio Unit 框架是一个底层的 API；所有 iOS 中的音频技术都构建在 Audio Unit 这个框架之上。音频单元是用来加工音频数据的插件。一个音频单元链叫做音频处理图。

如果你需要非常低的延迟 (如 VoIP 或合成乐器)、回声消除、混音或者音调均衡的话，你可能需要直接使用音频单元，或者自己写一个音频单元。但是其中的大部分工作可以使用 AVAudioEngine 的 API 来完成。如果你不得不写自己的音频单元的话，你可以将它们与 AVAudioUnit 节点一起集成在 AVAudioEngine 处理图中。
####跨应用程序音频

Audio Unit 的 API 可以在 iOS 中进行跨应用音频。音频流 (和 MIDI 命令) 可以在应用程序之间发送。比如说：一个应用程序可以提供音频的效果器或者滤波器。另一个应用程序可以将它的音频发送到第一个应用程序中，并使用其中的音频效果器处理音频。被过滤的音频又会被实时地发送回原来的应用程序中。 CoreAudioKit 提供了一个简单的跨应用程序的音频界面。
###其他 APIs
####OpenAL

OpenAL 是一个跨平台的 API。它提供了位置 (3D) 和低延迟的音频服务。它主要用于跨平台游戏的开发。它有意地模仿了 OpenGL 中 API 的风格。
####MIDI

在 iOS 上，Core MIDI 和 CoreAudioKit 可以被用来使应用程序表现为 MIDI 设备。在 OS X 上，Music Sequencing 服务提供了基于 MIDI 的控制和对音乐数据访问的权限。Core MIDI 服务为服务器和驱动程序提供了支持。
更多

    在 OS X 中，最基本的音频接口就是 NSBeep()，它能够简单地播放系统中的声音。
    NSSound 类为 OS X 提供了用于播放声音的简单接口，与 iOS 中的 AVAudioPlayer 在概念上基本类似。
    所有的通知 API，包括 iOS 中的本地通知或者推送通知、OS X 中的 NSUserNotification 以及 CloudKit 通知，都可以播放声音。
    Audio Toolbox 框架是强大的，但是它的层级却非常的低。在过去，它基于 C++ 所编写，但是其大多数的功能现在都可以通过 AVFoundation 实现。
    QTKit 和 QuickTime 框架现在已经过时了，它们不应该被用在以后的开发中。我们应该使用 AVFoundation (和 AVKit) 来代替它们。
