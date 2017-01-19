---
layout: post
title: "PHP完美搭配之Mysql初探"
date: 2016-12-03 13:36:37 +0800
comments: true
categories: PHP-Lover
---

###数据库概念

######什么是数据库

数据库就是用来存储和管理数据的仓库！

数据库存储数据的优先：

 
	可存储大量数据；

	 方便检索；
	
	 保持数据的一致性、完整性；
	
	 安全，可共享；
	
	 通过组合分析，可产生新数据。

 <!--more-->

######数据库的发展历程

 没有数据库，使用磁盘文件存储数据；

	 层次结构模型数据库；
	
	 网状结构模型数据库；
	
	 关系结构模型数据库：
	 
	 使用二维表格来存储数据；
	
	 关系-对象模型数据库；
	 
	 MySQL就是关系型数据库！

 

######常见数据库

	 Oracle（神喻）：甲骨文（最高！）；
	
	 DB2：IBM；
	
	 SQ Server：微软；
	
	 Sybase：赛尔斯；
	
	 MySQL：甲骨文；

 

######理解数据库

	 RDBMS = 管理员（manager）+仓库（database）

	 database = N个table

 table：

    表结构：定义表的列名和列类型！
    表记录：一行一行的记录！


我们现在所说的数据库泛指“关系型数据库管理系统（RDBMS - Relationa database management system）”，即“数据库服务器”。

 
当我们安装了数据库服务器后，就可以在数据库服务器中创建数据库，每个数据库中还可以包含多张表。

 
    表头(header): 每一列的名称;
    列(row): 具有相同数据类型的数据的集合;
    行(col): 每一行用来描述某个人/物的具体信息;
    值(value): 行的具体信息, 每个值必须与该列的数据类型相同;
    键(key): 表中用来识别某个特定的人\物的方法, 键的值在当前列中具有唯一性。


数据库表就是一个多行多列的表格。在创建表时，需要指定表的列数，以及列名称，列类型等信息。而不用指定表格的行数，行数是没有上限的

######应用程序与数据库

　　应用程序使用数据库完成对数据的存储！

######启动和关闭mysql服务器

	 启动：net start mysql；
	
	 关闭：net stop mysql；


######客户端登录退出mysql

在启动MySQL服务器后，我们需要使用管理员用户登录MySQL服务器，然后来对服务器进行操作。

 
######登录：mysq -u root -p 123 -h localhost；

    -u：后面的root是用户名，这里使用的是超级管理员root；
    -p：后面的123是密码，这是在安装MySQL时就已经指定的密码；
    -h：后面给出的localhost是服务器主机名，它是可以省略的，例如：mysq -u root -p 123；


######退出：quit或exit；

###概述

######什么是SQL

SQL（Structured Query Language）是“结构化查询语言”，它是对关系型数据库的操作语言。它可以应用到所有关系型数据库中，例如：MySQL、Oracle、SQ Server等。SQ标准（ANSI/ISO）有：

	 SQL-92：1992年发布的SQL语言标准；
	
	 SQL:1999：1999年发布的SQL语言标签；
	
	 SQL:2003：2003年发布的SQL语言标签；

 

这些标准就与JDK的版本一样，在新的版本中总要有一些语法的变化。不同时期的数据库对不同标准做了实现。

虽然SQL可以用在所有关系型数据库中，但很多数据库还都有标准之后的一些语法，我们可以称之为“方言”。例如MySQL中的LIMIT语句就是MySQL独有的方言，其它数据库都不支持！当然，Oracle或SQ Server都有自己的方言。

###语法要求

	 SQL语句可以单行或多行书写，以分号结尾；
	
	 可以用空格和缩进来来增强语句的可读性；
	
	 关键字不区别大小写，建议使用大写；

 
###分类

	 DDL（Data Definition Language）：数据定义语言，用来定义数据库对象：库、表、列等；
	
	 DML（Data Manipulation Language）：数据操作语言，用来定义数据库记录（数据）；
	
	 DCL（Data Contro Language）：数据控制语言，用来定义访问权限和安全级别；
	
	 DQL（Data Query Language）：数据查询语言，用来查询记录（数据）。

 
###DDL

######基本操作

 查看所有数据库名称：
 
	 SHOW DATABASES；　

 切换数据库：
 
	 USE mydb1，切换到mydb1数据库；

######操作数据库

 创建数据库：
 
	 CREATE DATABASE [IF NOT EXISTS] mydb1；

