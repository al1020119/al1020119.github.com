---
layout: post
title: "常用关键字总结"
date: 2015-11-03 17:43:59 +0800
comments: true
categories: 程序员必备
---




| Name	| Typedef| 	Header| 	True Value	| False Value| 
| ------------- |:-------------:| -----:|
| BOOL| 	signed char	objc.h| 	YES| 	NO| 
| bool	| _Bool (int)	| stdbool.h	true	| false| 
| Boolean| 	unsigned char| 	MacTypes.h	TRUE	| FALSE| 
| NSNumber| 	__NSCFBoolean| 	Foundation.h	| @(YES)| 	@(NO)
| CFBooleanRef| 	struct| 	CoreFoundation.h	| kCFBooleanTrue| 	kCFBooleanFalse| 


| 标志	| 值| 	含义| 
| ------------- |:-------------:| -----:|
| NULL| 	(void *)0	| C指针的字面零值| 
| nil	| (id)0	| Objective-C对象的字面零值| 
| Nil	| (Class)0	| Objective-C类的字面零值| 
| NSNull	| [NSNull null]	| 用来表示零值的单独的对象| 
 