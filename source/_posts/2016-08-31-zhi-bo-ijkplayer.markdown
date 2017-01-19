---
layout: post
title: "直播-iJKPlayer"
date: 2016-09-10 14:42:37 +0800
comments: true
categories: Audio  Video and Lve Radio
---


demo:[iCocosIJKPlayer](https://github.com/al1020119/iCocosIJKPlayer)

网上讨论比较多并且支持Android/iOS的项目

    Vitamio
    IJKPlayer

首先说下Vitamio目前可以拿到的版本是4.20，商业使用需要付费。

这里只介绍IJKPlayer，为什么？用了你就知道了！




<!--more-->



ijkplayer 是一款做视频直播的框架, 基于ffmpeg, 支持 Android 和 iOS, 网上也有很多集成说明, 但是个人觉得还是不够详细, 在这里详细的讲一下在 iOS 中如何集成ijkplayer, 即便以前从没有接触过, 按着下面做也可以集成成功!

[ijkPlayer下载地址](https://github.com/Bilibili/ijkplayer)

[ijkPlayer详解](http://blog.csdn.net/zc639143029/article/details/51191886)

必备条件:

	# install homebrew, git, yasm
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew install git
	brew install yasm



###一. 下载ijkplayer

[ijkplayer下载地址](https://github.com/Bilibili/ijkplayer)

下载完成后解压, 解压后文件夹内部目录如下图:

{% img /images/ijkplayer001.png Caption %} 



###二. 编译 ijkplayer

说是编译 ijkplayer, 其实是编译 ffmpeg, 在这里我们已经下载好了ijkplayer, 所以 github 上README.md中的Build iOS那一步中有一些步骤是不需要的.

下面开始一步一步编译:

1. 打开终端, cd 到jkplayer-master文件夹中, 也就是下载完解压后的文件夹, 如下图:

{% img /images/ijkplayer002.png Caption %} 
2. 执行命令行./init-ios.sh, 这一步是去下载 ffmpeg 的, 时间会久一点, 耐心等一下.如下图:

{% img /images/ijkplayer003.png Caption %} 
3. 在第2步中下载完成后, 执行cd ios, 也就是进入到 ios目录中, 如下图:

{% img /images/ijkplayer004.png Caption %} 
4. 进入 ios 文件夹后, 在终端依次执行./compile-ffmpeg.sh clean和./compile-ffmpeg.sh all命令, 编译 ffmpeg, 也就是README.md中这两步, 如下图:

{% img /images/ijkplayer005.png Caption %} 
编译时间较久, 耐心等待一下.

	./init-ios.sh
	cd ios
	./compile-ffmpeg.sh clean
	./compile-ffmpeg.sh all


###三. 打包IJKMediaFramework.framework框架

集成 ijkplayer 有两种方法: 一种方法是按照IJKMediaDemo工程中那样, 直接导入工程IJKMediaPlayer.xcodeproj, 在这里不做介绍, 如下图:

{% img /images/ijkplayer006.png Caption %} 
第二种集成方法是把 ijkplayer 打包成framework导入工程中使用. 下面开始介绍如何打包IJKMediaFramework.framework, 按下面步骤开始一步一步做:

1. 首先打开工程IJKMediaPlayer.xcodeproj, 位置如下图:

{% img /images/ijkplayer007.png Caption %} 
打开后是这样的, 如下图:

{% img /images/ijkplayer008.png Caption %} 
2. 工程打开后设置工程的 scheme, 具体步骤如下图:

{% img /images/ijkplayer009.png Caption %} 
{% img /images/ijkplayer010.png Caption %} 
3. 设置好 scheme 后, 分别选择真机和模拟器进行编译, 编译完成后, 进入 Finder, 如下图:

{% img /images/ijkplayer011.png Caption %} 
进入 Finder 后, 可以看到有真机和模拟器两个版本的编译结果, 如下图:

{% img /images/ijkplayer012.png Caption %} 
下面开始合并真机和模拟器版本的 framework, 注意不要合并错了, 合并的是这个文件, 如下图:

{% img /images/ijkplayer013.png Caption %} 
打开终端, 进行合并, 命令行具体格式为:

lipo -create "真机版本路径" "模拟器版本路径" -output "合并后的文件路径"

合并后如下图:

{% img /images/ijkplayer014.png Caption %} 
下面很重要, 需要用合并后的IJKMediaFramework把原来的IJKMediaFramework替换掉, 如下图, 希望你能看懂:

{% img /images/ijkplayer015.png Caption %} 
上图中的1、2两步完成后, 绿色框住的那个IJKMediaFramework.framework文件就是我们需要的框架了, 可以复制出来, 稍后我们需要导入工程使用.


###四. iOS工程中集成ijkplayer

新建工程, 导入合并后的IJKMediaFramework.framework以及相关依赖框架以及相关依赖框架,如下图:

{% img /images/ijkplayer016.png Caption %} 
导入框架后, 在ViewController.m进行测试, 首先导入IJKMediaFramework.h头文件, 编译看有没有错, 如果没有错说明集成成功.

接着开始在ViewController.m文件中使用IJKMediaFramework框架进行测试使用, 写一个简单的直播视频进行测试, 在这里看一下运行后的结果, 后面会放上 Demo 供下载.

{% img /images/ijkplayer0017.png Caption %} 

{% img /images/ijkplayer018.png Caption %} 

	为苦于各种奇怪原因而无法玩耍的小伙伴们提供了包装了ijkplayer的pod，仅供测试体验。
	1.基于ijkplayer 5737ccc提交制作成的framework，需要注意的是需要iOS8+。
	2.如果使用ijkplayer过程中遇到BUG什么的，可以移步去ijkplayer作者的GitHub上提issue或者PR。
	哦对了，地址在这里https://coding.net/u/shirokuma/p/IJKMediaLibrary/git，因framework超过100MB无法传到GitHub上，就放到Coding上了。祝各位玩的愉快！



项目源码：（在集成或者使用之前请细细品读，也许你会发现不一样的乐趣）
	
	//
	//  ViewController.m
	//  iCocosIjkPlayer
	//
	//  Created by tqy on 16/8/8.
	//  Copyright © 2016年 iCocos. All rights reserved.
	//
	
	#import "ViewController.h"
	
	#import <IJKMediaFramework/IJKMediaFramework.h>
	
	@interface ViewController ()
	
	@property (nonatomic, strong) NSURL *url;
	
	@property (nonatomic, retain) id<IJKMediaPlayback> player;
	
	@property (nonatomic, weak) UIView *PlayerView;
	
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad {
	    [super viewDidLoad];
	    
	    
	    
	    //网络视频
	    //    self.url = [NSURL URLWithString:@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
	    //    _player = [[IJKAVMoviePlayerController alloc] initWithContentURL:self.url];
	    
	    //直播视频
	    self.url = [NSURL URLWithString:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
	    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:nil];
	    
	    UIView *playerView = [self.player view];
	    
	    UIView *displayView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 180)];
	    self.PlayerView = displayView;
	    self.PlayerView.backgroundColor = [UIColor blackColor];
	    [self.view addSubview:self.PlayerView];
	    
	    playerView.frame = self.PlayerView.bounds;
	    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	    
	    [self.PlayerView insertSubview:playerView atIndex:1];
	    [_player setScalingMode:IJKMPMovieScalingModeAspectFill];
	    [self installMovieNotificationObservers];
	    
	}
	
	-(void)viewWillAppear:(BOOL)animated{
	    if (![self.player isPlaying]) {
	        [self.player prepareToPlay];
	    }
	}
	
	#pragma Selector func
	
	- (void)loadStateDidChange:(NSNotification*)notification {
	    IJKMPMovieLoadState loadState = _player.loadState;
	    
	    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
	        NSLog(@"LoadStateDidChange: IJKMovieLoadStatePlayThroughOK: %d\n",(int)loadState);
	    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
	        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
	    } else {
	        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
	    }
	}
	
	- (void)moviePlayBackFinish:(NSNotification*)notification {
	    int reason =[[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
	    switch (reason) {
	        case IJKMPMovieFinishReasonPlaybackEnded:
	            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
	            break;
	            
	        case IJKMPMovieFinishReasonUserExited:
	            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
	            break;
	            
	        case IJKMPMovieFinishReasonPlaybackError:
	            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
	            break;
	            
	        default:
	            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
	            break;
	    }
	}
	
	- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
	    NSLog(@"mediaIsPrepareToPlayDidChange\n");
	}
	
	- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
	    switch (_player.playbackState) {
	        case IJKMPMoviePlaybackStateStopped:
	            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
	            break;
	            
	        case IJKMPMoviePlaybackStatePlaying:
	            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
	            break;
	            
	        case IJKMPMoviePlaybackStatePaused:
	            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
	            break;
	            
	        case IJKMPMoviePlaybackStateInterrupted:
	            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
	            break;
	            
	        case IJKMPMoviePlaybackStateSeekingForward:
	        case IJKMPMoviePlaybackStateSeekingBackward: {
	            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
	            break;
	        }
	            
	        default: {
	            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
	            break;
	        }
	    }
	}
	
	#pragma Install Notifiacation
	
	- (void)installMovieNotificationObservers {
	    [[NSNotificationCenter defaultCenter] addObserver:self
	                                             selector:@selector(loadStateDidChange:)
	                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
	                                               object:_player];
	    [[NSNotificationCenter defaultCenter] addObserver:self
	                                             selector:@selector(moviePlayBackFinish:)
	                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
	                                               object:_player];
	    
	    [[NSNotificationCenter defaultCenter] addObserver:self
	                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
	                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
	                                               object:_player];
	    
	    [[NSNotificationCenter defaultCenter] addObserver:self
	                                             selector:@selector(moviePlayBackStateDidChange:)
	                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
	                                               object:_player];
	    
	}
	
	- (void)removeMovieNotificationObservers {
	    [[NSNotificationCenter defaultCenter] removeObserver:self
	                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
	                                                  object:_player];
	    [[NSNotificationCenter defaultCenter] removeObserver:self
	                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
	                                                  object:_player];
	    [[NSNotificationCenter defaultCenter] removeObserver:self
	                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
	                                                  object:_player];
	    [[NSNotificationCenter defaultCenter] removeObserver:self
	                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
	                                                  object:_player];
	    
	}
	
	
	- (IBAction)play_btn:(id)sender {
	    
	    if (![self.player isPlaying]) {
	        [self.player play];
	    }else{
	        [self.player pause];
	    }
	}
	
	@end







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