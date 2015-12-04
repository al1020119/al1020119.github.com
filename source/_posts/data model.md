---

layout: post
title: "数据与模型"
date: 2014-06-25 13:53:19 +0800
comments: true
categories: 项目实战 

--- 
 
/******************************************************************************/

###一:简单plist读取

 

1:定义一个数组用来保存读取出来的plist数据

	 1 @property (nonatomic, strong) NSArray *shops; 

 

2:使用懒加载的方式加载plist文件，并且放到数组中

	// 懒加载
	
	// 1.第一次用到时再去加载
	
	// 2.只会加载一次
	
	- (NSArray *)shops
	
	{
	
	    if (_shops == nil) {
	
	        // 获得plist文件的全路径
	
	        NSString *file = [[NSBundle mainBundle] pathForResource:@"shops.plist" ofType:nil];
	
	        
	
	        // 从plist文件中加载一个数组对象
	
	        _shops = [NSArray arrayWithContentsOfFile:file];
	
	    }
	
	    return _shops;
	
	}
 

 

3:使用数组中的数据

	// 设置数据
	
	1 NSDictionary *shop = self.shops[index];
	2 
	3 iconView.image = [UIImage imageNamed:shop[@"icon"]];
	4 
	5 nameLabel.text = shop[@"name"];
 

 

/******************************************************************************/

###二：字典转模型

 

######1:创建一个model类并且在里面创建对应的模型属性

	/** 名字 */
	
	 1 @property (nonatomic, strong) NSString *name; 
	
	/** 图标 */
	
	 1 @property (nonatomic, strong) NSString *icon; 

 

 

######2:定义一个数组用来保存读取出来的plist数据

	 1 @property (nonatomic, strong) NSMutableArray *shops; 

 

 

######3:使用懒加载的方式加载plist文件，并且放到模型中

 
	
	// 懒加载
	
	// 1.第一次用到时再去加载
	
	// 2.只会加载一次
	
	- (NSMutableArray *)shops
	
	{
	
	    if (_shops == nil) {
	
	        // 创建"模型数组"
	
	        _shops = [NSMutableArray array];
	
	 
	
	        // 获得plist文件的全路径
	
	        NSString *file = [[NSBundle mainBundle] pathForResource:@"shops.plist" ofType:nil];
	
	 
	
	        // 从plist文件中加载一个数组对象(这个数组中存放的都是NSDictionary对象)
	
	        NSArray *dictArray = [NSArray arrayWithContentsOfFile:file];
	
	 
	
	        // 将 “字典数组” 转换为 “模型数据”
	
	        for (NSDictionary *dict in dictArray) { // 遍历每一个字典
	
	            // 将 “字典” 转换为 “模型”
	
	            Shop *shop = [[Shop alloc] init];
	
	            shop.name = dict[@"name"];
	
	            shop.icon = dict[@"icon"];
	
	 
	
	            // 将 “模型” 添加到 “模型数组中”
	
	            [_shops addObject:shop];
	
	        }
	
	    }
	
	    return _shops;
	
	}
 

4:使用模型中的数据

	// 设置数据 
	Shop *shop = self.shops[index];
	 
	iconView.image = [UIImage imageNamed:shop.icon];
	 
	nameLabel.text = shop.name;
 

 

/******************************************************************************/

 

###三：字典转模型封装

 

######1:创建一个model类并且在里面创建对应的模型属性，定义两个模型方法

	/** 名字 */
	
	@property (nonatomic, copy) NSString *name;
	
	/** 图标 */
	
	@property (nonatomic, copy) NSString *icon;
	
	 
	
	/** 通过一个字典来初始化模型对象 */
	
	- (instancetype)initWithDict:(NSDictionary *)dict;
	
	 
	
	/** 通过一个字典来创建模型对象 */
	
	+ (instancetype)shopWithDict:(NSDictionary *)dict;
 

 

