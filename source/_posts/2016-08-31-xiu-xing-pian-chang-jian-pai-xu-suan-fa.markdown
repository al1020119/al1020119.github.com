---
layout: post
title: "修行篇-八大排序算法"
date: 2016-08-16 12:31:14 +0800
comments: true
categories: Algorithms and Data Structures
---

常用排序算法

>这里我们大概按照重要性的先后顺序介绍

##快速排序

+ 快速排序是不稳定的，其时间平均时间复杂度是O ( nlgn )。

+ 快速排序采用的思想是分治思想。


思路:快速排序是找出一个元素（理论上可以随便找一个）作为基准(pivot),然后对数组进行分区操作,使基准左边元素的值都不大于基准值,基准右边的元素值 都不小于基准值，如此作为基准的元素调整到排序后的正确位置。递归快速排序，将其他n-1个元素也调整到排序后的正确位置。最后每个元素都是在排序后的正 确位置，排序完成。所以快速排序算法的核心算法是分区操作，即如何调整基准的位置以及调整返回基准的最终位置以便分治递归。
 
<!--more-->



伪代码
 
	void quickSort(int a[], int len, int left, int right) {
	   // 所有都排序完毕了，就退出递归
	   if left >= right {
	     return;
	   }
	   
	   // 每一趟划分，使左边的比基准小，右边的比基准大，并返回新的基准的位置
	   int baseIndex = partition(a, len, left, right);
	   
	   // 递归排序左部分
	   quickSort(a, len, left, baseIndex - 1);
	   // 递归排序右部分
	   quickSort(a, len, baseIndex + 1, right)
	}
	 
	int partition(int a[], int len, int left, int right) {
	   // 记录哪个是基准数
	   int base = a[left];
	   // 记录当前基准数的位置
	   int baseIndex = left;
	   
	   while left < right {
	     // 先从右边往左边扫描，找到第一个比base还要小的数，但是不能与left相遇
	     while left < right && a[right] >= base {
	       right--;
	     }
	     
	     // 再从左边往右边扫描，找到第一个比base还要大的数，但是不能与right相遇
	     while left < right && a[left] <= base {
	       left++;
	     }
	     
	     // 将所扫描到的第一个比基准数小和第一个比基准数大的数交换
	     swap(a, left, right);
	   }
	   
	   // 交换left与baseIndex对应的元素，将left位置的元素作为新的基准数
	   swap(a, baseIndex, left);
	   
	   // 返回新的基准位置
	   return left;
	}
	 
	void swap(int a[], int i, int j) {
	   int temp = a[i];
	   
	   a[i] = a[j];
	   a[j] = temp;
	}
 
C语言版
 
	void quickSort(int a[], int len, int left, int right) {
	  if (left >= right) {
	    return;
	  }
	  
	  // 一次划分后，得到基准数据的位置
	 int baseIndex = partition(a, len, left, right);
	  
	  // 快排左边部分
	  quickSort(a, len, left, baseIndex - 1);
	  // 快排右边部分
	  quickSort(a, len, baseIndex + 1, right);
	}
	 
	int partition(int a[], int len, int left, int right) {
	  // 每一次的划分，都让第一个元素作为基准
	  int base = a[left];
	  // 记下刚开始的基准的位置， 便于最后相遇时交换
	  int baseIndex = left;
	  
	  while (left < right) {
	    // 查找右部分比base还小的元素的下标
	    while (left < right && a[right] >= base) {
	      right--;
	    }
	    
	    // 查找左部分比base还大的元素的下标
	    while (left < right && a[left] <= base) {
	      left++;
	    }
	    
	    // 将这一趟比基准大和比基准小的所找到的第一个值，互相交换
	    swap(a, left, right);
	  }
	  
	  // 在left与right相遇时，将基准数与相遇点交换
	  // 这样这一次划分，就可以保证左边的比基准数小，右边的比基准数大
	  swap(a, baseIndex, left);
	  
	  // 划分完成后，以left位置的元素作为新的基准，分成左右序列，分别递归排序
	  return left;
	}
	 
	void swap(int a[], int i, int j) {
	  int temp = a[i];
	  a[i] = a[j];
	  a[j] = temp;
	}
 
Swift版	
 
	func quickSort(inout a: [Int], left: Int, right: Int) {
	  if left >= right {
	    return
	  }
	  
	  let baseIndex = partition(&a, left: left, right: right)
	  
	  quickSort(&a, left: left, right: baseIndex - 1)
	  quickSort(&a, left: baseIndex + 1, right: right)
	}
	 
	func partition(inout a: [Int], var left: Int, var right: Int) ->Int {
	  let base = a[left]
	  let baseIndex = left
	  
	  while left < right {
	    while left < right && a[right] >= base {
	      right--
	    }
	    
	    while left < right && a[left] <= base {
	      left++
	    }
	    
	    swapInt(&a, i: left, j: right)
	  }
	  
	  swapInt(&a, i: baseIndex, j: left)
	  
	  return left
	}
	 
	func swapInt(inout a: [Int], i: Int, j: Int) {
	  let temp = a[i]
	  a[i] = a[j]
	  a[j] = temp
	}
 


===


##冒泡排序


