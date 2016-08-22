---
layout: post
title: "逆向支付宝"
date: 2016-04-10 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

{% img /images/bgHeader.png Caption %}  



为了了解支付宝app的源码结构，我们可以使用class-dump-z工具来分析支付宝二进制。
1.下载配置class_dump_z

前往 https://code.google.com/p/networkpx/wiki/class_dump_z ，下载tar包，然后解压配置到本地环境 
	
$ tar -zxvf class-dump-z_0.2a.tar.gz  
$ sudo cp mac_x86/class-dump-z /usr/bin/
2.class_dump支付宝app 
$ class-dump-z Portal > Portal-dump.txt  
 




<!--more-->




	@protocol XXEncryptedProtocol_10764b0  
	-(?)XXEncryptedMethod_d109df;  
	-(?)XXEncryptedMethod_d109d3;  
	-(?)XXEncryptedMethod_d109c7;  
	-(?)XXEncryptedMethod_d109bf;  
	-(?)XXEncryptedMethod_d109b8;  
	-(?)XXEncryptedMethod_d109a4;  
	-(?)XXEncryptedMethod_d10990;  
	-(?)XXEncryptedMethod_d1097f;  
	-(?)XXEncryptedMethod_d10970;  
	-(?)XXEncryptedMethod_d10968;  
	-(?)XXEncryptedMethod_d10941;  
	-(?)XXEncryptedMethod_d10925;  
	-(?)XXEncryptedMethod_d10914;  
	-(?)XXEncryptedMethod_d1090f;  
	-(?)XXEncryptedMethod_d1090a;  
	-(?)XXEncryptedMethod_d10904;  
	-(?)XXEncryptedMethod_d108f9;  
	-(?)XXEncryptedMethod_d108f4;  
	-(?)XXEncryptedMethod_d108eb;  
	@optional  
	-(?)XXEncryptedMethod_d109eb;  
	@end

查看得到的信息是加过密的，这个加密操作是苹果在部署到app store时做的，所以我们还需要做一步解密操作。
3.使用Clutch解密支付宝app

1）下载Clutch
iOS7越狱后的Cydia源里已经下载不到Clutch了，但是我们可以从网上下载好推进iPhone
地址：Clutch传送门

2）查看可解密的应用列表 
	
root
# ./Clutch   
 
Clutch-1.3.2  
usage: ./Clutch [flags] [application name] [...]  
Applications available: 9P_RetinaWallpapers breadtrip Chiizu CodecademyiPhone FisheyeFree food GirlsCamera IMDb InstaDaily InstaTextFree iOne ItsMe3 linecamera Moldiv MPCamera MYXJ NewsBoard Photo Blur Photo Editor PhotoWonder POCO相机 Portal QQPicShow smashbandits Spark tripcamera Tuding_vITC_01 wantu WaterMarkCamera WeiBo Weibo

3）解密支付宝app 
	
root# ./Clutch Portal  
 
Clutch-1.3.2  
Cracking Portal...  
Creating working directory...  
Performing initial analysis...  
Performing cracking preflight...  
dumping binary: analyzing load commands  
dumping binary: obtaining ptrace handle  
dumping binary: forking to begin tracing  
dumping binary: successfully forked  
dumping binary: obtaining mach port  
dumping binary: preparing code resign  
dumping binary: preparing to dump  
dumping binary: ASLR enabled, identifying dump location dynamically  
dumping binary: performing dump  
dumping binary: patched cryptid  
dumping binary: writing new checksum  
Censoring iTunesMetadata.plist...  
Packaging IPA file...  
 
compression level: 0  
    /var/root/Documents/Cracked/支付宝钱包-v8.0.0-(Clutch-1.3.2).ipa  
 
elapsed time: 7473ms  
 
Applications Cracked:   
Portal  
 
Applications that Failed:  
 
Total Success: 1 Total Failed: 0

4）导出已解密的支付宝app

从上一步骤得知，已解密的ipa位置为：/var/root/Documents/Cracked/支付宝钱包-v8.0.0-(Clutch-1.3.2).ipa
将其拷贝到本地去分析

4.class_dump已解密的支付宝app

解压.ipa后，到 支付宝钱包-v8.0.0-(Clutch-1.3.2)/Payload/Portal.app 目录下，class_dump已解密的二进制文件
1
	
$ class-dump-z Portal > ~/Portal-classdump.txt

这回就可以得到对应的信息了： 
	
@protocol ALPNumPwdInputViewDelegate <NSObject>  
-(void)onPasswordDidChange:(id)onPassword;  
@end  
 
@protocol ALPContactBaseTableViewCellDelegate <NSObject>  
-(void)shareClicked:(id)clicked sender:(id)sender;  
@end  
 
