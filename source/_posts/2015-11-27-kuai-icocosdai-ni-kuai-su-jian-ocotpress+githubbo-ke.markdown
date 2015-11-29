---

layout: post
title: "带你玩虐Ocotpress＋Github博客"
date: 2015-11-27 13:53:19 +0800
comments: true
categories: 欢迎来到iOS梦工厂
description: "我的个人简介" 
keywords: Octopress 

---

#####简介

Octopress是利用Jekyll博客引擎开发的一个博客系统，生成的静态页面能够很好的在github page上展现。号称是hacker专属的一个博客系统(A blogging framework for hackers.)

根据大家的反应，本文我就来介绍一下如何在苹果电脑(OS X 10.8.3)利用Octopress搭建一个Github博客。本文需要读者熟悉一些shell命令，并掌握基本的git操作。

目录

##一： 快速搭建
1. 安装Ruby
2. 安装Octopress
3. 配置Octopress
4. 将博客部署到GitHub上
5. 开始写博客

##二： 个性化配置（个性化初级篇）
1. Header（标题栏）
2. Navigation（导航栏）
3. footer（尾栏）
4. 添加背景图片
5. LOGO图片
6. 导航栏倒圆角
7. 滑动返回顶部按钮
8. 二维码展示

##三： 个性化配置（个性化中级篇）
1. 提高博客访问速度
2. 设置链接在新窗口打开
3. 首页文章以摘要形式展示
4. 代码着色
5. 修改代码生成css
6. 添加侧边栏文章分类（category）
7. 添加多说评论
8. 自动为图片添加url前缀
9. 添加访客统计

##四： 个性化配置（个性化高级篇）
1. 侧边栏
2. 最新文章
3. GitHub Repos
4. 微博秀
5. 豆瓣展示
6. 访客地图
7. 酷站博客
8. 最热文章
9. 3D标签云与标签列表
10. 相关文章功能
11. 社会化评论与分享
12. 为博文添加原文链接及声明
13. 添加版权声明
14. 公益404

##五： 其他
1. mackdown语法<br>

***

#一： 快速搭建

###安装Ruby
Octopress需要Ruby环境，RVM(Ruby Version Manager)负责安装和管理Ruby的环境。所以我们先在终端输入如下命令，来安装RVM：
 
	curl -L https://get.rvm.io | bash -s stable --ruby  


接着是安装Ruby 1.9.3，在终端依次运行如下命令：
 
	rvm install 1.9.3  
	rvm use 1.9.3  
	rvm rubygems latest  


完成上面的操作之后，运行ruby --version应该可以看到ruby 1.9.3环境已经安装好了。
参考：Installing Ruby With RVM

###安装Octopress
在安装Octopress之前，请确保你的电脑上已经安装有git了，在终端输入git --version，应该可以看到电脑中的git版本(我电脑上输出:git version 1.7.12.4 (Apple Git-37))，如果没有显示相关内容，请先安装git。
git安装之后，利用git命令将octopress从github上clone到本机，如下命令：

	git clone git://github.com/imathis/octopress.git octopress  
	cd octopress    # If you use RVM, You'll be asked if you trust 	the .rvmrc file (say yes).  
	ruby --version  # Should report Ruby 1.9.3  


接着安装相关依赖项：

 
	gem install bundler  
	rbenv rehash    # If you use rbenv, rehash to be able to run the 	bundle command  
	bundle install  


最后安装默认的Octopress 主题。
 
	rake install  
 

###配置Octopress
Octopress的作者已经尽量让配置简化了。大多数情况下只需要配置_config.yml和Rakefile文件即可。其中Rakefile是跟博客部署相关，一般情况下并不需要修改这个文件，除非使用了rsync。

config.yml是博客重要的一个配置文件，在config.yml文件中有三大配置项：Main Configs、Jekyll & Plugins和3rd Party Settings。

一般，该文件中其中url是必须要填写的，这里的url是在github上创建的一个仓库地址，具体请看第四步中创建的地址。另外再修改一下title、subtitle和author，根据需求，在开启一些第三方组件服务。

关于_config.yml文件中的更多内容，请看这里的内容：Configuring Octopress

建议：最好把里面的twitter相关的信息全部删掉，否则由于GFW的原因，将会造成页面load很慢。同理，修改定制文件/source/_includes/custom/head.html 把google的自定义字体去掉。from唐巧的博文中—配置。

###将博客部署到GitHub上
Github的Page service可以免费托管博客，并且还可以自定义域名。
首先需要在GitHub上创建一个仓库，并将仓库名称按照这样的方式进行命名：username.github.com或organization.github.com。等后面配置完毕之后，我们就可以在浏览器中使用页面地址

	http://username.github.com
	
来访问我们的博客。一般来说，我们希望在将博客的源码放到source分支下，并把生成的内容提交到master分支。

创建好仓库之后，我们需要利用octopress的一个配置rake任务来自动配置上面创建的仓库：可以让我们方便的部署GitHub page。在终端输入如下命令：
C代码  收藏代码

	$ rake setup_github_pages  

上面的命令会做一些事情(详细介绍看下面给出的参考链接)。其中最主要的就是创建一个_deploy目录，目录用来存放部署到master分支的内容。期间会要求你输入仓库的url，根据提示，进行输入即可。

完成上面的命令之后，我们就可以生成博客并真正的部署到仓库中了。执行如下命令：
 
	rake generate  
	rake deploy  

上面的命令首先生成博客文件，并将生成的博客文件拷贝到_deploy/目录下，然后将这些内容添加到git中，并commit和push到仓库的master分支。

