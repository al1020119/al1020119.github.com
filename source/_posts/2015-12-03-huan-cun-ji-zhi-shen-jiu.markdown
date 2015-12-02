---

layout: post
title: "自己写套缓存机制"
date: 2015-12-03 02:59:42 +0800
comments: true
categories: 底层开发

---


*  前言

大家都知道UITableView，最经典在于循环利用，这里我自己模仿UITableView循环利用,写了一套自己的TableView实现方案，希望大家看了我的文章，循环利用思想有显著提升。

 

##一： 研究UITableView底层实现

#####1.系统UITabelView的简单使用，这里就不考虑分组了，默认为1组。

  
	 1 // 返回第section组有多少行
	 2 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	 3 {
	 4     NSLog(@"%s",__func__);
	 5     return 10;
	 6 }
	 7  
	 8 // 返回每一行cell的样子
	 9 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	10 {
	11     NSLog(@"%s",__func__);
	12     static NSString *ID = @"cell";
	13     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
	14      
	15     if (cell == nil) {
	16          
	17         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
	18     }
	19      
	20     cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
	21      
	22     return cell;
	23 }
	24 // 返回每行cell的高度
	25 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
	26 {
	27     NSLog(@"%s--%@",__func__,indexPath);
	28     return 100;
	29 } 
 

#####2.验证UITabelView的实现机制。

如图打印结果:


{% img /images/huancun001.png Caption %}  

* 分析：底层先获取有多少cell（10个），在获取每个cell的高度，返回高度的方法一开始调用10次。

	- 目的：确定tableView的滚动范围，一开始计算所有cell的frame,就能计算下tableView的滚动范围。

* 分析：tableView:cellForRowAtIndexPath:方法什么时候调用。

打印验证，如图：

{% img /images/huancun002.png Caption %}  

一开始调用了7次，因为一开始屏幕最多显示7个cell

	- 目的：一开始只加载显示出来的cell，等有新的cell出现的时候会继续调用这个方法加载cell。

#####3.UITableView循环利用思想

当新的cell出现的时候，首先从缓存池中获取，如果没有获取到，就自己创建cell。

当有cell移除屏幕的时候，把cell放到缓存池中去。

##二、自定义UIScroolView，模仿UITableView循环利用

#####1.提供数据源和代理方法，命名和UITableView一致。

  
	 1 @class YZTableView;
	 2 @protocol YZTableViewDataSource
	 3  
	 4 @required
	 5  
	 6 // 返回有多少行cell
	 7 - (NSInteger)tableView:(YZTableView *)tableView numberOfRowsInSection:(NSInteger)section;
	 8  
	 9  
	10 // 返回每行cell长什么样子
	11 - (UITableViewCell *)tableView:(YZTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
	12  
	13 @end
	14  
	15 @protocol YZTableViewDelegate
	16  
	17 // 返回每行cell有多高
	18 - (CGFloat)tableView:(YZTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
	19  
	20 @end 
 

#####2.提供代理和数据源属性

  
	1 @interface YZTableView : UIScrollView
	2  
	3 @property (nonatomic, weak) id dataSource;
	4  
	5 @property (nonatomic, weak) id delegate;
	6  
	7 @end 
 

警告:


{% img /images/huancun003.png Caption %}  

解决，在YZTableView.m的实现中声明。


{% img /images/huancun004.png Caption %}  

+ 原因：有人会问为什么我要定义同名的delegate属性，我主要想模仿系统的tableView，系统tableView也有同名的属性。

 	- 思路：这样做，外界在使用设置我的tableView的delegate，就必须遵守的我的代理协议，而不是UIScrollView的代理协议。

#####3.提供刷新方法reloadData，因为tableView通过这个刷新tableView。

  
	 1 @interface YZTableView : UIScrollView
	 2  
	 3 @property (nonatomic, weak) id dataSource;
	 4  
	 5 @property (nonatomic, weak) id delegate;
	 6  
	 7 // 刷新tableView
	 8 - (void)reloadData;
	 9  
	10 @end 
 

#####4.实现reloadData方法，刷新表格

回顾系统如何刷新tableView

+ 1).先获取有多少cell,在获取每个cell的高度。因此应该是先计算出每个cell的frame.

+ 2).然后再判断当前有多少cell显示在屏幕上，就加载多少

