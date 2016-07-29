---

layout: post
title: "反编译App小菜篇"
date: 2016-05-01 13:53:19 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



---  


前面介绍了那么多关于反编译的问题，也没有真正实战几下，这里简单的教你装一下13，希望大鸟看到不要笑。

纯属个人即时玩玩，但是对于小菜还有有点用的，或者没有接触过的人！



<!--more-->



###获取App所有.h文件

第一步安装class-dump（class-dump可以提取.ipa中的.h文件）。
安装：
1. 下载地址 http://stevenygard.com/projects/class-dump/
2. 终端中输入open /usr/bin
3. 将解压出来的class-dump放入刚打开的目录。     
4. 更改class-dump权限     sudo chmod 777 /usr/bin/class-dump

#####线下版
1.新建一个App修改里面相关代码运行。
 
2.打开Products文件夹下的DecompilingTest.app所在目录

3.显示包内容，拿到二进制文件。

4.复制到桌面，执行以下命令，即可拿到工程中的.h文件

>class-dump -H Name

##### 线上版


举例：
1.首先下载一个.ipa文件。
 
2.将文件名改为.zip结尾

3.然后在解压出对应的文件夹

4.在该文件夹中找到

这个就是目标文件。


最后终端进入到纯在该文件的路径 ，运行class-dump -H Flap.app -o Flap就可以得到一个，这个文件夹中就是flappy中的所有头文件。

但是你可能会发现只有一个.h文件CDStructures.h，而且里面撒野没有，这里就证明苹果进行了加壳。

后面我们就开始怎么先处理这一层壳

>class-dump 命令的参数可以在终端中运行 class-dump --help查看


###取方法的实现

安装Hopper Disassembler（这里就不用说了，不像class-dump，傻瓜式操作）

用法很简单，只要将二进制文件拖进去就行了

。。。。。
