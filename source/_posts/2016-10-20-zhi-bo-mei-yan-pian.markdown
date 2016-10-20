---
layout: post
title: "直播-推流篇"
date: 2016-09-28 10:09:42 +0800
comments: true
categories: 
---

###前言

开发一款直播app，肯定需要流媒体服务器，本篇主要讲解直播中流媒体服务器搭建，并且讲解了如何利用FFMPEG编码和推流，并且介绍了FFMPEG常见命令。


{% img /images/ioszhibotuiliu001.png Caption %}  



##一、安装Homebrew

Homebrew简称brew，是Mac OSX上的软件包管理工具，能在Mac中方便的安装软件或者卸载软件。

######1、打开终端, 查看是否已经安装了Homebrew, 直接终端输入命令

*    man命令:manual（手册）的缩写，可以查看某一命令的帮助信息，比如git,brew,顺便可以查看有没有按照这个命令.

man brew


{% img /images/ioszhibotuiliu002.png Caption %}  




######2、 执行命令，安装Homebrew

执行命令后，需要按回车，并且需要输入电脑密码。

	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


{% img /images/ioszhibotuiliu003.png Caption %}  



##二、利用安装nginx

######1.Nginx：Nginx是一个非常出色的HTTP服务器，其特点是占有内存少，并发能力强，事实上nginx的并发能力确实在同类型的网页服务器中表现较好。

从github下载Nginx到本地,增加home-brew对nginx的扩展

	brew tap homebrew/nginx



{% img /images/ioszhibotuiliu004.png Caption %}  




######2.安装Nginx服务器和rtmp模块

brew install nginx-full --with-rtmp-module


{% img /images/ioszhibotuiliu005.png Caption %}  




######3.查看是否安装成功
在浏览器地址栏输入：

	http://localhost:8080 （直接点击）
如果出现下图, 则表示安装成功


{% img /images/ioszhibotuiliu006.png Caption %}  



##三、配置rtmp

######1.查看nginx配置文件安装在哪

brew info nginx-full

######2.用xcode打开配置文件，滚动到最后面(最后一个}后面即可，不能在{}里面)，添加一下代码，进行配置，最后记得保存

	rtmp {
	    server {
	        listen 1990;
	        application liveApp {
	            live on;
	            record off;
	        }
	    }
	}


{% img /images/ioszhibotuiliu007.png Caption %}  




    application：流媒体上应用名称，可以随意填

######3.重新加载nginx的配置文件

nginx -s reload

##四、安装ffmepg进行推流

	brew install ffmpeg


{% img /images/ioszhibotuiliu008.png Caption %}  



##五、使用ffmepg推流测试

	ffmpeg -re -i (视频全路径) -vcodec copy -f flv (rtmp路径

	ffmpeg -re -i /Users/yuanzheng/Desktop/02-如何学习项目.mp4 -vcodec copy -f flv rtmp://localhost:1990/liveApp/room

需要跟配置的一一对应，端口，应用名称，room可以随便写
    
    延时：发送流媒体的数据的时候需要延时。不然的话，FFmpeg处理数据速度很快，瞬间就能把所有的数据发送出去，流媒体服务器是接受不了的。因此需要按照视频实际的帧率发送数据
    -re: 一定要加，代表按照帧率发送，否则ffmpeg会一股脑地按最高的效率发送数据
    -i : 输入文件
    -vcodec copy: 强制使用codec编解码方式，要加，否则ffmpeg会重新编码输入的H.264裸流
    -f 强制转换为什么格式，后接格式
    ffmpeg参数中文详细解释

##六、使用VLC播放rtmp推流

######1.下载VLC

######2.打开VLC,输入直播地址，cmd + N


{% img /images/ioszhibotuiliu009.png Caption %}  




{% img /images/ioszhibotuiliu010.png Caption %}  



##七、用ffmpeg抓取桌面以及摄像头推流进行直播

######1.首先查看ffmpeg是否支持对应的设备，在OSX下面，Video和Audio设备使用的是avfoundation，所以可以使用avfoundation来查看

	ffmpeg -f avfoundation -list_devices true -i ""



{% img /images/ioszhibotuiliu011.png Caption %}  




######2.抓取桌面和摄像头进行推流

	ffmpeg -f avfoundation -framerate 30 -i "1:0" -f avfoundation -framerate 30 -video_size 640x480 -i "0" -c:v libx264 -preset slow -filter_complex 'overlay=main_w-overlay_w-10:main_h-overlay_h-10' -acodec libmp3lame -ar 44100 -ac 1  -f flv rtmp://localhost:1990/liveApp/room

    -f avfoundation 转换为avfoundation
    -framerate 30 : 设置帧率 30
    -i "1:0" : 设置输出，视频：Capture screen 音频：Built-in Microphone
    -f avfoundation -framerate 30 -video_size 640x480 ： 设置帧率和视频尺寸
    -c:v libx264 设置视频编码，H.264编码 优点是同等清晰度，视频文件更小 缺点就是转换慢
    -c:v flv 标准FLV编码 这个好处是速度快 清晰度高的话 视频文件会比较大
    -preset slow 使用慢速模式 延迟长 清晰度高
    ffmpeg的转码延时测试与设置优化
    -filter_complex 'overlay=main_w-overlay_w-10:main_h-overlay_h-10':给视频打水印
    -acodec libmp3lame 強制指定音频处理模式
    -ac 1 声道选择
    -ar 44100 音频赫兹


===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  