***
  
	 1 // 刷新tableView
	 2 - (void)reloadData
	 3 {
	 4     // 这里不考虑多组，假设tableView默认只有一组。
	 5      
	 6     // 先获取总共有多少cell
	 7     NSInteger rows = [self.dataSource tableView:self numberOfRowsInSection:0];
	 8      
	 9     // 遍历所有cell的高度，计算每行cell的frame
	10     CGRect cellF;
	11     CGFloat cellX = 0;
	12     CGFloat cellY = 0;
	13     CGFloat cellW = self.bounds.size.width;
	14     CGFloat cellH = 0;
	15     CGFloat totalH = 0;
	16      
	17     for (int i = 0; i < rows; i++) {
	18         
	19         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
	20         // 注意：这里获取的delegate，是UIScrollView中声明的属性
	21         if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
	22             cellH = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
	23         }else{
	24             cellH = 44;
	25         }
	26         cellY = i * cellH;
	27          
	28         cellF = CGRectMake(cellX, cellY, cellW, cellH);
	29          
	30         // 记录每个cell的y值对应的indexPath
	31         self.indexPathDict[@(cellY)] = indexPath;
	32          
	33         // 判断有多少cell显示在屏幕上,只加载显示在屏幕上的cell
	34         if ([self isInScreen:cellF]) { // 当前cell的frame在屏幕上
	35             // 通过数据源获取cell
	36             UITableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
	37              
	38             cell.frame = cellF;
	39              
	40             [self addSubview:cell];
	41              
	42         }
	43          
	44         // 添加分割线
	45         UIView *divideV = [[UIView alloc] initWithFrame:CGRectMake(0, cellY + cellH - 1, cellW, 1)];
	46         divideV.backgroundColor = [UIColor lightGrayColor];
	47         divideV.alpha = 0.3;
	48         [self addSubview:divideV];
	49          
	50         // 添加到cell可见数组中
	51             [self.visibleCells addObject:cell];
	52          
	53         // 计算tableView内容总高度
	54         totalH += cellY + cellH;
	55      
	56     }
	57      
	58     // 设置tableView的滚动范围
	59     self.contentSize = CGSizeMake(self.bounds.size.width, totalH);
	60      
	61 } 
 

#####5.如何判断cell显示在屏幕上

当tableView内容往下走


{% img /images/huancun005.gif Caption %}  

当tableView内容往上走


{% img /images/huancun006.gif Caption %}  

  
	 1 // 根据cell尺寸判断cell在不在屏幕上
	 2 - (BOOL)isInScreen:(CGRect)cellF
	 3 {
	 4     // tableView能滚动，因此需要加上偏移量判断
	 5      
	 6     // 当tableView内容往下走，offsetY会一直增加 ,cell的最大y值 < offsetY偏移量   ,cell移除屏幕
	 7     // tableView内容往上走 , offsetY会一直减少，屏幕的最大Y值 <  cell的y值 ，Cell移除屏幕
	 8     // 屏幕最大y值 = 屏幕的高度 + offsetY
	 9      
	10     // 这里拿屏幕来比较，其实是因为tableView的尺寸我默认等于屏幕的高度，正常应该是tableView的高度。
	11     // cell在屏幕上， cell的最大y值 > offsetY && cell的y值 < 屏幕的最大Y值(屏幕的高度 + offsetY)
	12      
	13     CGFloat offsetY = self.contentOffset.y;
	14      
	15     return CGRectGetMaxY(cellF) > offsetY && cellF.origin.y < self.bounds.size.height + offsetY;
	16  
	17     } 
 