算法思路：冒泡排序的核心思想就是通过与相邻元素的比较和交换，把小的数交换到最前面。因为这个过程类似于水泡向上升一样，因此被命名为冒泡排序。

> 冒泡排序需要两个循环来控制遍历，也就是需要n * n趟才能判断、交换完成。

冒泡排序的时间复杂度为O ( n2 )。

伪代码
 
	void bubbleSort(int a[], int len) {
	   for i = 0; i < len - 1; ++i {
	      for j = len - 1; j > i; --j {
	         if a[j] < a[j - 1] {
	            swap(a, j, j - 1);
	         }
	      }
	   }
	}
	 
	void swap(int a[], int i, int j) {
	   int temp = a[i];
	   a[i] = a[j];
	   a[j] = temp;
	}
 
C语言版
 
	void bubbleSortUsingC(int arr[], int len) {
	  // 代表走多少趟，最后一趟就不用再走了
	  for (int i = 0; i < len - 1; ++i) {
	    
	    // 从后往前走，相当于泡从水底冒出来到水面
	    for (int j = len - 1; j > i; --j) {
	      
	      // 如果后面的比前面一个的值还要小，则需要交换
	      if (arr[j] < arr[j - 1]) {
	        swap(arr, j, j - 1);
	      }
	    }
	  }
	}
	 
	void swap(int arr[], int i, int j) {
	  int temp = arr[i];
	  arr[i] = arr[j];
	  arr[j] = temp;
	}
 

测试一下：
 
	int a[5] = {5,3,8,6,4};
	  
	bubbleSortUsingC(a, sizeof(a) / sizeof(int));
	 
	for (int i = 0; i < sizeof(a) / sizeof(int); ++i) {
	    NSLog(@"%d", a[i]);
	}
	 
	// 打印: 3, 4, 5, 6, 8 初步如期效果
	 
	ObjC版
	 
	- (void)bubbleSort:(int [])array len:(size_t)len {
	  for (size_t i = 0; i < len - 1; ++i) {
	    for (size_t j = len - 1; j > i; --j) {
	      if (array[j] < array[j - 1]) {
	        // 交换
	        int temp = array[j];
	        array[j] = array[j - 1];
	        array[j - 1] = temp;
	      }
	    }
	  }
	}
 

测试使用：
 
int a[5] = {5,3,8,6,4};
[self bubbleSort:a len:sizeof(a) / sizeof(int)];
for (int i = 0; i < sizeof(a) / sizeof(int); ++i) {
    NSLog(@"%d", a[i]);
}
 
Swift版
 
	func bubbleSort(var arr: [Int]) ->[Int] {
	  // 走多少趟
	  for var i = 0; i < arr.count - 1; ++i {
	    
	    // 从后往前
	    for var j = arr.count - 1; j > i; --j {
	      
	      // 后者 < 前者 ？ 交换 ： 不交换
	      if arr[j] < arr[j - 1] {
	        let temp = arr[j]
	        
	        arr[j] = arr[j - 1]
	        arr[j - 1] = temp
	      }
	    }
	  }
	  
	  return arr
	}
 

测试使用：
 
	// 由于swift中数组也是结构体，是值类型，因此需要接收返回值才能得到排序后的数组
	var arr = [5, 3, 8, 6, 4]
	arr = bubbleSort(arr)
	print(arr)
	 
	尝试给Model排序
	
	- (void)bubbleSort:(NSMutableArray *)array {
	  for (NSUInteger i = 0; i < array.count - 1; ++i) {
	    
	    for (NSUInteger j = array.count - 1; j > i; --j) {
	      HYBTestModel *modelj = [array objectAtIndex:j];
	      HYBTestModel *modelj_1 = [array objectAtIndex:j - 1];
	      
	      // 前者 < 后者 ？ 交换 ： 不交换
	      if ([modelj.uid compare:modelj_1.uid options:NSCaseInsensitiveSearch] == NSOrderedAscending) {
	        [array exchangeObjectAtIndex:j withObjectAtIndex:j - 1];
	      }
	    }
	  }
	}
 

测试：
 
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < 10; ++i) {
	  HYBTestModel *model = [[HYBTestModel alloc] init];
	  model.title = [NSString stringWithFormat:@"标哥的技术博客：%ld", 10 - (i + 1)];
	  model.uid = [NSString stringWithFormat:@"%ld", 10 - (i + 1)];
	  
	  [array addObject:model];
	}
	 
	[self bubbleSort:array];
	 
	for (HYBTestModel *model in array) {
	  NSLog(@"%@ %@", model.uid, model.title);
	}
 
// 打印:

	2016-03-10 22:57:37.524 DataAgorithmDemos[96148:3779265] 0 标哥的技术博客：0
	2016-03-10 22:57:37.526 DataAgorithmDemos[96148:3779265] 1 标哥的技术博客：1
	2016-03-10 22:57:37.526 DataAgorithmDemos[96148:3779265] 2 标哥的技术博客：2
	2016-03-10 22:57:37.526 DataAgorithmDemos[96148:3779265] 3 标哥的技术博客：3
	2016-03-10 22:57:37.582 DataAgorithmDemos[96148:3779265] 4 标哥的技术博客：4
	2016-03-10 22:57:37.588 DataAgorithmDemos[96148:3779265] 5 标哥的技术博客：5
	2016-03-10 22:57:37.589 DataAgorithmDemos[96148:3779265] 6 标哥的技术博客：6
	2016-03-10 22:57:37.593 DataAgorithmDemos[96148:3779265] 7 标哥的技术博客：7
	2016-03-10 22:57:37.594 DataAgorithmDemos[96148:3779265] 8 标哥的技术博客：8
	2016-03-10 22:57:37.596 DataAgorithmDemos[96148:3779265] 9 标哥的技术博客：9
 