现在可以访问

	http://username.github.com

注意：有时候可能会有延时，要等几分钟才能打开。
至此，我们的博客已经完成基本的部署，不过博客的source需要单独提交，执行如下命令就可以将source提交到仓库的source分支下。
 
	$ git add .  
	$ git commit -m 'Initial source commit'  
	$ git push origin source  
 

如果在部署到仓库之前，需要先预览一下博客，可以在终端输入rake preview命令，然后就能在浏览器中进行本地预览访问了：

	http://127.0.0.1:4000/

或

	http://localhost:4000/

效果跟仓库中的一样。 

###开始写博客
Octopress为我们提供了一些task来创建博文和页面。博文必须存储在source/_posts目录下，并且需要按照Jekyll的命名规范对文章进行命名：YYYY-MM-DD-post-title.markdown。文章的名字会被当做url的一部分，而其中的日期用于对博文的区分和排序。

通过Octopress提供的task可以正确的按照命名规范创建一个博文，并且在博文中会附带常用的一些yaml元数据。只需要在终端输入如下命令：
 
	rake new_post["title"]  

其中title为博文的文件名，创建出来的文件默认是markdown格式。上面的命令会创建出这样一个文件：source/_posts/2013-08-03-title.markdown。打开这个文件，可以看到里面有如下一些内容了(告诉Jekyll博客引擎如何处理博文和页面)：
 
	layout: post  
	title: "title"  
	date: 2013-08-03 16:36  
	comments: true  
	categories:   
  

接着我们就可以在这个文件中写我们的博文啦。完成之后，我们可以预览和部署博文。下面是创建并部署博文的一个完整过程：

	$ rake new_post["New Post"]  
	$ rake generate  
	$ git add .  
	$ git commit -am "Some comment here."   
	$ git push origin source  
	$ rake deploy  
 

######本节介绍了如何利用Octopress搭建一个Github博客，下面讲介绍桌面去个性化你的博客。



***

#个性化配置（初级篇）

这几个部分是经常需要个性化定制的，在 source/_includes 中存在其对应的HTML文件，这是主题默认的文件，更换主题，更新octopress会被覆盖，所以应该编辑 source/_includes/custom 下的文件来实现修改。

##Header，Navigation，footer

### Header（标题栏）

标题栏显示的内容为 /source/_includes/custom/header.html 所实现的，其中title和subtitle在 _config.yml 中定义，你可以进行适量的修改：

		<hgroup>
	 <h1><a href="{{ root_url }}/">{{ site.title }}</a></h1>
	{% if site.subtitle %}
    <h2>{{ site.subtitle }}</h2>
	{% endif %}
	</hgroup>
### Navigation（导航栏）

可以自行为导航栏添加项目，链接至不同的页面，在 /source/_includes/custom/navigation.html 中编辑即可。

	<ul class="main-navigation">
	<li><a href="{{ root_url }}/">博客主页</a></li>
	 <li><a href="{{ root_url }}/blog/archives">文章列表</a></li>
	<li><a href="{{ root_url }}/category-cloud">分类云</a></li>
	<li><a href="{{ root_url }}/about">关于</a></li>
	</ul>
当想添加一些页面，如“关于”页面，可以试验 rake new_page['name'] 命令来创建，如 rake new_page['about'] 后，会建立 source/about/index.html 文件，在此文件编辑，添加自己想要展示的内容，然后再 navigation.html 里添加正确的路径即可，如 
	
	<li><a href="/about">关于</a></li> 
	

### footer（尾栏）

在 source/_includes/custom/footer.html 中编辑尾栏：

	<p>
		Copyright © {{ site.time | date: "%Y" }} - {{ site.author }} -
	<span class="credit">
          Powered by
          <a href="http://octopress.org">Octopress</a>
	</span>
	</p>
默认显示 Copyright@2013 - author - Powered by Octopress ，你可以添加自己想显示在尾栏的东西，第三方统计流量统计工具也可以添加到这，如CNZZ、Google analytics和百度统计等，使用这些工具可以更详细的分析网站流量，改善引流措施，完善网站，具体添加方法见统计工具与SEO。

### 添加背景图片

在 sass/custom/_styles.scss 中添加：

	html {
        background: #555555 url("/images/bg3.jpg");
        //background: #555555;
	}

	body > div {
        background-image: none;
        //background: #F5F5D5
	} //侧边栏

	body > div > div { //文章内容
        background-image: none;
        //background: #F5F5D5; 
        //background: url("/images/bg.jpg");
	}
将背景图片放入 source/images/ 中，修改上述代码中的路径指向想要的图片，即可 更改博客、侧边栏或文章的背景图片。博客使用背景图片后，与Header区不太和谐， 所以我在 /sass/base/_theme.scss 中将 header-bg 设置成透明色了。

### LOGO图片

我所说的logo图片有两种，一个是打开一个网页时，标签栏上显示的小图片。还有一个是标题栏主标题旁的图片。

首先针对于第一种可以选择你喜欢的图片（大小适中），替换 source 目录下的 favicon.png 即可。

或者将logo图片放入 source/images 中，然后修改 source/_includes/head.html ，找到 favicon.png ，修改其路径指向你的图片即可。

对于主标题旁的图片需要在 sass/custom/_styles.scss 中填入如下语句：

	//Blog logo pic
	@media only screen and (min-width: 550px) {

        body > header h1{
                background: url("/images/logo1.png") no-repeat 0 1px;
                padding-left: 65px;
        }

        body > header h2 { padding-left: 65px; }
	}
