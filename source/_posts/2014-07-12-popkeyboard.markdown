---

layout: post
title: "你是怎么退出键盘的？"
date: 2014-07-12 13:53:19 +0800
comments: true
categories: 项目实战 

--- 

iOS开发中键盘的退出方法用很多中我们应该在合适的地方使用合适的方法才能更好的提高开发的效率和应用的性能

下面给大家介绍几种最常用的键盘退出方法，基本上iOS开发中的键盘退出方法都是这几种中的一种活着几种。

 


<!--more-->





一：textView

	//通过委托来实现放弃第一响应者
	#pragma mark - UITextView Delegate  Method
	-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
	{
	    if([text isEqualToString:@"\n"]) {
	        [textView resignFirstResponder];
	        return NO;
	    }
	    return YES;
	}
 

 

二：textFiled

	//通过委托来实现放弃第一响应者
	#pragma mark - UITextField Delegate Method
	- (BOOL)textFieldShouldReturn:(UITextField *)textField
	{
	    [textField resignFirstResponder];
	    return YES;
	}
 

三：触摸屏幕

	1 ／／所有的界面都可以实现
	2 -(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
	3 {
	4     [self.view endEditing:YES];
	5 }
 

四：ScrollView拖拽

	 1 -(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
	 2 { 
	 3 		[self.view endEditing:YES]; 
	 4 } 

 

> 注：结合使用endEditing和resignFirstResponder

 

五：通知方式

注册与移除通知

	-(void) viewWillAppear:(BOOL)animated {
	    
	    //注册键盘出现通知
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:)
	                                                 name: UIKeyboardDidShowNotification object:nil];
	    //注册键盘隐藏通知
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:)
	                                                 name: UIKeyboardDidHideNotification object:nil];
	    [super viewWillAppear:animated];
	}
	
	
	-(void) viewWillDisappear:(BOOL)animated {
	    //解除键盘出现通知
	    [[NSNotificationCenter defaultCenter] removeObserver:self
	                                                    name: UIKeyboardDidShowNotification object:nil];
	    //解除键盘隐藏通知
	    [[NSNotificationCenter defaultCenter] removeObserver:self
	                                                    name: UIKeyboardDidHideNotification object:nil];
	    
	    [super viewWillDisappear:animated];
	}
实现通知的方法：

	-(void) keyboardDidShow: (NSNotification *)notif {
	    
	    if (keyboardVisible) {//键盘已经出现要忽略通知
	        return;
	    }
	    // 获得键盘尺寸
	    NSDictionary* info = [notif userInfo];
	    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	    CGSize keyboardSize = [aValue CGRectValue].size;
	    
	    //重新定义ScrollView的尺寸
	    CGRect viewFrame = self.scrollView.frame;
	    viewFrame.size.height -= (keyboardSize.height);
	    self.scrollView.frame = viewFrame;
	    
	    //滚动到当前文本框
	    CGRect textFieldRect = [self.textField frame];
	    [self.scrollView scrollRectToVisible:textFieldRect animated:YES];
	    
	    keyboardVisible = YES;
	}
	
	-(void) keyboardDidHide: (NSNotification *)notif {
	    
	    NSDictionary* info = [notif userInfo];
	    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	    CGSize keyboardSize = [aValue CGRectValue].size;
	    
	    CGRect viewFrame = self.scrollView.frame;
	    viewFrame.size.height += keyboardSize.height;
	    self.scrollView.frame = viewFrame;
	    
	    if (!keyboardVisible) {
	        return;
	    }
	    
	    keyboardVisible = NO;
	    
	}
	 
	