说明排序正常的~

##选择排序

+ 选择排序:的思想其实和冒泡排序有点类似，都是在一次排序后把最小的元素放到最前面。但是过程不同，冒泡排序是通过相邻的比较和交换。而选择排序是通过对整体的选择

算法思想：每一趟从前往后查找出值最小的索引（下标），最后通过比较是否需要交换。每一趟都将最小的元素交换到最前面。

其实选择排序可以看成是冒泡排序的优化，因为其目的相同，只是选择排序只有在确定了最小数的前提下才进行交换，大大减少了交换的次数，而比较次数是一样的。

> 注意：冒泡排序是从后往前扫，使大的往下沉，而小的往上浮；选择排序是从前往后扫，每趟找出值最小的索引，使每趟最小值都交换到该趟的最前面，从而得到升序序列


选择排序可以看作冒泡排序的优化版本，一样要两层循环才能排序完成。

所以，选择排序的时间复杂度为O ( n2 )

伪代码
 
	void selectSort(int arr[], int len) {
	  int min = 0;
	  
	  // 只需要n-1趟即可，到最后一趟只有一个元素，一定是最小的了
	  for i = 0; i < len - 1; ++i {
	  
	    // 每一趟的开始，假设该趟的第一个元素是最小的
	    min = i;
	    
	    // 查找该趟有没有更小的，如果找到更小的，则更新最小值的下标
	    for j = i + 1; j < len; ++j {
	       if arr[j] < arr[min] {
	          min = j;
	       } 
	    }
	    
	    // 如果该趟的第一个元素不是最小的，说明需要交换
	    if min != i {
	       int temp = arr[i];
	       arr[i] = arr[min];
	       arr[min] = temp;
	    }
	  }
	}
 
C语言版
 
	void selectSort(int arr[], int len) {
	  int min = 0;
	  
	  // 只需要n-1趟
	  for (int i = 0; i < len - 1; ++i) {
	    min = i;
	    
	    // 从第n+1趟起始找到末尾
	    for (int j = i + 1; j < len; ++j) {
	      
	      // 找到比min位置更小的，就更新这一趟所找到的最小值的位置
	      if (arr[j] < arr[min]) {
	        min = j;
	      }
	    }
	    
	    // 如果min与i不相等，说明有比i位置更小的，所以需要交换
	    if (min != i) {
	      int temp = arr[min];
	      arr[min] = arr[i];
	      arr[i] = temp;
	    }
	  }
	}
 
ObjC版
 
	- (void)selectSort:(int [])arr len:(int)len {
	  int min = 0;
	  
	  // 只需要n-1趟
	  for (int i = 0; i < len - 1; ++i) {
	    min = i;
	    
	    // 从第n+1趟起始找到末尾
	    for (int j = i + 1; j < len; ++j) {
	      
	      // 找到比min位置更小的，就更新这一趟所找到的最小值的位置
	      if (arr[j] < arr[min]) {
	        min = j;
	      }
	    }
	    
	    // 如果min与i不相等，说明有比i位置更小的，所以需要交换
	    if (min != i) {
	      int temp = arr[min];
	      arr[min] = arr[i];
	      arr[i] = temp;
	    }
	  }
	}
 
Swift版
 
	func selectSort(var arr: [Int]) ->[Int] {
	  var min = 0
	  
	  // 只需要n-1趟
	  for var i = 0; i < arr.count - 1; ++i {
	    min = i
	    
	    // 从第n+1趟起始找到末尾
	    for var j = i + 1; j < arr.count; ++j {
	      
	      // 找到比min位置更小的，就更新这一趟所找到的最小值的位置
	      if arr[j] < arr[min] {
	        min = j
	      }
	    }
	    
	    // 如果min与i不相等，说明有比i位置更小的，所以需要交换
	    if min != i {
	      let temp = arr[i]
	      arr[i] = arr[min]
	      arr[min] = temp
	    }
	  }
	  
	  return arr
	}
 
尝试ObjC实现模型选择排序	
 
	- (void)selectSort:(NSMutableArray *)array {
	  NSUInteger minIndex = 0;
	  
	  for (NSUInteger i = 0; i < array.count - 1; ++i) {
	    minIndex = i;
	    
	    for (NSUInteger j = i + 1; j < array.count; ++j) {
	      HYBTestModel *modelj = [array objectAtIndex:j];
	      HYBTestModel *model = [array objectAtIndex:minIndex];
	      
	      // 比min下的还要小，则更新min
	      if ([modelj.uid compare:model.uid options:NSCaseInsensitiveSearch] == NSOrderedAscending) {
	        minIndex = j;
	      }
	    }
	    
	    if (minIndex != i) {
	      [array exchangeObjectAtIndex:minIndex withObjectAtIndex:i];
	    }
	  }
	}
 

