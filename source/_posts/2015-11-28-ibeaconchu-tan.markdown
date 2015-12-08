---
layout: post
title: "iBeacon初探"
date: 2015-11-28 17:42:15 +0800
comments: true
categories: 高级开发
---

 
> iBeacon 是苹果公司在 iOS 7 中新推出的一种近场定位技术，可以感知一个附近的 iBeacon 信标的存在。
当一个 iBeacon 兼容设备进入/退出一个 iBeacon 信标标识的区域时，iOS 和支持 iBeacon 的 app 就能得知这一信息，从而对用户发出相应的通知。


典型的应用场景例如博物馆实时推送附近展品的相关信息，商场内即时通知客户折扣信息
等。苹果在 Apple Store 中也部署了 iBeacon 来推送优惠、活动信息。



<!--more-->




####Apple Store 中的 iBeacon 支持
 
######特点
	iBeacon 基于低功耗蓝牙技术（Bluetooth Low Energy, BLE）这一开放标准，因此也继承了 BLE 的一些特点。

######范围广

	相比于 NFC 的数厘米的识别范围，iBeacon 的识别范围可以达到数十米，并且能够估计距离的远近。
######兼容性

	iBeacon 是基于 BLE 做的一个简单封装，因此大部分支持 BLE 的设备都可以兼容。
	例如可以使用一个普通的蓝牙芯片作为信标，使用 Android 设备检测信标的存在。
######低能耗
	不少 beacon 实现宣称可以不依赖外部能源独立运行两年。

######使用场景
	我们以一个连锁商场的例子来讲解 iBeacon 的一个流程。在一个连锁商场中，店家需要在商场中的不同地方推送不同的优惠信息，比如服装和家居柜台推送的消息就很有可能不同。



当消费者走进某个商场时，会扫描到一个 beacon。这个 beacon 有三个标志符，proximityUUID 是一个整个公司（所有连锁商场）统一的值，可以用来标识这个公司，major 值用来标识特定的连锁商场，比如消费者正在走进的商场，minor 值标识了特定的一个位置的 beacon，例如定位到消费者正在门口。

这时商场的 app 会被系统唤醒，app 可以运行一个比较短的时间。在这段时间内，app 可以根据 beacon 的属性查询到用户的地理位置（通过查询服务器或者本地数据），例如在化妆品专柜，之后就可以通过一个 local notification 推送化妆品的促销信息。用户可以点击这次 local notification 来查看更详细的信息，这样一次促销行为就完成了。

######API
	闲话少说，我们来看下 iBeacon 具体怎么使用：

######Beacon 的表示
	iBeacon 本质上来说是一个位置（区域）信息，所以 Apple 把 iBeacon 功能集成在了 Core Location 里面。
iBeacon 信标在 Core Location 中表现为一个 CLBeacon，它圈定的范围则表现为 CLBeaconRegion，这是一个 CLRegion 的子类。

CLBeaconRegion 主要用三个属性来标识一个 iBeacon，proximityUUID、major 和 minor。
proximityUUID 是一个 NSUUID，用来标识公司，每个公司、组织使用的 iBeacon 应该拥有同样的 proximityUUID。
major 用来识别一组相关联的 beacon，例如在连锁超市的场景中，每个分店的 beacon 应该拥有同样的 major。
minor 则用来区分某个特定的 beacon。

	这些属性如果不指定（即 nil），匹配的时候就会忽略这个属性。例如只指定 proximityUUID 的 CLBeaconRegion 可以匹配某公司的所有 beacons。

######Monitoring
	Apple 在 iOS 4 中增加了地理围栏 API，可以用来在设备进入/退出某个地理区域时获得通知，这些 API 包括 -startMonitoringForRegion:、-locationManager:didEnterRegion:、-locationManager:didExitRegion: 等。
CLBeaconRegion 作为 CLRegion 的子类也可以复用这些 API，这种检测 iBeacon 的方式叫做 monitoring。

使用这种方法可以在程序在后台运行时检测 iBeacon，但是只能同时检测 20 个 region，也不能推测设备与 beacon 的距离。

######Ranging
	除了使用地理围栏 API 的方式，Apple 还在 iOS 7 中新增加了 iBeacon 专用的检测方式，也就是 ranging。
通过 CLLocationManager 的 -startRangingBeaconsInRegion: 方法可以开始检测特定的 iBeacon。

当检测到 beacon 的时候，CLLocationManager 的 delegate 方法 -locationManager:didRangeBeacons:inRegion: 会被调用，通知调用者现在被检测到的 beacons。
这个方法会返回一个 CLBeacon 的数组，根据 CLBeacon 的 proximity 属性就可以判断设备和 beacon 之间的距离。

> proximity 属性有四个可能的值，unknown、immediate、near 和 far。
另外 CLBeacon 还有 accuracy 和 rssi 两个属性能提供更详细的距离数据。

######使用 iOS 设备作为 iBeacon
我们可以使用 Core Bluetooth 框架来广播特定的 payload 来让 iOS 设备成为一个 iBeacon。
这个 payload 可以由 CLBeaconRegion 的 -peripheralDataWithMeasuredPower: 方法来获取。
之后交给 CBPeripheralManager 广播出去就可以了。

需要注意的是，广播 iBeacon 信息的时候 app 必须在前台运行。

######行为
iBeacon 的 API 并不十分复杂，但他的行为比较难弄清楚，特别是当应用运行在后台时，检测到 beacon 的时间延迟会让开发者难以推测。在做了一些实验和合理的推测后，我们得出了一些

> 结论：
检测到 beacon 的时间跟设备进行蓝牙扫描的时间间隔有关，每当设备进行扫描的时候，就能发现 iBeacon region 的变化。
在 ranging 打开的情况下，设备会每秒钟做一次扫描，也就是说状态更新最多延迟一秒。
程序在后台运行，并且 monitoring 打开的时候，设备可能每隔数分钟做一次扫描。iOS 7 的响应速度较慢，iOS 7.1 有比较大的改善。
如果存在设置 notifyEntryStateOnDisplay=YES 的 beacon，iOS 会在屏幕点亮的时候（锁屏状态下按下 home 键，或者因为收到推送点亮等）进行一次扫描。
设备重启并不影响 iBeacon 后台检测的执行。
iOS 7 中，在多任务界面中杀掉程序会终止 iBeacon 检测的执行，iOS 7.1 上改变了这一行为，被杀掉的 app 还可以继续进行 iBeacon 检测。
 