---
layout: post
title: "第三方支付总结"
date: 2016-01-18 11:35:08 +0800
comments: true
categories: Summary
---
 
引言：
随着移动互联的发展，支付功能越来越流行，这也使得各大app公司不得不集成相关支付功能，文本就就此谈谈支付相关。

本文源码源码（封装）[iCocosPay](https://github.com/al1020119/iCocosPay)（内集常见支付方案：成支付宝，微信，银联）


目录

* 常见支付方案
* 第三方支付SDK
* 苹果官方支付方案
* web支付方案


##一:常见支付方案

先来看一组截图

{% img /images/zhifu001.png Caption %}

{% img /images/zhifu002.png Caption %}

{% img /images/zhifu003.png Caption %}

{% img /images/zhifu004.png Caption %}

{% img /images/zhifu005.png Caption %}


+ 微信支付

+ 支付宝支付

+ 银联（快捷）支付

+ 京东支付

+ 百度钱包

+ web支付

+ QQ钱包支付

+ 连连支付

￼￼￼￼
整理图：

{% img /images/zhifu006.png Caption %}


##二：最常见的三种支付方式

+ 微信支付SDK
+ 支付宝支付SDK
+ 银联快捷支付SDK


####微信
#####什么事微信支付
微信支付是集成在微信客户端的支付功能，用户可以通过手机完成快速的支付流程。微信支付以绑定银行卡的快捷支付为基础，向用户提供安全、快捷、高效的支付服务。

#####申请流程：

第一阶段：

{% img /images/zhifu007.png Caption %}

第二阶段：

{% img /images/zhifu008.png Caption %}

第三阶段：

{% img /images/zhifu009.png Caption %}

#####应用场景：
商户APP调用微信提供的SDK调用微信支付模块，商户APP会跳转到微信中完成支付，支付完后跳回到商户APP内，最后展示支付结果。

#####支付流程
App内提交订单（确认支付）
商品信息确认（立即支付）
输入密码（进行支付）
支付成功

#####App接入步骤

{% img /images/zhifu010.png Caption %}



####支付宝
#####什么是支付宝支付：
支付宝移动支付是一种程序式的支付方式，在手机、掌上电脑等无线设备的应用程序内，买家可通过支付宝进行付款购买特定服务或商品，资金即时到账。

#####申请流程

{% img /images/zhifu011.png Caption %}


#####支付流程：
买家再手机应用中购买商品或者服务
买家选择支付宝方式支付
进入支付宝收银台进行支付
支付成功
交易完成买家可查看交易信息
返回对应的app界面

#####App接入步骤

{% img /images/zhifu012.png Caption %}

####银联

#####什么值银联支付

{% img /images/zhifu013.png Caption %}

#####申请流程：


{% img /images/zhifu014.png Caption %}

#####支付流程：


{% img /images/zhifu015.png Caption %}

#####接入流程：


{% img /images/zhifu016.png Caption %}


#####最后整理一下具体步骤：
1. 首先客户端浏览商品，点击下单，请求到达商户后台。
2. 商户后台再提交订单信息到银联后台。
3. 银联后台返回交易流水号。
4. 商户后台将交易流水号返回给客户端。
5. 客户端再通过交易流水号启动手机控件开始支付。
6. 支付控件收集支付信息并请求银联后台，完成支付后银联后台通知商户后台支付结果。
7. 银联后台通知支付控件支付结果。
8. 支付控件通知客户端支付结果。
9. 最后客户端将支付结果展示给用户。

##三：苹果官方支付方案

+ IPA
+ Apple Pay


#####IPA
什么事IPA：
In App Purchase属于iPhone SDK3.0的新特性，用于在应用程序中购买付费道具，增加新功能，订阅杂志。是应用程序除了植入广告外的另一种取得收益的方式。

#####IPA支持的产品类型：

{% img /images/zhifu017.png Caption %}

IPA两种支付方式：
方式一：内置产品类型

{% img /images/zhifu018.png Caption %}
方式二：服务器类型

{% img /images/zhifu019.png Caption %}

#####注意事项：

1. 你必须提供电子类产品和服务。不要使用In App Purchase 去出售实物和实际服务。
2. 不能提供代表中介货币的物品，因为让用户知晓他们购买的商品和服务是很重要的。

#####相关流程：

1. 程序向服务器发送请求，获得一份产品列表。
2. 服务器返回包含产品标识符的列表。
3. 程序向App Store发送请求，得到产品的信息。
4. App Store返回产品信息。
5. 程序把返回的产品信息显示给用户（App的store界面）
6. 用户选择某个产品
7. 程序向App Store发送支付请求
8. App Store处理支付请求并返回交易完成信息。
9. 程序从信息中获得数据，并发送至服务器。
10. 服务器纪录数据，并进行审(我们的)查。
11. 服务器将数据发给App Store来验证该交易的有效性。
12. App Store对收到的数据进行解析，返回该数据和说明其是否有效的标识。
13. 服务器读取返回的数据，确定用户购买的内容。
14. 服务器将购买的内容传递给程序。

#####什么是Apple Pay：
Apple Pay与诸多传统移动支付系统不同，不但有Touch ID指纹识别技术护航，还能在Apple Watch上运作。

#####相关流程：
1. 程序通过bundle存储的plist文件得到产品标识符的列表。
2. 程序向App Store发送请求，得到产品的信息。
3. App Store返回产品信息。
4. 程序把返回的产品信息显示给用户（App的store界面）
5. 用户选择某个产品
6. 程序向App Store发送支付请求
7. App Store处理支付请求并返回交易完成信息。
8. App获取信息并提供内容给用户。



##四：web支付方案
#####概述：
iOS中通过UIWebView展示WAP或HTML5支付页面，从而完成支付功能，无需接入额外第三方SDK。
UIWebView是iOS SDK中一个最常用的控件，是内置的浏览器控件，我们可以用它来浏览网页、打开文档等等。

#####类型界面：

{% img /images/zhifu020.png Caption %}


总结：



最后本人根据实际开发整理了一份关于支付的源码（封装）[iCocosPay](https://github.com/al1020119/iCocosPay)，内集成了：支付宝支付，微信支付，银联快捷支付！

其他参考：

[微信支付](https://pay.weixin.qq.com/wiki/doc/api/index.html)

[支付宝支付](https://b.alipay.com/order/productDetail.htm?productId=2015110218010538&tabId=1#ps-tabinfo-hashhttp://doc.open.alipay.com/doc2/detail?treeId=59&articleId=103563&docType=1)


[银联](https://open.unionpay.com/ajweb/index)


[Web支付](https://b.alipay.com/order/productDetail.htm?productId=2015110218008816https://open.unionpay.com/ajweb/help/file/techFile?productId=66)


[IAP](https://developer.apple.com/in-app-purchase/)


[Apple Pay](https://developer.apple.com/apple-pay/)





