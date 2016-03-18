---

layout: post
title: "自定义相册删除复活的实现"
date: 2015-06-29 00:22:52 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



---



 
在这里（[http://www.cnblogs.com/iCocos/p/4705585.html](http://www.cnblogs.com/iCocos/p/4705585.html)）我们提到了。

* 简单的实现了获取系统相册图片并且保存图片到系统相册
* 定义自定义的相册，并且保存到自定义相册
 
这里久以一个简单的例子实现一个上面的所有功能，并且添加一个很有用的功能实现
App中自定义的相册呗删除之后再次保存相片无法成功
 
 
这里使用的是一个系统的库：ALAssetsLibrary
 


<!--more-->




先来看看咱们取得相册中的相片

	- (void)getAllPhotos
	{
	    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	    // 遍历所有的文件夹, 一个ALAssetsGroup对象就代表一个文件夹
	    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
	        // 遍历文件夹内的所有多媒体文件（图片、视频）, 一个ALAsset对象就代表一张图片
	        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
	            // 缩略图
	            XMGLog(@"%@", [UIImage imageWithCGImage:result.thumbnail]);
	            // 获得原始图片
	            //            XMGLog(@"%@", [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage]);
	        }];
	       
	   } failureBlock:nil];
	}
 

下面我们看看代码具体的实现
 
一：首先定义一个属性涌来记录并且实现其他一些功能

	 /** 相册库 */
	@property (nonatomic, strong) ALAssetsLibrary *library;
 
二：然后就懒加载这个属性

	- (ALAssetsLibrary *)library
	{
	    if (!_library) {
	        _library = [[ALAssetsLibrary alloc] init];
	    }
	    return _library;
	}
 

三：点击保存按钮的实现
   
	- (IBAction)save
	{
    // 获得文件夹的名字
    __block NSString *groupName = [self groupName];
   
    // self的弱引用
    XMGWeakSelf;
   
    // 图片库
    __weak ALAssetsLibrary *weakLibrary = self.library;
   
    // 创建文件夹
    [weakLibrary addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
        if (group) { // 新创建的文件夹
            // 添加图片到文件夹中
            [weakSelf addImageToGroup:group];
        } else { // 文件夹已经存在
            [weakLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:groupName]) { // 是自己创建的文件夹
                    // 添加图片到文件夹中
					
					[weakSelf addImageToGroup:group];
                   
                    *stop = YES; // 停止遍历
                } else if ([name isEqualToString:@"Camera Roll"]) {
                    // 文件夹被用户强制删除了
                    groupName = [groupName stringByAppendingString:@" "];
                    // 存储新的名字
                    [[NSUserDefaults standardUserDefaults] setObject:groupName forKey:XMGGroupNameKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    // 创建新的文件夹
                    [weakLibrary addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
                        // 添加图片到文件夹中
                        [weakSelf addImageToGroup:group];
                    } failureBlock:nil];
                }
            } failureBlock:nil];
        }
	
		} failureBlock:nil];
		}

四：添加图片

	/**
	 * 添加一张图片到某个文件夹中
	 */
	- (void)addImageToGroup:(ALAssetsGroup *)group
	{
    __weak ALAssetsLibrary *weakLibrary = self.library;
    // 需要保存的图片
	
	CGImageRef image = self.imageView.image.CGImage;
   
    // 添加图片到【相机胶卷】
    [weakLibrary writeImageToSavedPhotosAlbum:image metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        [weakLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            // 添加一张图片到自定义的文件夹中
            [group addAsset:asset];
            [SVProgressHUD showSuccessWithStatus:@"保存成功!"];
        } failureBlock:nil];
    }];
	}
 
五：关于沙河中的组名
 
先定义一个用于保存名字用的key和一个需要保存的名字

	static NSString * const iCocosGroupNameKey = @"iCocosGroupNameKey";
	static NSString * const iCocosDefaultGroupName = @"iCocos";
 
实现祖名的存取
	
	- (NSString *)groupName
	{
   		// 先从沙盒中取得名字
   		
		NSString *groupName = [[NSUserDefaults standardUserDefaults] stringForKey:XMGGroupNameKey];
		if (groupName == nil) { // 沙盒中没有存储任何文件夹的名字
       groupName = XMGDefaultGroupName;
      
  		// 存储名字到沙盒中
 		[[NSUserDefaults standardUserDefaults] setObject:groupName forKey:XMGGroupNameKey];
     [[NSUserDefaults standardUserDefaults] synchronize];
   	}
   	return groupName;
	}
 
