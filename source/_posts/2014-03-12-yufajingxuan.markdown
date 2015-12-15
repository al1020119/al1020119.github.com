---

layout: post
title: "语法精选"
date: 2014-03-12 13:53:19 +0800
comments: true
categories: Developer 

--- 

####一、NSSet、NSMutableSet集合的介绍

 

1）NSSet、NSMutableSet集合，元素是无序的，不能有重复的值。

 

2）用实例方法创建一个不可变集合对象



<!--more-->




例如：

	//宏定义
	#define TOBJ(n) [NSNumber numberWithInt:n]
	NSSet *set1=[[NSSet alloc]initWithObjects:TOBJ(2),TOBJ(3),TOBJ(3),TOBJ(1),TOBJ(5), nil];
2）用类方法创建一个不可变集合对象 例如：

1 NSSet *set2=[NSSet setWithObjects:TOBJ(2),TOBJ(4),TOBJ(6), nil];
 

3）NSSet 快速遍历方法（无序，所以没有下标）例如：

 

	1  for(id num in set1){
	2     NSLog(@"%@",num);
	3 }
 

4）setSet 用于修改集合内容 例如：[mSet setSet:set1];

5）intersectSet 用于获取两个集合的交集(返回两个集合中相同的元素)。例如：

	#define TOBJ(n) [NSNumber numberWithInt:n]
	NSSet *set1=[[NSSet alloc]initWithObjects:TOBJ(2),TOBJ(3),TOBJ(3),TOBJ(1),TOBJ(5), nil];
	NSSet *set2=[NSSet setWithObjects:TOBJ(2),TOBJ(4),TOBJ(6), nil];
	[mSet intersectSet:set2];
	NSLog(@"intersect:%@",mSet); //结果：2
 

6）unionSet 用于获取两个集合的并集(返回两个集合中所有的元素,如果重复只显示其中一个) 例如：

	1 #define TOBJ(n) [NSNumber numberWithInt:n]
	2 NSSet *set1=[[NSSet alloc]initWithObjects:TOBJ(2),TOBJ(3),TOBJ(3),TOBJ(1),TOBJ(5), nil];
	3 NSSet *set2=[NSSet setWithObjects:TOBJ(2),TOBJ(4),TOBJ(6), nil];
	4 [mSet intersectSet:set2];
	5 NSLog(@"intersect:%@",mSet); //结果：123456
 

7）minusSet 用于获取两个集合的差集 例如：

	1 #define TOBJ(n) [NSNumber numberWithInt:n]
	2 NSSet * mSet =[[NSSet alloc]initWithObjects:TOBJ(2),TOBJ(3),TOBJ(3),TOBJ(1),TOBJ(5), nil];
	3 NSSet *set2=[NSSet setWithObjects:TOBJ(2),TOBJ(4),TOBJ(6), nil];
	4 [mSet minusSet:set2];
	5 NSLog(@"intersect:%@",mSet); //结果：13456
 

8）allObjects 用于将集合转换为数组 例如：

	1 #define TOBJ(n) [NSNumber numberWithInt:n]
	2 NSSet * mSet =[[NSSet alloc]initWithObjects:TOBJ(2),TOBJ(3),TOBJ(3),TOBJ(1),TOBJ(5), nil];
	3 NSArray *array= [mSet allObjects];
 

9）anyObject 取set中任意一个元素（如果set中只有一个元素，取值）

	1 #define TOBJ(n) [NSNumber numberWithInt:n]
	2 NSSet * mSet =[[NSSet alloc]initWithObjects:TOBJ(2),TOBJ(3),TOBJ(3),TOBJ(1),TOBJ(5), nil];
	3 id value=[mSet anyObject];
 

####二、NSIndexSet、NSMutableIndexSet 可变索引集合的介绍

1）索引集合，表示唯一的整数的集合,有可变和不可变之分。

