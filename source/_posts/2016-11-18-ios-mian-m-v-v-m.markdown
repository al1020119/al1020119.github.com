
---
layout: post
title: "MVVM实战篇"
date: 2016-11-18 18:16:05 +0800
comments: true
categories: 
---



M:Model中定义对应的模型属性


	@property (nonatomic, copy) NSString *movieName;
	
	@property (nonatomic, copy) NSString *movieTime;
	
	@property (nonatomic, copy) NSString *movieDetail;
	
	@property (nonatomic, strong) NSURL *movieURL;





<!--more-->



VM：ViewModel中定义对应的逻辑+数据+回调+代理方法


	#import "iCocosModel.h"
	
	typedef void(^resultSuccessBlock)(id resultData);
	typedef void(^resultErrorBlock)(id resultError);
	
	@interface iCocosViewModel : NSObject
	
	- (void)getMoviesData;
	
	- (void)moviesDetailWithPublicModel:(iCocosModel *)model withViewController:(UIViewController *)controller;
	
	
	@property (nonatomic, copy) resultSuccessBlock successBlcok;
	
	@property (nonatomic, copy) resultErrorBlock errorBlcok;
	
	
	@end

实现对应的方法


	#import "iCocosDetailController.h"

	@implementation iCocosViewModel
	
	- (void)getMoviesData
	{
	    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	    
	    NSString *url = @"https://api.douban.com/v2/movie/coming_soon";
	    
	    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
	        
	    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
	        
	        NSArray *subjects = responseObject[@"subjects"];
	        NSMutableArray *modelArr = [NSMutableArray arrayWithCapacity:subjects.count];
	        for (NSDictionary *subject in subjects) {
	            iCocosModel *model = [[iCocosModel alloc] init];
	            model.movieName = subject[@"title"];
	            model.movieTime = subject[@"year"];
	            
	            NSString *urlStr = subject[@"images"][@"medium"];
	            model.movieURL = [NSURL URLWithString:urlStr];
	            model.movieDetail = subject[@"alt"];
	            [modelArr addObject:model];
	        }
	        _successBlcok(modelArr);
	        
	        
	    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
	        
	    }];
	}
	
	- (void)moviesDetailWithPublicModel:(iCocosModel *)model withViewController:(UIViewController *)controller
	{
	    iCocosDetailController *detailVC = [[iCocosDetailController alloc] init];
	    detailVC.url = model.movieDetail;
	    [controller.navigationController pushViewController:detailVC animated:YES];
	}
	
	@end


V:View+Controller包括视图和控制器

View视图和MVC一样，用模型属性给控件赋值

	#import "iCocosModel.h"
	
	@interface iCocosViewCell : UITableViewCell
	
	@property (nonatomic, strong) iCocosModel *model;

	@end

View的实现

	#import "iCocosViewCell.h"
	#import <UIImageView+AFNetworking.h>
	
	@interface iCocosViewCell ()
	
	@property (nonatomic,strong) UILabel *nameLabel;
	@property (nonatomic,strong) UILabel *yearLabel;
	@property (nonatomic,strong) UIImageView *imgView;
	
	@end
	
	
	@implementation iCocosViewCell
	
	- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	    if (self) {
	        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 60)];
	        [self.contentView addSubview:_imgView];
	        
	        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 200, 20)];
	        [self.contentView addSubview:_nameLabel];
	        
	        _yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 50, 100, 20)];
	        _yearLabel.textColor = [UIColor lightGrayColor];
	        _yearLabel.font = [UIFont systemFontOfSize:14];
	        [self.contentView addSubview:_yearLabel];
	    }
	    return self;
	}
	
	- (void)setModel:(iCocosModel *)model
	{
	    _model = model;
	    
	    _nameLabel.text = _model.movieName;
	    _yearLabel.text = _model.movieTime;
	    [_imgView setImage:model.movieURL];
	}
	
	@end




===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  