@interface MMPPayWayViewController : XXUnknownSuperclass <SubChannelSelectDelegate, UITableViewDataSource, UITableViewDelegate, CellDelegate, UIAlertViewDelegate> {  
@private  
    Item* channelSelected;  
    BOOL _bCheck;  
    BOOL _bOpenMiniPay;  
    BOOL _bNeedPwd;  
    BOOL _bSimplePwd;  
    BOOL _bAutopayon;  
    BOOL _bHasSub;  
    BOOL _bFirstChannel;  
    BOOL _bChangeSub;  
    BOOL _bClickBack;  
    UITableView* _channelListTableView;  
    NSMutableArray* _channelListArray;  
    NSMutableArray* _subChanneSelectedlList;  
    NSMutableArray* _unCheckArray;  
    UIButton* _saveButton;  
    UILabel* _tipLabel;  
    MMPPasswordSwichView* _payWaySwitch;  
    MMPPopupAlertView* _alertView;  
    UIView* _setView;  
    int _originalSelectedRow;  
    int _currentSelectedRow;  
    NSString* _statusCode;  
    ChannelListModel* _defaultChannelList;  
}  
@property(assign, nonatomic) BOOL bClickBack;  
@property(retain, nonatomic) ChannelListModel* defaultChannelList;  
@property(retain, nonatomic) NSString* statusCode;  
@property(assign, nonatomic) int currentSelectedRow;  
@property(assign, nonatomic) int originalSelectedRow;  
@property(retain, nonatomic) UIView* setView;  
@property(retain, nonatomic) MMPPopupAlertView* alertView;  
@property(retain, nonatomic) MMPPasswordSwichView* payWaySwitch;  
@property(assign, nonatomic, getter=isSubChannelChanged) BOOL bChangeSub;  
@property(assign, nonatomic) BOOL bFirstChannel;  
@property(assign, nonatomic) BOOL bHasSub;  
@property(assign, nonatomic) BOOL bAutopayon;  
@property(assign, nonatomic) BOOL bSimplePwd;  
@property(assign, nonatomic) BOOL bNeedPwd;  
@property(assign, nonatomic) BOOL bOpenMiniPay;  
@property(assign, nonatomic) BOOL bCheck;  
@property(retain, nonatomic) UILabel* tipLabel;  
@property(retain, nonatomic) UIButton* saveButton;  
@property(retain, nonatomic) NSMutableArray* unCheckArray;  
@property(retain, nonatomic) NSMutableArray* subChanneSelectedlList;  
@property(retain, nonatomic) NSMutableArray* channelListArray;  
@property(retain, nonatomic) UITableView* channelListTableView;  
-(void).cxx_destruct;  
-(void)subChannelDidSelected:(id)subChannel;  
-(void)switchCheckButtonClicked:(id)clicked;  
-(void)checkboxButtonClicked:(id)clicked;  
-(void)onCellClick:(id)click;  
-(void)showSubChannels;  
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;  
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;  
-(int)tableView:(id)view numberOfRowsInSection:(int)section;  
-(float)tableView:(id)view heightForRowAtIndexPath:(id)indexPath;  
-(int)numberOfSectionsInTableView:(id)tableView;  
-(void)setTableViewFootView:(id)view;  
-(void)setTableViewHeaderView:(id)view;  
-(id)tableView:(id)view viewForHeaderInSection:(int)section;  
-(id)tableView:(id)view viewForFooterInSection:(int)section;  
-(float)tableView:(id)view heightForHeaderInSection:(int)section;  
-(float)tableView:(id)view heightForFooterInSection:(int)section;  
-(void)alertView:(id)view clickedButtonAtIndex:(int)index;  
-(void)clickSave;  
-(void)netWorkRequestWithPwd:(id)pwd;  
-(void)setPayWaySwitchStates:(id)states;  
-(void)changePayWaySwitch:(id)aSwitch;  
-(void)scrollToSelectedRow;  
-(void)didReceiveMemoryWarning;  
-(void)viewDidLoad;  
-(void)applicationEnterBackground:(id)background;  
-(void)dealloc;  
-(void)goBack;  
-(BOOL)isChannelsSetChanged;  
-(id)subChannelCode:(int)code;  
-(id)subChannelDesc:(int)desc;  
-(id)initWithDefaultData:(id)defaultData;  
-(id)initWithNibName:(id)nibName bundle:(id)bundle;  
-(void)commonInit:(id)init;  
@end
5.分析支付宝源码片段

1）使用了@private关键字限制成员访问权限
但是实际上，在Objective-C编程中，使用@private连Keypath访问都拦不住的

2）抛出了冗长的成员对象
这非常有利分析程序结构
6.进一步思考

1）如何利用 class-dump 结果，结合 cycript 进行攻击呢？
2）class-dump-z 如此强大，有什么方法可以减少暴露的信息吗？

接下来的博文将针对上面的思考，继续总结～


===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  