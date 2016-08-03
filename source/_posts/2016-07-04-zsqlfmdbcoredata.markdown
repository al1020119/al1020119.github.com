---

layout: post
title: "CoreData VS SQLite VS FMDB"
date: 2016-07-05 14:59:42 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---





概览

在iOS开发中数据存储的方式可以归纳为两类：一类是存储为文件，另一类是存储到数据库。例如前面IOS开发系列—Objective-C之Foundation框架的文章中提到归档、plist文件存储，包括偏好设置其本质都是存储为文件，只是说归档或者plist文件存储可以选择保存到沙盒中，而偏好设置系统已经规定只能保存到沙盒的Library/Preferences目录。当然，文件存储并不作为本文的重点内容。本文重点还是说数据库存储，做过数据库开发的朋友应该知道，可以通过SQL直接访问数据库，也可以通过ORM进行对象关系映射访问数据库。这两种方式恰恰对应iOS中SQLite和Core Data的内容，在此将重点进行分析:

###1. SQLite

###2. Core Data

###3. FMDB

---

##SQLite

SQLite是目前主流的嵌入式关系型数据库，其最主要的特点就是轻量级、跨平台，当前很多嵌入式操作系统都将其作为数据库首选。虽然SQLite是一款轻型数据库，但是其功能也绝不亚于很多大型关系数据库。学习数据库就要学习其相关的定义、操作、查询语言，也就是大家日常说得SQL语句。和其他数据库相比，SQLite中的SQL语法并没有太大的差别，因此这里对于SQL语句的内容不会过多赘述，大家可以参考SQLite中其他SQL相关的内容，这里还是重点讲解iOS中如何使用SQLite构建应用程序。先看一下SQLite数据库的几个特点：

1.基于C语言开发的轻型数据库

2.在iOS中需要使用C语言语法进行数据库操作、访问（无法使用ObjC直接访问，因为libqlite3框架基于C语言编写）

3.SQLite中采用的是动态数据类型，即使创建时定义了一种类型，在实际操作时也可以存储其他类型，但是推荐建库时使用合适的类型（特别是应用需要考虑跨平台的情况时）

4.建立连接后通常不需要关闭连接（尽管可以手动关闭）

要使用SQLite很简单，如果在Mac OSX上使用可以考虑到SQLite官方网站下载命令行工具，也可以使用类似于SQLiteManager、Navicat for SQLite等工具。为了方便大家开发调试，建议在开发环境中安装上述工具。

在iOS中操作SQLite数据库可以分为以下几步（注意先在项目中导入libsqlite3框架）：

1.打开数据库，利用sqlite3_open()打开数据库会指定一个数据库文件保存路径，如果文件存在则直接打开，否则创建并打开。打开数据库会得到一个sqlite3类型的对象，后面需要借助这个对象进行其他操作。

2.执行SQL语句，执行SQL语句又包括有返回值的语句和无返回值语句。

3.对于无返回值的语句（如增加、删除、修改等）直接通过sqlite3_exec()函数执行；

4.对于有返回值的语句则首先通过sqlite3_prepare_v2()进行sql语句评估（语法检测），然后通过sqlite3_step()依次取出查询结果的每一行数据，对于每行数据都可以通过对应的sqlite3_column_类型()方法获得对应列的数据，如此反复循环直到遍历完成。当然，最后需要释放句柄。

在整个操作过程中无需管理数据库连接，对于嵌入式SQLite操作是持久连接（尽管可以通过sqlite3_close()关闭），不需要开发人员自己释放连接。纵观整个操作过程，其实与其他平台的开发没有明显的区别，较为麻烦的就是数据读取，在iOS平台中使用C进行数据读取采用了游标的形式，每次只能读取一行数据，较为麻烦。因此实际开发中不妨对这些操作进行封装：

KCDbManager.h
//
//  DbManager.h
//  DataAccess
//
//  Created by Kenshin Cui on 14-3-29.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "KCSingleton.h"
@interface KCDbManager : NSObject
singleton_interface(KCDbManager);
#pragma mark - 属性
#pragma mark 数据库引用，使用它进行数据库操作
@property (nonatomic) sqlite3 *database;
#pragma mark - 共有方法
/**
 *  打开数据库
 *
 *  @param dbname 数据库名称
 */
-(void)openDb:(NSString *)dbname;
/**
 *  执行无返回值的sql
 *
 *  @param sql sql语句
 */
-(void)executeNonQuery:(NSString *)sql;
/**
 *  执行有返回值的sql
 *
 *  @param sql sql语句
 *
 *  @return 查询结果
 */
-(NSArray *)executeQuery:(NSString *)sql;
@end

