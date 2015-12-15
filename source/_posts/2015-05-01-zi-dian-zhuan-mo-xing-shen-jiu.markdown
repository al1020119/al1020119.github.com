---


layout: post
title: "字典转模型深究"
date: 2015-05-01 02:33:18 +0800
comments: true
categories: Projects


---


 

> 引言：
在文字开始之前先介绍两个软件：

#####JSONExport

 
{% img /images/zidianzhuanmoxin005.png Caption %}  

#####JSON Accelerator

{% img /images/zidianzhuanmoxin006.png Caption %}  

> 关于模型类的两个神器，我也是刚接触不久，但是感觉非常有用，基本上可以节省你在模型类上的99%的时间。

* 如果你觉得自己对应本文后面的内容非常了解，那么请直接下载上面的软件试试。
* 如果你并不是很熟练，那么轻认真看完后面的内容，相信对你有好处，再去下载对应的软件。


关于Plist转模型在iOS开发中是非常常见的，每开一一个项目或者实现一个功能都要用到它，所以今天就给大家讲讲Plist怎么转成模型数据，

> 前提：必须有一个Plist文件或者通过一定的方式返回的plist数据

 



<!--more-->





## 一：直接加载Plist数据

{% img /images/zidianzhuanmoxin001.png Caption %}  

	定义一个数组属性 
	@property (nonatomic, assign) NSArray *apps; 

######  获取Plist文件

	//懒加载plist文件，返回一个apps数据，后面直接使用旧可以
	-(NSArray *)apps
	{
	    if (_apps == nil) {
	        _apps = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iCocos.plist" ofType:nil]];
	    }
	    return _apps;
	}
	
###### 加载Plsit中的数据

		//取出数组中对应的数据放到一个字典里面
        NSDictionary *dic = self.apps[i];
        
        
        //创建一个UIImageView
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iW, 50)];
        /**
         取出字典中的icon
        */
         icon.image = [UIImage imageNamed:dic[@"icon"]];
        
        [view addSubview:icon];
        
        

        //创建一个Label
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame), iW, 20)];
        /**
         取出字典中的label
         */
        l.text = dic[@"label"];
        
        [view addSubview:l];
        
        
        
        //创建一个按钮
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(l.frame), iW, 20)];
        /**
         取出字典中的btn
         */
        [btn setTitle:dic[@"btn"] forState:UIControlStateNormal];
        
        [view addSubview:btn];
 

 

## 二：使用简单的模型加载Plist数据


{% img /images/zidianzhuanmoxin002.png Caption %}  

	 1 //定义一个数组属性
	 
	  2 @property (nonatomic, assign) NSArray *apps; 
	
###### 在模型中定义模型对应的属性

	@property (nonatomic, copy) NSString *icon;
	
	
	@property (nonatomic, copy) NSString *label;
	
	
	@property (nonatomic, copy) NSString *btn;


###### 模型方法

	/**
	 模型数据方法
	 */
	+(instancetype)messageWithDict:(NSDictionary *)dict;
	
	
	-(instancetype)initWithDict:(NSDictionary *)dict;
	 

###### 模型的实现文件
	
	/**
	 模型数据方法的实现
	 */
	
	+ (instancetype)messageWithDict:(NSDictionary *)dict
	{
	    return [[self alloc] initWithDict:dict];
	}
	
	- (instancetype)initWithDict:(NSDictionary *)dict
	{
	    if (self = [super init]) {
	        [self setValuesForKeysWithDictionary:dict];
	    }
	    return self;
	}
 

###### 实用模型加载Plist文件
	
	/**
	 模型数据的加载，返回arry以后我们就只要使用array就能使用这个模型类里面的数据也就是使用plist数据
	 */
	//懒加载plist文件，返回一个apps数据，后面直接使用旧可以
	-(NSMutableArray *)apps
	{
	    if (_apps == nil) {
	        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iCocos.plist" ofType:nil]];
	        
	        NSMutableArray *arrayApps = [NSMutableArray array];
	        
	        for (NSDictionary *dic in array) {
	            appsModel *model = [[appsModel alloc] init];
	            model.label = dic[@"label"];
	            model.btn = dic[@"btn"];
	            model.icon = dic[@"icon"];
	            
	            [arrayApps addObject:model];
	        }
	        _apps = arrayApps;
	    }
	    return _apps;
	}
