---
layout: post
title: "完虐ThinkPHP 5.* 远不止这些😱😂"
date: 2016-12-01 00:30:20 +0800
comments: true
categories: 
---

##目录

1. 下载安装
2. 规范整理
3. 结构介绍
4. 简单配置
5. 简单数据显示
6. 数据库配置
7. 数据库基本使用
8. 模型基本使用
9. 总结：（ThinkPhp5.+ <-->ThinkPhp3.+）



<!--more-->



### 下载安装

###### 一、官网下载安装

获取ThinkPHP的方式很多，官方网站（[http://thinkphp.cn](http://thinkphp.cn)）提供了稳定版本或者带扩展完整版本的下载。

    官网的下载版本不一定是最新版本，GIT版本获取的才是保持更新的版本。

###### 二、Composer安装

ThinkPHP5支持使用Composer安装，如果还没有安装 Composer，你可以按 Composer安装 中的方法安装。在 Linux 和 Mac OS X 中可以运行如下命令：

	curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/local/bin/composer

+ 在 Windows 中，你需要下载并运行 Composer-Setup.exe。
  
然后在命令行下面，切换到你的web根目录下面并执行下面的命令： 

	composer create-project topthink/think tp5  --prefer-dist

+ composer更新方式：composer self-update

###### 三、Git安装

如果你不太了解Composer或者觉得Composer太慢，也可以使用git版本库安装和更新，ThinkPHP5.0拆分为多个仓库，主要包括：

    应用项目：https://github.com/top-think/think
    核心框架：https://github.com/top-think/framework 

    之所以设计为应用和核心仓库分离，是为了支持Composer单独更新核心框架。

首先克隆下载应用项目仓库

	git clone https://github.com/top-think/think tp5

然后切换到tp5目录下面，再克隆核心框架仓库：

	git clone https://github.com/top-think/framework thinkphp

两个仓库克隆完成后，就完成了ThinkPHP5.0的Git方式下载，如果需要更新核心框架的时候，只需要切换到thinkphp核心目录下面，然后执行：

	git pull https://github.com/top-think/framework

> 如果不熟悉git命令行，可以使用任何一个GIT客户端进行操作，在此不再详细说明。

无论你采用什么方式获取的ThinkPHP框架，现在只需要做最后一步来验证是否正常运行。

在浏览器中输入地址：

	http://localhost/tp5/public/

如果浏览器输出如图所示，那么说明你成功了，如果不是，那么请检测相关配置或者步骤：

{% img /images/thinkphp5_0001.png Caption %}  


### 规范整理

ThinkPHP5遵循PSR-2命名规范和PSR-4自动加载规范，并且注意如下规范：
######目录和文件

    目录不强制规范，驼峰及小写+下划线模式均支持；
    类库、函数文件统一以.php为后缀；
    类的文件名均以命名空间定义，并且命名空间的路径和类库文件所在路径一致；
    类文件采用驼峰法命名（首字母大写），其它文件采用小写+下划线命名；
    类名和类文件名保持一致，统一采用驼峰法命名（首字母大写）；

######函数和类、属性命名

    类的命名采用驼峰法（首字母大写），例如 User、UserType，默认不需要添加后缀，例如UserController应该直接命名为User；
    函数的命名使用小写字母和下划线（小写字母开头）的方式，例如 get_client_ip；
    方法的命名使用驼峰法（首字母小写），例如 getUserName；
    属性的命名使用驼峰法（首字母小写），例如 tableName、instance；
    以双下划线“__”打头的函数或方法作为魔法方法，例如 __call 和 __autoload；

######常量和配置

    常量以大写字母和下划线命名，例如 APP_PATH和 THINK_PATH；
    配置参数以小写字母和下划线命名，例如 url_route_on 和url_convert；

######数据表和字段

    数据表和字段采用小写加下划线方式命名，并注意字段名不要以下划线开头，例如 think_user 表和 user_name字段，不建议使用驼峰和中文作为数据表字段命名。

######应用类库命名空间规范

应用类库的根命名空间统一为app（可以设置app_namespace配置参数更改）

	例如：app\index\controller\Index和app\index\model\User。

### 结构介绍

下载最新版框架后，解压缩到web目录下面，可以看到初始的目录结构如下：

{% img /images/thinkphp5_0002.png Caption %}  



5.0的部署建议是public目录作为web目录访问内容，其它都是web目录之外，当然，你必须要修改public/index.php中的相关路径。如果没法做到这点，请记得设置目录的访问权限或者添加目录列表的保护文件。

    router.php用于php自带webserver支持，可用于快速测试
    启动命令：php -S localhost:8888 router.php

5.0版本自带了一个完整的应用目录结构和默认的应用入口文件，开发人员可以在这个基础之上灵活调整。

    上面的目录结构和名称是可以改变的，尤其是应用的目录结构，这取决于你的入口文件和配置参数。


这里是我下载解压后的目录结构

{% img /images/thinkphp5_0003.png Caption %}  


### 简单配置


细心的话我们可以发现，ThinkPhp5中入口文件相对ThinkPhp3中的入口文件发生了变化，在ThinkPhp5中的入口文件是放在根目录中的public里面index.php文件，其实5相对3来说，变化还是挺大的，如果之前是使用3写的项目。要升级到5的话，估计也是一个大工程，需要很细心的处理。

+ 前面我们输入了：http://localhost/tp5/public/

查看public中可以看到index.php的内容和ThinkPhp3中的入口有点相似：

ThinkPhp3的入口文件

	
	// 应用入口文件
	
	// 检测PHP环境
	if(version_compare(PHP_VERSION,'5.3.0','<'))  die('require PHP > 5.3.0 !');
	
	// 开启调试模式 建议开发阶段开启 部署阶段注释或者设为false
	define('APP_DEBUG',True);
	
	// 定义应用目录
	define('APP_NAME','App');
	// 定义应用目录
	define('APP_PATH','./App/');
	
	// 引入ThinkPHP入口文件
	require './ThinkPHP/ThinkPHP.php';
	
	// 亲^_^ 后面不需要任何代码了 就是如此简单

ThinkPhp5的入口文件

	// [ 应用入口文件 ]
	
	// 定义应用目录
	define('APP_PATH', __DIR__ . '/../application/');
	// 加载框架引导文件
	require __DIR__ . '/../thinkphp/start.php';

所以我们会发现入口文件指向的是Application文件夹，然后进入到Application文件夹，有个index文件夹，里面有个Controller文件夹，打开index.php文件，看到：

	<?php
	namespace app\index\controller;
	
	class Index
	{
	    public function index()
	    {
	        return '<style type="text/css">*{ padding: 0; margin: 0; } .think_default_text{ padding: 4px 48px;} a{color:#2E5CD5;cursor: pointer;text-decoration: none} a:hover{text-decoration:underline; } body{ background: #fff; font-family: "Century Gothic","Microsoft yahei"; color: #333;font-size:18px} h1{ font-size: 100px; font-weight: normal; margin-bottom: 12px; } p{ line-height: 1.6em; font-size: 42px }</style><div style="padding: 24px 48px;"> <h1>:)</h1><p> ThinkPHP V5<br/><span style="font-size:30px">十年磨一剑 - 为API开发设计的高性能框架</span></p><span style="font-size:22px;">[ V5.0 版本由 <a href="http://www.qiniu.com" target="qiniu">七牛云</a> 独家赞助发布 ]</span></div><script type="text/javascript" src="http://tajs.qq.com/stats?sId=9347272" charset="UTF-8"></script><script type="text/javascript" src="http://ad.topthink.com/Public/static/client.js"></script><thinkad id="ad_bd568ce7058a1091"></thinkad>';
	    }
	}


其中return返回的数据，正好是我们前面输入：[http://localhost/tp5/public/](http://localhost/tp5/public/)所看到对应的数据。


下面开始简单的项目文件配置（根据个人习惯而定）。

######文件创建

一切先从Application文件夹开始。因为我们平时一个项目中都会分前后端，所以这里在Application中新建一些文件个文件夹，至于index文件夹可以不用管，也可以在他的基础上或者直接把他当做前段文件夹。

+ home文件夹
	- common.php文件
	- config.php文件
	- controller文件夹
		- index.php文件
	- view文件夹
		- index文件夹
			- index.html文件
	- model文件夹

+ admin文件夹
	- common.php文件
	- config.php文件
	- controller文件夹
		- index.php文件
	- view文件夹
		- index文件夹
			- index.html文件
	- model文件夹

+ app_extend文件夹
	- common.php文件
	- config.php文件
	- controller文件夹
		- miaosha文件夹
		- weixin文件夹
		- tuangou文件夹
	- view文件夹
		- miaosha文件夹
		- weixin文件夹
		- tuangou文件夹
	- model文件夹
		- miaosha文件夹
		- weixin文件夹
		- tuangou文件夹

+ common文件夹

关于其他配置和相关文件的介绍这里就略过了。相信有一点基础一应都能看懂。

### 数据简单显示


1. 在admin和home中controller文件夹对应的index.php文件中写下面代码：

index.php实现


	<?php
	namespace app\home\controller;
	
	use think\Controller;
	
	class Index extends Controller
	{
	    public function index()
	    {
	    	return $this->fetch();
	    }
	}

fetch()和ThinkPhp3中的display()方法的功能一应，实现MV层的传递。

	fetch 	渲染模板输出
	display 	渲染内容输出
	assign 	模板变量赋值
	engine 	初始化模板引擎


2. 在admin和home中view文件夹对应的index.html文件中写下面代码：

index.html实现

	<html>
	
	<head>
		<meta charset = "utf-8">
	</head> 
	
	 <body>
	
	欢迎来到iCocos=name；；；；；；；；；；；
	
	 </body>
	
	</html>


至于视图的实例化和相关配置，使用和渲染请查看官方手册：[视图](http://www.kancloud.cn/manual/thinkphp5/118113)


使用：浏览器分别输入下面的路径，可以看到对应我们想要看到的界面

home：

	http://127.0.0.1/ThComp3/public/home/index

admin：

	http://127.0.0.1/ThComp3/public/admin/index

这里就简单的实现了MVC中M层和V层之间的处理。

### 数据库配置

1. 先使用Navicat或者phpMyAdmin创建对应的数据库和表，并且初始化一些字段，然后插入一条简单的数据，这里我使用Navicat（支持多数数据库，操作简单）。

{% img /images/thinkphp5_0004.png Caption %}  

2. 配置数据库相关属性



在这之前先回顾一下原生PHP什么实现这个操作。

######链接数据库

面向对象

	<?php
	$servername = "localhost";
	$username = "username";
	$password = "password";
	 
	// 创建连接
	$conn = new mysqli($servername, $username, $password);
	 
	// 检测连接
	if ($conn->connect_error) {
	    die("连接失败: " . $conn->connect_error);
	} 
	echo "连接成功";
	?>


PDO实现


	<?php
	$servername = "localhost";
	$username = "username";
	$password = "password";
	 
	try {
	    $conn = new PDO("mysql:host=$servername;dbname=myDB", $username, $password);
	    echo "连接成功"; 
	}
	catch(PDOException $e)
	{
	    echo $e->getMessage();
	}
	?>
	
	关闭
	
	$conn->close(); 
	$conn = null; 


######创建数据库

	<?php
	$servername = "localhost";
	$username = "username";
	$password = "password";
	
	// 创建连接
	$conn = new mysqli($servername, $username, $password);
	// 检测连接
	if ($conn->connect_error) {
	    die("连接失败: " . $conn->connect_error);
	}
	
	// 创建数据库
	$sql = "CREATE DATABASE myDB";
	if ($conn->query($sql) === TRUE) {
	    echo "数据库创建成功";
	} else {
	    echo "Error creating database: " . $conn->error;
	}
	
	$conn->close();
	?> 

######创建表

	 <?php
	$servername = "localhost";
	$username = "username";
	$password = "password";
	$dbname = "myDB";
	
	// 创建连接
	$conn = new mysqli($servername, $username, $password, $dbname);
	// 检测连接
	if ($conn->connect_error) {
	    die("连接失败: " . $conn->connect_error);
	}
	
	// 使用 sql 创建数据表
	$sql = "CREATE TABLE MyGuests (
	id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(30) NOT NULL,
	lastname VARCHAR(30) NOT NULL,
	email VARCHAR(50),
	reg_date TIMESTAMP
	)";
	
	if ($conn->query($sql) === TRUE) {
	    echo "Table MyGuests created successfully";
	} else {
	    echo "创建数据表错误: " . $conn->error;
	}
	
	$conn->close();
	?> 


######插入数据库

	<?php
	$servername = "localhost";
	$username = "username";
	$password = "password";
	$dbname = "myDB";
	
	// 创建连接
	$conn = new mysqli($servername, $username, $password, $dbname);
	// 检测连接
	if ($conn->connect_error) {
	    die("连接失败: " . $conn->connect_error);
	}
	
	$sql = "INSERT INTO MyGuests (firstname, lastname, email)
	VALUES ('John', 'Doe', 'john@example.com')";
	
	if ($conn->query($sql) === TRUE) {
	    echo "新记录插入成功";
	} else {
	    echo "Error: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
	?> 


######插入多条

	<?php
	$servername = "localhost";
	$username = "username";
	$password = "password";
	$dbname = "myDB";
	
	// 创建链接
	$conn = new mysqli($servername, $username, $password, $dbname);
	// 检查链接
	if ($conn->connect_error) {
	    die("连接失败: " . $conn->connect_error);
	}
	
	$sql = "INSERT INTO MyGuests (firstname, lastname, email)
	VALUES ('John', 'Doe', 'john@example.com');";
	$sql .= "INSERT INTO MyGuests (firstname, lastname, email)
	VALUES ('Mary', 'Moe', 'mary@example.com');";
	$sql .= "INSERT INTO MyGuests (firstname, lastname, email)
	VALUES ('Julie', 'Dooley', 'julie@example.com')";
	
	if ($conn->multi_query($sql) === TRUE) {
	    echo "新记录插入成功";
	} else {
	    echo "Error: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
	?> 


######查询数据

	<?php
	$servername = "localhost";
	$username = "username";
	$password = "password";
	$dbname = "myDB";
	
	// 创建连接
	$conn = new mysqli($servername, $username, $password, $dbname);
	// 检测连接
	if ($conn->connect_error) {
	    die("连接失败: " . $conn->connect_error);
	}
	
	$sql = "SELECT id, firstname, lastname FROM MyGuests";
	$result = $conn->query($sql);
	
	if ($result->num_rows > 0) {
	    // 输出每行数据
	    while($row = $result->fetch_assoc()) {
	        echo "<br> id: ". $row["id"]. " - Name: ". $row["firstname"]. " " . $row["lastname"];
	    }
	} else {
	    echo "0 个结果";
	}
	$conn->close();
	?> 

######更新

	<?php
	$con=mysqli_connect("localhost","username","password","database");
	// 检测连接
	if (mysqli_connect_errno())
	{
		echo "连接失败: " . mysqli_connect_error();
	}
	
	mysqli_query($con,"UPDATE Persons SET Age=36
	WHERE FirstName='Peter' AND LastName='Griffin'");
	
	mysqli_close($con);
	?>

######删除

	<?php
	$con=mysqli_connect("localhost","username","password","database");
	// 检测连接
	if (mysqli_connect_errno())
	{
		echo "连接失败: " . mysqli_connect_error();
	}
	
	mysqli_query($con,"DELETE FROM Persons WHERE LastName='Griffin'");
	
	mysqli_close($con);
	?>

######ODBC 

下面的实例展示了如何首先创建一个数据库连接，接着创建一个结果集，然后在 HTML 表格中显示数据。

	<html>
	<body>
	
	<?php
	$conn=odbc_connect('northwind','','');
	if (!$conn)
	{
		exit("连接失败: " . $conn);
	}
	
	$sql="SELECT * FROM customers";
	$rs=odbc_exec($conn,$sql);
	
	if (!$rs)
	{
		exit("SQL 语句错误");
	}
	echo "<table><tr>";
	echo "<th>Companyname</th>";
	echo "<th>Contactname</th></tr>";
	
	while (odbc_fetch_row($rs))
	{
		$compname=odbc_result($rs,"CompanyName");
		$conname=odbc_result($rs,"ContactName");
		echo "<tr><td>$compname</td>";
		echo "<td>$conname</td></tr>";
	}
	odbc_close($conn);
	echo "</table>";
	?>
	
	</body>
	</html>


######在根目录的database.php中配置对应的数据信息

	<?php
	// +----------------------------------------------------------------------
	// | ThinkPHP [ WE CAN DO IT JUST THINK ]
	// +----------------------------------------------------------------------
	// | Copyright (c) 2006~2016 http://thinkphp.cn All rights reserved.
	// +----------------------------------------------------------------------
	// | Licensed ( http://www.apache.org/licenses/LICENSE-2.0 )
	// +----------------------------------------------------------------------
	// | Author: liu21st <liu21st@gmail.com>
	// +----------------------------------------------------------------------

	return [
	    // 数据库类型
	    'type'           => 'mysql',
	    // 服务器地址
	    'hostname'       => '127.0.0.1',
	    // 数据库名
	    'database'       => 'WWWiCocos',
	    // 用户名
	    'username'       => 'root',
	    // 密码
	    'password'       => '',
	    // 端口
	    'hostport'       => '3306',
	    // 连接dsn
	    'dsn'            => '',
	    // 数据库连接参数
	    'params'         => [],
	    // 数据库编码默认采用utf8
	    'charset'        => 'utf8',
	    // 数据库表前缀
	    'prefix'         => '',
	    // 数据库调试模式
	    'debug'          => true,
	    // 数据库部署方式:0 集中式(单一服务器),1 分布式(主从服务器)
	    'deploy'         => 0,
	    // 数据库读写是否分离 主从式有效
	    'rw_separate'    => false,
	    // 读写分离后 主服务器数量
	    'master_num'     => 1,
	    // 指定从服务器序号
	    'slave_no'       => '',
	    // 是否严格检查字段是否存在
	    'fields_strict'  => true,
	    // 数据集返回类型 array 数组 collection Collection对象
	    'resultset_type' => 'array',
	    // 是否自动写入时间戳字段
	    'auto_timestamp' => false,
	    // 是否需要进行SQL性能分析
	    'sql_explain'    => false,
	];


######也可以在调用Db类的时候动态定义连接信息



	Db::connect([
	    // 数据库类型
	    'type'        => 'mysql',
	    // 数据库连接DSN配置
	    'dsn'         => '',
	    // 服务器地址
	    'hostname'    => '127.0.0.1',
	    // 数据库名
	    'database'    => 'thinkphp',
	    // 数据库用户名
	    'username'    => 'root',
	    // 数据库密码
	    'password'    => '',
	    // 数据库连接端口
	    'hostport'    => '',
	    // 数据库连接参数
	    'params'      => [],
	    // 数据库编码默认采用utf8
	    'charset'     => 'utf8',
	    // 数据库表前缀
	    'prefix'      => 'think_',
	]);

######或者使用字符串方式：

	Db::connect('mysql://root:1234@127.0.0.1:3306/thinkphp#utf8');

####验证连接并打印数据


	首先必须清楚的明白之前在ThinkPhp3中的单字母函数，ThinkPhp5中已经取消了，比如M(),D()等，所以我们必须忘掉之前的这种风格。
	
这里配置好了数据库之后，使用对应的函数来验证连接，并且打印相关信息。

ThinkPhp3的方式

        $db = M('tp_user'); 
        print("<pre>"); // 格式化输出数组
        var_dump($db);
        print("</pre>");

ThinkPhp5的方式

        print("<pre>"); // 格式化输出数组
        var_dump(Db::table('tp_user')->select());
        // Db::name('user')->select(); // 或者
        print("</pre>");


这样就可以打印出数据库相关的信息如下：
	
	array(2) {
	  [0]=>
	  array(5) {
	    ["id"]=>
	    int(1)
	    ["uname"]=>
	    string(2) "56"
	    ["upwd"]=>
	    string(2) "65"
	    ["ip"]=>
	    string(3) "645"
	    ["last_time"]=>
	    int(564)
	  }
	  [1]=>
	  array(5) {
	    ["id"]=>
	    int(2)
	    ["uname"]=>
	    string(3) "234"
	    ["upwd"]=>
	    string(3) "wer"
	    ["ip"]=>
	    string(3) "221"
	    ["last_time"]=>
	    int(23)
	  }
	}




###基本使用

配置了数据库连接信息后，我们就可以直接使用数据库运行原生SQL操作了，支持query（查询操作）和execute（写入操作）方法，并且支持参数绑定。

	Db::query('select * from think_user where id=?',[8]);
	Db::execute('insert into think_user (id, name) values (?, ?)',[8,'thinkphp']);

也支持命名占位符绑定，例如：

	Db::query('select * from think_user where id=:id',['id'=>8]);
	Db::execute('insert into think_user (id, name) values (:id, :name)',['id'=>8,'name'=>'thinkphp']);

可以使用多个数据库连接，使用

	Db::connect($config)->query('select * from think_user where id=:id',['id'=>8]);

config是一个单独的数据库配置，支持数组和字符串，也可以是一个数据库连接的配置参数名。

###CRUD

######查询： 基本查询

查询一个数据使用：

	// table方法必须指定完整的数据表名
	Db::table('think_user')->where('id',1)->find();

+ find 方法查询结果不存在，返回 null

查询数据集使用：

	Db::table('think_user')->where('status',1)->select();

    select 方法查询结果不存在，返回空数组

如果设置了数据表前缀参数的话，可以使用

	Db::name('user')->where('id',1)->find();
	Db::name('user')->where('status',1)->select();


######增加：添加一条数据

使用 Db 类的 insert 方法向数据库提交数据

	$data = ['foo' => 'bar', 'bar' => 'foo'];
	Db::table('think_user')->insert($data);

如果你在database.php配置文件中配置了数据库前缀(prefix)，那么可以直接使用 Db 类的 name 方法提交数据

	Db::name('user')->insert($data);

+ insert 方法添加数据成功返回添加成功的条数，insert 正常情况返回 1

添加数据后如果需要返回新增数据的自增主键，可以使用getLastInsID方法：
	
	Db::name('user')->insert($data);
	$userId = Db::name('user')->getLastInsID();

或者直接使用insertGetId方法新增数据并返回主键值：

	Db::name('user')->insertGetId($data);

+ insertGetId 方法添加数据成功返回添加数据的自增主键


######更新：更新数据表中的数据

	Db::table('think_user')
	    ->where('id', 1)
	    ->update(['name' => 'thinkphp']);

如果数据中包含主键，可以直接使用：

	Db::table('think_user')
	    ->update(['name' => 'thinkphp','id'=>1]);

+ update 方法返回影响数据的条数，没修改任何数据返回 0

如果要更新的数据需要使用SQL函数或者其它字段，可以使用下面的方式：

	Db::table('think_user')
	    ->where('id', 1)
	    ->update([
	        'login_time'  => ['exp','now()'],
	        'login_times' => ['exp','login_times+1'],
	    ]);

更新某个字段的值：

	Db::table('think_user')
	    ->where('id',1)
	    ->setField('name', 'thinkphp');

+ setField 方法返回影响数据的条数，没修改任何数据字段返回 0


######删除： 删除数据表中的数据

	// 根据主键删除
	Db::table('think_user')->delete(1);
	Db::table('think_user')->delete([1,2,3]);
	
	// 条件删除    
	Db::table('think_user')->where('id',1)->delete();
	Db::table('think_user')->where('id','<',10)->delete();

+ delete 方法返回影响数据的条数，没有删除返回 0

助手函数

	// 根据主键删除
	db('user')->delete(1);
	// 条件删除    
	db('user')->where('id',1)->delete();

######查询：条件查询方法
+ where方法

可以使用where方法进行AND条件查询：

	Db::table('think_user')
	    ->where('name','like','%thinkphp')
	    ->where('status',1)
	    ->find();

多字段相同条件的AND查询可以简化为如下方式：

	Db::table('think_user')
	    ->where('name&title','like','%thinkphp')
	    ->find();

+ whereOr方法

使用whereOr方法进行OR查询：

	Db::table('think_user')
	    ->where('name','like','%thinkphp')
	    ->whereOr('title','like','%thinkphp')
	    ->find();

多字段相同条件的OR查询可以简化为如下方式：

	Db::table('think_user')
	    ->where('name|title','like','%thinkphp')
	    ->find();


其他高级操作参考官方手册：[数据库操作](http://www.kancloud.cn/manual/thinkphp5/118058)


### 模型介绍

####模型类定义

如果在某个模型类里面定义了connection属性的话，则该模型操作的时候会自动连接给定的数据库连接，而不是配置文件中设置的默认连接信息，通常用于某些数据表位于当前数据库连接之外的其它数据库，例如：

	//在模型里单独设置数据库连接信息
	namespace app\index\model;
	
	use think\Model;
	
	class User extends Model
	{
	    protected $connection = [
	        // 数据库类型
	        'type'        => 'mysql',
	        // 数据库连接DSN配置
	        'dsn'         => '',
	        // 服务器地址
	        'hostname'    => '127.0.0.1',
	        // 数据库名
	        'database'    => 'thinkphp',
	        // 数据库用户名
	        'username'    => 'root',
	        // 数据库密码
	        'password'    => '',
	        // 数据库连接端口
	        'hostport'    => '',
	        // 数据库连接参数
	        'params'      => [],
	        // 数据库编码默认采用utf8
	        'charset'     => 'utf8',
	        // 数据库表前缀
	        'prefix'      => 'think_',
	    ];
	}

也可以采用DSN字符串方式定义，例如：

	//在模型里单独设置数据库连接信息
	namespace app\index\model;
	
	use think\Model;
	
	class User extends Model
	{
	    //或者使用字符串定义
	    protected $connection = 'mysql://root:1234@127.0.0.1:3306/thinkphp#utf8';
	}

和连接数据库的参数一样，connection属性的值也可以设置为数据库的配置参数。

    5.0不支持单独设置当前模型的数据表前缀。

####模型调用

模型类可以使用静态调用或者实例化调用两种方式，例如：

	// 静态调用
	$user = User::get(1);
	$user->name = 'thinkphp';
	$user->save();
	
	// 实例化模型
	$user = new User;
	$user->name= 'thinkphp';
	$user->save();
	
	// 使用 Loader 类实例化（单例）
	$user = Loader::model('User');
	
	// 或者使用助手函数`model`
	$user = model('User');
	$user->name= 'thinkphp';
	$user->save();

####模型初始化
模型同样支持初始化，与控制器的初始化不同的是，模型的初始化是重写Model的initialize，具体如下

	namespace app\index\model;
	
	use think\Model;
	
	class Index extends Model
	{
	
	    //自定义初始化
	    protected function initialize()
	    {
	        //需要调用`Model`的`initialize`方法
	        parent::initialize();
	        //TODO:自定义的初始化
	    }
	}

同样也可以使用静态init方法，需要注意的是init只在第一次实例化的时候执行，并且方法内需要注意静态调用的规范，具体如下：

	namespace app\index\model;
	
	use think\Model;
	
	class Index extends Model
	{
	
	    //自定义初始化
	    protected static function init()
	    {
	        //TODO:自定义的初始化
	    }
	}


####CRUD

######增加

+ 添加一条数据

第一种是实例化模型对象后赋值并保存：

	$user           = new User;
	$user->name     = 'thinkphp';
	$user->email    = 'thinkphp@qq.com';
	$user->save();

也可以使用data方法批量赋值：

	$user = new User;
	$user->data([
	    'name'  =>  'thinkphp',
	    'email' =>  'thinkphp@qq.com'
	]);
	$user->save();

或者直接在实例化的时候传入数据

	$user = new User([
	    'name'  =>  'thinkphp',
	    'email' =>  'thinkphp@qq.com'
	]);
	$user->save();

如果需要过滤非数据表字段的数据，可以使用：

	$user = new User($_POST);
	// 过滤post数组中的非数据表字段数据
	$user->allowField(true)->save();

如果你通过外部提交赋值给模型，并且希望指定某些字段写入，可以使用：

	$user = new User($_POST);
	// post数组中只有name和email字段会写入
	$user->allowField(['name','email'])->save();

    save方法新增数据返回的是写入的记录数。

######更新

+ 查找并更新

在取出数据后，更改字段内容后更新数据。

	$user = User::get(1);
	$user->name     = 'thinkphp';
	$user->email    = 'thinkphp@qq.com';
	$user->save();

+ 直接更新数据

也可以直接带更新条件来更新数据

	$user = new User;
	// save方法第二个参数为更新条件
	$user->save([
	    'name'  => 'thinkphp',
	    'email' => 'thinkphp@qq.com'
	],['id' => 1]);

上面两种方式更新数据，如果需要过滤非数据表字段的数据，可以使用：

	$user = new User();
	// 过滤post数组中的非数据表字段数据
	$user->allowField(true)->save($_POST,['id' => 1]);

如果你通过外部提交赋值给模型，并且希望指定某些字段写入，可以使用：

	$user = new User();】(['name','email'])->save($_POST, ['id' => 1]);

######删除

+ 删除当前模型

删除模型数据，可以在实例化后调用delete方法。

	$user = User::get(1);
	$user->delete();

+ 根据主键删除

或者直接调用静态方法

	User::destroy(1);
	// 支持批量删除多个数据
	User::destroy('1,2,3');
	// 或者
	User::destroy([1,2,3]);

+ 条件删除

使用数组进行条件删除，例如：

	// 删除状态为0的数据
	User::destroy(['status' => 0]);

还支持使用闭包删除，例如：

	User::destroy(function($query){
	    $query->where('id','>',10);
	});

或者通过数据库类的查询条件删除

	User::where('id','>',10)->delete();


######查询
+ 获取单个数据

获取单个数据的方法包括：

取出主键为1的数据

	$user = User::get(1);
	echo $user->name;
	
	// 使用数组查询
	$user = User::get(['name' => 'thinkphp']);
	
	// 使用闭包查询
	$user = User::get(function($query){
	    $query->where('name', 'thinkphp');
	});
	echo $user->name;

或者在实例化模型后调用查询方法

	$user = new User();
	// 查询单个数据
	$user->where('name', 'thinkphp')
	    ->find();

+ get或者find方法返回的是当前模型的对象实例，可以使用模型的方法。


其他高级操作参考官方手册：[模型操作](http://www.kancloud.cn/manual/thinkphp5/135186)

####MVC思想

1. 连接并获取数据相关数据

	    $result = Db::table('tp_user')->find();

	    //$result = Db::table('tp_user')->where('upwd', 'wer')->find();
	        
		//var_dump(Db::select(function ($query)
		//{
		//   $query->table('tp_user')->where('id', 2);
		//
		//}));
		
2. 将获取到的数据库数据赋值给View（注意这里使用assign,thin3中是display）
 
        $this->assign('result',$result);
        return $this->fetch();
        
3. 在View中拿到数据显示

	    <!DOCTYPE html>
	    <html>
	    <head>
	      <meta charset="UTF-8">
	      <title>Insert title here</title>
	    </head>
	    <body>
	      {$result.id}--{$result.data}
	    </body>
	    </html>


一个最简单的MVC模式就实现了，其实后面开发和实战中基本上就是讲这个实现扩大，然后做相应的逻辑或者细节处理。


### 总结


####ThinkPHP5.* 与 ThinkPHP3.* 之间的使用差异

因为研究TP5时间不是很长，暂时先列以下几处差异：

1、过去的单字母函数已完全被替换掉，如下：

	S=>cache，C=>config，M/D=>model，U=>url，I=>input，E=>exception，L=>lang，A=>controller，R=>action

2、模版渲染：$this->display() => return view()/return $this->fetch();

3、在model中调用自身model：$this => Db::table($this->table)

4、在新建控制器与模型时的命名：

	　　①控制器去掉后缀controller：UserController => User
	
	　　②模型去掉后缀model：UserModel => User

5、url访问：

	　　如果控制器名使用驼峰法，访问时需要将各字母之间用下划线链接后进行访问。
	
	　　eg：控制器名为AddUser，访问是用add_user来进行访问

6、在TP5中支持配置二级参数（即二维数组），配置文件中，二级配置参数读取：

	　　①Config::get('user.type');
	
	　　②config('user.type');

7、模板中支持三元运算符的运算：{$info.status ? $info.msg : $info.error}还支持这种写法：

	{$varname.aa ?? 'xxx'}或{$varname.aa ?: 'xxx'}

8、TP5内置标签：

	　　系统内置的标签中，volist、switch、if、elseif、else、foreach、compare（包括所有的比较标签）、（not）present、（not）empty、（not）defined等

9、TP5数据验证：

	　　$validate = new Validate(['name' => 'require|max:25','email' => 'email']);
	
	　　$data = ['name' => 'thinkphp','email' => 'thinkphp@qq.com'];
	
	　　if(!validate->check($data)){
	
	　　　　debug::dump($validate->getError());
	
	　　}

> 注：使用助手函数实例化验证器——$validate = validate('User');

10、TP5实现了内置分页，使用如下：

查询状态为1的用户数据，且每页显示10条数据

	　　$list = model('User')->where('status',1)->paginate(10);
	
	　　 $page = $this->render();
	
	　　 $this->assign('_list',$list);
	
	　　 $this->assign('_page',$page);
	
	　　 return $this->fetch();

模板文件中分页输出代码如下：

	　　<div>{$_page}</div>

===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  








