---
layout: post
title: "常用系统文件夹"
date: 2016-02-26 13:32:08 +0800
comments: true
categories: Summary
---

iPhone系统常用文件夹位置

1、 【/Applications】   
常用软件的安装目录  

2.    【/private /var/ mobile/Media /iphone video Recorder】   
iphone video Recorder录像文件存放目录

3、 【/private /var/ mobile/Media /DCIM】 
相机拍摄的照片文件存放目录

4、 【/private/var/ mobile /Media/iTunes_Control/Music】 
iTunes上传的多媒体文件（例如MP3、MP4等）存放目录，文件没有被修改，但是文件名字被修改了，直接下载到电脑即可读取。

5、 【/private /var/root/Media/EBooks】 
熊猫看书存放目录

6、 【/Library/Ringtones】 
系统自带的来电铃声存放目录（用iTunes将文件转换为ACC文件，把后缀名改成.m4r,用iPhone_PC_Suite传到/Library/Ringtones即可）

7、 【/System/Library/Audio/UISounds】 
短信记其它系统默认效果铃声（m4r铃声文件改扩展名为.caf）短信铃声文件名为sms-received开头的caf文件

8、 【/private/var/ mobile /Library/AddressBook】 
系统电话本的存放目录

       【/private/var/mobile/Library/SMS】 
短信存放目录

9、 【/private /var/ mobile/Media /iphone Recorder】 
iphone Recorder录音软件文件存放目录

10、【/Applications/Preferences.app/zh_CN.lproj】 
软件Preferences.app的中文汉化文件存放目录

11、【/Library/Wallpaper】 
系统q1ang纸的存放目录

12、【/System/Library/Audio/UISounds】 
系统声音文件的存放目录

13、【/private/var/root/Media/PXL】 
ibrickr上传安装程序建立的一个数据库，估计和windows的uninstall记录差不多。

14、【/bin】 
和linux系统差不多，是系统执行指令的存放目录。

15、【/private/var/ mobile /Library/SMS】 
系统短信的存放目录

16、【/private/var/run】 
系统进程运行的临时目录？（查看这里可以看到系统启动的所有进程）

17、【/private/var/logs/CrashReporter】 
系统错误记录报

特殊图标存放目录介绍：

充电图标： 
System/Library/CoreServices/SpringBoard.app/BatteryBG_1.png 一直到 BatteryBG_17.png ，Batteryfill.png  
18个图标为充电图标

手机信号图标： 
SystemLibraryCoreServicesSpringBoard.app下Default_0_Bars.png一直到Default_5_Bars.png 和FSO_0_Bars.png--FSO_5_Bars.png

10个图标为信号图标

Wifi信号图标: 
SystemLibraryCoreServicesSpringBoard.appDefault_0_AirPort.png---Default_3_AirPort.png和FSO_0_AirPort.png---FSO_3_AirPort.png

8个图标为wifi信号图标

Edge信号图标: 
SystemLibraryCoreServicesSpringBoard.app Default_EDGE_ON.png和FSO_EDGE_ON.png 

2个图标为Edge信号图标

日期美化图标： 
SystemLibraryCoreServicesSpringBoard.app|FSO_LockIcon.png

待机播放器图标： 
SystemLibraryCoreServicesSpringBoard.app|nexttrack.png , pause.png , play.png, prevtrack.png 

4个图标为待机播放器图标

IPOD播放信号图标： 
SystemLibraryCoreServicesSpringBoard.appFSO_Play.png ,Default_Play.png

闹钟信号图标： 
SystemLibraryCoreServicesSpringBoard.appDefault_AlarmClock.png ,FSO_AlarmClock.png

震动图标： 
SystemLibraryCoreServicesSpringBoard.appsilent.png ,hud.png ,ring.png

滑块图标：

SystemLibraryPrivateFrameworksTelephonyUI.framework 目录下： 
Bottombarknobgray.png（待机解锁滑块图标） 
bottombarknobgreen.png（待机状态下移动滑动来接听 滑块图标) 
Bottombarknobred.png（关机滑块 图标）

