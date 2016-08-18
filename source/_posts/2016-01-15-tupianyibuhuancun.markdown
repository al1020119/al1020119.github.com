---
layout: post
title: "图片处理-异步缓存优化"
date: 2016-01-15 02:35:08 +0800
comments: true
categories: Performance
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---


1. 引言

过去的几年里，iOS 应用在视觉方面越来越吸引人。图像展示是其中很关键的部分，因为大部分图像展示都需要下载并且渲染。大部分开发者都要使用图像填充表格视图（table views）或者集合视图（collection views）。下载图片消耗一些资源（如蜂窝数据、电池以及 CPU 等）。为了减少资源消耗，一些缓存模型也应运而生。

为了获得良好的用户体验，当我们缓存和加载图像时，了解 iOS 底层如何处理是很重要的。此外，大多数使用了图片缓存的开源库也是个不错解决方案。



<!--more-->



2. 常用的解决途径

    异步下载图像
    处理图像（拉伸，去红眼，去边框）以便展示
    写入磁盘
    需要时从磁盘读取并展示

    // 假设我们有一个 NSURL *imageUrl and UIImageView *imageView, 我们需要通过NSURL下载图片并在UIImageview上展示

	    if ([self hasImageDataForURL:imageUrl] {
	        NSData *data = [self imageDataForUrl:imageUrl];
	        UIImage *image = [UIImage imageWithData:imageData];
	        dispatch_async(dispatch_get_main_queue(), ^{
	            imageView.image = image;
	        });
	    } else {
	        [self downloadImageFromURL:imageUrl withCompletion:^(NSData *imageData, …) {
	            [self storeImageData:imageData …];
	            UIImage *image = [UIImage imageWithData:imageData];
	            dispatch_async(dispatch_get_main_queue(), ^{
	                imageView.image = image;
	            });
	        }];
	    }

FPS 简介

    UI 渲染理想情况 FPS=60
    60FPS => 16.7ms 每帧，这就意味着如果任何主线程操作大于 16.7ms，动态 FPS 将会下降，因为 CPU 忙于处理其他事情，而不是渲染 UI。

3. 常用解决途径的缺点

    从磁盘加载图像或文件时间消耗昂贵（磁盘读取比内存读取慢大概 10-1000 倍，如果是 SSD 硬盘，则可能与内存读取速度更接近（大概慢 10 倍）。参考这里的比较：Introduction to RAM Disks
    如果使用 SSD，将获得接近内存的速度（大概比内存访问速度慢十倍），但目前还没有手机和平板集成 SSD 模块。
    创建 UIImage 实例将会在内存区生成一个图片的压缩版。但是压缩后的图像太小且无法渲染，如果我们从磁盘加载图像，图像甚至都没有加载到内存。解压图片同样也很消耗资源。
    设置 imageView 的 image 属性，这种情况下将会创建一个 CATransaction 并加入主循环中。在下一次循环迭代中，CATransaction 会对任何设置为 layer contents 的图像进行拷贝。

拷贝图像包含以下过程：

    给文件 io 和解压缩分配缓冲区
    读取磁盘数据到内存
    解压图像数据（生成原位图） - 高 CPU 消耗
    CoreAnimation 使用解压数据并渲染

字节位没有正确对齐的图像将被 CoreAnimation 拷贝，以修复字节位对齐并使之能被渲染。这一点在 Apple 文档里没有说明，但是使用 Instruments 表明 CA::Render::copy_image 会执行此操作，即使 Core Aniation 即使没有拷贝图像。

从 iOS7 开始，第三方应用不能使用JPEG硬件解码器。这意味着我们只能使用慢很多的软解码器。这一点在 FastImageCache 团队的 GitHub 主页以及 Nick Lockwood 的推文上都有指出。
4. 一个强大的 iOS 图像缓存需包含以下部分：

    异步下载图像，尽可能减少使用主线程队列
    使用后台队列解压图像。这是个复杂的过程，请阅读 Avoiding Image Decompression Sickness
    在内存和磁盘上缓存图像。在磁盘上缓存图像很重要，因为 App 可能因为内存不足而被强行关闭或者需要清理内存。这种情况下，重新从磁盘加载图像比下载会快很多。
    备注：如果使用 NSCache 作为内存缓存，当有内存警告时，NSCache 会清空缓存内容。NSCache 相关细节请查看 nshipster 文章：NSCache
    保存解压过的图片到硬盘以及内存中，以避免再次解压。
    使用 GCD 和 blocks，这将使得代码更加高效和简单，如今 GCD 和 blocks 是异步操作时必需的。
    最好使用 UIImageView 的分类以便集成
    最好在下载后以及存入到缓存前能够处理图像

iOS图像优化

更多的成像相关以及 SDK 框架（CoreGraphics, ImageIO, CoreAnimation, CoreImage)工作原理，CPU vs GPU 等，请阅读 @rsebbe 的文章：Advanced Imaging on iOS
Core Data 是一个好的选择吗？