#####6.在滚动的时候，如果有新的cell出现在屏幕上，先从缓存池中取，没有取到，在创建新的cell.

+ 分析：

需要及时监听tableView的滚动，判断下有没有新的cell出现。

大家都会想到scrollViewDidScroll方法，这个方法只要一滚动scrollView就会调用，但是这个方法有个弊端，就是tableView内部需要作为自身的代理，才能监听，这样不好，有时候外界也需要监听滚动，因此自身类最好不要成为自己的代理。（设计思想）

  + 解决：

重写layoutSubviews，判断当前哪些cell显示在屏幕上。

因为只要一滚动，就会修改contentOffset,就会调用layoutSubviews，其实修改contentOffset，内部其实是修改tableView的bounds,而layoutSubviews刚好是父控件尺寸一改就会调用.具体需要了解scrollView底层实现。

+ 思路：

判断下，当前tableView内容往上移动，还是往下移动，如何判断，取出显示在屏幕上的第一次cell，当前偏移量 > 第一个cell的y值，往下走。

需要搞个数组记录下，当前有多少cell显示在屏幕上，在一开始的时候记录.

  
	 1 @interface YZTableView ()
	 2  
	 3 @property (nonatomic, strong) NSMutableArray *visibleCells;
	 4  
	 5 @end
	 6  
	 7 @implementation YZTableView
	 8  
	 9 @dynamic delegate;
	10  
	11 - (NSMutableArray *)visibleCells
	12 {
	13  
	14     if (_visibleCells == nil) {
	15         _visibleCells = [NSMutableArray array];
	16     }
	17     return _visibleCells;
	18      
	19 }
	20 @end 
 

###往下移动

* 1.如果已经滚动到tableView内容最底部，就不需要判断新的cell，直接返回.

* 2.需要判断之前显示在屏幕cell有没有移除屏幕

* 3.只需要判断下当前可见cell数组中第一个cell有没有离开屏幕

* 4.只需要判断下当前可见cell数组中最后一个cell的下一个cell显没显示在屏幕上即可。

***
  
	 1 // 判断有没有滚动到最底部
	 2         if (offsetY + self.bounds.size.height > self.contentSize.height) {
	 3             return;
	 4         }
	 5          
	 6         // 判断下当前可见cell数组中第一个cell有没有离开屏幕
	 7         if ([self isInScreen:firstCell.frame] == NO) { // 如果不在屏幕
	 8             // 从可见cell数组移除
	 9             [self.visibleCells removeObject:firstCell];
	10              
	11             // 删除第0个从可见的indexPath
	12             [self.visibleIndexPaths removeObjectAtIndex:0];
	13              
	14             // 添加到缓存池中
	15             [self.reuserCells addObject:firstCell];
	16              
	17             // 移除父控件
	18             [firstCell removeFromSuperview];
	19              
	20         }
	21         // 判断下当前可见cell数组中最后一个cell的下一个cell显没显示在屏幕上
	22         // 这里需要计算下一个cell的y值，需要获取对应的cell的高度
	23         // 而高度需要根据indexPath，从数据源获取
	24         // 可以数组记录每个可见cell的indexPath的顺序,然后获取对应可见的indexPath的角标，就能获取下一个indexPath.
	25          
	26         // 获取最后一个cell的indexPath
	27         NSIndexPath *indexPath = [self.visibleIndexPaths lastObject];
	28          
	29         // 获取下一个cell的indexPath
	30         NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
	31          
	32         // 获取cell的高度
	33         if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
	34             cellH = [self.delegate tableView:self heightForRowAtIndexPath:nextIndexPath];
	35         }else{
	36             cellH = 44;
	37         }
	38          
	39         // 计算下一个cell的y值
	40         cellY = lastCellY + cellH;
	41          
	42         // 计算下下一个cell的frame
	43         CGRect nextCellFrame = CGRectMake(cellX, cellY, cellW, cellH);
	44          
	45         if ([self isInScreen:nextCellFrame]) { // 如果在屏幕上，就加载
	46              
	47             // 通过数据源获取cell
	48             UITableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:nextIndexPath];
	49              
	50             cell.frame = nextCellFrame;
	51              
	52             [self insertSubview:cell atIndex:0];
	53              
	54             // 添加到cell可见数组中
	55             [self.visibleCells addObject:cell];
	56              
	57             // 添加到可见的indexPaths数组
	58             [self.visibleIndexPaths addObject:nextIndexPath];
	59              
	60              
	61         } 
	 