创建数据库，例如：

	CREATE DATABASE mydb1，创建一个名为mydb1的数据库。如果这个数据已经存在，那么会报错。例如CREATE DATABASE IF NOT EXISTS mydb1，在名为mydb1的数据库不存在时创建该库，这样可以避免报错。

 

 删除数据库：
 
	 DROP DATABASE [IF EXISTS] mydb1；

删除数据库，例如：

	DROP DATABASE mydb1，删除名为mydb1的数据库。如果这个数据库不存在，那么会报错。DROP DATABASE IF EXISTS mydb1，就算mydb1不存在，也不会的报错。

 

 修改数据库编码：
 
	 ALTER DATABASE mydb1 CHARACTER SET utf8

修改数据库mydb1的编码为utf8。注意，在MySQL中所有的UTF-8编码都不能使用中间的“-”，即UTF-8要书写为UTF8。

###数据类型


MySQL有三大类数据类型, 分别为数字、日期\时间、字符串, 这三大类中又更细致的划分了许多子类型:


######数字类型

        整数: tinyint、smallint、mediumint、int、bigint
        浮点数: float、double、real、decimal

######日期和时间: 

		date、time、datetime、timestamp、year

######字符串类型
        字符串: char、varchar
        文本: tinytext、text、mediumtext、longtext
        二进制(可用来存储图片、音乐等): tinyblob、blob、mediumblob、longblob



MySQL与Java一样，也有数据类型。MySQL中数据类型主要应用在列上。


常用类型：

	 int：整型
	
	 double：浮点型，例如double(5,2)表示最多5位，其中必须有2位小数，即最大值为999.99；
	
	 decimal：泛型型，在表单钱方面使用该类型，因为不会出现精度缺失问题；
	
	 char：固定长度字符串类型；
	
	 varchar：可变长度字符串类型；
	
	 text：字符串类型；
	
	 blob：字节类型；
	
	 date：日期类型，格式为：yyyy-MM-dd；
	
	 time：时间类型，格式为：hh:mm:ss
	
	 timestamp：时间戳类型；

###组成

与常规的脚本语言类似, MySQ 也具有一套对字符、单词以及特殊符号的使用规定, MySQ 通过执行 SQ 脚本来完成对数据库的操作, 该脚本由一条或多条MySQL语句(SQL语句 + 扩展语句)组成, 保存时脚本文件后缀名一般为 .sql。在控制台下, MySQ 客户端也可以对语句进行单句的执行而不用保存为.sql文件。
###标识符

标识符用来命名一些对象, 如数据库、表、列、变量等, 以便在脚本中的其他地方引用。MySQL标识符命名规则稍微有点繁琐, 这里我们使用万能命名规则: 标识符由字母、数字或下划线(_)组成, 且第一个字符必须是字母或下划线。

对于标识符是否区分大小写取决于当前的操作系统, Windows下是不敏感的, 但对于大多数 linux\unix 系统来说, 这些标识符大小写是敏感的。

 

######关键字:

	MySQL的关键字众多, 这里不一一列出, 在学习中学习。 这些关键字有自己特定的含义, 尽量避免作为标识符。

 

######语句:

	MySQL语句是组成MySQL脚本的基本单位, 每条语句能完成特定的操作, 他是由 SQ 标准语句 + MySQ 扩展语句组成。

 

######函数:

	MySQL函数用来实现数据库操作的一些高级功能, 这些函数大致分为以下几类: 字符串函数、数学函数、日期时间函数、搜索函数、加密函数、信息函数。



###操作

######登录到MySQL

当 MySQ 服务已经运行时, 我们可以通过MySQL自带的客户端工具登录到MySQL数据库中, 首先打开命令提示符, 输入以下格式的命名:

mysq -h 主机名 -u 用户名 -p

    -h : 该命令用于指定客户端所要登录的MySQL主机名, 登录当前机器该参数可以省略;
    -u : 所要登录的用户名;
    -p : 告诉服务器将会使用一个密码来登录, 如果所要登录的用户名密码为空, 可以忽略此选项。

以登录刚刚安装在本机的MySQL数据库为例, 在命令行下输入 mysq -u root -p 按回车确认, 如果安装正确且MySQL正在运行, 会得到以下响应:

	Enter password:

> 若密码存在, 输入密码登录, 不存在则直接按回车登录, 按照本文中的安装方法, 默认 root 账号是无密码的。登录成功后你将会看到 Welecome to the MySQ monitor... 的提示语。

然后命令提示符会一直以 mysql> 加一个闪烁的光标等待命令的输入, 输入 exit 或 quit 退出登录。



######创建一个数据库