测试：
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < 10; ++i) {
	  HYBTestModel *model = [[HYBTestModel alloc] init];
	  model.title = [NSString stringWithFormat:@"标哥的技术博客：%ld", 10 - (i + 1)];
	  model.uid = [NSString stringWithFormat:@"%ld", 10 - (i + 1)];
	  
	  [array addObject:model];
	  
	}
	 
	[self selectSort:array];
	 
	for (HYBTestModel *model in array) {
	  NSLog(@"%@ %@", model.uid, model.title);
	}
 
// 打印:

	2016-03-11 11:52:47.482 DataAgorithmDemos[97923:4012461] 0 标哥的技术博客：0
	2016-03-11 11:52:47.484 DataAgorithmDemos[97923:4012461] 1 标哥的技术博客：1
	2016-03-11 11:52:47.484 DataAgorithmDemos[97923:4012461] 2 标哥的技术博客：2
	2016-03-11 11:52:47.484 DataAgorithmDemos[97923:4012461] 3 标哥的技术博客：3
	2016-03-11 11:52:47.484 DataAgorithmDemos[97923:4012461] 4 标哥的技术博客：4
	2016-03-11 11:52:47.484 DataAgorithmDemos[97923:4012461] 5 标哥的技术博客：5
	2016-03-11 11:52:47.484 DataAgorithmDemos[97923:4012461] 6 标哥的技术博客：6
	2016-03-11 11:52:47.485 DataAgorithmDemos[97923:4012461] 7 标哥的技术博客：7
	2016-03-11 11:52:47.487 DataAgorithmDemos[97923:4012461] 8 标哥的技术博客：8
	2016-03-11 11:52:47.487 DataAgorithmDemos[97923:4012461] 9 标哥的技术博客：9
	
	
	
##堆排序

堆是指二叉堆，二叉堆又称完全二叉树或者叫近似完全二叉树。二叉堆又分为最大堆和最小堆。

堆排序(Heapsort)是指利用堆这种数据结构所设计的一种排序算法，它是选择排序的一种。可以利用数组的特点快速定位指定索引的元素。数组可以根据索引直接获取元素，时间复杂度为O（1），也就是常量，因此对于取值效率极高。


最大堆的特性如下：

    父结点的键值总是大于或者等于任何一个子节点的键值
    每个结点的左子树和右子树都是一个最大堆

最小堆的特性如下：

    父结点的键值总是小于或者等于任何一个子节点的键值
    每个结点的左子树和右子树都是一个最小堆

堆排序的时间，主要由建立初始堆和反复调整堆这两部分的时间开销构成.由于堆排序是不稳定的，它得扭到的时间复杂度会根据实际情况较大，因此只能取平均时间复杂度。

平均时间复杂度为：O( N * log2(N) )

使用建议：

	由于初始化堆需要比较的次数较多，因此，堆排序比较适合于数据量非常大的场合（百万数据或更多）。由于高效的快速排序是基于递归实现的，所以在数据量非常大时会发生堆栈溢出错误。
	
基于最大堆实现升序排序
	
 
	// 初始化堆
	void initHeap(int a[], int len) {
	  // 从完全二叉树最后一个非子节点开始
	  // 在数组中第一个元素的索引是0
	  // 第n个元素的左孩子为2n+1，右孩子为2n+2，
	  // 最后一个非子节点位置在(n - 1) / 2
	  for (int i = (len - 1) / 2; i >= 0; --i) {
	    adjustMaxHeap(a, len, i);
	  }
	}
	 
	void adjustMaxHeap(int a[], int len, int parentNodeIndex) {
	  // 若只有一个元素，那么只能是堆顶元素，也没有必要再排序了
	  if (len <= 1) {
	    return;
	  }
	 
	  // 记录比父节点大的左孩子或者右孩子的索引
	  int targetIndex = -1;
	  
	  // 获取左、右孩子的索引
	  int leftChildIndex = 2 * parentNodeIndex + 1;
	  int rightChildIndex = 2 * parentNodeIndex + 2;
	 
	  // 没有左孩子
	  if (leftChildIndex >= len) {
	    return;
	  }
	  
	  // 有左孩子，但是没有右孩子
	  if (rightChildIndex >= len) {
	    targetIndex = leftChildIndex;
	  }
	  // 有左孩子和右孩子
	  else {
	    // 取左、右孩子两者中最大的一个
	    targetIndex = a[leftChildIndex] > a[rightChildIndex] ? leftChildIndex : rightChildIndex;
	  }
	  
	  // 只有孩子比父节点的值还要大，才需要交换
	  if (a[targetIndex] > a[parentNodeIndex]) {
	    int temp = a[targetIndex];
	    
	    a[targetIndex] = a[parentNodeIndex];
	    a[parentNodeIndex] = temp;
	    
	    
	    // 交换完成后，有可能会导致a[targetIndex]结点所形成的子树不满足堆的条件，
	    // 若不满足堆的条件，则调整之使之也成为堆
	    adjustMaxHeap(a, len, targetIndex);
	  }
	}
	 
	void heapSort(int a[], int len) {
	  if (len <= 1) {
	    return;
	  }
	  
	  // 初始堆成无序最大堆
	  initHeap(a, len);
	  
	  for (int i = len - 1; i > 0; --i) {
	    // 将当前堆顶元素与最后一个元素交换，保证这一趟所查找到的堆顶元素与最后一个元素交换
	    // 注意：这里所说的最后不是a[len - 1]，而是每一趟的范围中最后一个元素
	    // 为什么要加上>0判断？每次不是说堆顶一定是最大值吗？没错，每一趟调整后，堆顶是最大值的
	    // 但是，由于len的范围不断地缩小，导致某些特殊的序列出现异常
	    // 比如说，5, 3, 8, 6, 4序列，当调整i=1时，已经调整为3,4,5,6,8序列，已经有序了
	    // 但是导致了a[i]与a[0]交换，由于变成了4,3,5,6,8反而变成无序了!
	    if (a[0] > a[i]) {
	      int temp = a[0];
	      a[0] = a[i];
	      a[i] = temp;
	    }
	    
	    // 范围变成为：
	    // 0...len-1
	    // 0...len-1-1
	    // 0...1 // 结束
	    // 其中，0是堆顶，每次都是找出在指定的范围内比堆顶还大的元素，然后与堆顶元素交换
	    adjustMaxHeap(a, i - 1, 0);
	  }
	}
 
