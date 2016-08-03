---

layout: post
title: "FMDB封装篇"
date: 2016-07-02 22:59:42 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---


前言：

在自己开发中，每次用到数据库都会纠结是使用CoreData还是FMDB。CoreData虽然Api简单，但是调用栈非常复杂，要初始化一个Context需要至少20行代码。。。

显然，对于这种这么恶心的情况，我们的大Github必须有人会跳出来解决这种问题。于是就出现了MagicRecord这个对CoreData的封装库。一开始遇到这个库的时候，好用到几乎让我想把所有项目的数据库都换成CoreData了。两句话解决CoreData调用栈的初始化，一句话完成数据库版本升级和自动数据合并更新（虽然我们很少用到）。

然而这并不能解决一个根本性的问题，CoreData中的每个Object都要和一个context进行绑定，导致我们很多业务需求需要创建自己的私有context，然后再需要更新的时候保存到主context中。这又导致了我们在controller中或者在自己的业务类中维护多一个私有context属性。

所以，最后还是选择了FMDB进行封装。

之前自己搞过Java后台，将FMDB进行Hibernate式的封装，使用runtime解析，不用继承任何基类（swift中要继承NSObject），只要实现一个持久化协议并实现方法即可，屏蔽基本的数据库和表操作。

项目简介：

JRDB：一个对FMDB进行类Hibernate封装的iOS库，支持Objective-C 和 Swift。

Description

    使用分类的模式，模仿Hibernate，对FMDB进行简易封装

    支持pod 安装 『pod 'JRDB'』，Podfile需要添加 use_framework!

    使用协议，不用继承基类，对任意NSObject可以进行入库操作

    支持swift 和 Objective-C

    支持数据类型：基本数据类型（int，double，等），String，NSData，NSNumber，NSDate

注：Swift的基本数据类型，不支持Option类型，既不支持Int？Int！等，对象类型支持Option类型

Installation（安装）

	
use_frameworks!
pod 'JRDB'
@import JRDB;

Usage

Save（保存）

    Objective-C


	
Person *p = [[Person alloc] init];
p.a_int = 1;
p.b_unsigned_int = 2;
p.c_long = 3;
p.d_long_long = 4;
p.e_unsigned_long = 5;
p.f_unsigned_long_long = 6;
p.g_float = 7.0;
p.h_double = 8.0;
p.i_string = @"9";
p.j_number = @10;
p.k_data = [NSData data];
p.l_date = [NSDate date];
[p jr_save];

    Swift

Swift中需要入库的类需要继承NSObject（使用到runtime）

The Object that you want to persistent should inherit from NSObject

let p = Person()
p.name = "name"
p.age = 10
p.birthday = NSDate()
p.jr_save()

Update（更新）

Person *p = [Person jr_findAll].firstObject;
p.name = @"abc";
[p jr_update columns:nil];

column: 需要更新的字段名，传入空为全量更新

Delete（删除）
1
2
	
Person *p = [Person jr_findAll].firstObject;
[p jr_delete];

Select（查找）

    常规查找

	
Person *p = [Person jr_findByPrimaryKey:@"111"];
NSArray *list = [Person jr_findAll];
NSArray *list1 = [Person jr_findAllOrderBy:@"_age" isDesc:YES];

    条件查询

	
NSArray *condis = @[
     [JRQueryCondition condition:@"_l_date < ?" args:@[[NSDate date]] type:JRQueryConditionTypeAnd],
     [JRQueryCondition condition:@"_a_int > ?" args:@[@9] type:JRQueryConditionTypeAnd],];
NSArray *arr = [Person jr_findByConditions:condis
                      groupBy:@"_room"
                      orderBy:@"_age"
                      limit:@" limit 0,13 "
                      isDesc:YES];

    SQL

1
2
	
NSString *sql = @"select * from Person where age = ?";
NSArray *list = [Person jr_executeSql:sql args:@[@10]];

Other（其他）

协议：JRPersistent

	
@protocol JRPersistent @required
- (void)setID:(NSString * _Nullable)ID;
- (NSString * _Nullable)ID;
@optional
/**
 *  返回不用入库的对象字段数组
 *  The full property names that you want to ignore for persistent
 *  @return array
 */
+ (NSArray * _Nullable)jr_excludePropertyNames;
/**
 *  返回自定义主键字段
 *  @return 字段全名
 */
+ (NSString * _Nullable)jr_customPrimarykey;
/**
 *  返回自定义主键值
 *  @return 主键值
 */
- (id _Nullable)jr_customPrimarykeyValue;
@end

主键

默认每个Object的主键为ID， UUID字符串。

可以实现 jr_customPrimarykey 以及 jr_customPrimarykeyValue 方法，自定义主键。

默认NSObject分类实现

	
@interface NSObject (JRDB) (...methods)
@end
JRDBMgr
@interface JRDBMgr : NSObject
@property (nonatomic, strong) FMDatabase *defaultDB;
+ (instancetype)shareInstance;
+ (FMDatabase *)defaultDB;
- (FMDatabase *)createDBWithPath:(NSString *)path;
- (void)deleteDBWithPath:(NSString *)path;
/**
 *  在这里注册的类，使用本框架的数据库将全部建有这些表
 *  @param clazz 类名
 */
- (void)registerClazzForUpdateTable:(Class)clazz;
- (NSArray *)registedClazz;
/**
 * 更新默认数据库的表（或者新建没有的表）
 * 更新的表需要在本类先注册
 */
- (void)updateDefaultDB;
- (void)updateDB:(FMDatabase *)db;
@end

JRDBMgr持有一个默认数据库（~/Documents/jrdb/jrdb.sqlite），任何不指定数据库的操作，都在此数据库进行操作。默认数据库可以自行设置。

Method
1
	
- (void)registerClazzForUpdateTable:(Class)clazz;

在JRDBMgr中注册的类，可以使用
1
	
-(void)updateDB:(FMDatabase *)db

进行统一更新或者创建表。

Table Operation（表操作）

Create（建表）

	
// FMDatabase+JRDB 方法
[[JRDBMgr defaultDB] createTable4Clazz:[Person class]];
[Person jr_createTable];
// 删除原有的表，重新创建
[[JRDBMgr defaultDB] truncateTable4Clazz:[Person class]];
[Person jr_truncateTable];
//保存时，若发现没有表，将自动创建
[person jr_save];
Update 【更新表】
[[JRDBMgr defaultDB] updateTable4Clazz:[Person class]];
[Person jr_updateTable];

更新表时，只会添加不存在的字段，不会修改字段属性，不会删除字段，若有需要，需要自行写sql语句进行修改

Drop（删表）

	
[[JRDBMgr defaultDB] dropTable4Clazz:[Person class]];
[Person jr_dropTable];

Thread Operation（线程操作）

多线程操作使用FMDB自带的 FMDatabaseQueue

	
[person jr_saveWithComplete:^(BOOL success) {
    NSLog(@"%d", success);
}];

任何带complete block的操作，都将放入到FMDatabaseQueue进行顺序执行

注：所有需要立刻返回结果，或者影响其他操作的数据库操作，都建议放在主线程进行更新，大批量更新以及多线程操作数据库时，请使用带complete block的操作。

MoreUsage

    查看FMDatabase+JRDB.h

项目地址：https://github.com/scubers/JRDB（觉得可以的话就麻烦星一下呗~~~）

第一次写这种东西，可能已经Github上已经有了很多类似的东西，如果有不足之处还请指教。