###往上移动

* 1.如果已经滚动到tableView最顶部，就不需要判断了有没有心的cell，直接返回.

* 2.需要判断之前显示在屏幕cell有没有移除屏幕

* 3.只需要判断下当前可见cell数组中最后一个cell有没有离开屏幕

* 4.只需要判断下可见cell数组中第一个cell的上一个cell显没显示在屏幕上即可

注意点：如果可见cell数组中第一个cell的上一个cell显示到屏幕上，一定要记得是插入到可见数组第0个的位置。

  
	 1 // 判断有没有滚动到最顶部
	 2         if (offsetY < 0) {
	 3             return;
	 4         }
	 5          
	 6          
	 7          
	 8         // 判断下当前可见cell数组中最后一个cell有没有离开屏幕
	 9         if ([self isInScreen:lastCell.frame] == NO) { // 如果不在屏幕
	10             // 从可见cell数组移除
	11             [self.visibleCells removeObject:lastCell];
	12              
	13             // 删除最后一个可见的indexPath
	14             [self.visibleIndexPaths removeLastObject];
	15              
	16             // 添加到缓存池中
	17             [self.reuserCells addObject:lastCell];
	18              
	19             // 移除父控件
	20             [lastCell removeFromSuperview];
	21              
	22         }
	23          
	24         // 判断下可见cell数组中第一个cell的上一个cell显没显示在屏幕上
	25         // 获取第一个cell的indexPath
	26         NSIndexPath *indexPath = self.visibleIndexPaths[0];
	27          
	28          
	29         // 获取下一个cell的indexPath
	30         NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
	31          
	32         // 获取cell的高度
	33         if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
	34             cellH = [self.delegate tableView:self heightForRowAtIndexPath:preIndexPath];
	35         }else{
	36             cellH = 44;
	37         }
	38          
	39         // 计算上一个cell的y值
	40         cellY = firstCellY - cellH;
	41          
	42          
	43         // 计算上一个cell的frame
	44         CGRect preCellFrame = CGRectMake(cellX, cellY, cellW, cellH);
	45          
	46         if ([self isInScreen:preCellFrame]) { // 如果在屏幕上，就加载
	47              
	48             // 通过数据源获取cell
	49             UITableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:preIndexPath];
	50              
	51             cell.frame = preCellFrame;
	52              
	53             [self insertSubview:cell atIndex:0];
	54              
	55             // 添加到cell可见数组中,这里应该用插入，因为这是最上面一个cell,应该插入到数组第0个
	56             [self.visibleCells insertObject:cell atIndex:0];
	57              
	58             // 添加到可见的indexPaths数组,这里应该用插入，因为这是最上面一个cell,应该插入到数组第0个
	59             [self.visibleIndexPaths insertObject:preIndexPath atIndex:0];
	60              
	61         }
	62          
	63     } 
 

+ 问题1：

判断下当前可见cell数组中最后一个cell的下一个cell显没显示在屏幕上

这里需要计算下一个cell的frame,frame就需要计算下一个cell的y值，需要获取对应的cell的高度 cellY = lastCellY + cellH

而高度需要根据indexPath，从数据源获取

+ 解决：