使用 create database 语句可完成对数据库的创建, 创建命令的格式如下:

	create database 数据库名 [其他选项];

例如我们需要创建一个名为 samp_db 的数据库, 在命令行下执行以下命令:

	create database samp_db character set gbk;


######选择所要操作的数据库

要对一个数据库进行操作, 必须先选择该数据库, 否则会提示错误:

	ERROR 1046(3D000): No database selected

两种方式对数据库进行使用的选择:

一: 在登录数据库时指定, 命令: mysq -D 所选择的数据库名 -h 主机名 -u 用户名 -p

	例如登录时选择刚刚创建的数据库: mysq -D samp_db -u root -p

二: 在登录后使用 use 语句指定, 命令: use 数据库名;

	use 语句可以不加分号, 执行 use samp_db 来选择刚刚创建的数据库, 选择成功后会提示: Database changed



######创建数据库表

使用 create table 语句可完成对表的创建, create table 的常见形式:

	create table 表名称(列声明);

以创建 students 表为例, 表中将存放 学号(id)、姓名(name)、性别(sex)、年龄(age)、联系电话(tel) 这些内容:

	create table students
	（
		id int unsigned not nul auto_increment primary key,
		name char(8) not null,
		sex char(4) not null,
		age tinyint unsigned not null,
		te char(13) nul default "-"
	);
				

######向表中插入数据

insert 语句可以用来将一行或多行数据插到数据库表中, 使用的一般形式如下:

	insert [into] 表名 [(列名1, 列名2, 列名3, ...)] values (值1, 值2, 值3, ...);

其中 [] 内的内容是可选的, 例如, 要给 samp_db 数据库中的 students 表插入一条记录, 执行语句:

	insert into students values(NULL, "王刚", "男", 20, "13811371377");



######查询表中的数据

select 语句常用来根据一定的查询规则到数据库中获取数据, 其基本的用法为:

	select 列名称 from 表名称 [查询条件];

例如要查询 students 表中所有学生的名字和年龄, 输入语句 select name, age from students; 执行结果如下:

	mysql> select name, age from students;
	+--------+-----+
	| name   | age |
	+--------+-----+
	| 王刚   |  20 |
	| 孙丽华 |  21 |
	| 王永恒 |  23 |
	| 郑俊杰 |  19 |
	| 陈芳   |  22 |
	| 张伟朋 |  21 |
	+--------+-----+
	6 rows in set (0.00 sec)


按特定条件查询:

	where 关键词用于指定查询条件, 用法形式为: select 列名称 from 表名称 where 条件;

	以查询所有性别为女的信息为例, 输入查询语句: select * from students where sex="女";

######更新表中的数据

update 语句可用来修改表中的数据, 基本的使用形式为:

	update 表名称 set 列名称=新值 where 更新条件;

使用示例:

	将id为5的手机号改为默认的"-": update students set tel=default where id=5;

	将所有人的年龄增加1: update students set age=age+1;

	将手机号为 13288097888 的姓名改为 "张伟鹏", 年龄改为 19: update students set name="张伟鹏", age=19 where tel="13288097888";
######删除表中的数据

delete 语句用于删除表中的数据, 基本用法为:

	delete from 表名称 where 删除条件;

使用示例:

	删除id为2的行: delete from students where id=2;
	
	删除所有年龄小于21岁的数据: delete from students where age<20;
	
	删除表中的所有数据: delete from students;
###创建后表的修改

alter table 语句用于创建后对表的修改, 基础用法如下:


######添加列

	基本形式: alter table 表名 add 列名 列数据类型 [after 插入位置];

示例:

	在表的最后追加列 address: alter table students add address char(60);
	
	在名为 age 的列后插入列 birthday: alter table students add birthday date after age;

######修改列

	基本形式: alter table 表名 change 列名称 列新名称 新数据类型;

示例:

	将表 te 列改名为 telphone: alter table students change te telphone char(13) default "-";
	
	将 name 列的数据类型改为 char(16): alter table students change name name char(16) not null;

######删除列

	基本形式: alter table 表名 drop 列名称;

示例:

	删除 birthday 列: alter table students drop birthday;
######重命名表

	基本形式: alter table 表名 rename 新表名;

示例:

	重命名 students 表为 workmates: alter table students rename workmates;
######删除整张表

基本形式: drop table 表名;

	示例: 删除 workmates 表: drop table workmates;
删除整个数据库

	基本形式: drop database 数据库名;

示例: 

	删除 samp_db 数据库: drop database samp_db;


###附录


######修改 root 用户密码