待机时间字体： 
/System/Library/Fonts/Cache/LockClock.ttf

待机时间背景： 
system/library/Frameworks/UIKit.framework/Other.artwork

滑块文字变为闪光字: 
SystemLibraryPrivateFrameworksTelephonyUI.framework/bottombarlocktextmask.png

解锁滑条路径: 
SystemLibraryPrivateFrameworksTelephonyUI.framework/ opbarbkgnd.png ,bottombarbkgndlock.png

滑块文字路径： 
/System/Library/CoreServices/SpringBoard.app/zh_CN.lproj

移动：

改彩色的文件名为：Default_CARRIER_CHINAMOBILE.png 
改黑白的文件名为：FSO_CARRIER_CHINAMOBILE.png

联通：

改彩色的文件名为：Default_CARRIER_CHINAUNICOM.png 
改黑白的文件名为：FSO_CARRIER_CHINAUNICOM.png

iPhone 特殊文件目录介绍：

1. 【/private/var/mobile】 
新刷完的机器，要在这个文件夹下建一个Documents的目录。

2. 【/private/var/mobile/Applications】 
通过AppStore和iTunes安装的程序都在里面。

3. 【/private/var/stash】 iPhone4这条不能用 
这个文件夹下的Applications目录里面是所有通过Cydia和app安装的程序，Ringtones目录里是所有的手机铃音，自制铃音直接拷在里面即可，Themes目录里是所有Winterboard主题，可以手工修改。

4. 【/var/mobile/Media/ROMs/GBA】 
gpsPhone模拟器存放rom的目录。

5. 【/var/mobile/Media/textReader】 
textReader看书软件读取的电子书的存放路径。

6. 【/System/Library/Fonts/Cache】 
系统字体目录，要替换的字体放在该目录下，权限644不变

7. 【/private/var/mobile/Media/Maps】 
离线地图目录，把地图文件夹放到该目录下，文件夹赋予777权限

8. 【/private/var/mobile/Library/Downloads】 
ipa文件存放目录，用Installous安装

9. 【/private/var/mobile/Library/Keyboard】 
系统拼音字库文件位置

10. 【/var/stash/Themes.XXXXXX】 iPhone4这条不能用 
winterboard主题文件存放路径

11. 【/private/var/mobile/Media/DCIM/999APPLE】 
系统自带截屏文件存放路径

一.进程优化:

优化内存的操作最好用WinSCP，用91手机助手也可以可以。

这些后台进程的启动程序都存放在

【/System/Library/LaunchDaemon】目录下,就是那些【.plist】文件.要不启动这些进程的最简单的方法就是删除相应的【.plist】文件. 
前先一定要备份,以防万一！你可以在你的iPhone或iPod的【/private/var/】下面建一个【backup】目录,然后把要删除的【.plist】文件用iFile直接剪切并存储到【backup】目录下 ，或者直接备份整个【/System/Library/LaunchDaemon】目录！

完全可以安全删除的进程:  

1. com.apple.DumpPanic.plist -这是苹果公司用来评估系统崩溃的,完全没必要运行.   
2. com.apple.DumpBasebandCrash.plist -这是苹果公司用来苹果基带崩溃的,也没必要运行.   
3. ReportCrash -有5个带"ReportCrash"的".plist"文件,都是用来收集系统或系统程序崩溃的信息,没什么用处.   
4. com.apple.CrashHouseKeeping.plist -也是和程序崩溃相关的,可以删.   
5. com.apple.powerlog.plist -用来监测第三方不兼容的充电器,可以删.   
6. com.apple.tcpdump.server.plist -似乎是用来转存网络数据的,具体不是很清楚,但删除后不影响设备.   
7.com.apple.chud.chum.plist -这个进程应该和苹果的CHUD工具相关(计算机硬件协议开发/ComputerHardware Understanding Developer).如果你不是一个软件开发者,应该不用启动这个进程.   
8. com.apple.chud.pilotfish.plist -着也是和苹果CHUD工具相关的一个进程.如果你不开发苹果软件,可以删除这个. 要稍微谨慎一点处理的进程-有些用户可以禁用以下几个进程.  

