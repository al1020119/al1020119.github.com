---
layout: post
title: "常见越狱方法"
date: 2016-03-04 15:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---

{% img /images/bgHeader.png Caption %}  



iOS设备的越狱方法

最近公司的事情很忙，在开发一个类似于微信的App，经常加班，所以也没有时间去更新微信公众账号的内容了。iOSJailbreak, 申请这个账号大概有一个多月了吧，发布的内容不多，更多是针对开发者的内容，针对普通iPhone & iPad用户的内容几乎没有，有收听的朋友经常发问，怎样去越狱，怎样去开发越狱的插件或者app。后面都会细细道来。

###一、先说iPhone 5S 和 iPhone5C吧
最新的iPhone又要出来了，大概是9月21号左右美国和香港应该是可以购买的。新的iOS7应该是在9月16号发布。5C有5个颜色，配截图。

> 其实我是大概在今年3月底4月初的时候听 富士康那边的朋友说的，有一款中端版本的iPhone5C, 价格大概在3000左右，估计香港，美国那边的更便宜，应该是2000+的样子。等待新机的到来，其实iPhone5的感觉就是轻，拿着很舒服。估计5C应该也差不多。






<!--more-->




###二、怎么越狱

越狱有很多种方法和工具，红雪的 (redsn0w)  ， 绿毒的(greenp0ison)，Absinthe， evasi0n等等， 还有一些其他的，不怎么知名，当然也比不上上面的了，就不过多介绍了。
我在网上找了相关的越狱教程，因为涉及到的系统版本，设备型号太多了，无法逐一验证。找了一个靠谱的链接，绝不是广告哦，我亲测过。
这个网站上几乎针对每种系统，每种机型都可以越狱。

* 链接一、在这个链接里面选择对应的设备类型，比如iPhone5， iPad mini等等。
http://jb.appvv.com/shebei/

* 链接二、选择对应的设备之后，进入到选择设备对应的系统版本页面，不同的机型有差别，比如这个是4s的
http://jb.appvv.com/shebei/iphone4s/

链接三、在选择对应的设备和系统版本之后，就可以自己开始越狱了，严格按照教程操作，比如4s的, iOS6.1.2的版本就可以按照如下链接操作
http://jb.appvv.com/news/19806.shtml

有时间可以多看下网站上的内容。


###三、关于越狱的安全性等问题
很多人说，越狱的iPhone存在着安全性问题，从一个方面来讲，确实存在这样的问题。但是这并不是iOS系统的问题，包括Windows, Android系统都存在问题。同样的前提下，iOS的安全性绝对要高的多。听说过Windows系统下，Android系统下用户的账号被盗用，卡被盗刷的情况，但是iOS系统下的我没听说过类似的情况，包括越狱的iOS系统，安全性依然很高。

手机本来就是用来玩儿，越狱之后有很多好用的插件，还可以免费装各种应用，还有输入法，黑名单等等，一系列的“好处”吧。但是越狱之后，手机的安全性还是值得警惕，涉及到银行转账和交易的时候最好双方确认好，避免被骗。
总之越狱之后可玩儿性更高一些。对于越狱我保持中立吧，有些人拿着手机就打打电话，发发微信，不想折腾。喜欢玩儿的人，可以去试试。

> PS：之前我越狱了自己的iPad，把微信的打飞机刷了200多万分，天天爱消除刷了180W分，越狱之后用插件弄的。我推测了一下，手工打的话，打飞机不会超过160W分，后面太难了，大飞机太多了。爱消除我只用了40S刷了180W分，后面都没管了。大家可以自己试试。

####实例方案

办法1.

int xx=fork() //这个函数从这里起，程序被分为两个进程，父和子，子进程，返回0，父进程返回子进程ID，如果执行fork成功，说明沙盒被破坏，说明越狱了
if(!xx)。//子进程，关闭他
{
     exit(0);
}
if(xx>=0)父进程，说明越狱
{
return 1;
}
return 0 ;//，没有越狱，返回-1，

办法2
检测cydia.app是否存在
    struct stat s;
    int is_jailbroken=stat("/Applications/Cydia.app", &s);
    NSLog(@"-----is_jailbroken=%d----",is_jailbroken);//返回为0说明有Cydia.app，否则-1
或者
   struct stat s;
    int is_jailbroken=stat("/Library/MobileSubstrate/DynamicLibraries/MobileSubstrate.dylib", &s);
    NSLog(@"-----is_jailbroken=%d----",is_jailbroken);


办法3.判断文件大小


struct stat s
stat(“/etc/fstab”,&s);
return s.st_size 


===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  