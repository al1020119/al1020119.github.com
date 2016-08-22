---

layout: post
title: "随笔记录，你懂得！"
date: 2016-05-05 13:53:19 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



---  


{% img /images/bgHeader.png Caption %}  


平时在开发中喜欢写一些随笔记录，可能是个人习惯问题，虽然不一定有用。

哈哈


<!--more-->



1. FPS=60帧，用户体验最好。

2. 加载Cell之后将数据的渲染写在	if(self.tableView.dragging==NO&&self.tableView.decelerating==NO)中。

3. 阴影圆角计算在GPU中进行

4. 注意设置alpha=1

5. 圆角使用layer的shouldRasterize而不是clipToBounds

6. 本身不透明设置opaque=YES

7. 加密方式：base64，MD5，DES（分组，堆成），SSKeychain，Cookie 

对称：加密和解密使用同一个算法
不对称：加密和解密使用两个不同的算法

8.tableViewCell分割线

    [self.tableView setTableFooterView:[[UIView alloc] init]];//FooterView
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;

9.tableView左边间距问题


	- (void)_leftLine {
	    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
	        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
	    } if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
	        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
	    }
	}
	
	- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
	        [cell setSeparatorInset:UIEdgeInsetsZero];
	    } if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
	        [cell setLayoutMargins:UIEdgeInsetsZero];
	    }
	    
	}

10. AVPlayer 最多只能创建16个

11. 安全
 
	- App代码安全，包括代码混淆，加密或者app加壳。
	- App数据存储安全，主要指在磁盘做数据持久化的时候所做的加密。
	- App网络传输安全，指对数据从客户端传输到Server中间过程的加密，防止网络世界当中其他节点对数据的窃听。
	
12. 算法安全
	
	- 对称加密算法，代表算法AES
	- 非对称加密算法，代表算法RSA，ECC
	- 电子签名，用于确认消息发送方的身份
	- 消息摘要生成算法，MD5，SHA，用于检测消息是否被第三方修改过
	
===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  