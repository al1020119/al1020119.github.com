---

layout: post
title: "取消TableView的Header与Footer的黏性效果"
date: 2015-11-28 00:24:40 +0800
comments: true
categories: 项目实战

---
 
引言：


最近做一个项目的时候，遇到了一个bug问题，或者说个人能力有限，想了很久没有想到最好的方法去现实。


###### 那么是什么问题呢？

 

首先当我在tabelView中为没饿过section设置一个header和footer之后，滑动tableView的时候，发现header和footer并不随着tableView中的cell一起滚动，而且会在顶部活着底部停留一段时间，这样的效果虽然好，但是上面就是不需要者也的功能，所以只好自己想办法解决。

 


<!--more-->





我记得有时候header是不会停顿的，可是为什么这个时候header和footer都隐藏呢？

后来发现原来设置tableView.tableHeaderView = ?或者footerView的时候就不会停顿，那是当然，因为这个是tableView的一部分，不是section的一部分。

也在网上找了一段这样的代码

###去掉UItableview headerview黏性(sticky)

	- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView == self.tableView)

    {

	        CGFloat sectionHeaderHeight = 64; //sectionHeaderHeight
	
	        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
	
	            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
	
	        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
	
	            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
	
	        }
	
	    }

	}
 

但是他职能设置headerView不能设置footerView，自己也试着去补充footerView的实现，但是发现技术有限，所以，你懂的！

### 最后看到国外一位大神写的一一篇文章找到了下面的代码

	 -(void)scrollViewDidScroll:(UIScrollView *)scrollView {

	    if (scrollView == self.tableView)
	
	        {
	
	        UITableView *tableview = (UITableView *)scrollView;
	
	        CGFloat sectionHeaderHeight = 64;
	
	        CGFloat sectionFooterHeight = 120;
	
	        CGFloat offsetY = tableview.contentOffset.y;
	
	        if (offsetY >= 0 && offsetY <= sectionHeaderHeight)
	
	        {
	
	            tableview.contentInset = UIEdgeInsetsMake(-offsetY, 0, -sectionFooterHeight, 0);
	
	        }else if (offsetY >= sectionHeaderHeight && offsetY <= tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight)
	
	        {
	
	            tableview.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, -sectionFooterHeight, 0);
	
	        }else if (offsetY >= tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight && offsetY <= tableview.contentSize.height - tableview.frame.size.height)         {
	
	            tableview.contentInset = UIEdgeInsetsMake(-offsetY, 0, -(tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight), 0);
	
	        }
	
    	}

	}


注：sectionHeaderHeight和sectionFooterHeight根据项目进行设置。

发现基本上搞定，最后只需要设置对应的内边距即可！

<!-- more -->

 