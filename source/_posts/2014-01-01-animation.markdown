---

layout: post
title: "三维动画初探"
date: 2014-01-01 13:53:19 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



--- 

实现三位旋转动画的方法有很多种，这里介绍三种

一：UIView
	
	[UIView animateWithDuration:1.0 animations:^{
	        self.iconView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
	    } completion:^(BOOL finished) {
	        self.iconView.image = [UIImage imageNamed:@"user_defaultgift"];
	       
	        [UIView animateWithDuration:1.0 animations:^{
	            self.iconView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
	        }];
	    }];


<!--more-->




二：CATransition自定义

     CATransition
      CATransition *anim = [CATransition animation];
     anim.duration = 1.0;
     anim.type = @"rippleEffect";
     [self.iconView.layer addAnimation:anim forKey:nil];
三：CATransition

	[UIView transitionWithView:self.iconView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
	        self.iconView.image = [UIImage imageNamed:@"user_defaultgift"];
	    } completion:^(BOOL finished) {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	            [UIView transitionWithView:self.iconView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
	                self.iconView.image = [UIImage imageNamed:@"default_avatar"];
	            } completion:nil];
	        });
	    }];
	}
	 