按照本文的安装方式, root 用户默认是没有密码的, 重设 root 密码的方式也较多, 这里仅介绍一种较常用的方式。

使用 mysqladmin 方式:

	打开命令提示符界面, 执行命令: mysqladmin -u root -p password 新密码

执行后提示输入旧密码完成密码修改, 当旧密码为空时直接按回车键确认即可。


###总结：

1、说明：创建数据库

	CREATE DATABASE database-name
2、说明：删除数据库

	drop database dbname
3、说明：备份sq server

--- 创建 备份数据的 device

	USE master
	EXEC sp_addumpdevice 'disk', 'testBack', 'c:\mssql7backup\MyNwind_1.dat'
--- 开始 备份

	BACKUP DATABASE pubs TO testBack
4、说明：创建新表

	create table tabname(col1 type1 [not null] [primary key],col2 type2 [not null],..)
根据已有的表创建新表：

	A：create table tab_new like tab_old (使用旧表创建新表)
	B：create table tab_new as select col1,col2… from tab_old definition only
5、说明：删除新表

	drop table tabname
6、说明：增加一个列

	Alter table tabname add column co type
	
	注：列增加后将不能删除。DB2中列加上后数据类型也不能改变，唯一能改变的是增加varchar类型的长度。
7、说明：添加主键： Alter table tabname add primary key(col)

	说明：删除主键： Alter table tabname drop primary key(col)
8、说明：创建索引：create [unique] index idxname on tabname(col….)

	删除索引：drop index idxname
	注：索引是不可更改的，想更改必须删除重新建。
9、说明：创建视图：create view viewname as select statement

	删除视图：drop view viewname
10、说明：几个简单的基本的sql语句

	选择：select * from table1 where 范围
	插入：insert into table1(field1,field2) values(value1,value2)
	删除：delete from table1 where 范围
	更新：update table1 set field1=value1 where 范围
	查找：select * from table1 where field1 like ’%value1%’ ---like的语法很精妙，查资料!
	排序：select * from table1 order by field1,field2 [desc]
	总数：select count as totalcount from table1
	求和：select sum(field1) as sumvalue from table1
	平均：select avg(field1) as avgvalue from table1
	最大：select max(field1) as maxvalue from table1
	最小：select min(field1) as minvalue from table1



###Mysql写出高质量的sql语句的几点建议


######1 建议一：尽量避免在列上运算
尽量避免在列上运算，这样会导致索引失效。
1.1 日期运算
优化前：

	select * from system_user where date(createtime) >= '2015-06-01'

优化后：

	select * from system_user where createtime >= '2015-06-01'

1.2 加，减，乘，除
优化前：

	select * from system_user where age + 10 >= 20

优化后：

	select * from system_user where age >= 10

######2 建议二：用整型设计索引

用整型设计的索引，占用的字节少，相对与字符串索引要快的多。特别是创建主键索引和唯一索引的时候。 1）设计日期时候，建议用int取代char(8)。例如整型：20150603。 2）设计IP时候可以用bigint把IP转化为长整型存储。 



######3 建议三：join时，使用小结果集驱动大结果集
使用join的时候，应该尽量让小结果集驱动大的结果集，把复杂的join查询拆分成多个query。因为join多个表的时候，可能会有表的锁定和阻塞。如果大结果集非常大，而且被锁了，那么这个语句会一直等待。这个也是新手常犯的一个错误！ 优化前：

	select
		*
	from table_a a
	left join table_b b
		on a.id = b.id
	left join table_c c
		on a.id = c.id
	where a.id > 100
		and b.id < 200


优化后：

	select
		*
	from (
		select	
			*
		from table_a
		where id > 100
	) a
	left join(
		select	
			*
		from table_b
		where id < 200
	)b
		on a.id = b.id
	left join table_c
		on a.id = c.id


######4 建议四：仅列出需要查询的字段
仅列出需要查询的字段，新手一般都查询的时候都是*，其实这样不好。这对速度不会有明显的影响，主要考虑的是节省内存。 优化前：

	select * from system_user where age > 10

优化后：

	select username,emai from system_user where age > 10


######5 建议五：使用批量插入节省交互
优化前：

	insert into system_user(username,passwd) values('test1','123456')
	insert into system_user(username,passwd) values('test2','123456')
	insert into system_user(username,passwd) values('test3','123456')


优化后：

	insert into system_user(username,passwd) values('test1','123456'),('test2','123456'),('test3','123456')

######6 建议六：多习惯使用explain分析sql语句
######7 建议七：多使用profiling分析sql语句时间开销

    




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