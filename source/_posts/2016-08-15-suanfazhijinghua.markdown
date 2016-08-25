 
---

layout: post
title: "修行篇-算法之精华-算法&冒泡"
date: 2016-08-15 23:53:19 +0800
comments: true
categories: Developer
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

--- 

+ 冒泡排序（交换）
	
	- 改进

+ 快速排序（交换）
	
	- 改进


##交换排序—冒泡排序（Bubble Sort）
基本思想：

> 在要排序的一组数中，对当前还未排好序的范围内的全部数，自上而下对相邻的两个数依次进行比较和调整，让较大的数往下沉，较小的往上冒。即：每当两相邻的数比较后发现它们的排序与排序要求相反时，就将它们互换。
算法的实现：


    void bubbleSort(int a[], int n){  
        for(int i =0 ; i< n-1; ++i) {  
            for(int j = 0; j < n-i-1; ++j) {  
                if(a[j] > a[j+1])  
                {  
                    int tmp = a[j] ; a[j] = a[j+1] ;  a[j+1] = tmp;  
                }  
            }  
        }  
    }  

####改进

<!--more-->

> 对冒泡排序常见的改进方法是加入一标志性变量exchange，用于标志某一趟排序过程中是否有数据交换，如果进行某一趟排序时并没有进行数据交换，则说明数据已经按要求排列好，可立即结束排序，避免不必要的比较过程。本文再提供以下两种改进算法：

1．设置一标志性变量pos,用于记录每趟排序中最后一次进行交换的位置。由于pos位置之后的记录均已交换到位,故在进行下一趟排序时只要扫描到pos位置即可。
改进后算法如下:


    void Bubble_1 ( int r[], int n) {  
        int i= n -1;  //初始时,最后位置保持不变  
        while ( i> 0) {   
            int pos= 0; //每趟开始时,无记录交换  
            for (int j= 0; j< i; j++)  
                if (r[j]> r[j+1]) {  
                    pos= j; //记录交换的位置   
                    int tmp = r[j]; r[j]=r[j+1];r[j+1]=tmp;  
                }   
            i= pos; //为下一趟排序作准备  
         }   
    }    
2．传统冒泡排序中每一趟排序操作只能找到一个最大值或最小值,我们考虑利用在每趟排序中进行正向和反向两遍冒泡的方法一次可以得到两个最终值(最大者和最小者) , 从而使排序趟数几乎减少了一半。
改进后的算法实现为:


    void Bubble_2 ( int r[], int n){  
        int low = 0;   
        int high= n -1; //设置变量的初始值  
        int tmp,j;  
        while (low < high) {  
            for (j= low; j< high; ++j) //正向冒泡,找到最大者  
                if (r[j]> r[j+1]) {  
                    tmp = r[j]; r[j]=r[j+1];r[j+1]=tmp;  
                }   
            --high;                 //修改high值, 前移一位  
            for ( j=high; j>low; --j) //反向冒泡,找到最小者  
                if (r[j]<r[j-1]) {  
                    tmp = r[j]; r[j]=r[j-1];r[j-1]=tmp;  
                }  
            ++low;                  //修改low值,后移一位  
        }   
    }   






##交换排序—快速排序（Quick Sort）


基本思想：

+ 1）选择一个基准元素,通常选择第一个元素或者最后一个元素,

+ 2）通过一趟排序讲待排序的记录分割成独立的两部分，其中一部分记录的元素值均比基准元素值小。另一部分记录的 元素值比基准值大。

+ 3）此时基准元素在其排好序后的正确位置

+ 4）然后分别对这两部分记录用同样的方法继续进行排序，直到整个序列有序。

算法的实现：
 递归实现：


    void print(int a[], int n){  
        for(int j= 0; j<n; j++){  
            cout<<a[j] <<"  ";  
        }  
        cout<<endl;  
    }  
      
    void swap(int *a, int *b)  
    {  
        int tmp = *a;  
        *a = *b;  
        *b = tmp;  
    }  
    int partition(int a[], int low, int high)  
    {  
        int privotKey = a[low];                             //基准元素  
        while(low < high){                                   //从表的两端交替地向中间扫描  
            while(low < high  && a[high] >= privotKey) --high;  //从high 所指位置向前搜索，至多到low+1 位置。将比基准元素小的交换到低端  
            swap(&a[low], &a[high]);  
            while(low < high  && a[low] <= privotKey ) ++low;  
            swap(&a[low], &a[high]);  
        }  
        print(a,10);  
        return low;  
    }  
    void quickSort(int a[], int low, int high){  
        if(low < high){  
            int privotLoc = partition(a,  low,  high);  //将表一分为二  
            quickSort(a,  low,  privotLoc -1);          //递归对低子表递归排序  
            quickSort(a,   privotLoc + 1, high);        //递归对高子表递归排序  
        }  
    }  
    int main(){  
        int a[10] = {3,1,5,7,2,4,9,6,10,8};  
        cout<<"初始值：";  
        print(a,10);  
        quickSort(a,0,9);  
        cout<<"结果：";  
        print(a,10);  
      
    }  

分析：

>快速排序是通常被认为在同数量级（O(nlog2n)）的排序方法中平均性能最好的。但若初始序列按关键码有序或基本有序时，快排序反而蜕化为冒泡排序。为改进之，通常以“三者取中法”来选取基准记录，即将排序区间的两个端点与中点三个记录关键码居中的调整为支点记录。快速排序是一个不稳定的排序方法。
快速排序的改进

####改进

在本改进算法中,只对长度大于k的子序列递归调用快速排序,让原序列基本有序，然后再对整个基本有序序列用插入排序算法排序。实践证明，改进后的算法时间复杂度有所降低，且当k取值为 8 左右时,改进算法的性能最佳。算法思想如下：


    void print(int a[], int n){  
        for(int j= 0; j<n; j++){  
            cout<<a[j] <<"  ";  
        }  
        cout<<endl;  
    }  
    void swap(int *a, int *b)  
    {  
        int tmp = *a;  
        *a = *b;  
        *b = tmp;  
    }  
    int partition(int a[], int low, int high)  
    {  
        int privotKey = a[low];                 //基准元素  
        while(low < high){                   //从表的两端交替地向中间扫描  
            while(low < high  && a[high] >= privotKey) --high; //从high 所指位置向前搜索，至多到low+1 位置。将比基准元素小的交换到低端  
            swap(&a[low], &a[high]);  
            while(low < high  && a[low] <= privotKey ) ++low;  
            swap(&a[low], &a[high]);  
        }  
        print(a,10);  
        return low;  
    }  
    void qsort_improve(int r[ ],int low,int high, int k){  
        if( high -low > k ) { //长度大于k时递归, k为指定的数  
            int pivot = partition(r, low, high); // 调用的Partition算法保持不变  
            qsort_improve(r, low, pivot - 1,k);  
            qsort_improve(r, pivot + 1, high,k);  
        }   
    }   
    void quickSort(int r[], int n, int k){  
        qsort_improve(r,0,n,k);//先调用改进算法Qsort使之基本有序  
        //再用插入排序对基本有序序列排序  
        for(int i=1; i<=n;i ++){  
            int tmp = r[i];   
            int j=i-1;  
            while(tmp < r[j]){  
                r[j+1]=r[j]; j=j-1;   
            }  
            r[j+1] = tmp;  
        }   
      
    }   
    int main(){  
        int a[10] = {3,1,5,7,2,4,9,6,10,8};  
        cout<<"初始值：";  
        print(a,10);  
        quickSort(a,9,4);  
        cout<<"结果：";  
        print(a,10);  
      
    }  