选择性删除： 
1. com.apple.AddressBook.plist -如果不启动这个进程,那么电话中的通讯录的载入速度会稍微变慢一些.若不介意这一点,则可以删除这个进程.   
2. com.apple.accessoryd.plist -不启动这个进程就会禁用一些辅助设备功能,例如: FM收音机, iPhone座充, AV数据线.当然,即便禁用了这个进程,用iPhone座充还是能充电,但也只能有充电的功能啦.   
3. com.apple.dataaccess.dataaccessd.plist -禁用了这个进程,就不能通过Exchange或者Google来同步了.   
4. com.apple.datamigrator.plist -这个进程的作用是把联系人从你的SIM卡传到你的iPhone里. iPod用户就没必要启动它了.尽管我是iPhone,但我也没有启动它,因为我从来不在SIM卡中存联系人.   
5. com.apple.racoon.plist -这是ＶＰＮ需要的进程.若你不用ＶＰＮDaiLi,那就不需要启动了.   
6. com.apple***leInternetSharing.plist -这是网络共享功能. iPod用户完全可以删除. iPhone用户就看你自己是否需要网络共享.其实真没啥作用.   
7. com.apple.aggregated.plist -这个应该和"音频输入"有关.第一代的iPod完全不需要这个进程.第二代iPod可以根据自己的需要来决定. iPhone用户需要这个进程.   
8. com.apple.AOSNotification.plist -这是同步MobileMe用的.不用MobileMe的人完全不需要它.   
9.com.apple.AdminLite.plist-这个进程的作用是:当某个程序启动或反应时间过长,则iPhone或iPod会自动终止这个程序(即:让程序崩溃),从而把控制权转交到你手中.如果你不愿意经常看到程序崩溃,那么你可以关闭这个进程,但结果是,当遇到某个程序启动或反应过慢时,你得多等一会儿.一般情况下不建议关闭这个进程.   
10. com.saurik.Cydia.Startup.plist -安装Cydia后产生的进程,应该是用来执行自动安装deb软件的.其实完全可以禁用它,我更喜欢用MobileTerminal来安装deb软件.  

二.服务优化:  
4.01通讯录解决排序混乱的方法（包括英文名） 
设置——通用——多语言环境——语言 改成ENGLISH， 然后区域格式 中国，然后，再把 多语言环境 语言改成 中文。 
XX或多装了一些应用程序后，都存在反应慢、很卡或者无故退出等问题。这都是因为运行内存不足造成的，下面的教程可以解决这个问题。

步骤:

(1)首先我们需要安装BossPrefs，请从Cydia上下载最新版本。 
(2)需要下载一些服务开关插件 
(3)安装Bossprefs。 
(4)将Svrs Svrs

7个文件上传到/private/var/stash/Applications.xxxxxx/BossPrefs.app/services/文件夹中。(用户:root 权限:777)

(注意:是将Svrs内的7个文件上传,而不是将Svrs文件夹上传!)

(5)运行BossPrefs，可以看到你手机的所有服务。大家可以按需要随时启动或关闭上述服务，无需重启iPhone，效果等同于Windows的服务管理器——当你在BossPrefs关闭上述任一服务时，会立即从内存中关闭该项服务，并把占用的内存释放出来。当选择打开该服务时，则会立即启动该项服务。

(6)部分服务解释以及建议：

大部分的服务大家应该都看的明白，我说一下比较重点的服务

FairPlaydSvr：FairPlayd服务，占用17M内存；（注意：这个不能关闭，否则有些程序运行不了！） 
SysLogdSvr：iPhone日志服务，占用13M内存；（可以关闭！） 
UpdateSvr：iPhone更新服务，占用12M内存；（可以关闭！） 
Wiki2touchSvr：wiki服务，占用20M内存。（可以关闭！）

上述服务，平时都可关掉，当要用服务时，只需到BossPrefs中启动相应服务即可，无需重启手机。