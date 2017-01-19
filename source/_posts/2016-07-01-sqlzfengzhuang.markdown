---

layout: post
title: "SQLite封装篇"
date: 2016-07-01 12:59:42 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---



最近写的项目中有用到数据库,写了不少蛋疼的sql语句,每次都是好几行代码,而且每次都是重复的没有一点技术含量的代码,虽然也有不少基于sqlite的封装,不过用起来还是感觉不够面向对象! 为了不再写重复的代码,花了几天时间,基于SQLite3简单封装了下,实现了一行代码解决增删改查等常用的功能!并没有太过高深的知识,主要用了runtime和KVC:



<!--more-->



首先我们创建个大家都熟悉的Person类,并声明两个属性,下面将以类此展开分析

	@interface Person : NSObject
	@property(nonatomic, copy) NSString *name;
	@property(nonatomic, assign) NSInteger age;
	@end

#####创建表格

相信下面这句创表语句大家都熟悉吧,就不做介绍了

	create table if not exists Person (id integer primary key autoincrement,name text,age integer)

然而开发中我们都是基于模型开发的,基本上都是一个模型对应数据库的一张表,那么每个模型的属性都不一样,那么我们又该如何生成类似上面的语句呢? 我想到了runtime,通过runtime获取一个类的属性列表,所以有了下面这个方法:

	/// 获取当前类的所有属性
	+ (NSArray *)getAttributeListWithClass:(id)className {
	    // 记录属性个数
	    unsigned int count;
	    objc_property_t *properties = class_copyPropertyList([className class], &count);
	    NSMutableArray *tempArrayM = [NSMutableArray array];
	    for (int i = 0; i < count; i++) {
	        // objc_property_t 属性类型
	        objc_property_t property = properties[i];
	        // 转换为Objective C 字符串
	        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
	        NSAssert(![name isEqualToString:@"index"], @"禁止在model中使用index作为属性,否则会引起语法错误");
	        if ([name isEqualToString:@"hash"]) {
	            break;
	        }
	        [tempArrayM addObject:name];
	    }
	    free(properties);
	    return [tempArrayM copy];
	}

通过这个方法我们可以获取一个类的所有属性列表并将其保存到数组中(index是数据库中保留的关键字,所以在这里用了个断言),然而仅仅是拿到属性列表还是不够的,我们还需要将对应的OC类型转换为SQL对应的数据类型,相信通过上面获取属性名的方法,大家也知道通过runtime能拿到属性对应的数据类型了,那么我们可以通过下面方法将其转换为SQLite需要的类型

	/// OC类型转SQL类型
	+ (NSString *)OCConversionTyleToSQLWithString:(NSString *)String {
	    if ([String isEqualToString:@"long"] || [String isEqualToString:@"int"] || [String isEqualToString:@"BOOL"]) {
	        return @"integer";
	    }
	    if ([String isEqualToString:@"NSData"]) {
	        return @"blob";
	    }
	    if ([String isEqualToString:@"double"] || [String isEqualToString:@"float"]) {
	        return @"real";
	    }
	    // 自定义数组标记
	    if ([String isEqualToString:@"NSArray"] || [String isEqualToString:@"NSMutableArray"]) {
	        return @"customArr";
	    }
	    // 自定义字典标记
	    if ([String isEqualToString:@"NSDictionary"] || [String isEqualToString:@"NSMutableDictionary"]) {
	        return @"customDict";
	    }
	    return @"text";
	}

通过上面方法我们将OC的数据类型转换为了SQL的数据类型并保存到了数组中(上面有两个自定义的类型,后面使用到的时候再做介绍),通过上面的方法我们成功的拿到了一个模型类的属性名和对应的SQL数据类型,然后使用键值对的形式将其保存到了一个字典中,比如:

	@{@"name" : @"text",@"age":"integer"};

获取到这些之后那么创表语句就不难了吧,

// 该方法接收一个类型,内部通过遍历类的属性,字符串拼接获取完整的创表语句,并在内部执行sql语句,并返结果

		- (BOOL)creatTableWithClassName:(id)className;