###### 加载模型中对应的plist数据

		//取出数组中对应的数据放到一个字典里面
        appsModel *app = self.apps[i];
        
        
        //创建一个UIImageView
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iW, 50)];
        /**
         取出字典中的icon
         */
        icon.image = [UIImage imageNamed:app.icon];
        [view addSubview:icon];
        
        
        
        //创建一个Label
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame), iW, 20)];
        /**
         取出字典中的label
         */
        l.text = app.label;
        [view addSubview:l];
        
        
        
        //创建一个按钮
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(l.frame), iW, 20)];
        /**
         取出字典中的btn
         */
        [btn setTitle:app.btn forState:UIControlStateNormal];
        [view addSubview:btn];
#####注：上面是plist中的属性和模型中定义的属性一一对应的时候的，如果不是一一对应我们就要将模型一个一个的赋值与实现

	- (instancetype)initWithDict:(NSDictionary *)dict
	{
    self = [super init];
    if (self) {
        self.label = dict[@"label"];
        self.btn = dict[@"btn"];
        self.icon = dict[@"icon"];
        
	//[self setValue:dict[@"label"] forKeyPath:@"label"];
        
        //封装
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
	}


/**
 模型数据的加载，返回arry以后我们就只要使用array就能使用这个模型类里面的数据也就是使用plist数据
 */
 
	//懒加载plist文件，返回一个apps数据，后面直接使用旧可以
	-(NSMutableArray *)apps
	{
		if (_apps == nil) {
	        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iCocos.plist" ofType:nil]];
	        
	        NSMutableArray *arrayApps = [NSMutableArray array];
	        
	        for (NSDictionary *dic in array) {
	//            appsModel *model = [[appsModel alloc] initWithDict:dic];
	            appsModel *model = [appsModel appsWithDict:dic];
	            
	            [arrayApps addObject:model];
	        }
	        _apps = arrayApps;
	    }
	    return _apps;
	}


###### 我们也可以讲加载模型的代码进行封装，这样更加简单的实现模式数据的的使用

在模型中定义并且实现一个模型封装的方法


	+(NSArray *)appList
	{
	        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iCocos.plist" ofType:nil]];
	        
	        NSMutableArray *arrayApps = [NSMutableArray array];
	        
	        for (NSDictionary *dic in array) {
	            //            appsModel *model = [[appsModel alloc] initWithDict:dic];
	            appsModel *model = [appsModel appsWithDict:dic];
	            
	            [arrayApps addObject:model];
	    }
	    return arrayApps;
	    
	}
	
###### 实用的时候只要直接使用封装好的模型方法就可以：
	
	/**
	 模型数据的加载，返回arry以后我们就只要使用array就能使用这个模型类里面的数据也就是使用plist数据
	 */
	//懒加载plist文件，返回一个apps数据，后面直接使用旧可以
	-(NSArray *)apps
	{
	    if (_apps == nil) {
	
	        _apps = [appsModel appList];
	    }
	    return _apps;
	}
 

## 三：复杂Plist转模型


有的时候我们会遇到Plist中还有更小一级的节点和属性这个时候我们就需要更复杂的模型来加载，但是实用起来并不复杂

比如Plist中海油一个friends这歌子模型

{% img /images/zidianzhuanmoxin003.png Caption %}  


###### 那么我转模型的时候就可以根据plist中的数据进行处理，

###### 首先我们一一般都是从子模型开始，我们就先定义子模型
	
	/**
	 根据plist里面存在的子列中的数据再创建一个模型数据
	 */
	
	/**
	 设置子模型数据的属性
	 */
	
	@property (nonatomic, assign) NSString *icon;
	
	@property (nonatomic, assign) NSString *intro;
	
	@property (nonatomic, assign) NSString *name;
	
	@property (nonatomic, assign, getter=isVip)BOOL vip;
	
	
	/**
	 子模型数据的方法
	 */
	+ (instancetype)friendWithDict:(NSDictionary *)dict;
	
	- (instancetype)initWithDict:(NSDictionary *)dict;



###### 子模型的实现
	/**
	 子模型数据的方法de实现
	 */
	
	+ (instancetype)friendWithDict:(NSDictionary *)dict
	{
	    return [[self alloc] initWithDict:dict];
	}
	
	- (instancetype)initWithDict:(NSDictionary *)dict
	{
	    if (self = [super init]) {
	        [self setValuesForKeysWithDictionary:dict];
	    }
	    return self;
	}


###### 然后就是根模型

	/**
	 根据plist中的数据创建一个模型数据
	 */
	
	/**
	 设置模型数据的中的属性
	 */
	
	@property (nonatomic, assign) NSArray *friends;
	
	@property (nonatomic, copy) NSString *name;
	
	@property (nonatomic, assign) NSNumber *online;
	
	/**
	 模型数据的方法
	 */
	
	+ (instancetype)groupWithDict:(NSDictionary *)dict;
	
	
	- (instancetype)initWithDict:(NSDictionary *)dict;



###### 根模型的实现，这里只需要在根模型加载需要实现的子模型酒可以

	/**
	 模型数据的方法的实现
	 */
	
	+ (instancetype)groupWithDict:(NSDictionary *)dict
	{
	    return [[self alloc] initWithDict:dict];
	}
	
	- (instancetype)initWithDict:(NSDictionary *)dict
	{
	    if (self = [super init]) {
	        [self setValuesForKeysWithDictionary:dict];
	        
	        NSMutableArray *friendArray = [NSMutableArray array];
	        for (NSDictionary *dict in self.friends) {
	            FriendsPlistChildren *friend = [FriendsPlistChildren friendWithDict:dict];
	            [friendArray addObject:friend];
	        }
	        self.friends = friendArray;
	    }
	    return self;
	}


###### 使用模型数据，方法还是和之前一样的，不需要去处理子模型，因为我们在跟模型里面已经处理好了

	/**
	 加载模型数据的方法
	 */
	
	- (NSArray *)groups
	{
	    if (_groups == nil) {
	        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"friends.plist" ofType:nil]];
	        
	        NSMutableArray *groupArray = [NSMutableArray array];
	        for (NSDictionary *dict in dictArray) {
	            FirendsPlistRoot *group = [FirendsPlistRoot groupWithDict:dict];
	            [groupArray addObject:group];
	        }
	        
	        _groups = groupArray;
	    }
	    return _groups;
	}
 