######2:模型方法的实现
	- (instancetype)initWithDict:(NSDictionary *)dict
	
	{
	
	    if (self = [super init]) {
	
	        self.name = dict[@"name"];
	
	        self.icon = dict[@"icon"];
	
	    }
	
	    return self;
	
	}
	
	 
	
	+ (instancetype)shopWithDict:(NSDictionary *)dict
	
	{
	
	    // 这里要用self
	
	    return [[self alloc] initWithDict:dict];
	
	} 

 

######3:定义一个数组用来保存读取出来的plist数据

	 1 @property (nonatomic, strong) NSMutableArray *shops; 

 

 

######4:使用懒加载的方式加载plist文件，并且放到模型中

	// 懒加载
	
	// 1.第一次用到时再去加载
	
	// 2.只会加载一次
	- (NSMutableArray *)shops
	
	{
	
	    if (_shops == nil) {
	
	        // 创建"模型数组"
	
	        _shops = [NSMutableArray array];
	
	        
	
	        // 获得plist文件的全路径
	
	        NSString *file = [[NSBundle mainBundle] pathForResource:@"shops.plist" ofType:nil];
	
	        
	
	        // 从plist文件中加载一个数组对象(这个数组中存放的都是NSDictionary对象)
	
	        NSArray *dictArray = [NSArray arrayWithContentsOfFile:file];
	
	        
	
	        // 将 “字典数组” 转换为 “模型数据”
	
	        for (NSDictionary *dict in dictArray) { // 遍历每一个字典
	
	            // 将 “字典” 转换为 “模型”
	
	            XMGShop *shop = [XMGShop shopWithDict:dict];
	
	            
	
	            // 将 “模型” 添加到 “模型数组中”
	
	            [_shops addObject:shop];
	
	        }
	
	    }
	
	    return _shops;
	
	}
 

 

 

######5:使用模型中的数据
 
	// 设置数据
	 
	XMGShop *shop = self.shops[index];
	 
	iconView.image = [UIImage imageNamed:shop.icon];
	 
	nameLabel.text = shop.name;
 

 

 

/******************************************************************************/

###四：自定义View

 

######1:创建一个model类并且在里面创建对应的模型属性，定义两个模型方法

	/** 名字 */
	
	@property (nonatomic, copy) NSString *name;
	
	/** 图标 */
	
	@property (nonatomic, copy) NSString *icon;
	
	 
	
	/** 通过一个字典来初始化模型对象 */
	
	- (instancetype)initWithDict:(NSDictionary *)dict;
	
	 
	
	/** 通过一个字典来创建模型对象 */
	
	+ (instancetype)shopWithDict:(NSDictionary *)dict;
 

######2:模型方法的实现

	- (instancetype)initWithDict:(NSDictionary *)dict
	
	{
	
	    if (self = [super init]) {
	
	        self.name = dict[@"name"];
	
	        self.icon = dict[@"icon"];
	
	    }
	
	    return self;
	
	}
	
	 
	
	+ (instancetype)shopWithDict:(NSDictionary *)dict
	
	{
	
	    // 这里要用self
	
	    return [[self alloc] initWithDict:dict];
	
	}
 

######3:自定义一个View，引入模型类，并且创建模型类的属性

 

	@class XMGShop;
	
	 
	
	/** 商品模型 */
	
	@property (nonatomic, strong) XMGShop *shop;

######4:实现文件中，定义相应的控件属性

	/** 图片 */
	
	@property (nonatomic, weak) UIImageView *iconView;
	
	 
	
	/** 名字 */
	
	@property (nonatomic, weak) UILabel *nameLabel;
 

