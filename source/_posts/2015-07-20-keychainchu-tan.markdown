---
layout: post
title: "KeyChain初探"
date: 2015-07-20 22:46:16 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---



iOS的keychain服务提供了一种安全的保存私密信息（密码，序列号，证书等）的方式，每个ios程序都有一个独立的keychain存储。相对于NSUserDefaults、文件保存等一般方式，keychain保存更为安全，而且keychain里保存的信息不会因App被删除而丢失，所以在重装App后，keychain里的数据还能使用。
 
> “yourAppID.com.yourCompany.whatever”就是你要起的公共区名称，除了whatever字段可以随便定之外，其他的都必须如实填写。这个文件的路径要配置在 Project->build setting->Code Signing Entitlements里，否则公共区无效，配置好后，须用你正式的证书签名编译才可通过，否则xcode会弹框告诉你code signing有问题。所以，苹果限制了你只能同公司的产品共享KeyChain数据，别的公司访问不了你公司产品的KeyChain。
 
<!--more-->




###一.基本知识
######1.方法

* SecItemAdd 增
* SecItemUpdate 改
* SecItemDelete 删
* SecItemCopyMatching 查

######2.权限 
文档上说iOS的keyChain是一个相对独立的空间，当程序替换，删除时并不会删除keyChain的内容，这个要比Library/Cache好。刷机，恢复出厂应该就没有了。关于备份，只会备份数据，到那时不会备份设备的密钥，换句话说，即使拿到数据，也没有办法解密里面的内容。有人说似乎破解的手机就能破解keyChain,本人并不清楚，希望有大神能指教。但个人认为，keyChain只是沙盒的升级版，可以存放一些非私密的信息，即使破解也不影响其它用户，只影响那个破解了的设备。（比如针对该设备的一个密钥）。


可访问性一般来说，自己的程序只能访问自己的keychain,相同bundle的程序通过设置group可以互相共享同组的keychain，从而实现程序间可以共同访问一些数据。详细后面介绍一些我测试下来的经验。

######3.如何查询keyChain
 
	[objc] view plaincopyprint?在CODE上查看代码片派生到我的代码片
	genericPasswordQuery = [[NSMutableDictionary alloc] init];   
	[genericPasswordQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];//1  
	[genericPasswordQuery setObject:identifier forKey:(id)kSecAttrGeneric];//2  
	if (accessGroup != nil){  
	    [genericPasswordQuery setObject:accessGroup forKey:(id)kSecAttrAccessGroup];//3  
	}  
	[genericPasswordQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];//4  
	[genericPasswordQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];//5  
	NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:genericPasswordQuery];  
	NSMutableDictionary *outDictionary = nil;      
	if (SecItemCopyMatching((CFDictionaryRef)tempQuery, (CFTypeRef *)&outDictionary) == noErr){//6  
	//found and outDicitionary is not nil  
	}else{  
	//not found  
	}  

* 1.设置Class值，每个Class对应的都有不同的参数类型
* 2.用户确定的参数，一般是程序中使用的类别，比如说是"Password"或"Account Info"，作为search的主力条件
* 3.设置Group,如果不同程序都拥有这个组，那么不同程序间可以共享这个组的数据
* 4.只返回第一个匹配数据，查询方法使用，还有值kSecMatchLimitAll
* 5.返回数据为CFDicitionaryRef，查询方法使用
* 6.执行查询方法，判断返回值

> eg:这个是none-ARC的代码哦！ARC情况下会有bridge提示。

######4.类型转换
介绍增删改方法调用前，先介绍转换方法，如何将NSDictionary转换成KeyChain方法可以设置的Dicitionary，一般在写程序过程中，应该尽量避免直接访问KeyChain，一般会创建一个NSDictionary来同步对应的数据，所以两者需要做转换。 

	//data to secItem  
	- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert  
	{  
	    // Create a dictionary to return populated with the attributes and data.  
	    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];  
	      
	    //设置kSecClass  
	    [returnDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];  
	    //将Dictionary里的kSecValueData(一般就是这个keyChain里主要内容，比如说是password),NSString转换成NSData  
	    NSString *passwordString = [dictionaryToConvert objectForKey:(id)kSecValueData];  
	    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];  
	    return returnDictionary;  
	}  
	//secItem to data  
	- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert  
	{  
	    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];  
	      
	    // Add the proper search key and class attribute.  
	    [returnDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];  
	    [returnDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];  
	      
	    // Acquire the password data from the attributes.  
	    NSData *passwordData = NULL;  
	    if (SecItemCopyMatching((CFDictionaryRef)returnDictionary, (CFTypeRef *)&passwordData) == noErr)  
	    {  
	        // 删除多余的kSecReturnData数据  
	        [returnDictionary removeObjectForKey:(id)kSecReturnData];  
	          
	        // 对应前面的步骤，将数据从NSData转成NSString  
	        NSString *password = [[[NSString alloc] initWithBytes:[passwordData bytes] length:[passwordData length]  
	                                                     encoding:NSUTF8StringEncoding] autorelease];  
	        [returnDictionary setObject:password forKey:(id)kSecValueData];  
	    }  
	    else  
	    {  
	        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");  
	    }  
	    [passwordData release];   
	    return returnDictionary;  
	}  
