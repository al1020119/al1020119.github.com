---
layout: post
title: "Node.js是什么鬼？"
date: 2017-01-12 11:18:13 +0800
comments: true
categories: 
---





######Node.js介绍

    Node.js什么时候出现，2009年，Ryan Dahl(瑞恩·达尔)在GitHub上发布了最初版本的部分Node.js包，随后几个月里，有人开始使用Node.js开发应用
    什么是Node.js,做过Javascript开发的，看到Node.js这个名字，初学者可能会误以为这是一个Javascript应用，事实上，Node.js采用C++语言编写而成，是一个Javascript的运行环境，意思就是底层使用c++编写，外层封装采用Javascript，需要使用Javascript解析执行。
    比如OC底层也是c++，但是执行代码，只需要解析OC代码。
    Node.js是一个后端的Javascript运行环境，这意味着你可以编写服务器端的Javascript代码，交给Node.js来解释执行。

<!--more-->

######Node.js工作原理与优缺点（了解一门语言的开始）

    传统Web服务器原理(T):传统的网络服务技术，是每个新增一个连接（请求）便生成一个新的线程，这个新的线程会占用系统内存，最终会占掉所有的可用内存。

    Node.js工作原理(T)：只运行在一个单线程中，使用非阻塞的异步 I/O 调用，所有连接都由该线程处理，也就是一个新的连接，不会开启新的线程，仅仅一个线程去处理多个请求。

    优缺点：
        传统的比较消耗内存，Node.js只开启一个线程，大大减少内存消耗。
        假设是普通的Web程序，新接入一个连接会占用 2M 的内存，在有 8GB RAM的系统上运行时, 算上线程之间上下文切换的成本，并发连接的最大理论值则为 4000 个。这是在传统 Web服务端技术下的处理情况。而 Node.js 则达到了约 1M 一个并发连接的拓展级别
        Node.js弊端:大量的计算可能会使得 Node 的单线程暂时失去反应, 并导致所有的其他客户端的请求一直阻塞, 直到计算结束才恢复正常

    疑问？Node.js是单线程的。单线程怎么开启异步?怎么工作的？ 需要了解事件驱动。

    什么是事件驱动?
    传统的web server多为基于线程模型。你启动Apache或者什么server，它开始等待接受连接。当收到一个连接，server保持连接连通直到页面或者什么事务请求完成。如果他需要花几微妙时间去读取磁盘或者访问数据库，web server就阻塞了IO操作（这也被称之为阻塞式IO).想提高这样的web server的性能就只有启动更多的server实例。
    Node.Js使用事件驱动模型，当web server接收到请求，就把它关闭然后进行处理，然后去服务下一个web请求。当这个请求完成，它被放回处理队列，当到达队列开头，这个结果被返回给用户。这个模型非常高效可扩展性非常强，因为webserver一直接受请求而不等待任何读写操作。（这也被称之为非阻塞式IO或者事件驱动IO）
    本质:当然最终处理事件还是需要底层开启线程，只不过接受请求只用一个线程去接收。

######Node.js使用介绍

    Node.js使用Module模块去划分不同的功能，以简化App开发，Module就是库，跟组件化差不多，一个功能一个库。
    NodeJS内建了一个HTTP服务器，可以轻而易举的实现一个网站和服务器的组合，不像PHP那样，在使用PHP的时候，必须先搭建一个Apache之类的HTTP服务器，然后通过HTTP服务器的模块加载CGI调用，才能将PHP脚本的执行结果呈现给用户
    require() 函数，用于在当前模块中加载和使用其他模块；

######Express模块(框架)

    Express是Node.JS第三方库
    Express可以处理各种HTTP请求
    Express是目前最流行的基于Node.js的Web开发框架，
    Express框架建立在node.js内置的http模块上，可以快速地搭建一个Web服务器
    
###Node搭建服务器及使用

####方案一：

    打开终端，输入node -v，先查看是否已经安装
    如果没有安装，就需要安装node软件。
    mac上可以使用Homebrew，安装node
        Homebrew:Homebrew简称brew，是Mac OSX上的软件包管理工具，能在Mac中方便的安装软件或者卸载软件,相当于window上360管家，可以帮你下载软件。

    先输入brew -v,查看mac是否安装了HomeBrew
        安装ruby教程(http://www.jianshu.com/p/daa92187621c)
        使用ruby安装Homebrew，前提是安装了ruby
        输入指令安装brew

       ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    使用Homebrew安装Node，输入指令

    brew install node

    安装完，输入`node -v``查看是否安装成功
######二、安装NPM
    NPM是随同NodeJS一起安装的包管理工具，用于下载NodeJS第三方库。
    类似iOS开发中cocoapods，用于安装第三方框架
    新版的NodeJS已经集成了npm，所以只要安装好Node.JS就好

######三、利用NPM下载第三方模块（Express和Socket.IO）

    package.json
        package.json类似cocoapods中的Podfile文件
        package.json文件描述了下载哪些第三方框架.
        可以使用npm init创建
        需要添加dependencies字段，描述添加哪些框架,其他字段随便填
        注意：不能有中文符号

         "dependencies": {
               "express": "^4.14.0",
               "socket.io": "^1.4.8"
             }

######四、执行npm install,就会自动下载依赖库

	npm install

####方案二：

######step1

或者你如果不喜欢使用命令的话这个方案相信是最好的选择。

    访问nodejs官网，点击蓝色选框区域稳定版，并下载https://nodejs.org/en/

######step 2：

    双击刚下载的文件，按步骤默认安装就行

######step 3：

    安装完成后打开终端，输入
    npm -v
    node -v
    两个命令，如下图出现版本信息，说明安装成功。



####使用

使用上面任何一种种方式完成以后，就可以开始测试了。

新建一个js文件，nodejsTest.js , 输入下面的代码, 并保存


	var http = require("http");
	
	http.createServer(function(request, response) {
	    response.writeHead(200, {
	        "Content-Type" : "text/plain"
	    });
	    response.write("Welcome to Nodejs");
	    response.end();
	}).listen(8000, "127.0.0.1");
	
	console.log("Creat server on http://127.0.0.1:8000/");


####测试

打开终端进入 nodejsTest.js 所在目录， 输入 node nodejsTest


{% img /images/node0001.png Caption %}  

打开浏览器，点击或者输入http://127.0.0.1:8000/， 如果无法打开，可以去掉.listen(8000, “127.0.0.1”) 中得ip监听改成 .listen(8000)，然后点击或者输入http://localhost:8000/


{% img /images/node0002.png Caption %}  


关于Node.js其他的相关配置可以查看[http://www.jianshu.com/p/d76ecf5ed690](http://www.jianshu.com/p/d76ecf5ed690),笔者也就是好奇所以是了一下，希望不会被喷。


>后面有机会会结合客户端实现数据的交互相关处理。



参考：
[http://www.ruanyifeng.com/blog/2014/10/event-loop.html](http://www.ruanyifeng.com/blog/2014/10/event-loop.html)

[http://www.csdn.net/article/a/2016-07-12/3358](http://www.csdn.net/article/a/2016-07-12/3358)

[http://www.yiibai.com/nodejs/nodejs-quick-start.html](http://www.yiibai.com/nodejs/nodejs-quick-start.html)








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