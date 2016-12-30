---

layout: post
title: "系统相关检测"
date: 2013-10-10 13:53:19 +0800
comments: true
categories: Developer
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



--- 


iOS系统版本的不断升级的前提，伴随着用户使用设备的安全性提升，iOS系统对于App需要使用的硬件限制也越来越严格，App处理稍有不妥，轻则造成功能不可用用户还不知道，重则会造成App Crash。

当用户在App启动时，看到弹出来的一条条“XXX 请求访问您的位置” “XXX 请求访问您的通讯录” “XXX 请求访问您的日历” “XXX 请求访问您的摄像头” 等一系列消息时，用户觉得不耐烦的同时，也会由于一时的安全考虑而把相应的功能给屏蔽掉，这还只是开始，当用户真正在使用对应功能的时候，就会出现一连续的奇怪现象，比如数据显示异常：明明通讯录里面有信息，却总是加载不出数据;有的甚至是直接Crash。

下面，笔者将会综合性地把上述硬件的授权检测，一一地详细列出，并给出相关示例代码：

<!--more-->


1、定位服务

相关框架



检测方法

	+ (CLAuthorizationStatus)authorizationStatus

相关返回参数

	//用户尚未做出选择
	kCLAuthorizationStatusNotDetermined = 0,
	 
	// 未授权，且用户无法更新，如家长控制情况下
	kCLAuthorizationStatusRestricted,
	 
	// 用户拒绝App使用
	kCLAuthorizationStatusDenied,
	 
	// 总是使用
	kCLAuthorizationStatusAuthorizedAlways NS_ENUM_AVAILABLE(NA, 8_0),
	 
	// 按需使用
	kCLAuthorizationStatusAuthorizedWhenInUse NS_ENUM_AVAILABLE(NA, 8_0),
	 
	// 已授权
	kCLAuthorizationStatusAuthorized

参考代码

	__block void (^checkLocationAuth)(void) = ^{
	    CLAuthorizationStatus authStatus = [CLLocationManager  authorizationStatus];
	     
	    if (CLAuthorizationStatusAuthorized == authStatus) {
	        //授权成功，执行后续操作
	    }else {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	            checkLocationAuth();
	        });
	    }
	};
	checkLocationAuth();

2、通讯录



检测方法

	ABAuthorizationStatus ABAddressBookGetAuthorizationStatus(void)

授权状态

	kABAuthorizationStatusNotDetermined = 0,    // 未进行授权选择
	kABAuthorizationStatusRestricted,           // 未授权，且用户无法更新，如家长控制情况下
	kABAuthorizationStatusDenied,               // 用户拒绝App使用
	kABAuthorizationStatusAuthorized            // 已授权，可使用

参考代码

	__block void (^checkAddressBookAuth)(void) = ^{
	    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
	     
	    if (kABAuthorizationStatusAuthorized == authStatus) {
	        //授权成功，执行后续操作
	    }else {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	            checkAddressBookAuth();
	        });
	    }
	};
	checkAddressBookAuth();

3、日历/提醒事项授权



检测方法

	+ (EKAuthorizationStatus)authorizationStatusForEntityType:(EKEntityType)entityType

参数类型

	EKEntityTypeEvent,  //事件
	 
	EKEntityTypeReminder//提醒

授权状态

	EKAuthorizationStatusNotDetermined = 0,// 未进行授权选择
	 
	EKAuthorizationStatusRestricted,　　　　// 未授权，且用户无法更新，如家长控制情况下
	 
	EKAuthorizationStatusDenied,　　　　　　 // 用户拒绝App使用
	 
	EKAuthorizationStatusAuthorized,　　　　// 已授权，可使用

参考代码

	__block void (^checkCalanderAuth)(void) = ^{
	    EKAuthorizationStatus authStatus = [EKAuthorizationStatus authorizationStatusForEntityType:EKEntityTypeEvent];
	     
	    if (EKAuthorizationStatusAuthorized == authStatus) {
	        //授权成功，执行后续操作
	    }else {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	            checkCalanderAuth();
	        });
	    }
	};
	checkCalanderAuth();

