---

layout: post
title: "教你怎么显示gif图片"
date: 2013-10-18 13:53:19 +0800
comments: true
categories: Foundation
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



--- 


###方法一：第三方
 
    // 网络图片
    //  NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.chinagif.com/gif/part/boy/0045.gif"]]; 
    
    // 本地图片 
    NSData *localData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"run" ofType:@"gif"]]; 
    
    GifView *dataView = [[GifView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) data:localData];  
    [self.view addSubview:dataView];
    
<!--more-->


######或者你也可以这样，直接加载路径
    
    GifView *pathView =[[GifView alloc] initWithFrame:CGRectMake(100, 0, 100, 100) filePath:[[NSBundle mainBundle] pathForResource:@"run" ofType:@"gif"]];
    [self.view addSubview:pathView];

###方法二：webView
        
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"run" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:path];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 120, 100, 100)];
    webView.backgroundColor = [UIColor redColor];
    webView.scalesPageToFit = YES;
    [webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    [self.view addSubview:webView];
    [webView release];
  
###方法三：animationView
  
    
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 240, 100, 100)];
    NSArray *gifArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"1"],
                         [UIImage imageNamed:@"2"],
                         [UIImage imageNamed:@"3"],
                         [UIImage imageNamed:@"4"],
                         [UIImage imageNamed:@"5"],
                         [UIImage imageNamed:@"6"],
                         [UIImage imageNamed:@"7"],
                         [UIImage imageNamed:@"8"],
                         [UIImage imageNamed:@"9"],
                         [UIImage imageNamed:@"10"],
                         [UIImage imageNamed:@"11"],
                         [UIImage imageNamed:@"12"],
                         [UIImage imageNamed:@"13"],
                         [UIImage imageNamed:@"14"],
                         [UIImage imageNamed:@"15"],
                         [UIImage imageNamed:@"16"],
                         [UIImage imageNamed:@"17"],
                         [UIImage imageNamed:@"18"],
                         [UIImage imageNamed:@"19"],
                         [UIImage imageNamed:@"20"],
                         [UIImage imageNamed:@"21"],
                         [UIImage imageNamed:@"22"],nil];
    gifImageView.animationImages = gifArray; //动画图片数组
    gifImageView.animationDuration = 5; //执行一次完整动画所需的时长
    gifImageView.animationRepeatCount = 999;  //动画重复次数
    [gifImageView startAnimating];
    [self.view addSubview:gifImageView];
    [gifImageView release];