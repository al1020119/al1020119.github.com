---

layout: post
title: "玩转CollectionView"
date: 2013-08-18 13:53:19 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

 

--- 

实现步骤

###一、新建两个类
1.继承自UIScrollView的子类，比如iCocosWaterflowView

* 瀑布流显示控件，用来显示所有的瀑布流数据

2.继承自UIView的子类，比如iCocosWaterflowViewCell

* 代表着瀑布流数据中的一个单元（一个格子）

3.总结



<!--more-->




* iCocosWaterflowView和iCocosWaterflowViewCell的关系实际上类似于
UITableView和UITableViewCell的关系

###二、设计iCocosWaterflowView的接口
1.模仿UITableView的接口来设计

* 设计一套数据源和代理方法

###三、iCocosWaterflowView的实现
1.reloadData

* 作用：刷新数据
* 步骤：
1> 清空以前残余的数据
2> 计算所有新数据对应的frame

2.layoutSubviews

+ 作用：显示和移除子控件
+ 步骤：

	- 检测每一个数据对应的frame在不在屏幕上（用户能不能看见）

	- 如果这个数据对应的frame在屏幕上：向数据源索要这个数据对应的cell，添加这个cell到iCocosWaterflowView中显示

	- 如果这个数据对应的frame不在屏幕上：从iCocosWaterflowView中移除这个数据对应的cell，并将这个cell添加到缓存池中
 
 