介绍完了怎么创表,那么我们再来说说怎么将数据插入到数据库中: 我们先看一看插入数据的sql语句:insert into Person (name,age) values ('花菜ChrisCai98',89); 前面都是固定格式的,同样我们可以通过字符串的拼接获取完整的创表语句; 在上面我们已经可以拿到Person类的所有属性列表,那么我们如何拼接sql语句呢? 在这里我定义了这么一个方法

	/// 该方法接收一个对象作为参数(模型对象),并返回是否插入成功
	- (BOOL)insertDataFromObject:(id)object;
	/// 我们可以这样
	Person * p = [[Person alloc]init];
	p.name = @"花菜ChrisCai";
	p.age = 18;
	[[GKDatabaseManager sharedManager] insertDataFromObject:p];

#####插入数据

通过上面这么简单的一句代码实现将数据插入到数据库中,在该方法内部我们通过上面所述的方法获取Person类的所有属性列表,那么我们可以就可以拼接插入语句的前半句了,然后通过KVC的形式完成后半部分赋值的操作;

	/// 插入数据
	- (BOOL)insertDataFromObject:(id)object {
	    // 创建可变字符串用于拼接sql语句
	    NSMutableString * sqlString = [NSMutableString stringWithFormat:@"insert into %@ (",NSStringFromClass([object class])];
	    [[GKObjcProperty getUserNeedAttributeListWithClass:[object class]] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
	        // 拼接字段名
	        [sqlString appendFormat:@"%@,",obj];
	    }];
	    // 去掉后面的逗号
	    [sqlString deleteCharactersInRange:NSMakeRange(sqlString.length-1, 1)];
	    // 拼接values
	    [sqlString appendString:@") values ("];
	    
	    // 拼接字段值
	    [[GKObjcProperty getSQLProperties:[object class]] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
	        // 拼接属性
	        if ([object valueForKey:key]){
	            if ([obj isEqualToString:@"text"]) {
	                [sqlString appendFormat:@"'%@',",[object valueForKey:key]];
	            } else if ([obj isEqualToString:@"customArr"] || [obj isEqualToString:@"customDict"]) { // 数组字典转处理
	                NSData * data = [NSJSONSerialization dataWithJSONObject:[object valueForKey:key] options:0 error:nil];
	                NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
	                [sqlString appendFormat:@"'%@',",jsonString];
	            }else if ([obj isEqualToString:@"blob"]){ // NSData处理
	                NSString * jsonString = [[NSString alloc] initWithData:[object valueForKey:key] encoding:(NSUTF8StringEncoding)];
	                [sqlString appendFormat:@"'%@',",jsonString];
	            }else {
	                [sqlString appendFormat:@"%@,",[object valueForKey:key]];
	            }
	        }else {// 没有值就存NULL
	            [sqlString appendFormat:@"'%@',",[object valueForKey:key]];
	        }
	    }];
	    // 去掉后面的逗号
	    [sqlString deleteCharactersInRange:NSMakeRange(sqlString.length-1, 1)];
	    // 添加后面的括号
	    [sqlString appendFormat:@");"];
	    // 执行语句
	    return [self executeSqlString:sqlString];
	}

在上面方法中,我们用到了之前提到的自定义的类型,通过该自定的类型我们知道需要存储的是字典或者数组,在这里,我们将数组和字典转换为JSON字符串的形式存入数据库中;
到此我们完成了创表和插入向表格中插入数据的操作,下面我们再看看如何从实现一行代码从数据库中将值取出来,在这里我们提供了6中查询的接口,

#####提供的接口如下:

	- (NSArray *)selecteDataWithClass:(id)className;// 根据类名查询对应表格内所有数据
	- (NSInteger)getTotalRowsFormClass:(id)className; // 获取表的总行数
	- (id)selecteFormClass:(id)className index:(NSInteger)index;// 获取指定行数据
	- (NSArray *)selectObject:(Class)className key:(id)key operate:(NSString *)operate value:(id)value;// 指定条件查询
	- (NSArray *)selecteDataWithSqlString:(NSString *)sqlString class:(id)className;// 自定义语句查询
	- (NSArray *)selectObject:(Class)className propertyName:(NSString *)propertyName type:(GKDatabaseSelectLocation)type content:(NSString *)content;// 模糊查询