根据自己情况进行修改即可。

### 导航栏倒圆角

我设置的header区背景色透明，所以导航栏的直角有些尖锐，在 sass/custom/_styles.scss 中添加如下语句，将其修改为圆角：

	//倒圆角
	@media only screen and (min-width: 1040px) {
        body > nav {
                @include border-top-radius(.4em);
        }

        body > footer {
                @include border-bottom-radius(.4em);
        }
	}
### 滑动返回顶部按钮

当文章较长，通常希望有一个返回顶部的按钮，如下方法实现了在页面右下方添加一个返回顶部的图片按钮，点击后可以滑动的返回顶部。

首先创建 source/javascripts/top.js ，实现滑动返回顶部效果，添加如下代码：

	function goTop(acceleration, time)
	{
        acceleration = acceleration || 0.1;
        time = time || 16;

        var x1 = 0;
        var y1 = 0;
        var x2 = 0;
        var y2 = 0;
        var x3 = 0;
        var y3 = 0;

        if (document.documentElement)
        {
                x1 = document.documentElement.scrollLeft || 0;
                y1 = document.documentElement.scrollTop || 0;
        }
        if (document.body)
        {
                x2 = document.body.scrollLeft || 0;
                y2 = document.body.scrollTop || 0;
        }
        var x3 = window.scrollX || 0;
        var y3 = window.scrollY || 0;

        var x = Math.max(x1, Math.max(x2, x3));
        var y = Math.max(y1, Math.max(y2, y3));

        var speed = 1 + acceleration;
        window.scrollTo(Math.floor(x / speed), Math.floor(y / speed));

        if(x > 0 || y > 0)
        {
                var invokeFunction = "goTop(" + acceleration + ", " + time + ")";
                window.setTimeout(invokeFunction, time);
        }
	}
然后创建 source/_includes/custom/totop.html ，设置返回顶部按钮样式和位置，代码如下：

	<!--返回顶部开始-->
	<div id="full" style="width:0px; height:0px; position:fixed; right:180px; bottom:150px; z-index:100; text-align:center; background-color:transparent; cursor:pointer;">
        <a href="#" onclick="goTop();return false;"><img src="/images/top.png" border=0 alt="返回顶部"></a>
	</div>
	<script src="/javascripts/top.js" type="text/javascript"></script>
	<!--返回顶部结束-->
最后，还需要将返回顶部的图片放入 source/images ，命名为 top.png （或修改totop.html中图片的路径）。

### 二维码展示

在关于页面或边栏可以展示你的个人博客的二维码，方便移动终端扫描访问你的博客，插件主页 点击这里 。

在侧边栏显示，则将 qrcode.html 放入 source/_includes/custom/asides/ 中，在 _config.yml 中 default_asides 添加 custom/asides/qrcode.html 即可显示。

或者将 qrcode.html 代码添加到你想展示的页面的HTML文件中亦可。

***

#个性化配置（中级篇）

### 提高博客访问速度

因为“墙”的关系，所以Octopress建立以后会发现访问速度奇慢无比，竟然超过了40s。

仔细分析后我们发现其中都是一些被墙的请求报了404Error，所以导致访问博客巨慢无比，下面我们就一次阉割掉这些被墙的请求。T_T

#### 替换Google JS公共库

Octopress默认使用的是Google的JS公共库地址，加载的过程无比的缓慢。因此我们要把它改为 百度的JS公共库 ，需要把 /source/_includes/head.html 文件中的Google公共库地址改为：

<script src="//libs.baidu.com/jquery/1.7.2/jquery.min.js"></script>
#### 去掉Twitter

从上图可以看出加载失败的还有twitter，这个也得给去掉。

把在根目录下的 _config.yml 文件中Twitter内容给注释掉。

	# Twitter
	#twitter_user:
	#twitter_tweet_button: true
把 \source\_includes\after_footer.html 文件中的twitter内容给注释掉：

	include twitter_sharing.html
	
	
#### 删除Google font

把在 \source\_includes\custom\head.html 中的Google font样式给删除：

	<link href="//fonts.googleapis.com/css?family=PT+Serif:regular,italic,bold,bolditalic" rel="stylesheet" type="text/css">
	<link href="//fonts.googleapis.com/css?family=PT+Sans:regular,italic,bold,bolditalic" rel="stylesheet" type="text/css">
### 设置链接在新窗口打开

在博文中，如果点击链接直接在本窗口打开了，那么用户体验就不是很好。而markdown的标准语法是不支持链接在新窗口打开的，虽然可以通过在markdown中直接写html标签来解决这个问题，但是这与markdown的简洁书写特性不符。但是我们可以通过设置Octopress来达到这种效果，即在 \source\_includes\custom\head.html 文件中添加如下一段代码：

	<script>
	function addBlankTargetForLinks () {
    $('a[href^="http"]').each(function(){
      $(this).attr('target', '_blank');
    });
	}
	$(document).bind('DOMNodeInserted', function(event) {
    addBlankTargetForLinks();
	});
	</script>

### 首页文章以摘要形式展示

2.在文章对应的markdown文件中，在需要显示在首页的文字后面添加 <!--more--> ，执行rake generate后在首页上会看到只显示<!—more—>前面的文字，文字后面会显示 Read on 链接，点击后进入文字的详细页面;

1.如果想将Read on修改为中文，可以修改_config.yml文件

	excerpt_link: "Read on →"  # 	"Continue reading" link text at the 	bottom of excerpted articles
	excerpt_link: "阅读全文→"  # "Continue reading" link text at the 	bottom of excerpted articles
	
