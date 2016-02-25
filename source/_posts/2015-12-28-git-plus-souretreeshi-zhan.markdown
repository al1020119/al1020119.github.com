---
layout: post
title: "Git+SoureTree实战"
date: 2015-12-28 12:28:06 +0800
comments: true
categories: Tools
---

由于之前一直使用SVN（Cornerstone），最近手痒痒的想弄一下git，听说soureTree不错，就花了一段时间研究了一下，并记录下来！



GitHub相信大家都知道，上面有很多优秀的开源项目供我们学习，比较著名的类似AFNetworking、SDWebImage等等。本篇文章就是教大家如何在Mac系统下提交自己的项目到GitHub上，相信对于新手还是很有帮助的。

##首先我们必须先从git命令开始，没有为什么！



###需要的工具

+ 1.安装Git  http://git-scm.com/download/mac 我下的是2.2.1版本的。

+ 2.终端 (自带的，请允许我卖个萌。。。)


###操作流程

+ 1.GitHub 上注册账号  https://github.com/ 去这上面注册下就行（这里就不多说，自己去做吧）。

+ 2.配置 SSH key


<!--more-->




	-  ①  defaults write com.apple.finder AppleShowAllFiles -bool true     终端 显示隐藏文件（需要重新运行Finder)。

	-  ② 点击桌面顶部菜单  前往>个人  看看自己电脑上有没有个 .ssh 的隐藏文件，有的话个人建议删除，新建个。

	-  ③  mkdir .ssh    终端新建个 .ssh文件

	-  ④  cd .ssh   进入到刚才新建的.ssh文件目录下 

	-  ⑤  ssh-Keygen -t rsa -C "your_email@example.com"       后面“ ”里面 随意输入个邮箱就行,回车会提示你输入密码什么的，可以无视一直回车下去。

	-  ⑥  ls -la      查看是否存在 id_rsa(私钥)  id_rsa.pub(公钥) 这两个东西，如果存在就成功了。

	-  ⑦ pbcopy < ~/.ssh/id_rsa.pub     拷贝 公钥

	-  ⑧ 进入GitHub 登入 。 
 
			添加你刚才生成的SSH Key 到GitHub上，也就是最后一张图的 Add SSH Key 点击 会让你输入秘钥 以及秘钥的名称。 秘钥 pbcopy < ~/.ssh/id_rsa.pub 这个终端命令就已经复制过了  直接command + V 粘贴上去就行，秘钥名称随意。


{% img /images/git004.png Caption %}  


{% img /images/git005.png Caption %}
  

ssh -T git@github.com   新添加到github上的秘钥左边的点一开始是灰色的，终端执行这个命令后，刷新网页会看到灰色点变成了绿色。


{% img /images/git006.png Caption %}  


+ 3.在GitHub 上创建公开项目。

 

{% img /images/git001.png Caption %}  


{% img /images/git002.png Caption %}  


{% img /images/git003.png Caption %}  



+ 4.上传本地项目到GitHub。

	-  ① 在电脑上新建个项目文件夹 。

	-  ②  cd + 刚才新建的项目文件夹路径

	-  ③  git clone + GitHub 上创建的项目地址    （GitHub 上创建的项目地址如下图所示）这样你在GitHub 上创建的项目就克隆下来了

	-  ④ cd + 克隆下来的项目路径 （如何在终端输入路径，可以直接把你想要知道路径的文件夹拖到终端里 这样自动就要该文件夹的路径了）

	-  ⑤ git init    (git 仓库的初始化)

	-  ⑥ git add .    (这里注意：add 空格 再加 .)

	-  ⑦ git status    (查看add 成功没)

	-  ⑧ git commit -m "描述"   （“ ” 引号里面输入你的描述 随意）

	-  ⑨ git push origin master        (最后push到GitHub上)


{% img /images/git007.png Caption %}  


到这里大概结束了，祝大家能够在GitHub上发起更多好的项目，发扬光大开源精神！


{% img /images/git008.png Caption %}  



***

##SourceTree
 
 
> 简介
SourceTree 是 Windows 和Mac OS X 下免费的 Git 和 Hg 客户端，拥有可视化界面，容易上手操作。同时它也是Mercurial和Subversion版本控制系统工具。支持创建、提交、clone、push、pull 和merge等操作。
  

关于SourceTree的下载，github的账号注册，仓库的创建这里就不介绍了，亦或者没有什么好说的，因为会用电脑都会做，而且前面已经介绍过了，一部分。我们就从上面做好的所用项目中最后一步开始。看卡下面的图片：
  
{% img /images/git008.png Caption %}  
  

#####SourceTree基本使用

> 以下以SourceTree For Mac V2.0.5.2中文版为例，托管平台以Github为例


* 1.打开我们的SourceTree，点击：“+新仓库”，选择：“从URL克隆”
 
{% img /images/git009.png Caption %}  

* 2.粘贴我们的仓库链接至源URL，SourceTree会自动帮我们生成目标路径（本地仓库路径）以及名称，点击克隆

{% img /images/git010.png Caption %}  


* 3.等待数秒后，SourceTree会为我们自动打开我们刚才克隆的仓库，选择master选项，这里我们可以看到我们仓库里的所有文件

{% img /images/git011.png Caption %}  

* 4.双击souretree中对应的项目之后。


{% img /images/git012.png Caption %}  


后面就是需要熟悉souretree界面，并且使用了，也就是平时开发者们最常用的一些操作。

{% img /images/git013.png Caption %}  






具体的详细步骤，后面我会找机会根据项目实际开发整理好(不过，如果你使用果Coerstone那这个也并不难)。由于时间的原因，这里就到这里了！


#####最后总结一下：SourceTree&Git部分名词解释

    克隆(clone)：从远程仓库URL加载创建一个与远程仓库一样的本地仓库
    提交(commit)：将暂存文件上传到本地仓库（我们在Finder中对本地仓库做修改后一般都得先提交一次，再推送）
    检出(checkout)：切换不同分支
    添加（add）：添加文件到暂存区
    移除（remove）：移除文件至暂存区
    暂存(git stash)：保存工作现场
    重置(reset)：回到最近添加(add)/提交(commit)状态
    合并(merge)：将多个同名文件合并为一个文件，该文件包含多个同名文件的所有内容，相同内容抵消
    抓取(fetch)：从远程仓库获取信息并同步至本地仓库
    拉取(pull)：从远程仓库获取信息并同步至本地仓库，并且自动执行合并（merge）操作，即 pull=fetch+merge
    推送(push)：将本地仓库同步至远程仓库，一般推送（push）前先拉取（pull）一次，确保一致
    分支(branch)：创建/修改/删除分枝
    标签(tag):给项目增添标签
    工作流(Git Flow):团队工作时，每个人创建属于自己的分枝（branch），确定无误后提交到master分枝
    终端(terminal):可以输入git命令行


######相关链接推荐

→[Github help for mac](https://help.github.com/desktop/)

→[Github help for win](https://help.github.com/desktop/)
