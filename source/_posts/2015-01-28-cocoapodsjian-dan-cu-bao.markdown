---

layout: post
title: "cocoaPods简单粗暴"
date: 2015-01-28 00:32:20 +0800
comments: true
categories: 开发工具

---



直接上代码，不要问为什么，照着做就可以，我也是这么做的，具体的细节，请查看相关文档，网上太多！

 

1:移除ruby镜像（天朝的网你们懂的）

	 $ gem sources --remove https://rubygems.org/ 

 

2:新增淘宝镜像

	$ gem sources -a http://ruby.taobao.org/ 

 

3:查看列表

	 $ gem sources -l 

成功的征兆：

	*** CURRENT SOURCES ***
	http://ruby.taobao.org/
	$ sudo gem install cocoapods
 

4:正式安装

	 sudo gem install cocoapods 

 

接下来就是开始使用了。

 

查看对应的框架

	 $ pod search AFNetworking 

 

创建文件

	 $ vim Podfile 

 或者在命令行行中cd到对应的项目文件夹使用

	touch Podfile
	
新建一个文件

 

然后在Podfile文件中输入以下文字：

	platform :ios, '7.0'
	pod "AFNetworking", "~> 2.0”
 

 

安装

	 pod install  

更新

	 $ pod update 

 

有时候可能上面的命令没有用可能是网络的原因，那么你可以试试下面的：

	pod update 换成pod update --verbose --no-repo-update
	pod install 换成pod install --verbose --no-repo-update

 

+ $ pod install只会按照Podfile的要求来请求类库，如果类库版本号有变化，那么将获取失败。
$ pod update会更新所有的类库，获取最新版本的类库。
或许还有一些情况是因为mac中对应的文件有问题，比如有两个Xcode的时候就会发生歧义（系统不知道用哪个），这个时候我们可以试试下面的方法。

CocoaPods安装东西的时候它要找到Xcode的Developer文件夹, 如果找不到会报如下错误 

- 解决方案

LNJ替换为你自己的用户名
	
	sudo xcode-select --switch /Users/LNJ/Applications/Xcode.app/Contents/Developer
      
而且你会发现，如果用了 $ pod update，再用 $ pod install 就成功了。

+ 那你也许会问，什么时候用 $ pod install，什么时候用 $ pod update 呢，我又不知道类库有没有新版本。

+ 好吧，那你每次直接用 $ pod update 算了。或者先用 $ pod install，如果不行，再用 	
	`$ pod update。`
	

当然你也可以使用Xcode插件，使用非常简单，这里就不多介绍，以后有机会给大家整理：


[cocoapods-xcode-plugin](https://github.com/kattrali/cocoapods-xcode-plugin)

