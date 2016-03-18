---
layout: post
title: "资源文件夹获取"
date: 2016-03-12 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---


用pngcrush反编译ios app 资源文件

时间：2012-12-27 11:56:45 类别：ios开发 访问: 3705 次

要提高app制作水平，最好的方法就是学习领先者，用pngcrush反编译ios app 资源文件，步骤很简单





<!--more-->




1. 在电脑的itunes中下载你选中的app，下载完成之后，然后在finder里面找到对应的ipa包，也可以在91等市场中直接下载ipa文件

2. ipa文件其实是zip包，重命名为zip后缀文件之后，双击打开
找到 xxx.app 文件，这其实是个目录，点击右键，在菜单中选中“查看包内容”，就可以进入目录，然后看到大量的资源文件，这些png文件都直接放在app的根目录，你可以在finder中直接浏览

3. 但是这些png文件都是打包过程中被压缩过的，photoshop无法正确识别 （ 注：打包app的时候，你可以在xcode project选项中选择对png文件不压缩）

4. 要把这些png文件还原，可以通过一个名叫 pngcrush 的开源软件，你可以到 sourceforge 下载，实际上ios的sdk也提供了这个程序（xcode就是利用它压缩png的）xcrun -sdk iphoneos -find pngcrush 可以获得 pngcrush的安装目录，然后直接使用，或者在你的$PATH目录里面做一个符号链接，这样可以在console窗口直接敲pngcrush


进入资源文件存放目录，打开对应的命令行窗口，执行下面的命令即可
    
    
	pngcrush -d xxx reverted -revert-iphone-optimizations -q *.png
	pngcrush -e xxx reverted -revert-iphone-optimizations -q *.png

上面提到的方法都是在mac操作系统下面，如果是windows/linux也可以用，pngcrush也提供了对应的版本