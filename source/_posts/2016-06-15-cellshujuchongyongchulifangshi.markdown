---

layout: post
title: "Cell重用数据混乱"
date: 2016-06-15 13:53:19 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---  



关于Cell重用，我们经常会遇到cell重用的时候数据不对，或者混乱的情况，这里笔者由于刚好遇到了在项目中，所以解决后整理了一下。

常规配置如下 当超过tableView显示的范围的时候 后面显示的内容将会和前面重复

<!--more-->


这样配置的话超过页面显示的内容会重复出现

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    // 定义唯一标识
	    static NSString *CellIdentifier = @"Cell";
	    // 通过唯一标识创建cell实例
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	    // 判断为空进行初始化  --（当拉动页面显示超过主页面内容的时候就会重用之前的cell，而不会再次初始化）
	    if (!cell) {
	        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	    }
	    // 对cell 进行简单地数据配置
	    cell.textLabel.text = @"text";
	    cell.detailTextLabel.text = @"text";
	    cell.imageView.image = [UIImage imageNamed:@"4.png"];
	    
	    return cell;
	}


通过以下3方案可以解决


方案一  取消cell的重用机制，通过indexPath来创建cell 将可以解决重复显示问题 不过这样做相对于大数据来说内存就比较吃紧了

通过不让他重用cell 来解决重复显示

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    // 定义唯一标识
	    static NSString *CellIdentifier = @"Cell";
	    // 通过indexPath创建cell实例 每一个cell都是单独的
	    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	    // 判断为空进行初始化  --（当拉动页面显示超过主页面内容的时候就会重用之前的cell，而不会再次初始化）
	    if (!cell) {
	        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	    }
	    // 对cell 进行简单地数据配置
	    cell.textLabel.text = @"text";
	    cell.detailTextLabel.text = @"text";
	    cell.imageView.image = [UIImage imageNamed:@"4.png"];
	    
	    return cell;
	}


方案二  让每个cell都拥有一个对应的标识 这样做也会让cell无法重用 所以也就不会是重复显示了 显示内容比较多时内存占用也是比较多的和方案一类似
同样通过不让他重用cell 来解决重复显示 不同的是每个cell对应一个标

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    // 定义cell标识  每个cell对应一个自己的标识
	    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",indexPath.section,indexPath.row];
	    // 通过不同标识创建cell实例
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	    // 判断为空进行初始化  --（当拉动页面显示超过主页面内容的时候就会重用之前的cell，而不会再次初始化）
	    if (!cell) {
	        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	    }
	    // 对cell 进行简单地数据配置
	    cell.textLabel.text = @"text";
	    cell.detailTextLabel.text = @"text";
	    cell.imageView.image = [UIImage imageNamed:@"4.png"];
	    
	    return cell;
	}


方案三 只要最后一个显示的cell内容不为空，然后把它的子视图全部删除，等同于把这个cell单独出来了 然后跟新数据就可以解决重复显示

 当页面拉动需要显示新数据的时候，把最后一个cell进行删除 就有可以自定义cell 此方案即可避免重复显示，又重用了cell相对内存管理来说是最好的方案 前两者相对比较消耗内存
 
	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    // 定义唯一标识
	    static NSString *CellIdentifier = @"Cell";
	    // 通过唯一标识创建cell实例
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	   
	    // 判断为空进行初始化  --（当拉动页面显示超过主页面内容的时候就会重用之前的cell，而不会再次初始化）
	    if (!cell) {
	        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	    }
	    else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
	    {
	        while ([cell.contentView.subviews lastObject] != nil) {
	            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
	        }
	    }
	    // 对cell 进行简单地数据配置
	    cell.textLabel.text = @"text";
	    cell.detailTextLabel.text = @"text";
	    cell.imageView.image = [UIImage imageNamed:@"4.png"];
	    
	    return cell;
	}

以上都是个人理解，本人也是菜鸟，有理解不对的地方希望大家指出，同时也希望能对大家起到一定的帮助！！ Thank you！ 



    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  