######5:实现自定义View的相应方法
	
	- (instancetype)init
	
	{
	
	    if (self = [super init]) {
	
	        // 添加一个图片
	
	        UIImageView *iconView = [[UIImageView alloc] init];
	
	        [self addSubview:iconView];
	
	        self.iconView = iconView;
	
	        
	
	        // 添加一个文字
	
	        UILabel *nameLabel = [[UILabel alloc] init];
	
	        nameLabel.textAlignment = NSTextAlignmentCenter;
	
	        [self addSubview:nameLabel];
	
	        self.nameLabel = nameLabel;
	
	    }
	
	    return self;
	
	}
	
	 
	
	/**
	
	 * 这个方法专门用来布局子控件，设置子控件的frame
	
	 */
	
	- (void)layoutSubviews
	
	{
	
	    // 一定要调用super方法
	
	    [super layoutSubviews];
	
	    
	
	    CGFloat shopW = self.frame.size.width;
	
	    CGFloat shopH = self.frame.size.height;
	
	    
	
	    self.iconView.frame = CGRectMake(0, 0, shopW, shopW);
	
	    self.nameLabel.frame = CGRectMake(0, shopW, shopW, shopH - shopW);
	
	}
	
	 
	
	-(void)setShop:(XMGShop *)shop
	
	{
	
	    _shop = shop;
	
	    
	
	    self.iconView.image = [UIImage imageNamed:shop.icon];
	
	    self.nameLabel.text = shop.name;
	
	}
 

######6:定义一个数组用来保存读取出来的plist数据

	 1 @property (nonatomic, strong) NSMutableArray *shops; 

 

######7:使用懒加载的方式加载plist文件，并且放到模型中

	// 懒加载
	
	// 1.第一次用到时再去加载
	
	// 2.只会加载一次
	
	- (NSMutableArray *)shops
	
	{
	
	    if (_shops == nil) {
	
	        // 创建"模型数组"
	
	        _shops = [NSMutableArray array];
	
	        
	
	        // 获得plist文件的全路径
	
	        NSString *file = [[NSBundle mainBundle] pathForResource:@"shops.plist" ofType:nil];
	
	        
	
	        // 从plist文件中加载一个数组对象(这个数组中存放的都是NSDictionary对象)
	
	        NSArray *dictArray = [NSArray arrayWithContentsOfFile:file];
	
	        
	
	        // 将 “字典数组” 转换为 “模型数据”
	
	        for (NSDictionary *dict in dictArray) { // 遍历每一个字典
	
	            // 将 “字典” 转换为 “模型”
	
	            XMGShop *shop = [XMGShop shopWithDict:dict];
	
	            
	
	            // 将 “模型” 添加到 “模型数组中”
	
	            [_shops addObject:shop];
	
	        }
	
	    }
	
	    return _shops;
	
	} 

######8:使用View
 
	// 创建一个商品父控件
	 
	XMGShopView *shopView = [[XMGShopView alloc] init];
	 
	shopView.frame = CGRectMake(shopX, shopY, shopW, shopH);
	 
	// 将商品父控件添加到shopsView中
	 
	[self.shopsView addSubview:shopView];
	 
	
	 
	
	/**
	
	 
	
	NSDictionary *dict = nil; // 从其他地方加载的字典
	
	 
	
	 XMGShop *shop = [XMGShop shopWithDict:dict];
	
	 
	
	 XMGShopView *shopView = [[XMGShopView alloc] init];
	
	 shopView.shop = shop;
	
	 shopView.frame = CGRectMake(0, 0, 70, 100);
	
	 [self.view addSubview:shopView];
	 
	
	 
	
	 
	
	 // 扩展性差
	
	 // 扩展好的体现：即使改变了需求。我们也不需要动大刀子
	
	 */

 

/******************************************************************************/

 

###五：initWithFrame

1:在上一步的基础上只要修改init方法为

	/** init方法内部会自动调用initWithFrame:方法 */
	
	- (instancetype)initWithFrame:(CGRect)frame
	
	{
	
	    if (self = [super initWithFrame:frame]) {
	
	        // 添加一个图片
	
	        UIImageView *iconView = [[UIImageView alloc] init];
	
	        [self addSubview:iconView];
	
	        self.iconView = iconView;
	
	        
	
	        // 添加一个文字
	
	        UILabel *nameLabel = [[UILabel alloc] init];
	
	        nameLabel.textAlignment = NSTextAlignmentCenter;
	
	        [self addSubview:nameLabel];
	
	        self.nameLabel = nameLabel;
	
	    }
	
	    return self;
	
	}
 

 