2）initWithIndexesInRange 用指定的范围对应的索引创建索引对象 例如：

	1 NSIndexSet *indexSet1=[[NSIndexSet alloc]initWithIndexesInRange:
	2 NSMakeRange(2,   3)];//结果 2,3,4
	3）objectsAtIndexes 根据索引集合中的索引取出数组中对应的元素（返回数组） 例如：
	
	1 NSIndexSet *indexSet1=[[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(2,   3)]; 
	2 NSArray *array=@[@"one",@"two",@"three",@"four",@"five",@"sex"];
	3 NSArray *array2=[array objectsAtIndexes:indexSet1];
	4 NSLog(@"array2:%@",array2); //结果：array2:three four five
 

4）创建一个可变的集合索引(初始化时有一个索引）(可以存储不连续的索引值） 例如：

	1 NSMutableIndexSet *indexSet2=[NSMutableIndexSet indexSetWithIndex:2];
	2 [indexSet2 addIndex:4];
	3 [indexSet2 addIndex:1];
	4 [indexSet2 addIndex:2];
	5 NSLog(@"count:%ld",indexSet2.count);//获取个数
	6 NSArray *array3=[array objectsAtIndexes:indexSet2];//结果：two three  five
 

5）NSNull:类表示空, 只有一个类方法[NSNull null]获取空对象，在数组中nil表示元素结束（不能用nil表示空元素

可采用[NSNull null]表示空元素） 例如：

 

	1 NSArray *array5=[NSArray arrayWithObjects:@"red",[NSNull null],@"yellow",@"blue", nil];
 

####三、Category 介绍

1）Category 意为： 类别、分类、类目

1、可以在不改变类名的情况下，扩充类的功能（给类增加方法）

2、可以将类的功能拆成多个文件编译

3、类别中不能增加成员变量，可以访问原来类中的成员变量

4、类别中可以增加与原来类中同名的方法，调用时优先调用

5、添加文件时选择Objective-C File 那个文件同时注意选择要拓展的类名

2）类别的声明类似于类的声明，@interface要扩充功能的类名（类别名）

1、类别不能实例化对象 

2、类别中不能增加成员变量。

3、类别中的方法可以访问原来类中的成员变量

4、类别可以调用原来类中的方法

5、类别中的方法可以被子类继承

6、类别可以添加与原来类中相同的方法，调用时类别中的方法优先调用，一般不建议这样操作（无法再调用原来类中的方法）

3）字符串、NSNumber是簇类，底层是由很多类组成的，不能有子类 ,因为子类调用不了父类中的方法

4）Category 文件名格式为：父类文件名+子类文件名 如：NSMutaleString+Resvrse.h

5）Category .m文件中的方法表现形式： 1 @implementation NSMutableString (Reverse) 

 

####四、Extension 的介绍

1）extension：相当于未命名的Category，可以扩展类的功能（增加方法），也可以增加成员变量。

2）extension：只有.h文件

3）extension  表现形式 @interface 类名（）例如： 1 @interface Person (){} 

4）在.m文件中也可以声明成员变量，不会将其放在接口h文件中暴露给使用者。 例如：

	复制代码
	1 @interface Person()
	2 { 
	3     int _num;
	4 }
	5 //将方法声明为私有的
	6 -(void)print2;
	7 @end
	复制代码
 

####五、SEL的介绍

1）SEL是一种类型，将方法名封装为sel的变量，通过SEL找到方法的地址，调用方法。

2）SEL 封装方法实例代码：

	复制代码
	1  //将play方法名封装成SEL类型的数据
	2 SEL sel=@selector(play);
	3  //判断p1所属的类是否实现了sel中的方法
	4 if([p1 respondsToSelector:sel]){
	5  //p1查找sel中方法的地址，再调用对应的方法
	6 [p1 performSelector:sel];
	7  }
	复制代码
3）performSelector 用于执行SEL封装的方法 例如： 1 [p1 performSelector:@selector(jump)]; 

4)SEL 封装带参数的方法实例代码：

	1  //将带一个参数的方法封装为SEL的变量，执行，参数是id类型
	2  [p1 performSelector:@selector(print:) withObject:@"hello"];
 

5)NSSelectorFromString 用于将字符串形式的方法名封装成SEL的数据 实例代码：

 

	1  SEL sel2=NSSelectorFromString(@"study");
	2  [p1 performSelector:sel2];
 

6）_cmd 表示当前执行的方法 例如： 1NSLog(@"*****metheod:%@",NSStringFromSelector(_cmd));  

7)在C语言中 __func 表示获取当前执行方法 例如： 1 NSLog(@"func=%s",__func__);  

	__DATE__ 表示获取当前系统时间  1 NSLog(@"date=%s",__DATE__); 

8）SEL实现数组排序 实例代码： 

	复制代码
	1 void testSel()
	2 {
	3     Person *p1;
	4     Person *p2;
	5     Person *p3;
	6     NSMutableArray *array1=[[NSMutableArray alloc]initWithObjects:p1,p2,p3, nil];
	7     [array1 sortUsingSelector:@selector(comparePerson:)];
	8     
	9 }
	复制代码
 

####六、构造OC中的二维数组

实例代码：

	复制代码
	//创建一个空的外层数组
	 2         NSMutableArray *bigArray=[NSMutableArray array];
	 3         //创建一个存放4个数据对象的数组
	 4         NSMutableArray *array1=[[NSMutableArray alloc]init];
	 5         for(int i=0;i<4;i++){
	 6             [array1 addObject:[NSNumber numberWithInt:i]];
	 7         }
	 8         //创建一个存放3个字符串的数组
	 9         NSMutableArray *array2=[[NSMutableArray alloc]init];
	10         for(int i=0;i<3;i++){
	11             [array2 addObject:[NSString stringWithFormat:@"str%d",i+1]];
	12         }
	13         //将array1和array2两个数组对象存入外层数组（相当于创建了一个二维数组）
	14         [bigArray addObject:array1];
	15         [bigArray addObject:array2];
	16         
	17         //遍历，显示所有的元素
	18         for(int i=0;i<bigArray.count;i++){
	19             for(int j=0;j<[bigArray[i] count];j++){
	20                 //取出数组中第i行第j列的元素（每行又是一个数组对象）
	21                 if([bigArray[i][j] isKindOfClass:[NSNumber class]]){
	22                     NSLog(@"number:%@",bigArray[i][j]);
	23                 }
	24                 else if ([[[bigArray objectAtIndex:i] objectAtIndex:j] isKindOfClass:[NSString class]]){
	25                     NSLog(@"string:%@",[[bigArray objectAtIndex:i] objectAtIndex:j]);
	26                 }
	27             }
	28         }
	复制代码
####七、Class (类)的介绍

 

1）类的本质也是一个对象，是Class类型的对象，获取类对象（可以通过实例方法或类方法获取）,

每个类只有一个类对象。

2）load 方法当程序启动时会加载所有的类和分类，调用load方法，先加载父类，再加载子类，然后是分类 例如：

	1  +(void)load
	2  {
	3      NSLog(@"Person---load");
	4  }
 

3）initialize方法 当第一次使用类的时候，调用initialize方法，先调用父类的，再调用子类的 例如：

 

	1 +(void)initialize
	2  {
	3     NSLog(@"Person---initialize");
	4  }
本博文由博主（iCocos）独立编写或者借鉴别人的好文章进行修改而成，如果不对的地方望指正，谢谢！ 如果您还有看到新浪博客关于IOS梦工厂的博文，麻烦请到这里找更完整更清晰的版本，博主已从http://blog.sina.com.cn/s/articlelist_3288975567_0_1.html转移到博客园