4、照片库授权


检测方法

	+ (ALAuthorizationStatus)authorizationStatus;

授权状态

	ALAuthorizationStatusNotDetermined = 0,// 未进行授权选择
	 
	ALAuthorizationStatusRestricted,　　　　// 未授权，且用户无法更新，如家长控制情况下
	 
	ALAuthorizationStatusDenied,　　　　　　 // 用户拒绝App使用
	 
	ALAuthorizationStatusAuthorized,　　　　// 已授权，可使用

参考代码

	__block void (^checkAssetLibraryAuth)(void) = ^{
	    ALAuthorizationStatus authStatus = [ALAuthorizationStatus authorizationStatus];
	     
	    if (ALAuthorizationStatusAuthorized == authStatus) {
	        //授权成功，执行后续操作
	    }else {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	            checkAssetLibraryAuth();
	        });
	    }
	};
	checkAssetLibraryAuth();

5、蓝牙授权状态检测



检测方法

	+ (CBPeripheralManagerAuthorizationStatus)authorizationStatus;

授权状态

	CBPeripheralManagerAuthorizationStatusNotDetermined = 0,// 未进行授权选择
	 
	CBPeripheralManagerAuthorizationStatusRestricted,　　　　// 未授权，且用户无法更新，如家长控制情况下
 
	CBPeripheralManagerAuthorizationStatusDenied,　　　　　　 // 用户拒绝App使用
	 
	CBPeripheralManagerAuthorizationStatusAuthorized,　　　　// 已授权，可使用

参考代码

	__block void (^checkPeripheralAuth)(void) = ^{
	    CBPeripheralManagerAuthorizationStatus authStatus = [CBPeripheralManagerAuthorizationStatus authorizationStatus];
	     
	    if (CBPeripheralManagerAuthorizationStatusAuthorized == authStatus) {
	        //授权成功，执行后续操作
	    }else {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	            checkPeripheralAuth();
	        });
	    }
	};
	checkPeripheralAuth();

6、摄像头授权状态检测


检测方法

	+ (AVAuthorizationStatus)authorizationStatusForMediaType:(NSString *)mediaType;

授权状态

	AVAuthorizationStatusNotDetermined = 0,// 未进行授权选择
	 
	AVAuthorizationStatusRestricted,　　　　// 未授权，且用户无法更新，如家长控制情况下
	 
	AVAuthorizationStatusDenied,　　　　　　 // 用户拒绝App使用
	 
	AVAuthorizationStatusAuthorized,　　　　// 已授权，可使用

参考代码

	__block void (^checkCameraAuth)(void) = ^{
	    AVAuthorizationStatus authStatus = [AVAuthorizationStatus authorizationStatusForMediaType:AVMediaTypeVideo];
	     
	    if (AVAuthorizationStatusAuthorized == authStatus) {
	        //授权成功，执行后续操作
	    }else {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	            checkCameraAuth();
	        });
	    }
	};
	checkCameraAuth();

7、麦克风授权状态检测



检测方法

	- (AVAudioSessionRecordPermission)recordPermission;

授权状态

	AVAudioSessionRecordPermissionUndetermined,　　　　// 用户尚未被请求许可。
	 
	AVAudioSessionRecordPermissionDenied,　　　　　　 // 用户已被要求并已拒绝许可。
	 
	AVAudioSessionRecordPermissionGranted,　　　　// 用户已被要求并已授予权限。

参考代码

	__block void (^checkRecordPermission)(void) = ^{
	    AVAudioSessionRecordPermission authStatus = [[AVAudioSession sharedInstance] recordPermission];
	     
	    if (AVAudioSessionRecordPermissionGranted == authStatus) {
	        //授权成功，执行后续操作
	    }else {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	            checkRecordPermission();
	        });
	    }
	};
	checkRecordPermission();