######5.增删改
用代码来说明 

	- (void)writeToKeychain  
	{  
	    NSDictionary *attributes = NULL;  
	    NSMutableDictionary *updateItem = NULL;  
	    OSStatus result;  
	    //判断是增还是改  
	    if (SecItemCopyMatching((CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&attributes) == noErr)  
	    {  
	            // First we need the attributes from the Keychain.  
	            updateItem = [NSMutableDictionary dictionaryWithDictionary:attributes];  
	        // Second we need to add the appropriate search key/values.  
	            [updateItem setObject:[genericPasswordQuery objectForKey:(id)kSecClass] forKey:(id)kSecClass];  
	            // Lastly, we need to set up the updated attribute list being careful to remove the class.  
	            NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:keychainItemData];  
	            //删除kSecClass update不能update该字段，否则会报错  
	            [tempCheck removeObjectForKey:(id)kSecClass];  
	        //参数1表示search的，参数2表示需要更新后的值  
	            result = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)tempCheck);  
	    }else{  
	            //增加  
	            result = SecItemAdd((CFDictionaryRef)[self dictionaryToSecItemFormat:keychainItemData], NULL);  
	    }  
	}  
删除很简单，就不写注释了 

	- (void)resetKeychainItem  
	{  
	    OSStatus junk = noErr;  
	    if (!keychainItemData)  
	    {  
	        self.keychainItemData = [[NSMutableDictionary alloc] init];  
	    }  
	    else if (keychainItemData)  
	    {  
	        NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:keychainItemData];  
	        junk = SecItemDelete((CFDictionaryRef)tempDictionary);  
	        NSAssert( junk == noErr || junk == errSecItemNotFound, @"Problem deleting current dictionary." );  
	    }  
	      
	    // Default attributes for keychain item.  
	    [keychainItemData setObject:@"" forKey:(id)kSecAttrAccount];  
	    [keychainItemData setObject:@"" forKey:(id)kSecAttrLabel];  
	    [keychainItemData setObject:@"" forKey:(id)kSecAttrDescription];  
	      
	    // Default data for keychain item.  
	    [keychainItemData setObject:@"" forKey:(id)kSecValueData];  
	}  
二.Group的配置
配置Target的Code Signing Entitlements.

{% img /images/keyChain001.png Caption %}  

配置该文件

{% img /images/keyChain002.png Caption %} 


{% img /images/keyChain003.png Caption %} 

可以配置一个Array列表，表示该程序可以支持多个group
这样就可以在创建secItem时候添加kSecAttrAccessGroup了。
经过测试有以下经验同大家分享：

* 1.相同bundle下生成的程序都可以共享相同group的keyChain.
相同bundle解释下就是：比如:2个程序分别使用的provision对应bundle是com.jv.key1和com.jv.key2，那你配置文件肯定是{Identifer}.com.jv.{name},其中identifer是苹果生成的随机串号，可以在申请证书时看到，复制过来即可，name可以自己取，程序中指定属于哪个Group即可。

* 2.如果你在 addkey时，没有指定group,则会默认添加你keychain-access-groups里第一个group，如果你没有设置Entitlements,则默认使用对应的程序的bundle name,比如com.jv.key1,表示只能给自己程序使用。

* 3.如果你程序添加的group并不存在你的配置文件中，程序会奔溃，表示无法添加。因此你只能添加你配置文件中支持的keychain。

 
三、保存私密信息（工具）
在应用里使用使用keyChain，我们需要导入Security.framework ，keychain的操作接口声明在头文件SecItem.h里。直接使用SecItem.h里方法操作keychain，需要写的代码较为复杂，为减轻咱们程序员的开发，我们可以使用一些已经封装好了的工具类，下面我会简单介绍下我用过的两个工具类：KeychainItemWrapper和SFHFKeychainUtils。
 
（一）KeychainItemWrapper是apple官方例子“GenericKeychain”里一个访问keychain常用操作的封装类，在官网上下载了GenericKeychain项目后，只需要
把“KeychainItemWrapper.h”和“KeychainItemWrapper.m”拷贝到我们项目，并导入Security.framework 。KeychainItemWrapper的用法：
 
	/** 初始化一个保存用户帐号的KeychainItemWrapper */
	KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Account Number"
	                                                                   accessGroup:@"YOUR_APP_ID_HERE.com.yourcompany.AppIdentifier"];  
	 
	//保存帐号
	[
	wrapper setObject:@"<帐号>" forKey:(id)kSecAttrAccount];    
	 
	//保存密码
	[
	wrapper setObject:@"<帐号密码>" forKey:(id)kSecValueData];    
	 
	//从keychain里取出帐号密码
	NSString *password = [wrapper objectForKey:(id)kSecValueData];      
	 
	//清空设置
	[
	wrapper resetKeychainItem];
其中方法“- (void)setObject:(id)inObject forKey:(id)key;”里参数“forKey”的值应该是Security.framework 里头文件“SecItem.h”里定义好的key，用其他字符串做key程序会崩溃！
 
 
（二）SFHFKeychainUtils 提供了在 iOS keychain中安全的存储密码的工具
 
下载地址https://github.com/ldandersen/scifihifi-iphone/tree/master/security
 
* 1、引入Security.frameWork框架。
 
* 2、引入头文件：SFHKeychainUtils.h.
 
* 3、存密码：
 
 ***
 
 
	[SFHFKeychainUtils storeUsername:@"dd" andPassword:@"aa"forServiceName:SERVICE_NAME updateExisting:1 error:nil];
	 
	[SFHFKeychainUtils deleteItemForUsername:@"dd" andServiceName:SERVICE_NAME error:nil];
 
* 4、取密码：
 
 ***
 
	NSString *passWord =  [SFHFKeychainUtils getPasswordForUsername:@"dd"andServiceName:SERVICE_NAME error:nil];




===
===


######微信号：
	
clpaial10201119（Q Q：2211523682）
    
######微博WB:

[http://weibo.com/u/3288975567?is_hot=1](http://weibo.com/u/3288975567?is_hot=1)

######gitHub：


[https://github.com/al1020119](https://github.com/al1020119)
	
######博客

[http://al1020119.github.io/](http://al1020119.github.io/)

===

{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  