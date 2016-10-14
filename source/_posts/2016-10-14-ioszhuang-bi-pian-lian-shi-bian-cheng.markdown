---
layout: post
title: "iOS装逼篇——链式编程"
date: 2016-10-14 12:49:24 +0800
comments: true
categories: 

---

###开篇

在使用 masonry 框架实现自动布局时，在程序里为一个布局穿插着6行左右这样的代码

[View mas_makeConstraints:^(MASConstraintMaker *make) {

      make.top.equalTo(anotherView);

      make.left.equalTo(anotherView);

      make.width.mas_equalTo(@60);

      make.height.mas_equalTo(@60);

}];

<!--more-->


一直觉得不够漂亮，希望有个一行代码设置约束的框架，我曾尝试过在masonry上封装一个类别 UIView+HKSetConstraints ，用起来也不顺手，总觉得不够味，直到我见到了 SDAutoLayout , 真正的实现了一句代码实现自动布局，加上研究ReactiveCocoa时看到的最快让你上手之ReactiveCocoa基础篇（下面会给出链接）提到编程思想，才明了Masonry 和 SDAutoLayout一点实现思路：链式编程思想。


####先简单介绍下目前咱们已知的编程思想。

+ 1 面向过程：处理事情以过程为核心，一步一步的实现。

+ 2 面向对象：万物皆对象

+ 3 链式编程思想：是将多个操作（多行代码）通过点号(.)链接在一起成为一句代码,使代码可读性好。 a(1).b(2).c(3)

    - 链式编程特点：方法的返回值是block,block必须有返回值（本身对象），block参数（需要操作的值）

    - 代表：Masonry框架。

+ 4 响应式编程思想：不需要考虑调用顺序，只需要知道考虑结果，类似于蝴蝶效应，产生一个事件，会影响很多东西，这些事件像流一样的传播出去，然后影响结果，借用面向对象的一句话，万物皆是流。

    - 代表：KVO运用。

+ 5 函数式编程思想：是把操作尽量写成一系列嵌套的函数或者方法调用。

    - 函数式编程特点：每个方法必须有返回值（本身对象）,把函数或者Block当做参数,block参数（需要操作的值）block返回值（操作结果）

    - 代表：ReactiveCocoa。


###自己实现
我们这里以链式编程思想代码实现一个计算器:

	#import
	
	@class CaculatorMaker;
	
	@interface NSObject (CaculatorMaker)
	
	
	//计算
	
	+ (int)makeCaculators:(void(^)(CaculatorMaker *make))caculatorMaker;
	
	
	@end


===

	#import "NSObject+CaculatorMaker.h"
	
	#import "CaculatorMaker.h"
	
	
	@implementation NSObject (CaculatorMaker)
	
	
	//计算
	
	+ (int)makeCaculators:(void(^)(CaculatorMaker *make))block
	
	{
	
	    CaculatorMaker *mgr = [[CaculatorMaker alloc] init];
	
	    block(mgr);
	
	    return mgr.iResult;
	
	}
	
	
	@end

===

	#import
	
	
	@interface CaculatorMaker : NSObject
	
	
	@property (nonatomic, assign) int iResult;
	
	
	//加法
	
	- (CaculatorMaker *(^)(int))add;
	
	
	//减法
	
	- (CaculatorMaker *(^)(int))sub;
	
	
	//乘法
	
	- (CaculatorMaker *(^)(int))muilt;
	
	
	//除法
	
	- (CaculatorMaker *(^)(int))divide;
	
	
	@end

====


	#import "CaculatorMaker.h"
	
	
	@implementation CaculatorMaker
	
	
	- (CaculatorMaker *(^)(int))add
	
	{
	
	   return ^(int value)
	
	    {
	
	        _iResult += value;
	
	        return self;
	
	    };
	
	}


@end


调用：

	int iResult = [NSObject makeCaculators:^(CaculatorMaker *make) {
	
	     make.add(1).add(2).add(3).divide(2);
	
	   }];


分析下这个方法执行过程：

	第一步：NSObject 创建了一个block, 这个block里创建了一个CaculatorMaker对象make，并返回出来
	
	第二步：这个对象make调用方法add时，里面持有的属性iResult做了一个加法，并且返回自己，以便可以接下去继续调用方法。 

这就是链式编程思想的一个很小但很明了的例子。


{% img /images/ioslianshibiancheng001.png Caption %}  

###现在我们以 Masonry 举例：

我们看看Masonry的

	- (NSArray *)mas_makeConstraints:(void(^)(MASConstraintMaker *make))block;
	
	- (NSArray *)mas_makeConstraints:(void(^)(MASConstraintMaker *))block {
	
	    self.translatesAutoresizingMaskIntoConstraints = NO;
	
	    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
	
	    block(constraintMaker);
	
	    return [constraintMaker install];
	
	}


是不是跟我们的计算器的类别一个样？???? 

我们再来看看它的

	- (MASConstraint * (^)(id attr))mas_equalTo;
	
	- (MASConstraint * (^)(id))mas_equalTo {
	
	    return ^id(id attribute) {
	
	        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
	
	    };
	
	}


看看它的self.equalToWithRelation实现：

	- (MASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation {
	
	    return ^id(id attribute, NSLayoutRelation relation) {
	
	        if ([attribute isKindOfClass:NSArray.class]) {
	
	            NSAssert(!self.hasLayoutRelation, @"Redefinition of constraint relation");
	
	            NSMutableArray *children = NSMutableArray.new;
	
	            for (id attr in attribute) {
	
	                MASViewConstraint *viewConstraint = [self copy];
	
	                viewConstraint.secondViewAttribute = attr;
	
	                [children addObject:viewConstraint];
	
	            }
	
	            MASCompositeConstraint *compositeConstraint = [[MASCompositeConstraint alloc] initWithChildren:children];
	
	            compositeConstraint.delegate = self.delegate;
	
	            [self.delegate constraint:self shouldBeReplacedWithConstraint:compositeConstraint];
	
	            return compositeConstraint;
	
	        } else {
	
	            NSAssert(!self.hasLayoutRelation || self.layoutRelation == relation && [attribute isKindOfClass:NSValue.class], @"Redefinition of constraint relation");
	
	            self.layoutRelation = relation;
	
	            self.secondViewAttribute = attribute;
	
	            return self;
	
	        }
	
	    };
	
	}


的确是返回自己，所以这正是它的链式编程思想的体现。




===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  