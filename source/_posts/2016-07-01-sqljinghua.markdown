---

layout: post
title: "SQLite精华篇"
date: 2016-07-01 02:59:42 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---

####概述
iOS系统自带Core Data来进行持久化处理，而且Core Data可以使用图形化界面来创建对象，但是Core Data不是关系型数据库，对于Core Data来说比较擅长管理在设备上创建的数据持久化存储用户创建的对象，但是要处理大量的数据时就应该优先选择SQL关系型数据库来存储这些数据。 
Core Data在后台也是使用SQLite来存储数据的，但是开发人员不能直接访问这些数据，只能通过Core Data提供的API来操作，如果一旦人为的通过SQLite修改这些数据那么使用Core Data再次访问这些数据时就会发生错误。



<!--more-->



###SQLite库

SQLite是使用C语言写的开源库，实现了一个自包含的SQL关系型数据库引擎，可以使用SQLite存储操作大量的数据，作为关系型数据库我们可以在一个数据库中建立多张相关联的表来解决大量数据重复的问题。而且SQLite库也针对移动设备上的使用进行了优化。 
因为SQLite的接口使用C写的，而且Objective-C是C的超集所以可以直接在项目中使用SQLite。

###设计一个数据库

开始之前首先要想到需要存什么数据，然后怎么设计这个数据库。 
首先我们设计一个数据库用来存储人员信息如下：


{% img /images/sql0004.png Caption %} 

上面是所有的人员信息，实际可能比这个多很多。但是我们发现region这一行中有很多的数据重复出现。很多人可能来自同一个地方，为了避免这种情况我们应该再重新创建一张表来单独存储region这列的信息然后在这个表中引用region表中的信息。当然我们还可以在region表中添加更多的信息比如详细地址。现在创建两张表people与region如下所示

    people表

{% img /images/sql0001.png Caption %} 


    region表

{% img /images/sql0002.png Caption %} 


#####使用SQLite创建数据库

为了熟悉SQLite语句，打开shell使用SQLite命令行来创建一个数据库

    打开创建数据库

    打开shell切换到指定目录输入


	
	sqlite3 database.db

这行命令是启动sqlite命令行并且创建新的数据库database.db并附加该数据到命令行

此时已经进入sqlite命令行通过输入.help可以显示可以使用哪些命令，通过输入.databases来查看当前有哪些数据库附加到当前的命令行工具中。输入.quit或.exit退出当前命令行工具

#####创建表

	
	create table "main"."people" ("id" integer primary key autoincrement not null, "name" text,"age" integer,"email" text,"region" integer);

这条命令是创建一个people的表，并且将id字段设为primary key主键将其指定为一个autoincrement自动增长的字段。表示不用提供id的值数据库将自动生成。后面的表示该张表中所含有的字段。

因为要设计两张表所以还需要创建region表

	
	create table "main"."region" ("regionid" integer primary key autoincrement not null, "regioninfo" text,"address" text not null);

#####添加数据

此时已经成功创建了两张表我们要添加数据进去

	
	insert into "main"."people" ("name","age","email","region") values ('jhon','20','jhon@mail','1');

这样成功往people表成功的插入了一条数据。这样写效率比较低。每次只能插入一条数据不要担心SQLite支持将文件直接导入数据库中。可以是普通的文件文件也可以是excel文件。下面我们创建一个people.txt文件格式如下：

	
	1 jhon 20 jhon@mail 12 peter 20 peter@mail 23 july 20 july@mail 14 elev 20 elev@mail 35 ribet 20 ribet@mail

注意每个字段之间的空隙是用制表符来分割的，也就是创建文件是每个字段用tab键进行分割。字段的顺序必须和表中的顺序相同然后将people.txt文件导入people表中

	
.separator ""

根据来分割字段，然后接着输入

	
	.import "people.txt" people

导入people.txt文件到people表中此时会提示如下错误信息

	
	people.txt:1: INSERT failed: UNIQUE constraint failed: people.id

不用担心这个意思是说已经存在了一个id为1的数据所以这条数据插入失败，是因为我们之前手动了插入了一条数据。可以通过以下指令来查插入的数据

	
	select * from people;

然后用同样的方法创建一个region.txt的文件并将其导入region表中。

#####注意

使用SQLite命令行可能会出现...>这表示指令输入错误，按ctrl+d即可退出

查询数据上面已经添加完数据通过select指令可以查询这些数据

	
	select * from people;11

查询popple表中的所有数据

链接表数据

	
	select name,regioninfo from people,region where people.region=region.regionid;

输出结果

	
	jhon beijing
	peter shanghai
	july beijing
	elev shenzhen
	ribet beijing

从people和region表中查找name与regioninfo字段并且只查询people.region=region.regionid相匹配的结果，如果没有这个条件那么将出现5*3=15条数据

如果要查找某个地区的人使用where来筛选条件

	
	select name,regioninfo from people,region where people.region=region.regionid and region.regioninfo="beijing";

输出结果

	
	jhon beijing
	july beijing
	ribet beijing

###iOS中SQLite的使用

开始之前应该在项目中引用SQLite库。TARGETS->General->Linked Frameworks and Libraries如下图所示

{% img /images/sql0003.png Caption %} 


将之前创建好的database.db文件导入项目中，并引入sqlite3.h头文件

	
	#import