### 代码着色

Octopress使用的是Pygments来进行代码着色的，使用方式也比较简单如下所示：

```java xxx.java
//java code
```
Pygments支持的语言列表

### 修改代码生成css

当然你也可以修改Pygments生成的代码css样式。

Pygments默认提供了很多css样式，你可以在python shell中用下面命令列出当前pygments所支持的样式：

	>>> from pygments.styles import STYLE_MAP
	>>> STYLE_MAP.keys()
	['manni', 'igor', 'xcode', 'vim', 'autumn', 'vs', 'rrt', 'native', 'perldoc', 'borland', 'tango', 'emacs', 'friendly', 'monokai', 'paraiso-dark', 'colorful', 'murphy', 'bw', 'pastie', 'paraiso-light', 'trac', 'default', 'fruity']
	>>>
通过-S来选择，需要生成default的样式：

	pygmentize -S default -f html > your/path/pygments.css
有时候Octopress会把我们想要展示的Ruby代码解析成HTML，如果只是想展示代码，而不让Octopress来解析，那么可以在代码前后加入和代码。

### 添加侧边栏文章分类（category）

1.在 plugins 目录下创建 category_list_tag.rb 文件，内容如下：

	module Jekyll 
	class CategoryListTag < Liquid::Tag 
    def render(context) 
      html = "" 
      categories = context.registers[:site].categories.keys 
      categories.sort.each do |category| 
        posts_in_category = context.registers[:site].categories[category].size 
        category_dir = context.registers[:site].config['category_dir'] 
        category_url = File.join(category_dir, category.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase) 
        html << "<li class='category'><a href='/#{category_url}/'>#{category} (#{posts_in_category})</a></li>\n" 
      end 
      html 
    end 
	end 
	end

	Liquid::Template.register_tag('category_list', Jekyll::CategoryListTag)
2.添加 source/_includes/asides/category_list.html 文件，内容如下：

	<section>
	  <h1>Categories</h1>
	  <ul id="categories">
	  ***
	    {百分号raw百分号}{百分号 category_list 百分号}{百分号endraw百分号} 
	  ***
	  </ul>
	</section>
	
3.修改 _config.yml 文件，在 default_asides 项中添加 asides/category_list.html ，值之间以逗号隔开，值的先后顺序代表了侧边栏展现的先后顺序。

	default_asides: [asides/category_list.html, asides/recent_posts.html, asides/github.html, asides/delicious.html, asides/pinboard.html, asides/googleplus.html]
	
在侧边栏还可以添加其他组件，如微博、标签云等，添加方式和上面类似。

### 添加多说评论

Octopress默认自带了DISQUS，但是对于国内不是很好用。所以在经过考虑之后选择了国内比较流行的多说评论系统。 首先要去 多说网站注册 ，获取站点的 short_name 。

在 _config.yml 中添加

	# duoshuo comments
	duoshuo_comments: true
	duoshuo_short_name: yourname 
在 ./source/_layouts/post.html 中的 disqus 代码

下方添加多说评论模块：

	{% if site.duoshuo_short_name and site.duoshuo_comments == T and page.comments == T %}	
	<section>
		<h1>Comments</h1>
		<div id="comments" aria-live="polite">{% include post/duoshuo.html %}</div>
	</section>
	{% endif %}




如果你希望一些单独的页面下方也放置评论功能，那么在 ./source/_layouts/page.html 中也做如上修改。 然后创建一个 ./source/_includes/post/duoshuo.html 文件，内容如下：

> 
	
	<div class="ds-thread" data-title="Octopress博客的个性化配置"></div>
	<script type="text/javascript">
	var duoshuoQuery = {short_name:"tianweili"};
	(function() {
		var ds = document.createElement('script');
		ds.type = 'text/javascript';ds.async = true;
		ds.src = 'http://static.duoshuo.com/embed.js';
		ds.charset = 'UTF-8';
		(document.getElementsByTagName('head')[0] 
		|| document.getElementsByTagName('body')[0]).appendChild(ds);
	})();
	</script>

最后再修改 _includes/article.html 文件，在

下方添加下面代码：


	{% if site.duoshuo_short_name and page.comments != F and post.comments != F and site.duoshuo_comments == T %}
	| <a href="{% if index %}{{ root_url }}{{ post.url }}{% endif %}#comments">Comments</a>
	{% endif %}
> 
注意：
以上所有F代表false，T代表true，更改对应的就可以
（不要问为撒）


### 自动为图片添加url前缀

我把图片资源都 放在了七牛云存储 上，写博客时候就是用七牛的外链。但是这样有几个问题：

每次写博客插入图片外链地址时候都很麻烦，需要给每张图片都添加七牛外链地址url前缀；
如果以后更换了存储，那就麻烦了，需要依次编辑替换每个图片的url前缀
现在我们就使用一种灵活的方式来配置并自动生成图片的URL前缀：