KCDbManager.m
//
//  DbManager.m
//  DataAccess
//
//  Created by Kenshin Cui on 14-3-29.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import "KCDbManager.h"
#import <sqlite3.h>
#import "KCSingleton.h"
#import "KCAppConfig.h"
#ifndef kDatabaseName
#define kDatabaseName @"myDatabase.db"
#endif
@interface KCDbManager()
@end
@implementation KCDbManager
singleton_implementation(KCDbManager)
#pragma mark 重写初始化方法
-(instancetype)init{
    KCDbManager *manager;
    if((manager=[super init]))
    {
        [manager openDb:kDatabaseName];
    }
    return manager;
}
-(void)openDb:(NSString *)dbname{
    //取得数据库保存路径，通常保存沙盒Documents目录
    NSString *directory=[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@",directory);
    NSString *filePath=[directory stringByAppendingPathComponent:dbname];
    //如果有数据库则直接打开，否则创建并打开（注意filePath是ObjC中的字符串，需要转化为C语言字符串类型）
    if (SQLITE_OK ==sqlite3_open(filePath.UTF8String, &_database)) {
        NSLog(@"数据库打开成功!");
    }else{
        NSLog(@"数据库打开失败!");
    }
}
-(void)executeNonQuery:(NSString *)sql{
    char *error;
    //单步执行sql语句，用于插入、修改、删除
    if (SQLITE_OK!=sqlite3_exec(_database, sql.UTF8String, NULL, NULL,&error)) {
        NSLog(@"执行SQL语句过程中发生错误！错误信息：%s",error);
    }
}
-(NSArray *)executeQuery:(NSString *)sql{
    NSMutableArray *rows=[NSMutableArray array];//数据行
     
    //评估语法正确性
    sqlite3_stmt *stmt;
    //检查语法正确性
    if (SQLITE_OK==sqlite3_prepare_v2(_database, sql.UTF8String, -1, &stmt, NULL)) {
        //单步执行sql语句
        while (SQLITE_ROW==sqlite3_step(stmt)) {
            int columnCount= sqlite3_column_count(stmt);
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            for (int i=0; i<columnCount; i++) {
                const char *name= sqlite3_column_name(stmt, i);//取得列名
                const unsigned char *value= sqlite3_column_text(stmt, i);//取得某列的值
                dic[[NSString stringWithUTF8String:name]]=[NSString stringWithUTF8String:(const char *)value];
            }
            [rows addObject:dic];
        }
    }
     
    //释放句柄
    sqlite3_finalize(stmt);
     
    return rows;
}
@end

在上面的类中对于数据库操作进行了封装，封装之后数据操作更加方便，同时所有的语法都由C转换成了ObjC。

下面仍然以微博查看为例进行SQLite演示。当然实际开发中微博数据是从网络读取的，但是考虑到缓存问题，通常会选择将微博数据保存到本地，下面的Demo演示了将数据存放到本地数据库以及数据读取的过程。当然，实际开发中并不会在视图控制器中直接调用数据库操作方法，在这里通常会引入两个概念Model和Service。Model自不必多说，就是MVC中的模型。而Service指的是操作数据库的服务层，它封装了对于Model的基本操作方法，实现具体的业务逻辑。为了解耦，在控制器中是不会直接接触数据库的，控制器中只和模型（模型是领域的抽象）、服务对象有关系，借助服务层对模型进行各类操作，模型的操作反应到数据库中就是对表中数据的操作。具体关系如下：


{% img /images/CSR001.jpg Caption %} 

要完成上述功能，首先定义一个应用程序全局对象进行数据库、表的创建。为了避免每次都创建数据库和表出错，这里利用了偏好设置进行保存当前创建状态（其实这也是数据存储的一部分），如果创建过了数据库则不再创建，否则创建数据库和表。

KCDatabaseCreator.m
	
//
//  KCDatabaseCreator.m
//  DataAccess
//
//  Created by Kenshin Cui on 14-3-29.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import "KCDatabaseCreator.h"
#import "KCDbManager.h"
@implementation KCDatabaseCreator
+(void)initDatabase{
    NSString *key=@"IsCreatedDb";
    NSUserDefaults *defaults=[[NSUserDefaults alloc]init];
    if ([[defaults valueForKey:key] intValue]!=1) {
        [self createUserTable];
        [self createStatusTable];
        [defaults setValue:@1 forKey:key];
    }
}
+(void)createUserTable{
    NSString *sql=@"CREATE TABLE User (Id integer PRIMARY KEY AUTOINCREMENT,name text,screenName text, profileImageUrl text,mbtype text,city text)";
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
+(void)createStatusTable{
    NSString *sql=@"CREATE TABLE Status (Id integer PRIMARY KEY AUTOINCREMENT,source text,createdAt date,\"text\" text,user integer REFERENCES User (Id))";
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
@end

其次，定义数据模型，这里定义用户User和微博Status两个数据模型类。注意模型应该尽量保持其单纯性，仅仅是简单的POCO，不要引入视图、控制器等相关内容。

KCUser.h

	
//
//  KCUser.h
//  UrlConnection
//
//  Created by Kenshin Cui on 14-3-22.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface KCUser : NSObject
#pragma mark 编号
@property (nonatomic,strong) NSNumber *Id;
#pragma mark 用户名
@property (nonatomic,copy) NSString *name;
#pragma mark 用户昵称
@property (nonatomic,copy) NSString *screenName;
#pragma mark 头像
@property (nonatomic,copy) NSString *profileImageUrl;
#pragma mark 会员类型
@property (nonatomic,copy) NSString *mbtype;
#pragma mark 城市
@property (nonatomic,copy) NSString *city;
#pragma mark - 动态方法
/**
 *  初始化用户
 *
 *  @param name 用户名
 *  @param city 所在城市
 *
 *  @return 用户对象
 */
-(KCUser *)initWithName:(NSString *)name screenName:(NSString *)screenName profileImageUrl:(NSString *)profileImageUrl mbtype:(NSString *)mbtype city:(NSString *)city;
/**
 *  使用字典初始化用户对象
 *
 *  @param dic 用户数据
 *
 *  @return 用户对象
 */
-(KCUser *)initWithDictionary:(NSDictionary *)dic;
#pragma mark - 静态方法
+(KCUser *)userWithName:(NSString *)name screenName:(NSString *)screenName profileImageUrl:(NSString *)profileImageUrl mbtype:(NSString *)mbtype city:(NSString *)city;
@end

KCUser.m

	
//
//  KCUser.m
//  UrlConnection
//
//  Created by Kenshin Cui on 14-3-22.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import "KCUser.h"
@implementation KCUser
-(KCUser *)initWithName:(NSString *)name screenName:(NSString *)screenName profileImageUrl:(NSString *)profileImageUrl mbtype:(NSString *)mbtype city:(NSString *)city{
    if (self=[super init]) {
        self.name=name;
        self.screenName=screenName;
        self.profileImageUrl=profileImageUrl;
        self.mbtype=mbtype;
        self.city=city;
    }
    return self;
}
-(KCUser *)initWithDictionary:(NSDictionary *)dic{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
+(KCUser *)userWithName:(NSString *)name screenName:(NSString *)screenName profileImageUrl:(NSString *)profileImageUrl mbtype:(NSString *)mbtype city:(NSString *)city{
    KCUser *user=[[KCUser alloc]initWithName:name screenName:screenName profileImageUrl:profileImageUrl mbtype:mbtype city:city];
    return user;
}
@end

KCStatus.h

//
//  KCStatus.h
//  UITableView
//
//  Created by Kenshin Cui on 14-3-1.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "KCUser.h"
@interface KCStatus : NSObject
#pragma mark - 属性
@property (nonatomic,strong) NSNumber *Id;//微博id
@property (nonatomic,strong) KCUser *user;//发送用户
@property (nonatomic,copy) NSString *createdAt;//创建时间
@property (nonatomic,copy) NSString *source;//设备来源
@property (nonatomic,copy) NSString *text;//微博内容
#pragma mark - 动态方法
/**
 *  初始化微博数据
 *
 *  @param createAt        创建日期
 *  @param source          来源
 *  @param text            微博内容
 *  @param user            发送用户
 *
 *  @return 微博对象
 */
-(KCStatus *)initWithCreateAt:(NSString *)createAt source:(NSString *)source text:(NSString *)text user:(KCUser *)user;
/**
 *  初始化微博数据
 *
 *  @param profileImageUrl 用户头像
 *  @param mbtype          会员类型
 *  @param createAt        创建日期
 *  @param source          来源
 *  @param text            微博内容
 *  @param userId          用户编号
 *
 *  @return 微博对象
 */
-(KCStatus *)initWithCreateAt:(NSString *)createAt source:(NSString *)source text:(NSString *)text userId:(int)userId;
/**
 *  使用字典初始化微博对象
 *
 *  @param dic 字典数据
 *
 *  @return 微博对象
 */
-(KCStatus *)initWithDictionary:(NSDictionary *)dic;
#pragma mark - 静态方法
/**
 *  初始化微博数据
 *
 *  @param createAt        创建日期
 *  @param source          来源
 *  @param text            微博内容
 *  @param user            发送用户
 *
 *  @return 微博对象
 */
+(KCStatus *)statusWithCreateAt:(NSString *)createAt source:(NSString *)source text:(NSString *)text user:(KCUser *)user;
/**
 *  初始化微博数据
 *
 *  @param profileImageUrl 用户头像
 *  @param mbtype          会员类型
 *  @param createAt        创建日期
 *  @param source          来源
 *  @param text            微博内容
 *  @param userId          用户编号
 *
 *  @return 微博对象
 */
+(KCStatus *)statusWithCreateAt:(NSString *)createAt source:(NSString *)source text:(NSString *)text userId:(int)userId;
@end

KCStatus.m

//
//  KCStatus.m
//  UITableView
//
//  Created by Kenshin Cui on 14-3-1.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import "KCStatus.h"
@implementation KCStatus
-(KCStatus *)initWithDictionary:(NSDictionary *)dic{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dic];
        self.user=[[KCUser alloc]init];
        self.user.Id=dic[@"user"];
    }
    return self;
}
-(KCStatus *)initWithCreateAt:(NSString *)createAt source:(NSString *)source text:(NSString *)text user:(KCUser *)user{
    if (self=[super init]) {
        self.createdAt=createAt;
        self.source=source;
        self.text=text;
        self.user=user;
    }
    return self;
}
-(KCStatus *)initWithCreateAt:(NSString *)createAt source:(NSString *)source text:(NSString *)text userId:(int)userId{
    if (self=[super init]) {
        self.createdAt=createAt;
        self.source=source;
        self.text=text;
        KCUser *user=[[KCUser alloc]init];
        user.Id=[NSNumber numberWithInt:userId];
        self.user=user;
    }
    return self;
}
-(NSString *)source{
    return [NSString stringWithFormat:@"来自 %@",_source];
}
+(KCStatus *)statusWithCreateAt:(NSString *)createAt source:(NSString *)source text:(NSString *)text user:(KCUser *)user{
    KCStatus *status=[[KCStatus alloc]initWithCreateAt:createAt source:source text:text user:user];
    return status;
}
+(KCStatus *)statusWithCreateAt:(NSString *)createAt source:(NSString *)source text:(NSString *)text userId:(int)userId{
    KCStatus *status=[[KCStatus alloc]initWithCreateAt:createAt source:source text:text userId:userId];
    return status;
}
@end

然后，编写服务类，进行数据的增、删、改、查操作，由于服务类方法同样不需要过多的配置，因此定义为单例，保证程序中只有一个实例即可。服务类中调用前面封装的数据库方法将对数据库的操作转换为对模型的操作。

KCUserService.h

	
//
//  KCUserService.h
//  DataAccess
//
//  Created by Kenshin Cui on 14-3-29.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "KCUser.h"
#import "KCSingleton.h"
@interface KCUserService : NSObject
singleton_interface(KCUserService)
/**
 *  添加用户信息
 *
 *  @param user 用户对象
 */
-(void)addUser:(KCUser *)user;
/**
 *  删除用户
 *
 *  @param user 用户对象
 */
-(void)removeUser:(KCUser *)user;
/**
 *  根据用户名删除用户
 *
 *  @param name 用户名
 */
-(void)removeUserByName:(NSString *)name;
/**
 *  修改用户内容
 *
 *  @param user 用户对象
 */
-(void)modifyUser:(KCUser *)user;
/**
 *  根据用户编号取得用户
 *
 *  @param Id 用户编号
 *
 *  @return 用户对象
 */
-(KCUser *)getUserById:(int)Id;
/**
 *  根据用户名取得用户
 *
 *  @param name 用户名
 *
 *  @return 用户对象
 */
-(KCUser *)getUserByName:(NSString *)name;
@end

KCUserService.m

	
//
//  KCUserService.m
//  DataAccess
//
//  Created by Kenshin Cui on 14-3-29.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import "KCUserService.h"
#import "KCUser.h"
#import "KCDbManager.h"
@implementation KCUserService
singleton_implementation(KCUserService)
-(void)addUser:(KCUser *)user{
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO User (name,screenName, profileImageUrl,mbtype,city) VALUES('%@','%@','%@','%@','%@')",user.name,user.screenName, user.profileImageUrl,user.mbtype,user.city];
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
-(void)removeUser:(KCUser *)user{
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM User WHERE Id='%@'",user.Id];
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
-(void)removeUserByName:(NSString *)name{
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM User WHERE name='%@'",name];
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
-(void)modifyUser:(KCUser *)user{
    NSString *sql=[NSString stringWithFormat:@"UPDATE User SET name='%@',screenName='%@',profileImageUrl='%@',mbtype='%@',city='%@' WHERE Id='%@'",user.name,user.screenName,user.profileImageUrl,user.mbtype,user.city,user.Id];
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
-(KCUser *)getUserById:(int)Id{
    KCUser *user=[[KCUser alloc]init];
    NSString *sql=[NSString stringWithFormat:@"SELECT name,screenName,profileImageUrl,mbtype,city FROM User WHERE Id='%i'", Id];
    NSArray *rows= [[KCDbManager sharedKCDbManager] executeQuery:sql];
    if (rows&&rows.count>0) {
        [user setValuesForKeysWithDictionary:rows[0]];
    }
    return user;
}
-(KCUser *)getUserByName:(NSString *)name{
    KCUser *user=[[KCUser alloc]init];
    NSString *sql=[NSString stringWithFormat:@"SELECT Id, name,screenName,profileImageUrl,mbtype,city FROM User WHERE name='%@'", name];
    NSArray *rows= [[KCDbManager sharedKCDbManager] executeQuery:sql];
    if (rows&&rows.count>0) {
        [user setValuesForKeysWithDictionary:rows[0]];
    }
    return user;
}
@end

KCStatusService.h

//
//  KCStatusService.h
//  DataAccess
//
//  Created by Kenshin Cui on 14-3-29.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "KCSingleton.h"
@class KCStatus;
@interface KCStatusService : NSObject
singleton_interface(KCStatusService)
/**
 *  添加微博信息
 *
 *  @param status 微博对象
 */
-(void)addStatus:(KCStatus *)status;
/**
 *  删除微博
 *
 *  @param status 微博对象
 */
-(void)removeStatus:(KCStatus *)status;
/**
 *  修改微博内容
 *
 *  @param status 微博对象
 */
-(void)modifyStatus:(KCStatus *)status;
/**
 *  根据编号取得微博
 *
 *  @param Id 微博编号
 *
 *  @return 微博对象
 */
-(KCStatus *)getStatusById:(int)Id;
/**
 *  取得所有微博对象
 *
 *  @return 所有微博对象
 */
-(NSArray *)getAllStatus;
@end

KCStatusService.m

	
//
//  KCStatusService.m
//  DataAccess
//
//  Created by Kenshin Cui on 14-3-29.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import "KCStatusService.h"
#import "KCDbManager.h"
#import "KCStatus.h"
#import "KCUserService.h"
#import "KCSingleton.h"
@interface KCStatusService(){
     
}
@end
@implementation KCStatusService
singleton_implementation(KCStatusService)
-(void)addStatus:(KCStatus *)status{
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO Status (source,createdAt,\"text\" ,user) VALUES('%@','%@','%@','%@')",status.source,status.createdAt,status.text,status.user.Id];
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
-(void)removeStatus:(KCStatus *)status{
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM Status WHERE Id='%@'",status.Id];
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
-(void)modifyStatus:(KCStatus *)status{
    NSString *sql=[NSString stringWithFormat:@"UPDATE Status SET source='%@',createdAt='%@',\"text\"='%@' ,user='%@' WHERE Id='%@'",status.source,status.createdAt,status.text,status.user, status.Id];
    [[KCDbManager sharedKCDbManager] executeNonQuery:sql];
}
-(KCStatus *)getStatusById:(int)Id{
    KCStatus *status=[[KCStatus alloc]init];
    NSString *sql=[NSString stringWithFormat:@"SELECT Id, source,createdAt,\"text\" ,user FROM Status WHERE Id='%i'", Id];
    NSArray *rows= [[KCDbManager sharedKCDbManager] executeQuery:sql];
    if (rows&&rows.count>0) {
        [status setValuesForKeysWithDictionary:rows[0]];
        status.user=[[KCUserService sharedKCUserService] getUserById:[(NSNumber *)rows[0][@"user"] intValue]] ;
    }
    return status;
}
-(NSArray *)getAllStatus{
    NSMutableArray *array=[NSMutableArray array];
    NSString *sql=@"SELECT Id, source,createdAt,\"text\" ,user FROM Status ORDER BY Id";
    NSArray *rows= [[KCDbManager sharedKCDbManager] executeQuery:sql];
    for (NSDictionary *dic in rows) {
        KCStatus *status=[self getStatusById:[(NSNumber *)dic[@"Id"] intValue]];
        [array addObject:status];
    }
    return array;
}
@end

最后，在视图控制器中调用相应的服务层进行各类数据操作，在下面的代码中分别演示了增、删、改、查四类操作。

KCMainViewController.m
//
//  KCMainTableViewController.m
//  DataAccess
//
//  Created by Kenshin Cui on 14-3-29.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
#import "KCMainTableViewController.h"
#import "KCDbManager.h"
#import "KCDatabaseCreator.h"
#import "KCUser.h"
#import "KCStatus.h"
#import "KCUserService.h"
#import "KCStatusService.h"
#import "KCStatusTableViewCell.h"
@interface KCMainTableViewController (){
    NSArray *_status;
    NSMutableArray *_statusCells;
}
@end
@implementation KCMainTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [KCDatabaseCreator initDatabase];
     
//    [self addUsers];
//    [self removeUser];
//    [self modifyUserInfo];
     
//    [self addStatus];
     
    [self loadStatusData];
     
}
-(void)addUsers{
    KCUser *user1=[KCUser userWithName:@"Binger" screenName:@"冰儿" profileImageUrl:@"binger.jpg" mbtype:@"mbtype.png" city:@"北京"];
    [[KCUserService sharedKCUserService] addUser:user1];
    KCUser *user2=[KCUser userWithName:@"Xiaona" screenName:@"小娜" profileImageUrl:@"xiaona.jpg" mbtype:@"mbtype.png" city:@"北京"];
    [[KCUserService sharedKCUserService] addUser:user2];
    KCUser *user3=[KCUser userWithName:@"Lily" screenName:@"丽丽" profileImageUrl:@"lily.jpg" mbtype:@"mbtype.png" city:@"北京"];
    [[KCUserService sharedKCUserService] addUser:user3];
    KCUser *user4=[KCUser userWithName:@"Qianmo" screenName:@"阡陌" profileImageUrl:@"qianmo.jpg" mbtype:@"mbtype.png" city:@"北京"];
    [[KCUserService sharedKCUserService] addUser:user4];
    KCUser *user5=[KCUser userWithName:@"Yanyue" screenName:@"炎月" profileImageUrl:@"yanyue.jpg" mbtype:@"mbtype.png" city:@"北京"];
    [[KCUserService sharedKCUserService] addUser:user5];
}
-(void)addStatus{
    KCStatus *status1=[KCStatus statusWithCreateAt:@"9:00" source:@"iPhone 6" text:@"一只雪猴在日本边泡温泉边玩iPhone的照片，获得了\"2014年野生动物摄影师\"大赛特等奖。一起来为猴子配个词" userId:1];
    [[KCStatusService sharedKCStatusService] addStatus:status1];
    KCStatus *status2=[KCStatus statusWithCreateAt:@"9:00" source:@"iPhone 6" text:@"一只雪猴在日本边泡温泉边玩iPhone的照片，获得了\"2014年野生动物摄影师\"大赛特等奖。一起来为猴子配个词" userId:1];
    [[KCStatusService sharedKCStatusService] addStatus:status2];
    KCStatus *status3=[KCStatus statusWithCreateAt:@"9:30" source:@"iPhone 6" text:@"【我们送iPhone6了 要求很简单】真心回馈粉丝，小编觉得现在最好的奖品就是iPhone6了。今起到12月31日，关注我们，转发微博，就有机会获iPhone6(奖品可能需要等待)！每月抽一台[鼓掌]。不费事，还是试试吧，万一中了呢" userId:2];
    [[KCStatusService sharedKCStatusService] addStatus:status3];
    KCStatus *status4=[KCStatus statusWithCreateAt:@"9:45" source:@"iPhone 6" text:@"重大新闻：蒂姆库克宣布出柜后，ISIS战士怒扔iPhone，沙特神职人员呼吁人们换回iPhone 4。[via Pan-Arabia Enquirer]" userId:3];
    [[KCStatusService sharedKCStatusService] addStatus:status4];
    KCStatus *status5=[KCStatus statusWithCreateAt:@"10:05" source:@"iPhone 6" text:@"小伙伴们，有谁知道怎么往Iphone4S里倒东西？倒入的东西又该在哪里找？用了Iphone这么长时间，还真的不知道怎么弄！有谁知道啊？谢谢！" userId:4];
    [[KCStatusService sharedKCStatusService] addStatus:status5];
    KCStatus *status6=[KCStatus statusWithCreateAt:@"10:07" source:@"iPhone 6" text:@"在音悦台iPhone客户端里发现一个悦单《Infinite 金明洙》，推荐给大家! " userId:1];
    [[KCStatusService sharedKCStatusService] addStatus:status6];
    KCStatus *status7=[KCStatus statusWithCreateAt:@"11:20" source:@"iPhone 6" text:@"如果sony吧mp3播放器产品发展下去，不贪图手头节目源的现实利益，就木有苹果的ipod，也就木有iphone。柯达类似的现实利益，不自我革命的案例也是一种巨头的宿命。" userId:2];
    [[KCStatusService sharedKCStatusService] addStatus:status7];
    KCStatus *status8=[KCStatus statusWithCreateAt:@"13:00" source:@"iPhone 6" text:@"【iPhone 7 Plus】新买的iPhone 7 Plus ，如何？够酷炫么？" userId:2];
    [[KCStatusService sharedKCStatusService] addStatus:status8];
    KCStatus *status9=[KCStatus statusWithCreateAt:@"13:24" source:@"iPhone 6" text:@"自拍神器#卡西欧TR500#，tr350S～价格美丽，行货，全国联保～iPhone6 iPhone6Plus卡西欧TR150 TR200 TR350 TR350S全面到货 招收各种代理！[给力]微信：39017366" userId:3];
    [[KCStatusService sharedKCStatusService] addStatus:status9];
    KCStatus *status10=[KCStatus statusWithCreateAt:@"13:26" source:@"iPhone 6" text:@"猜到猴哥玩手机时所思所想者，再奖iPhone一部。（奖品由“2014年野生动物摄影师”评委会颁发）" userId:3];
    [[KCStatusService sharedKCStatusService] addStatus:status10];
}
-(void)removeUser{
    //注意在SQLite中区分大小写
    [[KCUserService sharedKCUserService] removeUserByName:@"Yanyue"];
}
-(void)modifyUserInfo{
    KCUser *user1= [[KCUserService sharedKCUserService]getUserByName:@"Xiaona"];
    user1.city=@"上海";
    [[KCUserService sharedKCUserService] modifyUser:user1];
     
    KCUser *user2= [[KCUserService sharedKCUserService]getUserByName:@"Lily"];
    user2.city=@"深圳";
    [[KCUserService sharedKCUserService] modifyUser:user2];
}
#pragma mark 加载数据
-(void)loadStatusData{
    _statusCells=[[NSMutableArray alloc]init];
    _status=[[KCStatusService sharedKCStatusService]getAllStatus];
    [_status enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KCStatusTableViewCell *cell=[[KCStatusTableViewCell alloc]init];
        cell.status=(KCStatus *)obj;
        [_statusCells addObject:cell];
    }];
    NSLog(@"%@",[_status lastObject]);
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _status.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identtityKey=@"myTableViewCellIdentityKey1";
    KCStatusTableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:identtityKey];
    if(cell==nil){
        cell=[[KCStatusTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identtityKey];
    }
    cell.status=_status[indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((KCStatusTableViewCell *)_statusCells[indexPath.row]).height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0f;
}
@end

项目目录结构：

{% img /images/CSR002.jpg Caption %} 

运行效果

{% img /images/CSR003.jpg Caption %} 
Core Data

基本概念

当前，各类应用开发中只要牵扯到数据库操作通常都会用到一个概念“对象关系映射（ORM）”。例如在Java平台使用Hibernate，在.NET平台使用Entity Framework、Linq、NHibernate等。在iOS中也不例外，iOS中ORM框架首选Core Data，这是官方推荐的，不需要借助第三方框架。无论是哪种平台、哪种技术，ORM框架的作用都是相同的，那就是将关系数据库中的表（准确的说是实体）转换为程序中的对象，其本质还是对数据库的操作（例如Core Data中如果存储类型配置为SQLite则本质还是操作的SQLite数据库）。细心的朋友应该已经注意到，在上面的SQLite中其实我们在KCMainViewController中进行的数据库操作已经转换为了对象操作，服务层中的方法中已经将对数据库的操作封装起来，转换为了对Model的操作，这种方式已经是面向对象的。上述通过将对象映射到实体的过程完全是手动完成的，相对来说操作比较复杂，就拿对KCStatus对象的操作来说：首先要手动创建数据库（Status表），其次手动创建模型KCStatus，接着创建服务层KCStatusService。Core Data正是为了解决这个问题而产生的，它将数据库的创建、表的创建、对象和表的转换等操作封装起来，简化了我们的操作（注意Core Data只是将对象关系的映射简化了，并不是把服务层替代了，这一点大家需要明白）。

使用Core Data进行数据库存取并不需要手动创建数据库，这个过程完全由Core Data框架完成，开发人员面对的是模型，主要的工作就是把模型创建起来，具体数据库如何创建则不用管。在iOS项目中添加“Data Model”文件。然后在其中创建实体和关系：

{% img /images/CSR004.jpg Caption %} 
{% img /images/CSR005.jpg Caption %} 

模型创建的过程中需要注意：

1.实体对象不需要创建ID主键，Attributes中应该是有意义属性（创建过程中应该考虑对象的属性而不是数据库中表有几个字段，尽管多数属性会对应表的字段）。

2.所有的属性应该指定具体类型（尽管在SQLite中可以不指定），因为实体对象会对应生成ObjC模型类。

3.实体对象中其他实体对象类型的属性应该通过Relationships建立，并且注意实体之间的对应关系（例如一个用户有多条微博，而一条微博则只属于一个用户,用户和微博形成一对多的关系）。

以上模型创建后，接下来就是根据上面的模型文件（.xcdatamodeld文件）生成具体的实体类。在Xcode中添加“NSManagedObject Subclass”文件，按照步骤选择创建的模型及实体，Xcode就会根据所创建模型生成具体的实体类。

User.h

	
//
//  User.h
//  CoreData
//
//  Created by Kenshin Cui on 14/03/27.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class Status;
@interface User : NSManagedObject
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * mbtype;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileImageUrl;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSSet *statuses;
@end
@interface User (CoreDataGeneratedAccessors)
- (void)addStatusesObject:(Status *)value;
- (void)removeStatusesObject:(Status *)value;
- (void)addStatuses:(NSSet *)values;
- (void)removeStatuses:(NSSet *)values;
@end

User.m

	
//
//  User.m
//  CoreData
//
//  Created by Kenshin Cui on 14/03/27.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//
#import "User.h"
#import "Status.h"
@implementation User
@dynamic city;
@dynamic mbtype;
@dynamic name;
@dynamic profileImageUrl;
@dynamic screenName;
@dynamic statuses;
@end

Status.h
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
	
//
//  Status.h
//  CoreData
//
//  Created by Kenshin Cui on 14/03/27.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface Status : NSManagedObject
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSManagedObject *user;
@end

Status.m

	
//
//  Status.m
//  CoreData
//
//  Created by Kenshin Cui on 14/03/27.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//
#import "Status.h"
@implementation Status
@dynamic createdAt;
@dynamic source;
@dynamic text;
@dynamic user;
@end

很显然，通过模型生成类的过程相当简单，通常这些类也不需要手动维护，如果模型发生的变化只要重新生成即可。有几点需要注意：

1.所有的实体类型都继承于NSManagedObject，每个NSManagedObject对象对应着数据库中一条记录。

2.集合属性（例如User中的status）生成了访问此属性的分类方法。

3.使用@dynamic代表具体属性实现，具体实现细节不需要开发人员关心。

当然，了解了这些还不足以完成数据的操作。究竟Core Data具体的设计如何，要完成数据的存取我们还需要了解一下Core Data几个核心的类。

{% img /images/CSR006.jpg Caption %} 

1.Persistent Object Store：可以理解为存储持久对象的数据库（例如SQLite，注意Core Data也支持其他类型的数据存储，例如xml、二进制数据等）。

2.Managed Object Model：对象模型，对应Xcode中创建的模型文件。

3.Persistent Store Coordinator：对象模型和实体类之间的转换协调器，用于管理不同存储对象的上下文。

4.Managed Object Context:对象管理上下文，负责实体对象和数据库之间的交互。

Core Data使用

Core Data使用起来相对直接使用SQLite3的API而言更加的面向对象，操作过程通常分为以下几个步骤：

1.创建管理上下文

创建管理上下可以细分为：加载模型文件->指定数据存储路径->创建对应数据类型的存储->创建管理对象上下方并指定存储。

经过这几个步骤之后可以得到管理对象上下文NSManagedObjectContext，以后所有的数据操作都由此对象负责。同时如果是第一次创建上下文，Core Data会自动创建存储文件（例如这里使用SQLite3存储），并且根据模型对象创建对应的表结构。下图为第一次运行生成的数据库及相关映射文件：

{% img /images/CSR007.jpg Caption %} 

为了方便后面使用，NSManagedObjectContext对象可以作为单例或静态属性来保存，下面是创建的管理对象上下文的主要代码：

	
-(NSManagedObjectContext *)createDbContext{
    NSManagedObjectContext *context;
    //打开模型文件，参数为nil则打开包中所有模型文件并合并成一个
    NSManagedObjectModel *model=[NSManagedObjectModel mergedModelFromBundles:nil];
    //创建解析器
    NSPersistentStoreCoordinator *storeCoordinator=[[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    //创建数据库保存路径
    NSString *dir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@",dir);
    NSString *path=[dir stringByAppendingPathComponent:@"myDatabase.db"];
    NSURL *url=[NSURL fileURLWithPath:path];
    //添加SQLite持久存储到解析器
    NSError *error;
    [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
    if(error){
        NSLog(@"数据库打开失败！错误:%@",error.localizedDescription);
    }else{
        context=[[NSManagedObjectContext alloc]init];
        context.persistentStoreCoordinator=storeCoordinator;
        NSLog(@"数据库打开成功！");
    }
    return context;
}

2.查询数据

对于有条件的查询，在Core Data中是通过谓词来实现的。首先创建一个请求，然后设置请求条件，最后调用上下文执行请求的方法。

	
-(void)addUserWithName:(NSString *)name screenName:(NSString *)screenName profileImageUrl:(NSString *)profileImageUrl mbtype:(NSString *)mbtype city:(NSString *)city{
    //添加一个对象
    User *us= [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.context];
    us.name=name;
    us.screenName=screenName;
    us.profileImageUrl=profileImageUrl;
    us.mbtype=mbtype;
    us.city=city;
    NSError *error;
    //保存上下文
    if (![self.context save:&error]) {
        NSLog(@"添加过程中发生错误,错误信息：%@！",error.localizedDescription);
    }
}

如果有多个条件，只要使用谓词组合即可，那么对于关联对象条件怎么查询呢？这里分为两种情况进行介绍：

a.查找一个对象只有唯一一个关联对象的情况，例如查找用户名为“Binger”的微博（一个微博只能属于一个用户），通过keypath查询

	
-(NSArray *)getStatusesByUserName:(NSString *)name{
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Status"];
    request.predicate=[NSPredicate predicateWithFormat:@"user.name=%@",name];
    NSArray *array=[self.context executeFetchRequest:request error:nil];
    return  array;
}

此时如果跟踪Core Data生成的SQL语句会发现其实就是把Status表和User表进行了关联查询（JOIN连接）。

b.查找一个对象有多个关联对象的情况，例如查找发送微博内容中包含“Watch”并且用户昵称为“小娜”的用户（一个用户有多条微博），此时可以充分利用谓词进行过滤。

	
-(NSArray *)getUsersByStatusText:(NSString *)text screenName:(NSString *)screenName{
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Status"];
    request.predicate=[NSPredicate predicateWithFormat:@"text LIKE '*Watch*'",text];
    NSArray *statuses=[self.context executeFetchRequest:request error:nil];
     
    NSPredicate *userPredicate= [NSPredicate predicateWithFormat:@"user.screenName=%@",screenName];
    NSArray *users= [statuses filteredArrayUsingPredicate:userPredicate];
    return users;
}

注意：如果单纯查找微博中包含“Watch”的用户，直接查出对应的微博，然后通过每个微博的user属性即可获得用户，此时就不用使用额外的谓词过滤条件。

3.插入数据

插入数据需要调用实体描述对象NSEntityDescription返回一个实体对象，然后设置对象属性，最后保存当前上下文即可。这里需要注意，增、删、改操作完最后必须调用管理对象上下文的保存方法，否则操作不会执行。

	
-(void)addUserWithName:(NSString *)name screenName:(NSString *)screenName profileImageUrl:(NSString *)profileImageUrl mbtype:(NSString *)mbtype city:(NSString *)city{
    //添加一个对象
    User *us= [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.context];
    us.name=name;
    us.screenName=screenName;
    us.profileImageUrl=profileImageUrl;
    us.mbtype=mbtype;
    us.city=city;
    NSError *error;
    //保存上下文
    if (![self.context save:&error]) {
        NSLog(@"添加过程中发生错误,错误信息：%@！",error.localizedDescription);
    }
}

4.删除数据

删除数据可以直接调用管理对象上下文的deleteObject方法，删除完保存上下文即可。注意，删除数据前必须先查询到对应对象。

	
-(void)removeUser:(User *)user{
    [self.context deleteObject:user];
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"删除过程中发生错误，错误信息：%@!",error.localizedDescription);
    }
}

5.修改数据

修改数据首先也是取出对应的实体对象，然后通过修改对象的属性，最后保存上下文。

	
-(void)modifyUserWithName:(NSString *)name screenName:(NSString *)screenName profileImageUrl:(NSString *)profileImageUrl mbtype:(NSString *)mbtype city:(NSString *)city{
    User *us=[self getUserByName:name];
    us.screenName=screenName;
    us.profileImageUrl=profileImageUrl;
    us.mbtype=mbtype;
    us.city=city;
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"修改过程中发生错误,错误信息：%@",error.localizedDescription);
    }
}

调试

虽然Core Data（如果使用SQLite数据库）操作最终转换为SQL操作，但是调试起来却不想操作SQL那么方便。特别是对于初学者而言经常出现查询报错的问题，如果能看到最终生成的SQL语句自然对于调试很有帮助。事实上在Xcode中是支持Core Data调试的，具体操作：Product-Scheme-Edit Scheme-Run-Arguments中依次添加两个参数（注意参数顺序不能错）：-com.apple.CoreData.SQLDebug、1。然后在运行程序过程中如果操作了数据库就会将SQL语句打印在输出面板。

{% img /images/CSR008.jpg Caption %} 

注意：如果模型发生了变化，此时可以重新生成实体类文件，但是所生成的数据库并不会自动更新，这时需要考虑重新生成数据库并迁移原有的数据。

FMDB

基本使用

相比于SQLite3来说Core Data存在着诸多优势，它面向对象，开发人员不必过多的关心更多数据库操作知识，同时它基于ObjC操作，书写更加优雅等。但是它本身也存在着一定的限制，例如如果考虑到跨平台，则只能选择SQLite，因为无论是iOS还是Android都可以使用同一个数据库，降低了开发成本和维护成本。其次是当前多数ORM框架都存在的性能问题，因为ORM最终转化为SQL操作，其中牵扯到模型数据转化，其性能自然比不上直接使用SQL操作数据库。那么有没有更好的选择呢？答案就是对SQLite进行封装。

其实通过前面对于SQLite的分析，大家应该已经看到KCDbManager就是对于SQLite封装的结果，开发人员面对的只有SQL和ObjC方法，不用过多libsqlite3的C语言API。但它毕竟只是一个简单的封装，还有更多的细节没有考虑，例如如何处理并发安全性，如何更好的处理事务等。因此，这里推荐使用第三方框架FMDB，整个框架非常轻量级但又不失灵活性，也是很多企业开发的首选。

1.FMDB既然是对于libsqlite3框架的封装，自然使用起来也是类似的，使用前也要打开一个数据库，这个数据库文件存在则直接打开否则会创建并打开。这里FMDB引入了一个MFDatabase对象来表示数据库，打开数据库和后面的数据库操作全部依赖此对象。下面是打开数据库获得MFDatabase对象的代码：

	
-(void)openDb:(NSString *)dbname{
    //取得数据库保存路径，通常保存沙盒Documents目录
    NSString *directory=[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@",directory);
    NSString *filePath=[directory stringByAppendingPathComponent:dbname];
    //创建FMDatabase对象
    self.database=[FMDatabase databaseWithPath:filePath];
    //打开数据上
    if ([self.database open]) {
        NSLog(@"数据库打开成功!");
    }else{
        NSLog(@"数据库打开失败!");
    }
}

注意：dataWithPath中的路径参数一般会选择保存到沙箱中的Documents目录中；如果这个参数设置为nil则数据库会在内存中创建；如果设置为@””则会在沙箱中的临时目录创建,应用程序关闭则文件删除。

2.对于数据库的操作跟前面KCDbManager的封装是类似的，在FMDB中FMDatabase类提供了两个方法executeUpdate:和executeQuery:分别用于执行无返回结果的查询和有返回结果的查询。当然这两个方法有很多的重载这里就不详细解释了。唯一需要指出的是，如果调用有格式化参数的sql语句时，格式化符号使用“?”而不是“%@”、等。下面是两种情况的代码片段：

a.无返回结果

	
-(void)executeNonQuery:(NSString *)sql{
    //执行更新sql语句，用于插入、修改、删除
    if (![self.database executeUpdate:sql]) {
        NSLog(@"执行SQL语句过程中发生错误！");
    }
}

b.有返回结果

	
-(NSArray *)executeQuery:(NSString *)sql{
    NSMutableArray *array=[NSMutableArray array];
    //执行查询sql语句
    FMResultSet *result= [self.database executeQuery:sql];
    while (result.next) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        for (int i=0; i<result.columnCount; ++i) {
            dic[[result columnNameForIndex:i]]=[result stringForColumnIndex:i];
        }
        [array addObject:dic];
    }
    return array;
}

对于有返回结果的查询而言，查询完返回一个游标FMResultSet，通过遍历游标进行查询。而且FMDB中提供了大量intForColumn、stringForColumn等方法进行取值。

并发和事务

我们知道直接使用libsqlite3进行数据库操作其实是线程不安全的，如果遇到多个线程同时操作一个表的时候可能会发生意想不到的结果。为了解决这个问题建议在多线程中使用FMDatabaseQueue对象，相比FMDatabase而言，它是线程安全的。

创建FMDatabaseQueue的方法是类似的，调用databaseQueueWithPath:方法即可。注意这里不需要调用打开操作。

	
-(void)openDb:(NSString *)dbname{
    //取得数据库保存路径，通常保存沙盒Documents目录
    NSString *directory=[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@",directory);
    NSString *filePath=[directory stringByAppendingPathComponent:dbname];
    //创建FMDatabaseQueue对象
    self.database=[FMDatabaseQueue databaseQueueWithPath:filePath];
}

然后所有的增删改查操作调用FMDatabaseQueue的inDatabase:方法在block中执行操作sql语句即可。

	
-(void)executeNonQuery:(NSString *)sql{
    //执行更新sql语句，用于插入、修改、删除
    [self.database inDatabase:^(FMDatabase *db) {
        [db executeQuery:sql];
    }];
}
-(NSArray *)executeQuery:(NSString *)sql{
    NSMutableArray *array=[NSMutableArray array];
    [self.database inDatabase:^(FMDatabase *db) {
        //执行查询sql语句
        FMResultSet *result= [db executeQuery:sql];
        while (result.next) {
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            for (int i=0; i<result.columnCount; ++i) {
                dic[[result columnNameForIndex:i]]=[result stringForColumnIndex:i];
            }
            [array addObject:dic];
        }
    }];
    return array;
}

之所以将事务放到FMDB中去说并不是因为只有FMDB才支持事务，而是因为FMDB将其封装成了几个方法来调用，不用自己写对应的sql而已。其实在在使用libsqlite3操作数据库时也是原生支持事务的（因为这里的事务是基于数据库的，FMDB还是使用的SQLite数据库），只要在执行sql语句前加上“begin transaction;”执行完之后执行“commit transaction;”或者“rollback transaction;”进行提交或回滚即可。另外在Core Data中大家也可以发现，所有的增、删、改操作之后必须调用上下文的保存方法，其实本身就提供了事务的支持，只要不调用保存方法，之前所有的操作是不会提交的。在FMDB中FMDatabase有beginTransaction、commit、rollback三个方法进行开启事务、提交事务和回滚事务。




总结：

core data
 
core data 基于model-view-controller（mvc）模式下，为创建分解的cocoa应用程序提供了一个灵活和强大的数据模型框架。
 
core data可以使你以图形界面的方式快速的定义app的数据模型，同时在你的代码中容易获取到它。core data提供了基础结构去处理常用的功能，例如保存，恢复，撤销和重做，允许你在app中继续创建新的任务。在使用core data的时候，你不用安装额外的数据库系统，因为core data使用内置的sqlite数据库。
 
core data提供了一个通用的数据管理解决方案来处理那些所有需要数据模型的app(或大或小)。app使用core data来管理数据对象是很多的益处。
 
苹果的图形用户界面编译器-interface builder（IB），提供了对core data controller对象的预构建，从而来减少app的用户界面和它的数据模型之间的粘滞代码。在使用core data的时候你不需要考虑sql的语法问题，也不需要管理相关的逻辑树去追踪用户的行为，更不用建立新的永久机制。当你写你app的用户界面到它的 core data模型的时候，它已经为你把所有的东西都做好了。
 
core data将你app的模型层放入到一组定义在内存中的数据对象。core data会追踪这些对象的改变，同时可以根据需要做相反的改变，例如用户执行撤销命令。当core data在对你app数据的改变进行保存的时候，core data会把这些数据归档，并永久性保存。它保存的数据在一些常规的文件，你可以在Finder中可以进行管理，用spotlight进行搜索，备份到 cd，和email给朋友或者家人。
 
在使用core data框架的时候，你可以创建一个管理对象的模型，该模型提供了对模型对象的抽象定义，这也就是我们所知道的entities，它可以在我们的程序中使用。
 
core data是一个实体-关系模型，该模型是使用Xcode的数据模型设计工具来定义的，对数据实体以及他们的关系提供了丰富的环境。
 
 
sqlite
 
mac os x中sqlite库，它是一个轻量级功能强大的关系数据引擎，也很容易嵌入到应用程序。可以在多个平台使用，sqlite是一个轻量级的嵌入式sql数据库编程。与core data框架不同的是，sqlite是使用程序式的，sql的主要的API来直接操作数据表。
 
fmdb
FMDB框架其实只是一层很薄的封装，主要的类也就两个：FMDatabase和FMResultSet。在使用fmdb的时候还需要导入libsqlite3.0.dylib。
 
core data允许用户使用代表实体和实体间关系的高层对象来操作数据。它也可以管理串行化的数据，提供对象生存期管理与object_graph 管理，包括存储。Core Data直接与Sqlite交互，避免开发者使用原本的SQL语句.
 
上面的三种，都是在什么情况下使用呢？
在编写程序的时候尽量使用core data，这样才是最优的选择。
至于sqlite和fmdb的使用情况，这个看个人喜好了，个人觉得没什么标准。fmdb就是对sqlite的封装，使用起来有方便的接口，没那么麻烦而已。