## 四：使用第三份库

在iOS届有一个神人不知道大家知不知道————他叫李明杰，他（MJ）不仅技术牛逼，而且对天朝iOS界的贡献也是无法用语言来形容的，如果你是老一辈的iOS开发者倒是很正常，如果你只是刚开始学习iOS或者学习iOS不久你都不知道或者没有听过这个名字那么就可以说明你真的out了，甚至说你你根本没有用心在学，关于这个神人我就不做多介绍了，如果你想知道更多，请点击www.520it.com

今天我就使用他的一个NB的框架来实现plist转模型数据，这个框架使用起来非常简单，一行代码就可以搞定你想的功能，

首先你需要去github上面下载这个框架：[MJExtension](https://github.com/CoderMJLee/MJExtension)

下载好了之后直接讲MJExtension拖到你的项目

{% img /images/zidianzhuanmoxin004.png Caption %}  


###### 首先根据plist数据新建对应的模型数据

这里我一新浪微博中的小部分做测试

	#import "User.h"
	#import "Status.h"
	#import "StatusResult.h"
	
	/**
	 *  微博文本内容
	 */
	@property (copy, nonatomic) NSString *text;
	
	/**
	 *  微博作者
	 */
	@property (strong, nonatomic) User *user;
	
	/**
	 *  转发的微博
	 */
	@property (strong, nonatomic) Status *retweetedStatus;
	/**
	 *  存放着某一页微博数据（里面都是Status模型）
	 */
	@property (strong, nonatomic) NSMutableArray *statuses;
	
	/**
	 *  总数
	 */
	@property (assign, nonatomic) NSNumber *totalNumber;
	
	/**
	 *  上一页的游标
	 */
	@property (assign, nonatomic) long long previousCursor;
	
	/**
	 *  下一页的游标
	 */
	@property (assign, nonatomic) long long nextCursor;
	/**
	 *  名称
	 */
	@property (copy, nonatomic) NSString *name;
	
	/**
	 *  头像
	 */
	@property (copy, nonatomic) NSString *icon;


###### 下面就是证明去使用这个框架实现你想要的功能了，这里介绍了几乎你开发中需要用到的所有方法和例子，

	/**
	 MJ友情提醒：
	 1.MJExtension是一套“字典和模型之间互相转换”的轻量级框架
	 2.MJExtension能完成的功能
	 * 字典 --> 模型
	 * 模型 --> 字典
	 * 字典数组 --> 模型数组
	 * 模型数组 --> 字典数组
	 3.具体用法主要参考 main.m中各个函数 以及 "NSObject+MJKeyValue.h"
	 4.希望各位大神能用得爽
	 */
	
	#import <Foundation/Foundation.h>
	#import "MJExtension.h"
	#import "User.h"
	#import "Status.h"
	#import "StatusResult.h"
	
	/**
	 *  简单的字典 -> 模型
	 */
	void keyValues2object()
	{
	    // 1.定义一个字典
	    NSDictionary *dict = @{
	                           @"name" : @"Jack",
	                           @"icon" : @"lufy.png",
	                           };
	    
	    // 2.将字典转为User模型
	    User *user = [User objectWithKeyValues:dict];
	    
	    // 3.打印User模型的属性
	    NSLog(@"name=%@, icon=%@", user.name, user.icon);
	}
	
	/**
	 *  复杂的字典 -> 模型 (模型里面包含了模型)
	 */
	void keyValues2object2()
	{
	    // 1.定义一个字典
	    NSDictionary *dict = @{
	                           @"text" : @"是啊，今天天气确实不错！",
	                           
	                           @"user" : @{
	                                   @"name" : @"Jack",
	                                   @"icon" : @"lufy.png"
	                                   },
	                           
	                           @"retweetedStatus" : @{
	                                   @"text" : @"今天天气真不错！",
	                                   
	                                   @"user" : @{
	                                           @"name" : @"Rose",
	                                           @"icon" : @"nami.png"
	                                           }
	                                   }
	                           };
	    
	    // 2.将字典转为Status模型
	    Status *status = [Status objectWithKeyValues:dict];
	    
	    // 3.打印status的属性
	    NSString *text = status.text;
	    NSString *name = status.user.name;
	    NSString *icon = status.user.icon;
	    NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
	    
	    // 4.打印status.retweetedStatus的属性
	    NSString *text2 = status.retweetedStatus.text;
	    NSString *name2 = status.retweetedStatus.user.name;
	    NSString *icon2 = status.retweetedStatus.user.icon;
	    NSLog(@"text2=%@, name2=%@, icon2=%@", text2, name2, icon2);
	}
	
	/**
	 *  复杂的字典 -> 模型 (模型的数组属性里面又装着模型)
	 */
	void keyValues2object3()
	{
	    // 1.定义一个字典
	    NSDictionary *dict = @{
	                           @"statuses" : @[
	                                   @{
	                                       @"text" : @"今天天气真不错！",
	                                       
	                                       @"user" : @{
	                                               @"name" : @"Rose",
	                                               @"icon" : @"nami.png"
	                                               }
	                                       },
	                                   
	                                   @{
	                                       @"text" : @"明天去旅游了",
	                                       
	                                       @"user" : @{
	                                               @"name" : @"Jack",
	                                               @"icon" : @"lufy.png"
	                                               }
	                                       },
	                                   
	                                   @{
	                                       @"text" : @"嘿嘿，这东西不错哦！",
	                                       
	                                       @"user" : @{
	                                               @"name" : @"Jim",
	                                               @"icon" : @"zero.png"
	                                               }
	                                       }
	                                   
	                                   ],
	                           
	                           @"totalNumber" : @"2014",
	                           
	                           @"previousCursor" : @"13476589",
	                           
	                           @"nextCursor" : @"13476599"
	                           };
	    
	    // 2.将字典转为StatusResult模型
	    StatusResult *result = [StatusResult objectWithKeyValues:dict];
	    
	    // 3.打印StatusResult模型的简单属性
	    NSLog(@"totalNumber=%d, previousCursor=%lld, nextCursor=%lld", result.totalNumber, result.previousCursor, result.nextCursor);
	    
	    // 4.打印statuses数组中的模型属性
	    for (Status *status in result.statuses) {
	        NSString *text = status.text;
	        NSString *name = status.user.name;
	        NSString *icon = status.user.icon;
	        NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
	    }
	}
	
	/**
	 *  字典数组 -> 模型数组
	 */
	void keyValuesArray2objectArray()
	{
	    // 1.定义一个字典数组
	    NSArray *dictArray = @[
	                           @{
	                               @"name" : @"Jack",
	                               @"icon" : @"lufy.png",
	                               },
	                           
	                           @{
	                               @"name" : @"Rose",
	                               @"icon" : @"nami.png",
	                               },
	                           
	                           @{
	                               @"name" : @"Jim",
	                               @"icon" : @"zero.png",
	                               }
	                           ];
	    
	    // 2.将字典数组转为User模型数组
	    NSArray *userArray = [User objectArrayWithKeyValuesArray:dictArray];
	    
	    // 3.打印userArray数组中的User模型属性
	    for (User *user in userArray) {
	        NSLog(@"name=%@, icon=%@", user.name, user.icon);
	    }
	}
	
	/**
	 *  模型 -> 字典
	 */
	void object2keyValues()
	{
	    // 1.新建模型
	    User *user = [[User alloc] init];
	    user.name = @"Jack";
	    user.icon = @"lufy.png";
	    
	    Status *status = [[Status alloc] init];
	    status.user = user;
	    status.text = @"今天的心情不错！";
	    
	    // 2.将模型转为字典
	    //    NSDictionary *dict = [status keyValues];
	    NSDictionary *dict = status.keyValues;
	    NSLog(@"%@", dict);
	}
	
	/**
	 *  模型数组 -> 字典数组
	 */
	void objectArray2keyValuesArray()
	{
	    // 1.新建模型数组
	    User *user1 = [[User alloc] init];
	    user1.name = @"Jack";
	    user1.icon = @"lufy.png";
	    
	    User *user2 = [[User alloc] init];
	    user2.name = @"Rose";
	    user2.icon = @"nami.png";
	    
	    User *user3 = [[User alloc] init];
	    user3.name = @"Jim";
	    user3.icon = @"zero.png";
	    
	    NSArray *userArray = @[user1, user2, user3];
	    
	    // 2.将模型数组转为字典数组
	    NSArray *dictArray = [User keyValuesArrayWithObjectArray:userArray];
	    NSLog(@"%@", dictArray);
	}
	
	int main(int argc, const char * argv[])
	{
	    @autoreleasepool {
	        // 简单的字典 -> 模型
	        keyValues2object();
	        
	        // 复杂的字典 -> 模型 (模型里面包含了模型)
	        keyValues2object2();
	        
	        // 复杂的字典 -> 模型 (模型的数组属性里面又装着模型)
	        keyValues2object3();
	        
	        // 字典数组 -> 模型数组
	        keyValuesArray2objectArray();
	        
	        // 模型转字典
	        object2keyValues();
	        
	        // 模型数组 -> 字典数组
	        objectArray2keyValuesArray();
	    }
	    return 0;
	}
	 
	
 