首先修改 /plugins/image_tag.rb 文件，在 @img['class'].gsub!(/"/, '') if @img['class'] 后添加下面一行代码：

	./plugins/image_tag.rb
	@img['src'] = Jekyll.configuration({})['static_file_prefix'] + @img['src'] if @img['src'][0] == '/'
然后再修改根目录下的 _config.yml 文件，添加如下配置：

	# Add url prefix for image automatically
	static_file_prefix: http://7u2i08.com1.z0.glb.clouddn.com
最后我们在插入图片的时候要记住不能再使用Markdown语法来写了，要 使用Ocotpress自定义的IMG标签来插入图片 。

本地预览先generate后preview，这样一来插入图片就灵活方便多了。

### 添加访客统计

本博客的访客统计系统使用的是Flag Counter，所以要 先去Flag Counter获取代码 。

拿到代码后添加 .\source\_includes\custom\asides\flag_counter.html 文件：

	flag_counter.html
	<section>
	<h1>访客统计</h1>
	<br/>
	<a href="http://s07.flagcounter.com/more/2SH"><img src="http://s07.flagcounter.com/count/2SH/bg_FFFFFF/txt_000000/border_CCCCCC/columns_2/maxflags_12/viewers_0/labels_0/pageviews_1/flags_0/" alt="Flag Counter" border="0"></a>
	</section>
将页面添加到侧边栏，在 ./_config.yml 配置文件中添加下面一行配置：

	default_asides: [……, custom/asides/flag_counter.html]
最后添加控制开关，在 ./_config.yml 配置文件中添加下面一行配置：

	# Flag Counter
	flag_counter: true


***


#个性化配置（高级篇） 

在节章 中，已经搭建起了octopress博客。使用的是默认的主题，样式千篇一律，而且自带的一些功能和侧边栏并不适合国内的国情，得不到网络的支持，如facebook、twitter、google plus和disqus等。所以还是有必要进行一下改造，打造中国特色octopress博客的。

### 第三方主题

首先，你先要选定的是博客使用的第三方主题，因为如果你已经进行了很多的网页设置，添加了很多的插件，再来改主题，你就要面临悲剧了，你会发现你已经配置好的东西被替换掉了，这无疑会对你的热情带来打击。所以我们先来看看第三方主题。

你需要先找到自己喜欢的主题，之后可以在此主题上进行修改。 点击这里 是一个主题网站，给出了不同主题的预览图，使用该主题的博客和该主题的GitHub链接。选中你想要的，获得GitHub仓库地址，如下安装

	$ cd blog
	$ git clone https://github.com/shashankmehta/greyshade.git ./themes/	greyshade
	$ rake install['greyshade']
	$ rake generate
	
这里我的博客在blog文件夹中，以安装greyshade主题为例。你按照自己的情况进行更改。 rake generate 后可以通过 rake preview 访问 http://localhost:4000 预览新的主题样式，不满意可以更换其他主题。

### 侧边栏

侧边栏可以添加的插件很多，新浪微博、豆瓣等很多网站都有相应的插件，也可以到 octopress的wiki页面 寻找。

侧边栏在 _config.yml 中设置，添加进 default_asides 中，先后顺序代表显示的先后顺序，各个侧边栏插件代码放入相应的位置即可，自己添加的一般放入 source/_includes/custom/asides ， default_asides 中默认从 _includes 之后路径开始写。

###  最新文章

首先说一下主题中可用的插件。

asides/recent_posts.html 是最近写的文章的一个展示，添加到 default_asides 中即可显示，在 _config.yml 中可以设置显示最近多少篇文章， recent_posts: 5 ，注意冒号后有空格。

###  GitHub Repos

asides/github.html 则是GitHub repos的一个展示，可以直接到达你的GitHub页面，在 _config.yml 中设置你的Github账号，并设置为 true 即可，如下：

	Github repositories
	github_user: 812lcl   #我的github
	github_repo_count: 0
	github_show_profile_link: true
	github_skip_forks: true
	
### 微博秀

新浪微博是一个信息传播非常迅速的媒介，如果你热衷于微博，可以在侧边栏添加自己的微博秀。首先需要获得自己的微博秀代码，链接为 http://app.weibo.com/tool/weiboshow ，进行相应的设置即可获得微博秀代码。

然后在 source/_includes/custom/asides 创建weibo.html，添加如下代码，刚刚获得的微博秀代码也要添加到相应位置：

	<section>
    <h1>新浪微博</h1>
	<ul id="weibo">
	<li>

    <!-- 在此插入获得的微博秀代码 -->

      </li>
    </ul>
	</section>
最后在 default_asides 中加入 custom/asides/weibo.html 即可显示你的微博秀了。

###  豆瓣展示

你可以通过豆瓣读书、豆瓣电影、豆瓣音乐等多方面展示你自己，豆瓣也提供了类似微博秀的展示方式，添加方法也类似。获得豆瓣收藏秀的链接 http://www.douban.com/service/badgemakerjs ，根据自己的喜欢进行设置

然后在 source/_includes/custom/asides 创建douban.html，添加如下代码，刚刚获得的代码添加到 <div> 之间：

	<section>
	<h1>My Douban</h1>
	<div>
	<!--添加到这-->
	</div>
	</section>
最后在 default_asides 中加入 custom/asides/douban.html 显示你的豆瓣展示。

### 访客地图

效果如我的博客右侧那个精美的3D旋转地球所示，它可以显示访客数量，访客来自的地域，既有装饰作用，又有统计作用。它也有2D效果版，可以根据自己喜欢进行设置，地址在 这里 ，然后获得代码。

依然在 source/_includes/custom/asides 创建earth.html，代码如下：

	<section>
	<h1>访客地图</h1>
	<!--获得代码添加到这-->
	</section>
在 default_asides 中加入 custom/asides/earth.html 显示你定制的访客地图。

### 酷站博客

你有一些经常去的网站、博客，想推荐给大家，则可以在侧边栏加上一个“酷站博客”，当然名字你自己取即可。

在 source/_includes/custom/asides 创建blog_link.html，代码如下：

	<section>
	<h1>酷站博客</h1>
	<ul>
        <li>
        <a href="http://blog.jobbole.com/">伯乐在线</a>
        </li>
        <li>
        <a href="http://www.csdn.net/">CSDN</a>
        </li>
        <li>
        <a href="http://www.cnblogs.com/">博客园</a>
        </li>
        <li>
        <a href="http://coolshell.cn/">酷壳CoolShell</a>
        </li>
        <li>
        <a href="http://www.cnblogs.com/Solstice/">陈硕</a>
        </li>
	</ul>
	</section>
可以自行添加喜爱网站，然后在 default_asides 中加入 custom/asides/blog_link.html 。

看到这，你应该很熟悉添加侧边栏的流程了吧。

### 最热文章

Octopress Popular Posts Plugin是根据Google page rank计算，展示出权值最高的文章，插件的项目主页为 点击这里 。

这个插件的安装与之前的方法不同，首先在 Gemfile 中添加

	gem 'octopress-popular-posts'
Gemfile 中的是bundle安装时安装的所有依赖的软件，然后用bundle安装

	bundle install
执行命令，将插件拷贝到你的source目录，如下：

	bundle exec octopress-popular-posts install
到这就安装完了，可以设置显示了，在 _config.yml 中设置，增加下面一行：

	popular_posts_count: 5      # Posts in the sidebar Popular Posts section
设置边栏显示文章数，最后在 default_asides 中添加 custom/asides/popular_posts.html ，即可显示出来。

这样就设置好了，同时建议将缓存的page rank文件添加进你的 .gitignore 中

	.page_rank
	
### 3D标签云与标签列表

octopress默认的只支持category的分类，而并没有tag。category和tag分别代表有序/无序的知识点归纳。一篇文章只能属于一个category，但可以有多个tag。原来的plugin下只有category_generator.rb插件，实现category功能，在github上有两个插件帮助实现了tag生成和tag cloud功能 插件1 ， 插件2 。但似乎并不支持中文，而category_generator.rb是支持中文的，所以我有样学样，改成了支持中文的，并且实现了3D标签云的，插件已经上传到 github 。clone到你博客的目录即可。

包含文件如下：

	 ├─ plugins/
    │  ├─ category_generator.rb
    │  ├─ category_list.rb
    │  ├─ category_tag_cloud.rb
    │  ├─ tag_generator.rb
    │  └─ tag_list.rb
    └─ source/
       └─ _includes/
          └─ custom/
             └─ asides/
                ├─ category_cloud.html
                ├─ category_list.html
                ├─ tag_cloud.html
                └─ tag_list.html
其中 category_generator.rb 和 tag_generator.rb 定义了根据文章的category和tag标签分类存储文章的方法， category_tag_cloud.rb 则可以定义了根据category或tag生成3D标签云的方法。 category_list.rb 和 tag_list.rb 实现了将所有文章的category和tag列出来的方法，其中category可以显示文章个数，tag根据此标签文章多少，大小随着改变。

四个HTML文件则是category和tag的列表和3D标签云的侧边栏实现。需要哪个，在 default_asides 中添加即可。

还有一点需要注意，在_config.yml中默认设置了category的目录，需自己加入tag目录

	category_dir: blog/categories
	tag_dir: blog/tags
这样可以观看效果了，不过3D效果的标签云，对于不支持flash的浏览器无效，如 safari 。

标签功能的实现，我参考了一下几篇文章：

[为octopress添加分类(category)列表](http://codemacro.com/2012/07/18/add-category-list-to-octopress/)

[给 Octopress 加上标签功能](http://blog.log4d.com/2012/05/tag-cloud/)
 

### 相关文章功能

此功能即根据当前阅读的文章，分析博客中其他与此相近的文章，进行推荐的一个功能，在octopress wiki中推荐的第三方插件中有一个插件实现此功能，项目主页 点击这里 。该插件，利用octopress自带的LSI实现对文章分析分类，然后进行推荐，但当文章较多时分类过慢，它推荐安装GSL来进行分类。我安装过这个功能，但不知道它是根据什么规则分类，而且之后不知道安装了什么，之后每次分类都会出错。你可以自己尝试一下，项目主页都有详细的步骤。

就在我想放弃这个功能的时候，我发现了它―― related_posts-jekyll_plugin 。这个插件很简单，只需下载_plugins/related_posts.rb放在自己的plugins文件夹中，然后在想添加相关文章推荐的地方添加如下语句：

	<section>
	<h2>相关文章：</h2>
	  <ul class="posts">
       {% for post in site.related_posts limit:5 %}
          <li class="related">
          <a href="{{ root_url }}{{ post.url }}">{{ post.title }}</a>
          </li>
      {% endfor %}
	</ul>
	</section>
	
我是在source/_layouts/post.html中加入的这些语句，这个html文件是打开博文时的布局，我将相关文章添加在博文的结束处。

这个插件是根据文章的tag进行分类的，根据所有博文与本篇文章共同tag的多少依次排序进行推荐，还是很简单有效的。
 

###  社会化评论与分享

####友言和加网

octopress内置了disqus评论系统，不适合我国基本国情，所以需要用一些国内的第三方评论系统，如友言、多说，可以以微博、人人、QQ等账号登陆发表评论，网站通过验证后可以对评论进行分析，管理。

多说评论系统可参见 为 Octopress 添加多说评论系统 ，不多做介绍。

我主要使用的是友言的一套评论系统及插件，分享使用的是加网JiaThis。首先注册 友言 账号，否则无法进行后台管理。注册之后获得代码，添加到 source/_includes/post/share_comment.html 。加网 点击这里 ，定制自己喜欢的样式，获得代码也添加到上述文件中。

share_comment.html文件中代码如下（每个人不同）：

	<!-- JiaThis BEGIN -->
	<div class="jiathis_style_32x32">
        <a class="jiathis_button_qzone"></a>
        <a class="jiathis_button_tsina"></a>
        <a class="jiathis_button_tqq"></a>
        <a class="jiathis_button_weixin"></a>
        <a class="jiathis_button_renren"></a>
        <a href="http://www.jiathis.com/share?uid=*******" class="jiathis jiathis_txt jtico jtico_jiathis" target="_blank"></a>
        <a class="jiathis_counter_style"></a>
	</div>
	<script type="text/javascript" src="http://v3.jiathis.com/code/jia.js?uid=1361705530382241" charset="utf-8"></script>
	<!-- JiaThis END -->

	<!-- Baidu Button BEGIN 
	<div id="bdshare" class="bdshare_t bds_tools_32 get-codes-bdshare">
        <a class="bds_tsina"></a>
        <a class="bds_qzone"></a>
        <a class="bds_tqq"></a>
        <a class="bds_renren"></a>
        <a class="bds_t163"></a>
        <a class="bds_hi"></a>
        <span class="bds_more"></span>
        <a class="shareCount"></a>
	</div>
	<script type="text/javascript" id="bdshare_js" data="type=tools&uid=6839808" ></script>
	<script type="text/javascript" id="bdshell_js"></script>
	<script type="text/javascript">
        document.getElementById("bdshell_js").src = "http://bdimg.share.baidu.com/static/js/shell_v2.js?cdnversion=" + Math.ceil(new Date()/3600000)
	</script>
	 Baidu Button END -->

	<!-- UY BEGIN -->
	<div id="uyan_frame"></div>
	<script type="text/javascript" src="http://v2.uyan.cc/code/uyan.js?uid=*******"></script>
	<!-- UY END -->
其中有一段代码注释掉了，那是我曾经添加的百度分享的代码，如果使用其他分享或评论，代码也可以添加到这。

现在功能代码在share_comment.html中了，下面需要使其显示到博文的底部。

首先在_config.yml中添加开关：

	# comment and share
	comment_share: true
然后在 source/_includes/post/sharing.html 中添加如下代码：

	{% if site.comment_share %}
	{% include post/share_comment.html %}
	{% endif %}
	
最后需要使你的网站通过友言的验证，才可以进行后台管理，后台可以进行评论管理、社交影响力分析、和评论栏的风格功能设置。

#### 评论热榜和最新评论侧边栏

友言提供了多个嵌入式组件，如评论热榜、最新评论、评论计数等。我们可以将他们做成侧边栏进行展示，或在首页文章列表中，显示每篇文章的评论数目。

首先在你的友言后台管理中找到 安装设置->嵌入式组件 获得评论热榜和最新评论的代码，分别创建 source/_includes/custom/asides/uyan_hotcmt.html 和 source/_includes/custom/asides/uyan_newcmt.html ，代码如下：

	<section>
	<h1>评论热榜</h1>
	<div id="uyan_hotcmt_unit"></div>
        <script type="text/javascript" src="http://v2.uyan.cc/code/uyan.js?uid=*******"></script>
	</section>
	<section>
	<h1>最新评论</h1>
	<div id="uyan_newcmt_unit"></div>
        <script type="text/javascript" src="http://v2.uyan.cc/code/uyan.js?uid=*******"></script>
	</section>
	
然后再 _config.yml 的 default_asides 中添加其路径即可显示在侧边栏中。

友言评论框、评论热榜、最新评论可以在后台进行设置，改变设置并不需要更改代码。

#### 评论计数显示

友言提供评论计数功能，可以将每篇文章的评论数显示在博客首页相应文章题目旁。实现方法为：在 source/_includes/article.html 中

`{% include post/date.html %}{{ time }}`
	
的后边填入嵌入组件中获得的评论计数的代码，需要修改其中一些内容

	| <a href="{% if index %}{{ root_url }}{{ post.url }}{% endif %}#comments" id="uyan_count_unit" du="" su="">0条评论</a>
 	 <script type="text/javascript" src="http://v2.uyan.cc/code/uyan.js?uid=*******"></script>
 	
###  为博文添加原文链接及声明

可以为你的每篇博文末尾加上原文链接，方法很简单，只需创建 plugins/post_footer_filter.rb ，代码如下：

	# post_footer_filter.rb
	# Append every post some footer infomation like original url 
	# Kevin Lynx
	# 7.26.2012
	#
	require './plugins/post_filters'

	module AppendFooterFilter
        def append(post)
                author = post.site.config['author']
                url = post.site.config['url']
                pre = post.site.config['original_url_pre']
                post.content + %Q[<p class='post-footer'>
                        #{pre or "original link:"}<a 	href='#{post.full_url}'>#{post.full_url}</a><br/> written by <a 	href='#{url}'>#{author}</a> posted at <a href='#{url}'>#{url}</a></p>]
        end
	end

	module Jekyll
        class AppendFooter < PostFilter
                include AppendFooterFilter
                def pre_render(post)
                        post.content = append(post) if post.is_post?
                end
        end
	end

	Liquid::Template.register_filter AppendFooterFilter
	
并可以针对这一区域的样式进行美化，在 sass/custom/_style.scss 末尾增加下列内容：

	.post-footer{margin-top:10px;padding:5px;background:none repeat scroll 0pt 0pt #eee;font-size:90%;color:gray}
	
尊重原创，此功能来源 为octopress每篇文章添加一个文章信息 。

###  添加版权声明
这里所说的版权声明是指每篇文章后面的版权信息

首先source\_includes\post目录中添加license.html文件，文件内容如下：
	
	{% if site.post_license %}
	
	<DIV style="font-size:12px;BORDER-BOTTOM: #bbbbbb 1px solid; BORDER-LEFT: #bbbbbb 1px solid; BACKGROUND: #f6f6f6; HEIGHT: 120px; BORDER-TOP: #bbbbbb 1px solid; BORDER-RIGHT: #bbbbbb 1px solid" class=oec2003right> 
	<DIV style="MARGIN-TOP: 10px; FLOAT: left; MARGIN-LEFT: 5px; MARGIN-RIGHT: 10px"> 
	<IMG alt="" src="http://images.cnblogs.com/cnblogs_com/oec2003/219566/r_fw90100.jpg" width=90 height=100></DIV> 
	<DIV style="LINE-HEIGHT: 200%; MARGIN-TOP: 10px; COLOR: #000000"> 
	作者： <A href="http://oec2003.github.io/">冯威</A> <BR> 
	出处： <A href="http://oec2003.github.io/">http://oec2003.github.io/</A> 
	<BR>本文基于<a target="_blank" title="Creative Commons Attribution 2.5 China Mainland License" href="http://creativecommons.org/licenses/by/2.5/cn/"> 
	署名 2.5 中国大陆</a>许可协议发布，欢迎转载，演绎或用于商业目的，但是必须保留本文的署名 
	<a href="http://oec2003.github.io/">冯威</a>（包含链接）。 </DIV></DIV> 
	{% endif %}

在sass\custom\_styles.scss添加如下样式信息来控制版权信息的样式

	.oec2003right 
	{ 
	    background: #C3D9FF; 
	    height:120px; 
	    border:1px solid #BBBBBB; 
	}
	
	.oec2003right a:link 
	{ 
	    color: #0057b6; 
	    text-decoration: none; 
	} 
	.oec2003right a:visited 
	{ 
	    color: #0057b6; 
	    text-decoration: none; 
	} 
	.oec2003right a:active,a:hover 
	{ 
	    color: #0057b6; 
	    text-decoration: underline; 
	}

修改文件source\_layouts\post.html

	在class中增加类类似的一行，修改为对应的html就可以

在_config.yml添加配置项用来控制是否显示页面的版权信息

	# Post License 
	post_license: true

###  公益404

在 source 目录下创建404.markdown，添加如下代码，即可实现公益404的功能，当你的网页出错找不到时，可以为公益尽一份力。
 
	layout: page
	title: "404 Error"
	date: 2013-10-10 19:17
	comments: false
	sharing: false
	footer: false
 	---
	<script type="text/javascript" src="http://www.qq.com/404/	search_children,js" charset="utf-8></script>
 
***




## mackdown语法简介

###下面简单介绍一下mackdown常用语法（mackdown语法程序员必备）
 

1. 标题设置（让字体变大，和word的标题意思一样）
在Markdown当中设置标题，有两种方式：
第一种：通过在文字下方添加“=”和“-”，他们分别表示一级标题和二级标题。
第二种：在文字开头加上 “#”，通过“#”数量表示几级标题。（一共只有1~6级标题，1级标题字体最大）

2. 块注释（blockquote）
通过在文字开头添加“>”表示块注释。（当>和文字之间添加五个blank时，块注释的文字会有变化。）

3. 斜体
将需要设置为斜体的文字两端使用1个“*”或者“_”夹起来

4. 粗体
将需要设置为斜体的文字两端使用2个“*”或者“_”夹起来

5. 无序列表
在文字开头添加(*, +, and -)实现无序列表。但是要注意在(*, +, and -)和文字之间需要添加空格。（建议：一个文档中只是用一种无序列表的表示方式）

6. 有序列表
使用数字后面跟上句号。（还要有空格）

7. 链接（Links）
Markdown中有两种方式，实现链接，分别为内联方式和引用方式。
内联方式：This is an [example link](http://example.com/).
引用方式：
I get 10 times more traffic from [Google][1] than from [Yahoo][2] or [MSN][3].  

[1]: http://google.com/        "Google" 
[2]: http://search.yahoo.com/  "Yahoo Search" 
[3]: http://search.msn.com/    "MSN Search"
 

8. 图片（Images）
图片的处理方式和链接的处理方式，非常的类似。
内联方式：

	`![alt text](/path/to/img.jpg "Title")`

	引用方式：

	`![alt text][id] `


	`[id]: /path/to/img.jpg "Title"`

9. 代码（HTML中所谓的Code）
实现方式有两种：
第一种：简单文字出现一个代码框。使用`<blockquote>`。（`不是单引号而是左上角的ESC下面~中的`）
第二种：大片文字需要实现代码框。使用Tab和四个空格。

10. 脚注（footnote）
实现方式如下：
	
	
	`hello[^hello]`


	`[^hello]: hi`

11. 下划线
在空白行下方添加三条“-”横线。（前面讲过在文字下方添加“-”，实现的2级标题）

相关参考

[mackdoen语法简介](http://www.cnblogs.com/itech/p/3800982.html) 

*** 

版权声明：欢迎转载，请贴上源地址
 
 [https://al1020119.github.io](https://al1020119.github.io)
 
 [http://www.cnblogs.com/iCocos/（iOS梦工厂）](http://www.cnblogs.com/iCocos/（iOS梦工厂）)

更多精彩请关注

[github：https://github.com/al1020119?tab=repositories](github：https://github.com/al1020119?tab=repositories)

<!--more-->