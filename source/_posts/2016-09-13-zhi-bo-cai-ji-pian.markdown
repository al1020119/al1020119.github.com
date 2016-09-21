---
layout: post
title: "直播-采集篇"
date: 2016-09-25 16:46:26 +0800
comments: true
categories: 
---

前言

在看这篇之前，如果您还不了解直播原理，请查看这篇文章如何快速的开发一个完整的iOS直播app(原理篇)

开发一款直播app，首先需要采集主播的视频和音频，然后传入流媒体服务器，本篇主要讲解如何采集主播的视频和音频，当前可以切换前置后置摄像头和焦点光标,但是美颜功能还没做，可以看见素颜的你，后续还会有直播的其他功能文章陆续发布。

基本知识介绍

    AVFoundation: 音视频数据采集需要用AVFoundation框架.

    AVCaptureDevice：硬件设备，包括麦克风、摄像头，通过该对象可以设置物理设备的一些属性（例如相机聚焦、白平衡等）
    AVCaptureDeviceInput：硬件输入对象，可以根据AVCaptureDevice创建对应的AVCaptureDeviceInput对象，用于管理硬件输入数据。
    AVCaptureOutput：硬件输出对象，用于接收各类输出数据，通常使用对应的子类AVCaptureAudioDataOutput（声音数据输出对象）、AVCaptureVideoDataOutput（视频数据输出对象）
    AVCaptionConnection:当把一个输入和输出添加到AVCaptureSession之后，AVCaptureSession就会在输入、输出设备之间建立连接,而且通过AVCaptureOutput可以获取这个连接对象。
    AVCaptureVideoPreviewLayer:相机拍摄预览图层，能实时查看拍照或视频录制效果，创建该对象需要指定对应的AVCaptureSession对象，因为AVCaptureSession包含视频输入数据，有视频数据才能展示。
    AVCaptureSession: 协调输入与输出之间传输数据
        系统作用：可以操作硬件设备
        工作原理：让App与系统之间产生一个捕获会话，相当于App与硬件设备有联系了， 我们只需要把硬件输入对象和输出对象添加到会话中，会话就会自动把硬件输入对象和输出产生连接，这样硬件输入与输出设备就能传输音视频数据。
        现实生活场景：租客（输入钱），中介（会话），房东（输出房），租客和房东都在中介登记，中介就会让租客与房东之间产生联系，以后租客就能直接和房东联系了。

捕获音视频步骤:官方文档

    1.创建AVCaptureSession对象
    2.获取AVCaptureDevicel录像设备（摄像头），录音设备（麦克风），注意不具备输入数据功能,只是用来调节硬件设备的配置。
    3.根据音频/视频硬件设备(AVCaptureDevice)创建音频/视频硬件输入数据对象(AVCaptureDeviceInput)，专门管理数据输入。
    4.创建视频输出数据管理对象（AVCaptureVideoDataOutput），并且设置样品缓存代理(setSampleBufferDelegate)就可以通过它拿到采集到的视频数据
    5.创建音频输出数据管理对象（AVCaptureAudioDataOutput），并且设置样品缓存代理(setSampleBufferDelegate)就可以通过它拿到采集到的音频数据
    6.将数据输入对象AVCaptureDeviceInput、数据输出对象AVCaptureOutput添加到媒体会话管理对象AVCaptureSession中,就会自动让音频输入与输出和视频输入与输出产生连接.
    7.创建视频预览图层AVCaptureVideoPreviewLayer并指定媒体会话，添加图层到显示容器layer中
    8.启动AVCaptureSession，只有开启，才会开始输入到输出数据流传输。

// 捕获音视频

	- (void)setupCaputureVideo
	{
	    // 1.创建捕获会话,必须要强引用，否则会被释放
	    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
	    _captureSession = captureSession;
	
	    // 2.获取摄像头设备，默认是后置摄像头
	    AVCaptureDevice *videoDevice = [self getVideoDevice:AVCaptureDevicePositionFront];
	
	    // 3.获取声音设备
	    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	
	    // 4.创建对应视频设备输入对象
	    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
	    _currentVideoDeviceInput = videoDeviceInput;
	
	    // 5.创建对应音频设备输入对象
	    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
	
	    // 6.添加到会话中
	    // 注意“最好要判断是否能添加输入，会话不能添加空的
	    // 6.1 添加视频
	    if ([captureSession canAddInput:videoDeviceInput]) {
	        [captureSession addInput:videoDeviceInput];
	    }
	    // 6.2 添加音频
	    if ([captureSession canAddInput:audioDeviceInput]) {
	        [captureSession addInput:audioDeviceInput];
	    }
	
	    // 7.获取视频数据输出设备
	    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	    // 7.1 设置代理，捕获视频样品数据
	    // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
	    dispatch_queue_t videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
	    [videoOutput setSampleBufferDelegate:self queue:videoQueue];
	    if ([captureSession canAddOutput:videoOutput]) {
	        [captureSession addOutput:videoOutput];
	    }
	
	    // 8.获取音频数据输出设备
	    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
	    // 8.2 设置代理，捕获视频样品数据
	    // 注意：队列必须是串行队列，才能获取到数据，而且不能为空
	    dispatch_queue_t audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
	    [audioOutput setSampleBufferDelegate:self queue:audioQueue];
	    if ([captureSession canAddOutput:audioOutput]) {
	        [captureSession addOutput:audioOutput];
	    }
	
	    // 9.获取视频输入与输出连接，用于分辨音视频数据
	    _videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
	
	    // 10.添加视频预览图层
	    AVCaptureVideoPreviewLayer *previedLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
	    previedLayer.frame = [UIScreen mainScreen].bounds;
	    [self.view.layer insertSublayer:previedLayer atIndex:0];
	    _previedLayer = previedLayer;
	
	    // 11.启动会话
	    [captureSession startRunning];
	}