基于最小堆实现降序排序
 
	// 初始化堆
	void initHeap(int a[], int len) {
	  // 从完全二叉树最后一个非子节点开始
	  // 在数组中第一个元素的索引是0
	  // 第n个元素的左孩子为2n+1，右孩子为2n+2，
	  // 最后一个非子节点位置在(n - 1) / 2
	  for (int i = (len - 1) / 2; i >= 0; --i) {
	    adjustMinHeap(a, len, i);
	  }
	}
	 
	void adjustMinHeap(int a[], int len, int parentNodeIndex) {
	  // 若只有一个元素，那么只能是堆顶元素，也没有必要再排序了
	  if (len <= 1) {
	    return;
	  }
	  
	  // 记录比父节点大的左孩子或者右孩子的索引
	  int targetIndex = -1;
	  
	  // 获取左、右孩子的索引
	  int leftChildIndex = 2 * parentNodeIndex + 1;
	  int rightChildIndex = 2 * parentNodeIndex + 2;
	  
	  // 没有左孩子
	  if (leftChildIndex >= len) {
	    return;
	  }
	  
	  // 有左孩子，但是没有右孩子
	  if (rightChildIndex >= len) {
	    targetIndex = leftChildIndex;
	  }
	  // 有左孩子和右孩子
	  else {
	    // 取左、右孩子两者中最上的一个
	    targetIndex = a[leftChildIndex] < a[rightChildIndex] ? leftChildIndex : rightChildIndex;
	  }
	  
	  // 只有孩子比父节点的值还要小，才需要交换
	  if (a[targetIndex] < a[parentNodeIndex]) {
	    int temp = a[targetIndex];
	    
	    a[targetIndex] = a[parentNodeIndex];
	    a[parentNodeIndex] = temp;
	    
	    
	    // 交换完成后，有可能会导致a[targetIndex]结点所形成的子树不满足堆的条件，
	    // 若不满足堆的条件，则调整之使之也成为堆
	    adjustMinHeap(a, len, targetIndex);
	  }
	}
	 
	void heapSort(int a[], int len) {
	  if (len <= 1) {
	    return;
	  }
	  
	  // 初始堆成无序最小堆
	  initHeap(a, len);
	  
	  for (int i = len - 1; i > 0; --i) {
	    // 将当前堆顶元素与最后一个元素交换，保证这一趟所查找到的堆顶元素与最后一个元素交换
	    // 注意：这里所说的最后不是a[len - 1]，而是每一趟的范围中最后一个元素
	    // 为什么要加上>0判断？每次不是说堆顶一定是最小值吗？没错，每一趟调整后，堆顶是最小值的
	    // 但是，由于len的范围不断地缩小，导致某些特殊的序列出现异常
	    // 比如说，5, 3, 8, 6, 4序列，当调整i=1时，已经调整为3,4,5,6,8序列，已经有序了
	    // 但是导致了a[i]与a[0]交换，由于变成了4,3,5,6,8反而变成无序了!
	    if (a[0] < a[i]) {
	      int temp = a[0];
	      a[0] = a[i];
	      a[i] = temp;
	    }
	    
	    // 范围变成为：
	    // 0...len-1
	    // 0...len-1-1
	    // 0...1 // 结束
	    // 其中，0是堆顶，每次都是找出在指定的范围内比堆顶还小的元素，然后与堆顶元素交换
	    adjustMinHeap(a, i - 1, 0);
	  }
	}
 
C语言版测试

大家可以测试一下：
	
 
	//  int a[] = {5, 3, 8, 6, 4};
	int a[] = {89,-7,999,-89,7,0,-888,7,-7};
	heapSort(a, sizeof(a) / sizeof(int));
	 
	for (int i = 0; i < sizeof(a) / sizeof(int); ++i) {
	    NSLog(@"%d", a[i]);
	}
	 
