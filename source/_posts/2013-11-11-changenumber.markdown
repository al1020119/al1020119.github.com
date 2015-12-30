---

layout: post
title: "不借助第三方变量修改两个值（四种方法）"
date: 2013-11-11 13:53:19 +0800
comments: true
categories: Projects 

--- 



交换值

* 1）算术运算；
* 2）指针地址操作；
* 3）位运算；
* 4）栈实现。

1） 算术运算

	int a,b;
	a=10;b=12;
	a=b-a; //a=2;b=12
	b=b-a; //a=2;b=10
	a=b+a; //a=10;b=10

<!--more-->



2） 指针地址操作

	int *a,*b; //假设
	*a=new int(10);
	*b=new int(20); //&a=0x00001000h,&b=0x00001200h
	a=(int*)(b-a); //&a=0x00000200h,&b=0x00001200h
	b=(int*)(b-a); //&a=0x00000200h,&b=0x00001000h
	a=(int*)(b+int(a)); //&a=0x00001200h,&b=0x00001000h

3） 位运算

	int a=10,b=12; //a=1010^b=1100;
	a=a^b; //a=0110^b=1100;
	b=a^b; //a=0110^b=1010;
	a=a^b; //a=1100=12;b=1010;

4）栈实现。 

	int exchange(int x,int y) 
	{ 
	 stack S; 
	 push(S,x); 
	 push(S,y); 
	 x=pop(S); 
	 y=pop(S); 
	}
	

> 以上方法中第一种和第三中是最常见的！