---
layout: post
title: "爬虫必备-Python抓包"
date: 2015-10-15 11:03:23 +0800
comments: true
categories: Full Stack
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

 

由于最近都在研究网络爬虫技术，自己也总结了一些。借助一个朋友（boyXiong）的博文，了解到了python抓包技术，所以就整理到这里，希望你能喜欢！

####准备搭建环境 
因为是MAC电脑，所以自动安装了Python 2.7的版本


添加一个 库 Beautiful Soup ,方法这里说两种 

* 1.在终端输入 pip install BeautifulSoup
* 2.手动下载包后，终端切换到 解压的文件夹，输入 sudo python setup.py install 下载地址BeautifulSoup



<!--more-->




####开始写代码吧 
先找一个想要抓取东西的网站，这里我就随便找一个吧 地址是：http://movie.douban.com/chart
好了在终端输入 vim 我知道这个东西，对于新手来说，就是一个挑战，这里我也建议使用轻量的Sublime
代码如下 (注意python是严格的缩进,以下代码要顶格写)

	#-*- coding:utf-8 -*-
	import urllib2
	import urllib
	html=urllib2.urlopen("http://movie.douban.com/chart").read()
	print html

输出的结果就是一个HTML的网页，这里我就看到自己想要抓取的图片和图片名的文字片段

	<a class="nbg" href="http://movie.douban.com/subject/24879839/"  title="道士下山">
	           <img src="http://img3.douban.com/view/movie_poster_cover/ipst/public/p2251450614.jpg" alt="道士下山" class=""/>
	</a>

分析我们想要的，一个是图片的名称，一个是图片的链接地址，直接上Python代码
	#-*- coding:utf-8 -*-
	import urllib2
	from bs4 import BeautifulSoup
	
	import sys  
	reload(sys)  
	sys.setdefaultencoding('utf8')
	
	# 函数
	def  printPlistCode():
	    #1.得到这个网页的 html 代码 #
	    html = urllib2.urlopen("http://movie.douban.com/chart").read()
	
	    #2.转换 一种格式，方便查找
	    soup = BeautifulSoup(html)
	    #3.  得到 找到的所有 包含 a 属性是class = nbg 的代码块,数组
	    liResutl = soup.findAll('a', attrs = {"class" : "nbg"})
	    #4.用于拼接每个字典的字符串
	    tmpDictM = ''
	
	    #5. 遍历这个代码块  数组
	    for li in liResutl:
	
	        #5.1 找到 img 标签的代码块 数组
	        imageEntityArray = li.findAll('img')
	
	        #5.2 得到每个image 标签
	        for image in imageEntityArray:
	            #5.3 得到src 这个属性的 value  后面也一样 类似 key value
	            link = image.get('src')
	            imageName = image.get('alt')
	            #拼接 由于 py中 {} 是一种数据处理格式，类似占位符
	            tmpDict = '''@{0}@\"name\" : @\"{1}\", @\"imageUrl\" : @\"{2}\"{3},'''
	
	            tmpDict =  tmpDict.format('{',imageName,link,'}')
	
	            tmpDictM = tmpDictM + tmpDict
	
	    #6.去掉最后一个 , 
	    tmpDictM = tmpDictM[0:len(tmpDictM) - 1].decode('utf8')
	
	    #7 拼接全部
	    restultStr = '@[{0}];'.format(tmpDictM)
	
	    print restultStr
	
	
	if __name__ == '__main__':
	    printPlistCode()

输出结果就是Objective-C的 数组

	@[@{@"name" : @"进击的巨人真人版：前篇", @"imageUrl" : @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p2251690571.jpg"},@{@"name" : @"花与爱丽丝杀人事件", @"imageUrl" : @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p2222398443.jpg"},@{@"name" : @"小黄人大眼萌", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2258235689.jpg"},@{@"name" : @"小森林 冬春篇", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2215147728.jpg"},@{@"name" : @"道士下山", @"imageUrl" : @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p2251450614.jpg"},@{@"name" : @"深夜食堂 电影版", @"imageUrl" : @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p2205014862.jpg"},@{@"name" : @"小男孩", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2230105606.jpg"},@{@"name" : @"头脑特工队", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2231021196.jpg"},@{@"name" : @"百元之恋", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2205471169.jpg"},@{@"name" : @"杀破狼2", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2246885606.jpg"}];

使用Xcode 写到Plist中去
	
	#import <Foundation/Foundation.h>
	
	int main(int argc, const char * argv[]) {


    NSArray *plistArray = @[@{@"name" : @"进击的巨人真人版：前篇", @"imageUrl" : @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p2251690571.jpg"},@{@"name" : @"花与爱丽丝杀人事件", @"imageUrl" : @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p2222398443.jpg"},@{@"name" : @"小黄人大眼萌", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2258235689.jpg"},@{@"name" : @"小森林 冬春篇", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2215147728.jpg"},@{@"name" : @"道士下山", @"imageUrl" : @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p2251450614.jpg"},@{@"name" : @"深夜食堂 电影版", @"imageUrl" : @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p2205014862.jpg"},@{@"name" : @"小男孩", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2230105606.jpg"},@{@"name" : @"头脑特工队", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2231021196.jpg"},@{@"name" : @"百元之恋", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2205471169.jpg"},@{@"name" : @"杀破狼2", @"imageUrl" : @"http://img4.douban.com/view/movie_poster_cover/ipst/public/p2246885606.jpg"}];
    //路径可以自己选择
    [plistArray writeToFile:@"/Users/xxx/Desktop/test/movie.plist" atomically:YES];

    return 0;

到这里，就可以看到plist 文件可以用于测试了 




{% img /images/python001.png Caption %}  


这里写图片描述
如果想要复制粘贴这里面的代码，那就选择Sublime编辑器




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