Swift版实现
基于最大堆实现升序排序
	 
	func initHeap(inout a: [Int]) {
	  for var i = (a.count - 1) / 2; i >= 0; --i {
	    adjustMaxHeap(&a, len: a.count, parentNodeIndex: i)
	  }
	}
	 
	func adjustMaxHeap(inout a: [Int], len: Int, parentNodeIndex: Int) {
	  // 如果len <= 0，说明已经无序区已经缩小到0
	  guard len > 1 else {
	    return
	  }
	  
	  // 父结点的左、右孩子的索引
	  let leftChildIndex = 2 * parentNodeIndex + 1
	  
	  // 如果连左孩子都没有， 一定没有右孩子，说明已经不用再往下了
	  guard leftChildIndex < len else {
	    return
	  }
	  
	  let rightChildIndex = 2 * parentNodeIndex + 2
	  
	  // 用于记录需要与父结点交换的孩子的索引
	  var targetIndex = -1
	  
	  // 若没有右孩子，但有左孩子，只能选择左孩子
	  if rightChildIndex > len {
	    targetIndex = leftChildIndex
	  } else {
	    // 左、右孩子都有，则需要找出最大的一个
	    targetIndex = a[leftChildIndex] > a[rightChildIndex] ? leftChildIndex : rightChildIndex
	  }
	  
	  // 只有孩子比父结点还要大，再需要交换
	  if a[targetIndex] > a[parentNodeIndex] {
	    let temp = a[targetIndex]
	    
	    a[targetIndex] = a[parentNodeIndex]
	    a[parentNodeIndex] = temp
	    
	    // 由于交换后，可能会破坏掉新的子树堆的性质，因此需要调整以a[targetIndex]为父结点的子树，使之满足堆的性质
	    adjustMaxHeap(&a, len: len, parentNodeIndex: targetIndex)
	  }
	}
	 
	func maxHeapSort(inout a: [Int]) {
	  guard a.count > 1 else {
	    return
	  }
	  
	  initHeap(&a)
	  
	  for var i = a.count - 1; i > 0; --i {
	    // 每一趟都将堆顶交换到指定范围内的最后一个位置
	    if a[0] > a[i] {
	      let temp = a[0]
	      
	      a[0] = a[i]
	      a[i] = temp
	    }
	    print(a)
	    print(i - 1)
	    // 有序区长度+1，而无序区长度-1，继续缩小无序区，所以i-1
	    // 堆顶永远是在0号位置，所以父结点调整从堆顶开始就可以了
	    adjustMaxHeap(&a, len: i - 1, parentNodeIndex: 0)
	    print(a)
	  }
	}
 
基于最小堆降序排序

	func initHeap(inout a: [Int]) {
	  for var i = (a.count - 1) / 2; i >= 0; --i {
	    adjustMinHeap(&a, len: a.count, parentNodeIndex: i)
	  }
	}
	 
	func adjustMinHeap(inout a: [Int], len: Int, parentNodeIndex: Int) {
	  // 如果len <= 0，说明已经无序区已经缩小到0
	  guard len > 1 else {
	    return
	  }
	  
	  // 父结点的左、右孩子的索引
	  let leftChildIndex = 2 * parentNodeIndex + 1
	  
	  // 如果连左孩子都没有， 一定没有右孩子，说明已经不用再往下了
	  guard leftChildIndex < len else {
	    return
	  }
	  
	  let rightChildIndex = 2 * parentNodeIndex + 2
	  
	  // 用于记录需要与父结点交换的孩子的索引
	  var targetIndex = -1
	  
	  // 若没有右孩子，但有左孩子，只能选择左孩子
	  if rightChildIndex > len {
	    targetIndex = leftChildIndex
	  } else {
	    // 左、右孩子都有，则需要找出最大的一个
	    targetIndex = a[leftChildIndex] < a[rightChildIndex] ? leftChildIndex : rightChildIndex
	  }
	  
	  // 只有孩子比父结点还要大，再需要交换
	  if a[targetIndex] < a[parentNodeIndex] {
	    let temp = a[targetIndex]
	    
	    a[targetIndex] = a[parentNodeIndex]
	    a[parentNodeIndex] = temp
	    
	    // 由于交换后，可能会破坏掉新的子树堆的性质，因此需要调整以a[targetIndex]为父结点的子树，使之满足堆的性质
	    adjustMinHeap(&a, len: len, parentNodeIndex: targetIndex)
	  }
	}
	 
	func minHeapSort(inout a: [Int]) {
	  guard a.count > 1 else {
	    return
	  }
	  
	  initHeap(&a)
	  
	  for var i = a.count - 1; i > 0; --i {
	    // 每一趟都将堆顶交换到指定范围内的最后一个位置
	    if a[0] < a[i] {
	      let temp = a[0]
	      
	      a[0] = a[i]
	      a[i] = temp
	    } else {
	       return // 可以直接退出了，因为已经全部有序了
	    }
	    
	    // 有序区长度+1，而无序区长度-1，继续缩小无序区，所以i-1
	    // 堆顶永远是在0号位置，所以父结点调整从堆顶开始就可以了
	    adjustMinHeap(&a, len: i - 1, parentNodeIndex: 0)
	  }
	}
 