使用SQLite需要一下几个步骤：

    声明类变量sqlite3来保存对数据库的引用

    使用sqlite3_open打开数据库

    创建SQLite语句

    创建SQLite语句对象sqlite3_stmt

    准备SQLite语句sqlite3_prepare_v2

    开始遍历结果sqlite3_step

#####初始化打开数据库

	
	sqlite3 * database;
	-(void)initDatabase
	{ NSString *path = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"db"];
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) { NSLog(@"open database");
	} else{
	sqlite3_close(database); NSLog(@"error %s",sqlite3_errmsg(database));
	}
}

打开数据库如果返回的状态码不是SQLITE_OK那么打开失败关闭数据库并且输出错误信息

#####查询数据

	-(void)operateDatabase
	{ const char * sql = "select name,regioninfo from people,region where people.region=region.regionid";
	sqlite3_stmt *statement; //创建sql语句对象
	int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL); //准备sql语句
	if ( sqlResult== SQLITE_OK) //是否准备结束
	{ while (sqlite3_step(statement) == SQLITE_ROW) //开始遍历查询结果
	{ NSLog(@"name %s, region %s",sqlite3_column_text(statement, 0),sqlite3_column_text(statement, 1));
	}
	}
	}

输出结果：

	name jhon, region beijingname peter, region shanghainame july, region beijingname elev, region shenzhenname ribet, region beijing1234512345

sqlite3_prepare_v2的参数第一个是数据库连接，第二个是sql语句，第三个是这个语句的长度传入-1表示地道第一个null终止符为止，第四个是返回一个语句对象，第五个是返回一个指向该sql语句的第一个字节的指针。

当sqlite3_prepare_v2返回状态码SQLITE_OK时开始遍历结果。

sqlite3_step用来遍历结果如果返回为SQLITE_ROW表示下一行准备结束可以开始查询。所以此处用一个while来便利所以查询的结果

遍历的过程中要取到结果通过一下的函数获取遍历结果

	
	SQLITE_API const void *SQLITE_STDCALL sqlite3_column_blob(sqlite3_stmt*, int iCol);
	SQLITE_API int SQLITE_STDCALL sqlite3_column_bytes(sqlite3_stmt*, int iCol);
	SQLITE_API int SQLITE_STDCALL sqlite3_column_bytes16(sqlite3_stmt*, int iCol);
	SQLITE_API double SQLITE_STDCALL sqlite3_column_double(sqlite3_stmt*, int iCol);
	SQLITE_API int SQLITE_STDCALL sqlite3_column_int(sqlite3_stmt*, int iCol);
	SQLITE_API sqlite3_int64 SQLITE_STDCALL sqlite3_column_int64(sqlite3_stmt*, int iCol);
	SQLITE_API const unsigned char *SQLITE_STDCALL sqlite3_column_text(sqlite3_stmt*, int iCol);
	SQLITE_API const void *SQLITE_STDCALL sqlite3_column_text16(sqlite3_stmt*, int iCol);
	SQLITE_API int SQLITE_STDCALL sqlite3_column_type(sqlite3_stmt*, int iCol);
	SQLITE_API sqlite3_value *SQLITE_STDCALL sqlite3_column_value(sqlite3_stmt*, int iCol);

上面是所支持的结果类型，第一个参数为sql语句对象，第二个为获取哪一列的信息。

#####参数化查询

上面的情况每次sql语句都写死了，如果想要改变某个条件就需要重新写一条语句，幸好sqlite支持参数化查询，每次只需要更改查询条件就可以而不用更改整条sql语句，如果现在只想查询北京地区的人口信息使用参数化查询如下：

	
	-(void)operateDatabase
	{ const char * sql = "select name,regioninfo from people,region where people.region=region.regionid and regioninfo=?";
	sqlite3_stmt *statement; //创建sql语句对象
	int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL); //准备sql语句
	sqlite3_bind_text(statement, 1, "beijing", -1,SQLITE_TRANSIENT); //绑定参数
	if ( sqlResult== SQLITE_OK) //是否准备结束
	{ while (sqlite3_step(statement) == SQLITE_ROW) //开始遍历查询结果
	{ NSLog(@"name %s, region %s",sqlite3_column_text(statement, 0),sqlite3_column_text(statement, 1));
	}
	}
	}

输出结果：

	name jhon, regionbeijingname july, regionbeijingname ribet, regionbeijing

可见需要更改的条件sql中用?来代替，然后用sqlite3_bind_text函数来绑定参数。根据类型不同绑定的函数也不同
 
	
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_blob64(sqlite3_stmt*, int, const void*, sqlite3_uint64,void(*)(void*));
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_double(sqlite3_stmt*, int, double);
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_int(sqlite3_stmt*, int, int);
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_int64(sqlite3_stmt*, int, sqlite3_int64);
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_null(sqlite3_stmt*, int);
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_text(sqlite3_stmt*,int,const char*,int,void(*)(void*));
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_text16(sqlite3_stmt*, int, const void*, int, void(*)(void*));
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_text64(sqlite3_stmt*, int, const char*, sqlite3_uint64,void(*)(void*), unsigned char encoding);
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_value(sqlite3_stmt*, int, const sqlite3_value*);
	SQLITE_API int SQLITE_STDCALL sqlite3_bind_zeroblob(sqlite3_stmt*, int, int n);

上面列出了所有支持绑定类型的函数。

>结束

>本篇只是列出了SQLite常用的基础方法，实际开发中数据库可能要比这复杂许多，而且还要考虑数据竞争线程安全的问题。具体还是要自己在开发中实践。







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