// 指定摄像头方向获取摄像头

	- (AVCaptureDevice *)getVideoDevice:(AVCaptureDevicePosition)position
	{
	    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	    for (AVCaptureDevice *device in devices) {
	        if (device.position == position) {
	            return device;
	        }
	    }
	    return nil;
	}

	#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

	// 获取输入设备数据，有可能是音频有可能是视频

	- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:	(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
	{
	    if (_videoConnection == connection) {
	        NSLog(@"采集到视频数据");
	    } else {
	        NSLog(@"采集到音频数据");
	    }
	}

视频采集额外功能一（切换摄像头）

    切换摄像头步骤
        1.获取当前视频设备输入对象
        2.判断当前视频设备是前置还是后置
        3.确定切换摄像头的方向
        4.根据摄像头方向获取对应的摄像头设备
        5.创建对应的摄像头输入对象
        6.从会话中移除之前的视频输入对象
        7.添加新的视频输入对象到会话中

// 切换摄像头

	- (IBAction)toggleCapture:(id)sender {
	
	    // 获取当前设备方向
	    AVCaptureDevicePosition curPosition = _currentVideoDeviceInput.device.position;
	
	    // 获取需要改变的方向
	    AVCaptureDevicePosition togglePosition = curPosition == AVCaptureDevicePositionFront?AVCaptureDevicePositionBack:AVCaptureDevicePositionFront;
	
	    // 获取改变的摄像头设备
	    AVCaptureDevice *toggleDevice = [self getVideoDevice:togglePosition];
	
	    // 获取改变的摄像头输入设备
	    AVCaptureDeviceInput *toggleDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:toggleDevice error:nil];
	
	    // 移除之前摄像头输入设备
	    [_captureSession removeInput:_currentVideoDeviceInput];
	
	    // 添加新的摄像头输入设备
	    [_captureSession addInput:toggleDeviceInput];
	
	    // 记录当前摄像头输入设备
	    _currentVideoDeviceInput = toggleDeviceInput;
	
	}

视频采集额外功能二（聚焦光标）

    聚焦光标步骤
        1.监听屏幕的点击
        2.获取点击的点位置，转换为摄像头上的点，必须通过视频预览图层（AVCaptureVideoPreviewLayer）转
        3.设置聚焦光标图片的位置，并做动画
        4.设置摄像头设备聚焦模式和曝光模式(注意：这里设置一定要锁定配置lockForConfiguration,否则报错)

// 点击屏幕，出现聚焦视图

	- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
	{
	   // 获取点击位置
	   UITouch *touch = [touches anyObject];
	   CGPoint point = [touch locationInView:self.view];
	
	   // 把当前位置转换为摄像头点上的位置
	   CGPoint cameraPoint = [_previedLayer captureDevicePointOfInterestForPoint:point];
	
	   // 设置聚焦点光标位置
	   [self setFocusCursorWithPoint:point];
	
	   // 设置聚焦
	   [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
	}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */

	-(void)setFocusCursorWithPoint:(CGPoint)point{
	    self.focusCursorImageView.center=point;
	    self.focusCursorImageView.transform=CGAffineTransformMakeScale(1.5, 1.5);
	    self.focusCursorImageView.alpha=1.0;
	    [UIView animateWithDuration:1.0 animations:^{
	        self.focusCursorImageView.transform=CGAffineTransformIdentity;
	    } completion:^(BOOL finished) {
	        self.focusCursorImageView.alpha=0;
	
	    }];
	}

/**
 *  设置聚焦
 */

	-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
	
	    AVCaptureDevice *captureDevice = _currentVideoDeviceInput.device;
	    // 锁定配置
	    [captureDevice lockForConfiguration:nil];
	
	    // 设置聚焦
	    if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
	        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
	    }
	    if ([captureDevice isFocusPointOfInterestSupported]) {
	        [captureDevice setFocusPointOfInterest:point];
	    }
	
	    // 设置曝光
	    if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
	        [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
	    }
	    if ([captureDevice isExposurePointOfInterestSupported]) {
	        [captureDevice setExposurePointOfInterest:point];
	    }
	
	    // 解锁配置
	    [captureDevice unlockForConfiguration];
	}

####结束语

后续还会更新更多有关直播的资料，希望做到教会每一个朋友从零开始做一款直播app，并且Demo也会慢慢完善.
Demo点击下载

    由于FFMPEG库比较大，大概100M。
    本来想自己上传所有代码了，上传了1个小时，还没成功，就放弃了。
    提供另外一种方案，需要你们自己导入IJKPlayer库
    具体步骤：
    下载Demo后，打开YZLiveApp.xcworkspace问题

{% img /images/zhibocaiji001.png Caption %} 

打开YZLiveApp.xcworkspace问题

    pod install就能解决


{% img /images/zhibocaiji002.png Caption %} 

    下载jkplayer库，点击下载
    把jkplayer直接拖入到与Classes同一级目录下，直接运行程序，就能成功了


{% img /images/zhibocaiji003.png Caption %} 

    注意不需要打开工程，把jkplayer拖入到工程中，而是直接把jkplayer库拷贝到与Classes同一级目录下就可以了。
    错误示范:不要向下面这样操作


{% img /images/zhibocaiji004.png Caption %} 