测试：
	
 
	var arr = [5, 3, 8, 6, 4]
	//var arr = [89,-7,999,-89,7,0,-888,7,-7]
	maxHeapSort(&arr)
	 
	print(arr)
	 
	// 打印日志如下：
	[4, 6, 5, 3, 8]
	3
	[6, 4, 5, 3, 8]
	 
	[3, 4, 5, 6, 8]
	2
	[5, 4, 3, 6, 8]
	 
	[3, 4, 5, 6, 8]
	1
	[3, 4, 5, 6, 8]
	 
	[3, 4, 5, 6, 8]
	0
	[3, 4, 5, 6, 8]
	 
	[3, 4, 5, 6, 8]
 
##归并排序

归并排序（MERGE-SORT）是建立在归并操作上的一种有效的排序算法,该算法是采用分治法（Divide and Conquer）的一个非常典型的应用。将已有序的子序列合并，得到完全有序的序列；即先使每个子序列有序，再使子序列段间有序。若将两个有序表合并成一个有序表，称为二路归并。

归并排序的效率是比较高的，假设数列长度为N，采用中分法的方式将数列分开成若干个小数列一共要log2N 步，每步都是一个合并有序数列的过程，时间复杂度可以记为O ( N )，故一共为O ( N * log2N )。

因为归并排序每次都是在相邻的数据中进行操作，所以归并排序在常用的几种排序方法（快速排序，归并排序，希尔排序，堆排序）中也是效率比较高的。

时间复杂度：O ( N * log2N )

C语言实现
 
	/**
	 *  归并排序算法
	 *
	 *  @param list   待排序的序列
	 *  @param first    子序列的起点索引
	 *  @param last   子序列的终点索引
	 *  @param temp   临时数组，用于将两个子序列二路归并时存储
	 */
	void mergeSort(int list[], int first, int last, int temp[]) {
	  if (first < last) {
	    int mid = (first + last) / 2;
	    
	    // 递归归并中分左子序列，使子序列有序
	    mergeSort(list, first, mid, temp);
	    
	    // 递归归并中分右子序列，使子序列有序
	    mergeSort(list, mid + 1, last, temp);
	    
	    // 最后二路归并，使序列成有序
	    // 必须明白的一点，每次中分递归归并都需要二路归并，因为中分后的任意子序列
	    // 在有序后，都要二路归并成一个序列
	    mergeList(list, first, mid, last, temp);
	  }
	}
	 
	/**
	 *  二路归并list[first...mid]子序列与list[mid+1...last]
	 *
	 *  @param list 序列
	 *  @param first    左子序列的起点
	 *  @param mid      序列中间分割点
	 *  @param last 右序列终点
	 *  @param temp 临时序列，用于将两个无序的子序列归并到temp中，使之有序
	 */
	void mergeList(int list[], int first, int mid, int last, int temp[]) {
	  int leftIndex = first;
	  int leftEndIndex = mid;
	  
	  int rightIndex = mid + 1;
	  int rightEndIndex = last;
	  
	  int tempIndex = 0;
	  
	  // 寻找两个子序列，顺序遍历，将值小的复制到临时数组中，直到其中一个子序列遍历完毕
	  while (leftIndex <= leftEndIndex && rightIndex <= rightEndIndex) {
	    // 值小的就复制到临时数组中
	    if (list[leftIndex] <= list[rightIndex]) {
	      temp[tempIndex] = list[leftIndex];
	      tempIndex++;
	      leftIndex++;
	    } else {
	      temp[tempIndex] = list[rightIndex];
	      tempIndex++;
	      rightIndex++;
	    }
	  }
	  
	  // 有可能左子序列更长，因此将剩下的部分直接复制到临时数组中
	  while (leftIndex <= leftEndIndex) {
	    temp[tempIndex++] = list[leftIndex++];
	  }
	  
	  // 有可能右子序列更长，因此将剩下的部分直接复制到临时数组中
	  while (rightIndex <= rightEndIndex) {
	    temp[tempIndex++] = list[rightIndex++];
	  }
	  
	  // 最后还需要将有序的临时数组复制到原始序列中
	  for (int i = 0; i < tempIndex; ++i) {
	    list[first + i] = temp[i];
	  }
	 
	 // 这里添加一个打印，记录归并
	 NSMutableString *str = [[NSMutableString alloc] init];
	  for (int i = 0; i < sizeof(list) - 1; ++i) {
	    if (i == 0) {
	      [str appendFormat:@"%d", list[i]];
	    } else {
	      [str appendFormat:@", %d", list[i]];
	    }
	  }
	  NSLog(@"此次二路归并后，得到的序列为：(%@)", str);
	}
	 

测试：
	
	 
	int list[] = {6, 202, 100, 301, 38, 8, 1};
	int temp[7] = {0};
	mergeSort(list, 0, 7-1, temp);
 

打印效果：
 
	此次二路归并后，得到的序列为：(6, 202, 100, 301, 38, 8, 1)
	此次二路归并后，得到的序列为：(6, 202, 100, 301, 38, 8, 1)
	此次二路归并后，得到的序列为：(6, 100, 202, 301, 38, 8, 1)
	此次二路归并后，得到的序列为：(6, 100, 202, 301, 8, 38, 1)
	此次二路归并后，得到的序列为：(6, 100, 202, 301, 1, 8, 38)
	此次二路归并后，得到的序列为：(1, 6, 8, 38, 100, 202, 301)
 

从打印结果可以看出来，果然与我们前面的算法分析是一样的。

##插入排序

插入排序有两种：

    直接插入排序
    折半插入排序