可以搞个字典记录每个可见cell的indexPath,然后获取对应可见的indexPath，就能获取下一个indexPath.

  
	 1 @interface YZTableView ()
	 2  
	 3 // 屏幕可见数组
	 4 @property (nonatomic, strong) NSMutableArray *visibleCells;
	 5  
	 6 // 缓存池
	 7 @property (nonatomic, strong) NSMutableSet *reuserCells;
	 8  
	 9  
	10 // 记录每个可见cell的indexPaths的顺序
	11 @property (nonatomic, strong) NSMutableDictionary *visibleIndexPaths;
	12  
	13 @end
	14  
	15 - (NSMutableDictionary *)visibleIndexPaths
	16 {
	17     if (_visibleIndexPaths == nil) {
	18         _visibleIndexPaths = [NSMutableDictionary dictionary];
	19     }
	20      
	21     return _visibleIndexPaths;
	22 } 
 

#####注意：

当cell从缓存池中移除，一定要记得从可见数组cell中移除，还有可见cell的indexPath也要移除.

  
	 1 // 判断下当前可见cell数组中第一个cell有没有离开屏幕
	 2         if ([self isInScreen:firstCell.frame] == NO) { // 如果不在屏幕
	 3             // 从可见cell数组移除
	 4             [self.visibleCells removeObject:firstCell];
	 5              
	 6             // 删除第0个从可见的indexPath
	 7             [self.visibleIndexPaths removeObjectAtIndex:0];
	 8              
	 9             // 添加到缓存池中
	10             [self.reuserCells addObject:firstCell];
	11              
	12         }
	13          
	14  // 判断下当前可见cell数组中最后一个cell有没有离开屏幕
	15         if ([self isInScreen:lastCell.frame] == NO) { // 如果不在屏幕
	16             // 从可见cell数组移除
	17             [self.visibleCells removeObject:lastCell];
	18              
	19             // 删除最后一个可见的indexPath
	20             [self.visibleIndexPaths removeLastObject];
	21              
	22             // 添加到缓存池中
	23             [self.reuserCells addObject:lastCell];
	24              
	25         } 
 

#####7.缓存池搭建，缓存池其实就是一个NSSet集合。

搞一个NSSet集合充当缓存池.

cell离开屏幕，放进缓存池

提供从缓存池获取方法，从缓存池中获取cell,记住要从NSSet集合移除cell.

  
	 1 @interface YZTableView ()
	 2  
	 3 // 屏幕可见数组
	 4 @property (nonatomic, strong) NSMutableArray *visibleCells;
	 5  
	 6 // 缓存池
	 7 @property (nonatomic, strong) NSMutableSet *reuserCells;
	 8  
	 9 // 记录每个cell的y值都对应一个indexPath
	10 @property (nonatomic, strong) NSMutableDictionary *indexPathDict;
	11  
	12 @end
	13 @implementation YZTableView
	14 - (NSMutableSet *)reuserCells
	15 {
	16     if (_reuserCells == nil) {
	17         _reuserCells = [NSMutableSet set];
	18     }
	19     return _reuserCells;
	20 }
	21  
	22 // 从缓存池中获取cell
	23 - (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
	24 {
	25     UITableViewCell *cell = [self.reuserCells anyObject];
	26      
	27     // 能取出cell,并且cell的标示符正确
	28     if (cell && [cell.reuseIdentifier isEqualToString:identifier]) {     
	29         // 从缓存池中获取
	30         [self.reuserCells removeObject:cell];
	31          
	32         return cell;
	33     }
	34     return nil;
	35 }
	36  
	37 @end 
 

#####8.tableView细节处理

原因：刷新方法经常要调用

解决：每次刷新的时候，先把之前记录的全部清空

 
	 1 // 刷新tableView
	 2 - (void)reloadData
	 3 {
	 4      
	 5     // 刷新方法经常要调用
	 6     // 每次刷新的时候，先把之前记录的全部清空
	 7     // 清空indexPath字典
	 8     [self.indexPathDict removeAllObjects];
	 9     // 清空屏幕可见数组
	10     [self.visibleCells removeAllObjects];
	11     ...
	12 } 
	
	

<!--more-->