View.h文件

	#import <UIKit/UIKit.h>
	
	typedef enum {
	    iCocosWaterflowViewMarginTypeTop,
	    iCocosWaterflowViewMarginTypeBottom,
	    iCocosWaterflowViewMarginTypeLeft,
	    iCocosWaterflowViewMarginTypeRight,
	    iCocosWaterflowViewMarginTypeColumn, // 每一列
	    iCocosWaterflowViewMarginTypeRow, // 每一行
	} iCocosWaterflowViewMarginType;
	
	@class iCocosWaterflowView, iCocosWaterflowViewCell;
	
	/**
	 *  数据源方法
	 */
	@protocol iCocosWaterflowViewDataSource <NSObject>
	@required
	/**
	 *  一共有多少个数据
	 */
	- (NSUInteger)numberOfCellsInWaterflowView:(iCocosWaterflowView *)waterflowView;
	/**
	 *  返回index位置对应的cell
	 */
	- (iCocosWaterflowViewCell *)waterflowView:(iCocosWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;
	
	@optional
	/**
	 *  一共有多少列
	 */
	- (NSUInteger)numberOfColumnsInWaterflowView:(iCocosWaterflowView *)waterflowView;
	@end
	
	/**
	 *  代理方法
	 */
	@protocol iCocosWaterflowViewDelegate <UIScrollViewDelegate>
	@optional
	/**
	 *  第index位置cell对应的高度
	 */
	- (CGFloat)waterflowView:(iCocosWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index;
	/**
	 *  选中第index位置的cell
	 */
	- (void)waterflowView:(iCocosWaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index;
	/**
	 *  返回间距
	 */
	- (CGFloat)waterflowView:(iCocosWaterflowView *)waterflowView marginForType:(iCocosWaterflowViewMarginType)type;
	@end
	
	/**
	 *  瀑布流控件
	 */
	@interface iCocosWaterflowView : UIScrollView
	/**
	 *  数据源
	 */
	@property (nonatomic, weak) id<iCocosWaterflowViewDataSource> dataSource;
	/**
	 *  代理
	 */
	@property (nonatomic, weak) id<iCocosWaterflowViewDelegate> delegate;
	
	/**
	 *  刷新数据（只要调用这个方法，会重新向数据源和代理发送请求，请求数据）
	 */
	- (void)reloadData;
	
	/**
	 *  cell的宽度
	 */
	- (CGFloat)cellWidth;
	
	/**
	 *  根据标识去缓存池查找可循环利用的cell
	 */
	- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
	@end
复制代码
 

View.m文件


	#import "iCocosWaterflowView.h"
	#import "iCocosWaterflowViewCell.h"
	
	#define iCocosWaterflowViewDefaultCellH 70
	#define iCocosWaterflowViewDefaultMargin 8
	#define iCocosWaterflowViewDefaultNumberOfColumns 3
	
	@interface iCocosWaterflowView()
	/**
	 *  所有cell的frame数据
	 */
	@property (nonatomic, strong) NSMutableArray *cellFrames;
	/**
	 *  正在展示的cell
	 */
	@property (nonatomic, strong) NSMutableDictionary *displayingCells;
	/**
	 *  缓存池（用Set，存放离开屏幕的cell）
	 */
	@property (nonatomic, strong) NSMutableSet *reusableCells;
	@end
	
	@implementation iCocosWaterflowView
	
	#pragma mark - 初始化
	- (NSMutableArray *)cellFrames
	{
	    if (_cellFrames == nil) {
	        self.cellFrames = [NSMutableArray array];
	    }
	    return _cellFrames;
	}
	
	- (NSMutableDictionary *)displayingCells
	{
	    if (_displayingCells == nil) {
	        self.displayingCells = [NSMutableDictionary dictionary];
	    }
	    return _displayingCells;
	}
	
	- (NSMutableSet *)reusableCells
	{
	    if (_reusableCells == nil) {
	        self.reusableCells = [NSMutableSet set];
	    }
	    return _reusableCells;
	}
	
	- (id)initWithFrame:(CGRect)frame
	{
	    self = [super initWithFrame:frame];
	    if (self) {
	        
	    }
	    return self;
	}
	
	- (void)willMoveToSuperview:(UIView *)newSuperview
	{
	    [self reloadData];
	}
	
	#pragma mark - 公共接口
	/**
	 *  cell的宽度
	 */
	- (CGFloat)cellWidth
	{
	    // 总列数
	    int numberOfColumns = [self numberOfColumns];
	    CGFloat leftM = [self marginForType:iCocosWaterflowViewMarginTypeLeft];
	    CGFloat rightM = [self marginForType:iCocosWaterflowViewMarginTypeRight];
	    CGFloat columnM = [self marginForType:iCocosWaterflowViewMarginTypeColumn];
	    return (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1) * columnM) / numberOfColumns;
	}
	
	/**
	 *  刷新数据
	 */
	- (void)reloadData
	{
	    // 清空之前的所有数据
	    // 移除正在正在显示cell
	    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
	    [self.displayingCells removeAllObjects];
	    [self.cellFrames removeAllObjects];
	    [self.reusableCells removeAllObjects];
	    
	    // cell的总数
	    int numberOfCells = [self.dataSource numberOfCellsInWaterflowView:self];
	    
	    // 总列数
	    int numberOfColumns = [self numberOfColumns];
	    
	    // 间距
	    CGFloat topM = [self marginForType:iCocosWaterflowViewMarginTypeTop];
	    CGFloat bottomM = [self marginForType:iCocosWaterflowViewMarginTypeBottom];
	    CGFloat leftM = [self marginForType:iCocosWaterflowViewMarginTypeLeft];
	    CGFloat columnM = [self marginForType:iCocosWaterflowViewMarginTypeColumn];
	    CGFloat rowM = [self marginForType:iCocosWaterflowViewMarginTypeRow];
	    
	    // cell的宽度
	    CGFloat cellW = [self cellWidth];
	    
	    // 用一个C语言数组存放所有列的最大Y值
	    CGFloat maxYOfColumns[numberOfColumns];
	    for (int i = 0; i<numberOfColumns; i++) {
	        maxYOfColumns[i] = 0.0;
	    }
	    
	    // 计算所有cell的frame
	    for (int i = 0; i<numberOfCells; i++) {
	        // cell处在第几列(最短的一列)
	        NSUInteger cellColumn = 0;
	        // cell所处那列的最大Y值(最短那一列的最大Y值)
	        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
	        // 求出最短的一列
	        for (int j = 1; j<numberOfColumns; j++) {
	            if (maxYOfColumns[j] < maxYOfCellColumn) {
	                cellColumn = j;
	                maxYOfCellColumn = maxYOfColumns[j];
	            }
	        }
	        
	        // 询问代理i位置的高度
	        CGFloat cellH = [self heightAtIndex:i];
	        
	        // cell的位置
	        CGFloat cellX = leftM + cellColumn * (cellW + columnM);
	        CGFloat cellY = 0;
	        if (maxYOfCellColumn == 0.0) { // 首行
	            cellY = topM;
	        } else {
	            cellY = maxYOfCellColumn + rowM;
	        }
	        
	        // 添加frame到数组中
	        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
	        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
	        
	        // 更新最短那一列的最大Y值
	        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
	    }
	    
	    // 设置contentSize
	    CGFloat contentH = maxYOfColumns[0];
	    for (int j = 1; j<numberOfColumns; j++) {
	        if (maxYOfColumns[j] > contentH) {
	            contentH = maxYOfColumns[j];
	        }
	    }
	    contentH += bottomM;
	    self.contentSize = CGSizeMake(0, contentH);
	}
	
	/**
	 *  当UIScrollView滚动的时候也会调用这个方法
	 */
	- (void)layoutSubviews
	{
	    [super layoutSubviews];
	    
	    // 向数据源索要对应位置的cell
	    NSUInteger numberOfCells = self.cellFrames.count;
	    for (int i = 0; i<numberOfCells; i++) {
	        // 取出i位置的frame
	        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
	        
	        // 优先从字典中取出i位置的cell
	        iCocosWaterflowViewCell *cell = self.displayingCells[@(i)];
	        
	        // 判断i位置对应的frame在不在屏幕上（能否看见）
	        if ([self isInScreen:cellFrame]) { // 在屏幕上
	            if (cell == nil) {
	                cell = [self.dataSource waterflowView:self cellAtIndex:i];
	                cell.frame = cellFrame;
	                [self addSubview:cell];
	                
	                // 存放到字典中
	                self.displayingCells[@(i)] = cell;
	            }
	        } else {  // 不在屏幕上
	            if (cell) {
	                // 从scrollView和字典中移除
	                [cell removeFromSuperview];
	                [self.displayingCells removeObjectForKey:@(i)];
	                
	                // 存放进缓存池
	                [self.reusableCells addObject:cell];
	            }
	        }
	    }
	}
	
	- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
	{
	    __block iCocosWaterflowViewCell *reusableCell = nil;
	    
	    [self.reusableCells enumerateObjectsUsingBlock:^(iCocosWaterflowViewCell *cell, BOOL *stop) {
	        if ([cell.identifier isEqualToString:identifier]) {
	            reusableCell = cell;
	            *stop = YES;
	        }
	    }];
	    
	    if (reusableCell) { // 从缓存池中移除
	        [self.reusableCells removeObject:reusableCell];
	    }
	    return reusableCell;
	}
	
	#pragma mark - 私有方法
	/**
	 *  判断一个frame有无显示在屏幕上
	 */
	- (BOOL)isInScreen:(CGRect)frame
	{
	    return (CGRectGetMaxY(frame) > self.contentOffset.y) &&
	    (CGRectGetMinY(frame) < self.contentOffset.y + self.bounds.size.height);
	}
	
	/**
	 *  间距
	 */
	- (CGFloat)marginForType:(iCocosWaterflowViewMarginType)type
	{
	    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
	        return [self.delegate waterflowView:self marginForType:type];
	    } else {
	        return iCocosWaterflowViewDefaultMargin;
	    }
	}
	/**
	 *  总列数
	 */
	- (NSUInteger)numberOfColumns
	{
	    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
	        return [self.dataSource numberOfColumnsInWaterflowView:self];
	    } else {
	        return iCocosWaterflowViewDefaultNumberOfColumns;
	    }
	}
	/**
	 *  index位置对应的高度
	 */
	- (CGFloat)heightAtIndex:(NSUInteger)index
	{
	    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
	        return [self.delegate waterflowView:self heightAtIndex:index];
	    } else {
	        return iCocosWaterflowViewDefaultCellH;
	    }
	}
	
	#pragma mark - 事件处理
	- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
	{
	    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) return;
	    
	    // 获得触摸点
	    UITouch *touch = [touches anyObject];
	    //    CGPoint point = [touch locationInView:touch.view];
	    CGPoint point = [touch locationInView:self];
	    
	    __block NSNumber *selectIndex = nil;
	    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, iCocosWaterflowViewCell *cell, BOOL *stop) {
	        if (CGRectContainsPoint(cell.frame, point)) {
	            selectIndex = key;
	            *stop = YES;
	        }
	    }];
	    
	    if (selectIndex) {
	        [self.delegate waterflowView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
	    }
	}