这有一篇文章--CoreData 对比 File System，实现图像缓存的基准测试，结果 File System 的表现更好。

看一看上面罗列的观点，自己实现图像缓存不仅复杂，耗时而且痛苦。这也是为什么我倾向于使用开源的图像缓存解决方案，你们大部分已经听说过 SDWebImage 或 new FastImageCache。

为了让你知道哪个开源库最适合你，我做了测试并且分析它们如何满足上述要求。
5. 基准测试

测试库：

    SDWebImage - version 3.5.4
    FastImageCache - version 1.2
    AFNetworking - version 2.2.1
    TMCache - version 1.2.0
    Haneke - version 0.0.5

注：AFNetworking 加入对比是由于其自iOS7后在磁盘缓存方面出色的表现（基于 NSURLCache 实现）
测试场景

对于每个库，我都会使用全新的测试app，然后启动app，等所有图像加载完后，慢慢滑动。然后以不同力度来回滑动（从慢到快）。接着关掉app强制应用从磁盘缓存中加载图像，最后重复以上测试场景。
关于测试 App 工程

    相关 demo 可以在 GitHub 找到并获取，名字是 ImageCachingBenchmark，同时还有本次实验的图表、结果数据表以及更多。

    请注意，请注意 GitHub 上的工程和图像缓存库都需要做一些调整，以便能让我们看到每一张缓存的图片都能够被加载出来。由于我不想检查 Cocoapods 源码文件（不是个好习惯），所以需要对 Cocoapods clean 后重新编译工程代码，目前 GitHub 上的版本与我做测试的版本有些差别。

    如果你们想重新跑一下测试，你需要编写相同 completionBlock 用于图像加载，所有库得要跟默认的 SDWebImage 一样返回 SDImageCacheType。

最快与最慢的设备对比结果

在 GitHub 工程上能看到完整的基准测试结果，由于这些表格很大，我只使用运行最快的设备 iPhone 5s 和运行最慢的 iPhone 4 来测试。




汇总：

表格名词解释：

    异步下载：库支持异步下载
    后台解压：通过后台队列或线程执行图像解压
    存储解压：存储解压后的图像版本
    内存/磁盘缓存：支持内存/磁盘缓存
    UIImageView 分类：库中含 UIImageView 类别
    从内存/磁盘：从缓存（内存/磁盘）中读取的平均时间

6. 结论

    从头开始编写 iOS 图像缓存组件很困难

    SDWebImage 和 AFNetworking 是稳定的工程。由于有很多贡献者，这样保证代码能够及时得到维护，FastImageCache 在维护方面更新很快。

    基于以上所有数据，我认为 SDWebImage 在目前是一个很好的解决方案。即使有些工程使用 AFNetworking 或 FastImageCache 更好，但是这些都依赖于项目需求。
tu


===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  