通过第一个方法(该方法接收一个类名作为参数)就能简单的实现一行代码查询表格中的数据了

	 NSArray * persons = [[GKDatabaseManager sharedManager] selecteDataWithClass:[Person class]];

下面我们着重介绍下核心方法,其他所有方法都是基于该方法实现的

	/// 自定义语句查询
	- (NSArray *)selecteDataWithSqlString:(NSString *)sqlString class:(id)className  {
	    // 创建模型数组
	    NSMutableArray *models = nil;
	    // 1.准备查询
	    sqlite3_stmt *stmt; // 用于提取数据的变量
	    int result = sqlite3_prepare_v2(database, sqlString.UTF8String, -1, &stmt, NULL);
	    // 2.判断是否准备好
	    if (SQLITE_OK == result) {
	        models = [NSMutableArray array];
	        // 获取属性列表名数组 比如name
	        NSArray * arr = [GKObjcProperty getUserNeedAttributeListWithClass:[className class]];
	        // 获取属性列表名和sql数据类型 比如  name : text
	        NSDictionary * dict = [GKObjcProperty getSQLProperties:[className class]];
	        // 准备好了
	        while (SQLITE_ROW == sqlite3_step(stmt)) { // 提取到一条数据
	            __block id objc = [[[className class] alloc]init];
	            for ( int i = 0; i < arr.count; i++) {
	                // 默认第0个元素为表格主键 所以元素从第一个开始
	                // 使用KVC完成赋值
	                if ([dict[arr[i]] isEqualToString:@"text"]) {
	                    [objc setValue:[NSString stringWithFormat:@"%@",[self textForColumn:i + 1  stmt:stmt]] forKey:arr[i]];
	                    
	                } else if ([dict[arr[i]] isEqualToString:@"real"]) {
	                    [objc setValue:[NSString stringWithFormat:@"%f",[self doubleForColumn:i + 1  stmt:stmt]] forKey:arr[i]];
	                    
	                } else if ([dict[arr[i]] isEqualToString:@"integer"]) {
	                    
	                    [objc setValue:[NSString stringWithFormat:@"%i",[self intForColumn:i + 1  stmt:stmt]] forKey:arr[i]];
	                    
	                } else if ([dict[arr[i]] isEqualToString:@"customArr"]) { // 数组处理
	                    
	                    NSString * str = [self textForColumn:i + 1 stmt:stmt];
	                    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
	                    NSArray * resultArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	                    [objc setValue:resultArray forKey:arr[i]];
	                }  else if ([dict[arr[i]] isEqualToString:@"customDict"]) { // 字典处理
	                    
	                    NSString * str = [self textForColumn:i + 1 stmt:stmt];
	                    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
	                    NSDictionary * resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	                    [objc setValue:resultDict forKey:arr[i]];
	                } else if ([dict[arr[i]] isEqualToString:@"blob"]) { // 二进制处理
	                    
	                    NSString * str = [self textForColumn:i + 1 stmt:stmt];
	                    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
	                    [objc setValue:data forKey:arr[i]];
	                }
	            }
	            [models addObject:objc];
	        }
	    }
	    return [models copy];
	}

在该方法内部,我们根据传递进来的类创建了一个对象(使用__block是因为在block内部需要修改对象的属性),通过之前的方法我们拿到了对应的sql类型,和属性名,这里就不重复介绍了,通过对应的sql类型执行对应的方法从数据中将数据取出来,并通过KVC的形式给对象赋值,值得一提的是这里我们通过自定义的字段(customArr,customDict)可以知道我们取的是数组或者字典,然后数据库中的JSON字符串转换为数组或者字典,然后再利用KVC赋值给对象!


到此基本上所有的功能就都实现了,其他的诸如更新数据,删除数据,删除表格等有提供具体的接口,这里就不一一介绍了,源码中有详细的注释,同时也有DEMO,有需要的可以自行下载,

以上均为个人这段时间的总结,如有不对的地方,可以在下面评论 也可以通过QQ:4593679联系我,如觉得好用记得star一下哦~,谢谢!!! 源码地址:https://github.com/ChrisCaixx/GKDatabase






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