复制代码
 

Cell.h文件

	
	 #import <UIKit/UIKit.h>
	 
	 @interface iCocosWaterflowViewCell : UIView
	 @property (nonatomic, copy) NSString *identifier;
	 @end
使用方法：

1:新建一个Cell模型

	#import <Foundation/Foundation.h>
	
	@interface iCocosShop : NSObject
	@property (nonatomic, assign) CGFloat w;
	@property (nonatomic, assign) CGFloat h;
	@property (nonatomic, copy) NSString *img;
	@property (nonatomic, copy) NSString *price;
	@end
2：定义一个集成自上面的Cell的Cell


	#import "iCocosWaterflowViewCell.h"
	@class iCocosWaterflowView, iCocosShop;
	
	@interface iCocosShopCell : iCocosWaterflowViewCell
	+ (instancetype)cellWithWaterflowView:(iCocosWaterflowView *)waterflowView;
	
	@property (nonatomic, strong) iCocosShop *shop;
	@end
实现这个Cell：


	#import "iCocosShopCell.h"
	#import "iCocosWaterflowView.h"
	#import "UIImageView+WebCache.h"
	#import "iCocosShop.h"
	
	@interface iCocosShopCell()
	@property (weak, nonatomic) UIImageView *imageView;
	@property (weak, nonatomic) UILabel *priceLabel;
	@end
	
	@implementation iCocosShopCell
	
	
	+ (instancetype)cellWithWaterflowView:(iCocosWaterflowView *)waterflowView
	{
	    static NSString *ID = @"SHOP";
	    iCocosShopCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
	    if (cell == nil) {
	        cell = [[iCocosShopCell alloc] init];
	        cell.identifier = ID;
	    }
	    return cell;
	}
	
	- (id)initWithFrame:(CGRect)frame
	{
	    self = [super initWithFrame:frame];
	    if (self) {
	        
	        UIImageView *imageView = [[UIImageView alloc] init];
	        [self addSubview:imageView];
	        self.imageView = imageView;
	        
	        UILabel *priceLabel = [[UILabel alloc] init];
	        priceLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
	        priceLabel.textAlignment = NSTextAlignmentCenter;
	        priceLabel.textColor = [UIColor whiteColor];
	        [self addSubview:priceLabel];
	        self.priceLabel = priceLabel;
	    }
	    return self;
	}
	
	- (void)setShop:(iCocosShop *)shop
	{
	    _shop = shop;
	    
	    self.priceLabel.text = shop.price;
	    [self.imageView sd_setImageWithURL:[NSURL URLWithString:shop.img] placeholderImage:[UIImage imageNamed:@"loading"]];
	}
	
	- (void)layoutSubviews
	{
	    [super layoutSubviews];
	    
	    self.imageView.frame = self.bounds;
	    
	    CGFloat priceX = 0;
	    CGFloat priceH = 25;
	    CGFloat priceY = self.bounds.size.height - priceH;
	    CGFloat priceW = self.bounds.size.width;
	    self.priceLabel.frame = CGRectMake(priceX, priceY, priceW, priceH);
	}