原理：

    第一个元素就认为是有序的
    取第二个元素，判断是否大于第一个元素。若是大于，表示已经有序，不用移动，否则将已经有序的序列整体向后移动一个位置
    依此类推，直到所有元素已经有序。
    
直接插入排序  
  
  
需要到两层循环来处理，外层循环用于跑多少趟，而内层循环用于移动元素位置，因此时间复杂度仍为 O ( n2 )

伪代码
 
	void insertSort(int a[], int len) {
	  for i = 1; i < len; ++i {     
	     // 后者>前者，才需要移动和插入
	     if a[i] < a[i - 1] {
	        // 记录下要移动的元素
	        int target = a[i];
	        
	        // 将前j-1个有序的元素分别后移一个位置
	        int j = i;
	        while j > 0 && a[j - 1] > target {
	          a[j] = a[j - 1];
	          j--;
	        }
	        
	        // 将目标元素插入对应的位置，使之有序
	        a[j] = target;
	     }
	  }
	}
 
C语言版
 
	void insertSort(int a[], int len) {
	  for (int i = 1; i < len; ++i) {
	    
	    // 遇到不是有序的，才进入移动元素
	    if (a[i] < a[i - 1]) {
	      int target = a[i];
	 
	      // 移动前j-1元素，分别向后移动一个位置
	      int j = i;
	      while (j > 0 && a[j - 1] > target) {
	        a[j] = a[j - 1];
	        
	        j--;
	      }
	      
	      // 将目标元素放到目标位置，使之有序
	      a[j] = target;
	    }
	  }
	}
 
OjbC版

	- (void)insertSort:(int[])a len:(int)len {
	  for (int i = 1; i < len; ++i) {
	    
	    // 遇到不是有序的，才进入移动元素
	    if (a[i] < a[i - 1]) {
	      int target = a[i];
	      
	      // 移动前j-1元素，分别向后移动一个位置
	      int j = i;
	      while (j > 0 && a[j - 1] > target) {
	        a[j] = a[j - 1];
	        
	        j--;
	      }
	      
	      // 将目标元素放到目标位置，使之有序
	      a[j] = target;
	    }
	  }
	}
 
Swift版
 
	func insertSort(var a: [Int]) ->[Int] {
	  for var i = 1; i < a.count; ++i {
	    if a[i] < a[i - 1] {
	      let target = a[i]
	      
	      var j = i
	      while j > 0 && a[j - 1] > target {
	        a[j] = a[j - 1]
	        
	        j--
	      }
	      
	      a[j] = target
	    }
	  }
	  
	  return a
	}
 
折半插入排序

从第二个元素开始逐个置入监视哨，使用low、high标签进行折半判断比较大小，并确认插入位置，该位置到最后一个数全部后移一位，然后腾出该位置，把监视哨里面的数置入该位置。依此类推进行排序，直到最后一个数比较完毕。
时间复杂度

折半插入排序, 即查找插入点的位置, 可以使用折半查找，这样可以减少比较的次数, 但是移动的次数不变，因此，时间复杂度仍为 O(n2) ;
伪代码

	void binaryInsertSort(int a[], int len) {
	  for int i = 2; i < len; ++i {
	     // 将元素放到哨兵的位置
	     a[0] = a[i];
	     
	     int low = 1;
	     int high = i - 1;
	     
	     // 折半查找位置
	     while low <= high {
	        int mid = (low + high) / 2;
	        
	        // 在低半区
	        if a[mid] > a[0] {
	          high = mid - 1;
	        } else { // 在高半区
	          low = mid + 1;
	        }
	     }
	     
	     // 将前i - 1个元素后移
	     // 找到high，那么high+1就是i要插入的位置  
	     for int j = i - 1; j >= high + 1; --j {
	        a[j + 1] = a[j];
	     }
	     
	     // 将临时放在岗哨的元素放到所查找到的位置处
	     a[high + 1] = a[0];
	  }
	}
 
C语言版
 
	void binaryInsertSort(int a[], int len) {
	  for (int i = 2; i < len; ++i) {
	    // 第一个位置永远只是当作哨兵用
	    a[0] = a[i];
	    
	    int low = 1;
	    int high = i - 1;
	    
	    while (low <= high) {
	      int mid = (low + high) / 2;
	      
	      if (a[mid] > a[0]) {
	        high = mid - 1;
	      } else {
	        low = mid + 1;
	      }
	    }
	    
	    // 移动前i - 1个元素
	    for (int j = i - 1; j >= high + 1; --j) {
	      a[j + 1] = a[j];
	    }
	    
	    // 放到查找到的位置处
	    a[high + 1] = a[0];
	  }
	}
 
Swift版
 
	func binaryInsertSort(var a: [Int]) ->[Int] {
	  for var i = 2; i < a.count; ++i {
	    a[0] = a[i]
	    
	    var low = 1
	    var high = i - 1
	    while low <= high {
	      let mid = (low + high) / 2
	      
	      if a[mid] > a[0] {
	        high = mid - 1
	      } else {
	        low = mid + 1
	      }
	    }
	    
	    for var j = i - 1; j >= high + 1; --j {
	      a[j + 1] = a[j]
	    }
	    
	    a[high + 1] = a[0]
	  }
	  
	  return a
	}
 





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