2:最后设置数据的时候也可以使用下面的方法实现View的创建

	 1 XMGShopView *shopView = [[XMGShopView alloc] initWithFrame:CGRectMake(shopX, shopY, shopW, shopH)]; 
  

 

/******************************************************************************/

 

###六：MVC

 

######1:model

	@interface XMGShop : NSObject
	
	/** 名字 */
	
	@property (nonatomic, copy) NSString *name;
	
	/** 图标 */
	
	@property (nonatomic, copy) NSString *icon;
	
	/** 通过一个字典来初始化模型对象 */
	
	- (instancetype)initWithDict:(NSDictionary *)dict;
	
	 
	
	/** 通过一个字典来创建模型对象 */
	
	+ (instancetype)shopWithDict:(NSDictionary *)dict;
	
	@end
	 
	
	 
	
	 
	
	@implementation XMGShop
	
	 
	
	- (instancetype)initWithDict:(NSDictionary *)dict
	
	{
	
	    if (self = [super init]) {
	
	        self.name = dict[@"name"];
	
	        self.icon = dict[@"icon"];
	
	    }
	
	    return self;
	
	}
	
	 
	
	+ (instancetype)shopWithDict:(NSDictionary *)dict
	
	{
	
	    // 这里要用self
	
	    return [[self alloc] initWithDict:dict];
	
	}
	
	 
	
	@end
 

 

######2:view

	@class XMGShop;
	
	 
	
	@interface XMGShopView : UIView
	
	/** 商品模型 */
	
	@property (nonatomic, strong) XMGShop *shop;
	
	 
	
	- (instancetype)initWithShop:(XMGShop *)shop;
	
	+ (instancetype)shopViewWithShop:(XMGShop *)shop;
	
	+ (instancetype)shopView;
	
	@end
	 
	
	 
	
	 
	
	@interface XMGShopView()
	
	/** 图片 */
	
	@property (nonatomic, weak) UIImageView *iconView;
	
	 
	
	/** 名字 */
	
	@property (nonatomic, weak) UILabel *nameLabel;
	
	@end
	
	 
	
	@implementation XMGShopView
	
	 
	
	- (instancetype)initWithShop:(XMGShop *)shop
	
	{
	
	    if (self = [super init]) {
	
	        self.shop = shop;
	
	    }
	
	    return self;
	
	}
	
	 
	
	+ (instancetype)shopViewWithShop:(XMGShop *)shop
	
	{
	
	    return [[self alloc] initWithShop:shop];
	
	}
	
	 
	
	+ (instancetype)shopView
	
	{
	
	    return [[self alloc] init];
	
	}
	
	 
	
	/** init方法内部会自动调用initWithFrame:方法 */
	
	- (instancetype)initWithFrame:(CGRect)frame
	
	{
	
	    if (self = [super initWithFrame:frame]) {
	
	        // 添加一个图片
	
	        UIImageView *iconView = [[UIImageView alloc] init];
	
	        [self addSubview:iconView];
	
	        self.iconView = iconView;
	
	        
	
	        // 添加一个文字
	
	        UILabel *nameLabel = [[UILabel alloc] init];
	
	        nameLabel.textAlignment = NSTextAlignmentCenter;
	
	        [self addSubview:nameLabel];
	
	        self.nameLabel = nameLabel;
	
	    }
	
	    return self;
	
	}
	
	 
	
	/**
	
	 * 当前控件的frame发生改变的时候就会调用
	
	 * 这个方法专门用来布局子控件，设置子控件的frame
	
	 */
	
	- (void)layoutSubviews
	
	{
	
	    // 一定要调用super方法
	
	    [super layoutSubviews];
	
	    
	
	    CGFloat shopW = self.frame.size.width;
	
	    CGFloat shopH = self.frame.size.height;
	
	    
	
	    self.iconView.frame = CGRectMake(0, 0, shopW, shopW);
	
	    self.nameLabel.frame = CGRectMake(0, shopW, shopW, shopH - shopW);
	
	}
	
	 
	
	- (void)setShop:(XMGShop *)shop
	
	{
	
	    _shop = shop;
	
	    
	
	    self.iconView.image = [UIImage imageNamed:shop.icon];
	
	    self.nameLabel.text = shop.name;
	
	}
	
	 
	
	@end

 