3:在控制器中直接使用：


		#import "iCocosShopsViewController.h"
		#import "iCocosShopCell.h"
		#import "iCocosWaterflowView.h"
		#import "iCocosShop.h"
		#import "MJExtension.h"
		#import "MJRefresh.h"
	
		@interface iCocosShopsViewController ()<iCocosWaterflowViewDataSource, iCocosWaterflowViewDelegate>
		@property (nonatomic, strong) NSMutableArray *shops;
		@property (nonatomic, weak) iCocosWaterflowView *waterflowView;
		@end
		
		@implementation iCocosShopsViewController
		
		- (NSMutableArray *)shops
		{
		    if (_shops == nil) {
		        self.shops = [NSMutableArray array];
		    }
		    return _shops;
		}
		
		- (void)viewDidLoad
		{
		    [super viewDidLoad];
		    
		    // 0.初始化数据
		    NSArray *newShops = [iCocosShop objectArrayWithFilename:@"2.plist"];
		    [self.shops addObjectsFromArray:newShops];
		    
		    // 1.瀑布流控件
		    iCocosWaterflowView *waterflowView = [[iCocosWaterflowView alloc] init];
		    waterflowView.backgroundColor = [UIColor redColor];
		    // 跟随着父控件的尺寸而自动伸缩
		    waterflowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		    waterflowView.frame = self.view.bounds;
		    waterflowView.dataSource = self;
		    waterflowView.delegate = self;
		    [self.view addSubview:waterflowView];
		    self.waterflowView = waterflowView;
		    
		    // 2.继承刷新控件
		//    [waterflowView addFooterWithCallback:^{
		//        NSLog(@"进入上拉加载状态");
		//    }];
		    
		//    [waterflowView addHeaderWithCallback:^{
		//        NSLog(@"进入下拉加载状态");
		    //    }];
		    
		    [waterflowView addHeaderWithTarget:self action:@selector(loadNewShops)];
		    [waterflowView addFooterWithTarget:self action:@selector(loadMoreShops)];
		}
		
		- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
		{
		//    NSLog(@"屏幕旋转完毕");
		    [self.waterflowView reloadData];
		}
		
		- (void)loadNewShops
		{
		    static dispatch_once_t onceToken;
		    dispatch_once(&onceToken, ^{
		        // 加载1.plist
		        NSArray *newShops = [iCocosShop objectArrayWithFilename:@"1.plist"];
		        [self.shops insertObjects:newShops atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newShops.count)]];
		    });
		    
		    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		        // 刷新瀑布流控件
		        [self.waterflowView reloadData];
		        
		        // 停止刷新
		        [self.waterflowView headerEndRefreshing];
		    });
		}
		
		- (void)loadMoreShops
		{
		    static dispatch_once_t onceToken;
		    dispatch_once(&onceToken, ^{
		        // 加载3.plist
		        NSArray *newShops = [iCocosShop objectArrayWithFilename:@"3.plist"];
		        [self.shops addObjectsFromArray:newShops];
		    });
		    
		    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		        
		        // 刷新瀑布流控件
		        [self.waterflowView reloadData];
		        
		        // 停止刷新
		        [self.waterflowView footerEndRefreshing];
		    });
		}
		
		#pragma mark - 数据源方法
		- (NSUInteger)numberOfCellsInWaterflowView:(iCocosWaterflowView *)waterflowView
		{
		    return self.shops.count;
		}
		
		- (iCocosWaterflowViewCell *)waterflowView:(iCocosWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index
		{
		    iCocosShopCell *cell = [iCocosShopCell cellWithWaterflowView:waterflowView];
		    
		    cell.shop = self.shops[index];
		    
		    return cell;
		}
		
		- (NSUInteger)numberOfColumnsInWaterflowView:(iCocosWaterflowView *)waterflowView
		{
		    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		        // 竖屏
		        return 3;
		    } else {
		        return 5;
		    }
		}
		
		#pragma mark - 代理方法
		- (CGFloat)waterflowView:(iCocosWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index
		{
		    iCocosShop *shop = self.shops[index];
		    // 根据cell的宽度 和 图片的宽高比 算出 cell的高度
		    return waterflowView.cellWidth * shop.h / shop.w;
		}
注：这里还需要引入第三方库和相应的工具类

