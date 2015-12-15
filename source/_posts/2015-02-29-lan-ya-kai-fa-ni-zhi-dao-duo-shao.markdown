---

layout: post
title: "蓝牙开发你知道多少"
date: 2015-02-29 00:38:13 +0800
comments: true
categories: 高级开发

---

蓝牙简单介绍和4.0的基本使用

 

背景：

* iOS的蓝牙不能用来传输文件。
* iOS与iOS设备之间进行数据通信，使用gameKit.framework
* iOS与其他非iOS设备进行数据通信，使用coreBluetooth.framework



<!--more-->




###iOS中蓝牙的实现方案

iOS中提供了4个框架用于实现蓝牙连接

1. GameKit.framework（用法简单）

	`只能用于iOS设备之间的连接，多用于游戏（比如五子棋对战），从iOS7开始过期`


2. MultipeerConnectivity.framework

	`只能用于iOS设备之间的连接，从iOS7开始引入，主要用于文件共享（仅限于沙盒的文件）`


3. ExternalAccessory.framework

	`可用于第三方蓝牙设备交互，但是蓝牙设备必须经过苹果MFi认证（国内较少）`


4. ######CoreBluetooth.framework（时下热门）

	`可用于第三方蓝牙设备交互，必须要支持蓝牙4.0`
	
	`硬件至少是4s，系统至少是iOS6`
	
	`蓝牙4.0以低功耗著称，一般也叫BLE（BluetoothLowEnergy）`
	
	`目前应用比较多的案例：运动手坏、嵌入式设备、智能家居`

下面具体介绍使用CoreBluetooth.framework的代码步骤：

##### 蓝牙系统库

	#import <CoreBluetooth/CoreBluetooth.h>

##### 必须要由UUID来唯一标示对应的service和characteristic

	#define kServiceUUID @"5C476471-1109-4EBE-A826-45B4F9D74FB9"
	
	#define kCharacteristicHeartRateUUID @"82C7AC0F-6113-4EC9-92D1-5EEF44571398"
	
	#define kCharacteristicBodyLocationUUID @"537B5FD6-1889-4041-9C35-F6949D1CA034"

***

	@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
	
	
	
	@property (nonatomic,strong)CBCentralManager * centralManager;
	
	@property (nonatomic,strong)CBPeripheral     * peripheral;
	
	@end

#### 创建中心角色

	#import <CoreBluetooth/CoreBluetooth.h>

	- (void)viewDidLoad
	{
	
	    [super viewDidLoad];
	
	    //初始化蓝牙 central manager
	
	    _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:nil];    
	
	}
 


#### 扫描外设

	[manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerRestoredStateScanOptionsKey:@(YES)}];
	 


#### 连接外设

	- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
	{
	        if([peripheral.name  isEqualToString:BLE_SERVICE_NAME]){
	                [self connect:peripheral];
	        }
	}       
	
	-(BOOL)connect:(CBPeripheral *)peripheral{
	        self.manager.delegate = self;
	        [self.manager connectPeripheral:peripheral
	                                options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
	}

#### 扫描外设中的服务和特征

	- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
	{
	
	   NSLog(@"Did connect to peripheral: %@", peripheral);       
	    
	   _testPeripheral = peripheral;
	   [peripheral setDelegate:self];  <br>//查找服务
	   [peripheral discoverServices:nil];
	
	
	}

#### 发现服务：
	
	- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
	{


    NSLog(@"didDiscoverServices");

    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);

        if ([self.delegate respondsToSelector:@selector(DidNotifyFailConnectService:withPeripheral:error:)])
            [self.delegate DidNotifyFailConnectService:nil withPeripheral:nil error:nil];

        return;
    }


    for (CBService *service in peripheral.services)
    {
         //发现服务
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]])
        {
            NSLog(@"Service found with UUID: %@", service.UUID);  <br>//查找特征
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }


    }
	}

#### 发现服务中的特征：

	- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
	{

    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);

        [self error];
        return;
    }

    NSLog(@"服务：%@",service.UUID);
    for (CBCharacteristic *characteristic in service.characteristics)
    {
       //发现特征
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"xxxxxxx"]]) {
                NSLog(@"监听：%@",characteristic);<br>//监听特征
                [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }

    }
	}

#### 与外设进行数据交互
读取数据：
	
	- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
	{
    	if (error)
    	{
			NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        	self.error_b = BluetoothError_System;
        	[self error];
        	return;
    }

	//    NSLog(@"收到的数据：%@",characteristic.value);
    [self decodeData:characteristic.value];
	}

#### 写数据：

	NSData *d2 = [[PBABluetoothDecode sharedManager] HexStringToNSData:@"0x02"];
                [self.peripheral writeValue:d2 forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
 
 
 
 详细请参看：
 
 [蓝牙开发专题](http://liuyanwei.jumppo.com/2015/07/17/ios-BLE-0.html)