######controller

 

	@property (nonatomic, strong) NSMutableArray *shops;
	
	 
	
	 
	
	 
	
	// 懒加载
	
	// 1.第一次用到时再去加载
	
	// 2.只会加载一次
	
	- (NSMutableArray *)shops
	
	{
	
	    if (_shops == nil) {
	
	        // 创建"模型数组"
	
	        _shops = [NSMutableArray array];
	
	        
	
	        // 获得plist文件的全路径
	
	        NSString *file = [[NSBundle mainBundle] pathForResource:@"shops.plist" ofType:nil];
	
	        
	
	        // 从plist文件中加载一个数组对象(这个数组中存放的都是NSDictionary对象)
	
	        NSArray *dictArray = [NSArray arrayWithContentsOfFile:file];
	
	        
	
	        // 将 “字典数组” 转换为 “模型数据”
	
	        for (NSDictionary *dict in dictArray) { // 遍历每一个字典
	
	            // 将 “字典” 转换为 “模型”
	
	            XMGShop *shop = [XMGShop shopWithDict:dict];
	
	            
	
	            // 将 “模型” 添加到 “模型数组中”
	
	            [_shops addObject:shop];
	
	        }
	
	    }
	
	    return _shops;
	
	}
	
	 
	
	// 创建一个商品父控件
	
	XMGShopView *shopView = [XMGShopView shopViewWithShop:self.shops[index]];
	
	// 设置frame
	
	shopView.frame = CGRectMake(shopX, shopY, shopW, shopH);
	
	// 将商品父控件添加到shopsView中
	
	[self.shopsView addSubview:shopView];
 

 

/******************************************************************************/

###七：XIB

 

1:xibView中
	
	/** 商品模型 */
	
	@property (nonatomic, strong) XMGShop *shop;
	
	+ (instancetype)shopViewWithShop:(XMGShop *)shop;
	
	 
	
	+ (instancetype)shopViewWithShop:(XMGShop *)shop
	
	{
	
	    // self == XMGShopView
	
	    // NSStringFromClass(self) == @"XMGShopView"
	
	    XMGShopView *shopView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
	
	    shopView.shop = shop;
	
	    return shopView;
	
	}
	
	 
	
	- (void)setShop:(XMGShop *)shop
	
	{
	
	    _shop = shop;
	
	    
	
	    UIImageView *iconView = (UIImageView *)[self viewWithTag:1];
	
	    iconView.image = [UIImage imageNamed:shop.icon];
	
	    
	
	    UILabel *nameLabel = (UILabel *)[self viewWithTag:2];
	
	    nameLabel.text = shop.name;
	
	}
 

######2:控制器中设置数据

	// 从xib中加载一个商品控件
	
	XMGShopView *shopView = [XMGShopView shopViewWithShop:self.shops[index]];
	
	// 设置frame
	
	shopView.frame = CGRectMake(shopX, shopY, shopW, shopH);
	
	// 添加商品控件
	
	[self.shopsView addSubview:shopView];
 

/******************************************************************************/

###八：MJExtension

######1:是一套“字典和模型之间互相转换”的轻量级框架，模型属性

	
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
 

######2:对应方法的实现

	
 + 1.MJExtension是一套“字典和模型之间互相转换”的轻量级框架

 + 2.MJExtension能完成的功能
 

	- 字典 --> 模型

	 - 模型 --> 字典

 	- 字典数组 --> 模型数组

 	- 模型数组 --> 字典数组

 + 3.具体用法主要参考 main.m中各个函数 以及 "NSObject+MJKeyValue.h"

 + 4.希望各位大神能用得爽


	
	 
		
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
	 
	
