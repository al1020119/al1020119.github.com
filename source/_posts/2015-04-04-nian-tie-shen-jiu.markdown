---

layout: post
title: "粘贴深究"
date: 2015-04-08 02:59:00 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



---

 

在iOS中，可以使用剪贴板实现应用程序之中以及应用程序之间实现数据的共享。比如你可以从iPhone QQ复制一个url，然后粘贴到safari浏览器中查看这个链接的内容。

###一、在iOS中下面三个控件，自身就有复制-粘贴的功能：


* 1、UITextView
* 2、UITextField
* 3、UIWebView



<!--more-->




###二、UIKit framework提供了几个类和协议方便我们在自己的应用程序中实现剪贴板的功能。


* 1、UIPasteboard：我们可以向其中写入数据，也可以读取数据
* 2、UIMenuController：显示一个快捷菜单，用来复制、剪贴、粘贴选择的项。
* 3、UIResponder中的 canPerformAction:withSender:用于控制哪些命令显示在快捷菜单中。
* 4、当快捷菜单上的命令点击的时候，UIResponderStandardEditActions将会被调用。

###三、下面这些项能被放置到剪贴板中

* 1、UIPasteboardTypeListString —  字符串数组, 包含kUTTypeUTF8PlainText
* 2、UIPasteboardTypeListURL —   URL数组，包含kUTTypeURL
* 3、UIPasteboardTypeListImage —   图形数组, 包含kUTTypePNG 和kUTTypeJPEG
* 4、UIPasteboardTypeListColor —   颜色数组

###四、剪贴板的类型分为两种：

系统级：使用UIPasteboardNameGeneral和UIPasteboardNameFind创建，系统级的剪贴板，当应用程序关闭，或者卸载时，数据都不会丢失。
应用程序级：通过设置，可以让数据在应用程序关闭之后仍然保存在剪贴板中，但是应用程序卸载之后数据就会失去。我们可用通过pasteboardWithName:create：来创建。

了解这些之后，下面通过一系列的例子来说明如何在应用程序中使用剪贴板。

例子：

#####1、复制剪贴文本。

    下面通过一个例子，可以在tableview上显示一个快捷菜单，上面只有复制按钮，复制tableview上的数据之后，然后粘贴到title上。

定义一个单元格类CopyTableViewCell，在这个类的上显示快捷菜单，实现复制功能。
	
	@interface CopyTableViewCell : UITableViewCell {
	    id delegate;
	}
	@property (nonatomic, retain) id delegate;
	@end

实现CopyTableViewCell ：

	#import "CopyTableViewCell.h"
	
	@implementation CopyTableViewCell
	
	@synthesize delegate;
	
	- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
	    }
	    return self;
	}
	- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	    [super setSelected:selected animated:animated];
	}
	- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	    [[self delegate] performSelector:@selector(showMenu:)
	                          withObject:self afterDelay:0.9f];
	
	    [super setHighlighted:highlighted animated:animated];
	
	}
	- (BOOL)canBecomeFirstResponder
	{
	    return YES;
	}
	- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
	    if (action == @selector(cut:)){
	        return NO;
	    }
	    else if(action == @selector(copy:)){
	        return YES;
	    }
	    else if(action == @selector(paste:)){
	        return NO;
	    }
	    else if(action == @selector(select:)){
	        return NO;
	    }
	    else if(action == @selector(selectAll:)){
	        return NO;
	    }
	    else
	    {
	        return [super canPerformAction:action withSender:sender];
	    }
	}
	- (void)copy:(id)sender {
	    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	    [pasteboard setString:[[self textLabel]text]];
	}
	- (void)dealloc {
	    [super dealloc];
	}
	@end
复制代码
定义CopyPasteTextController，实现粘贴功能。
	@interface CopyPasteTextController : UIViewController<UITableViewDelegate> {
	    //用来标识是否显示快捷菜单
	    BOOL menuVisible;
	    UITableView *tableView;
	}
	
	@property (nonatomic, getter=isMenuVisible) BOOL menuVisible;
	
	@property (nonatomic, retain) IBOutlet UITableView *tableView;
	@end
实现CopyPasteTextController ：
	
	#import "CopyPasteTextController.h"
	#import "CopyTableViewCell.h"
	
	@implementation CopyPasteTextController
	@synthesize menuVisible,tableView;
	- (void)viewDidLoad {
	    [super viewDidLoad];
	    [self setTitle:@"文字复制粘贴"];
	    //点击这个按钮将剪贴板的内容粘贴到title上
	    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
	                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
	                                      target:self
	                                      action:@selector(readFromPasteboard:)]
	                                     autorelease];
	    [[self navigationItem] setRightBarButtonItem:addButton];
	}
	
	
	// Customize the number of sections in the table view.
	- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
	{
	    return 1;
	}
	
	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	{
	    return 9;
	}
	
	// Customize the appearance of table view cells.
	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    static NSString *CellIdentifier =@"Cell";
	    CopyTableViewCell *cell = (CopyTableViewCell *)[tableView
	                                                           dequeueReusableCellWithIdentifier:CellIdentifier];
	    if (cell == nil)
	    {
	        cell = [[[CopyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	        [cell setDelegate:self];
	    }
	
	    // Configure the cell.
	    NSString *text = [NSString stringWithFormat:@"Row %d", [indexPath row]];
	    [[cell textLabel] setText:text];
	    return cell;
	}
	
	- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    if([self isMenuVisible])
	    {
	        return;
	    }
	    [[[self tableView] cellForRowAtIndexPath:indexPath] setSelected:YES
	                                                           animated:YES];
	}
	//显示菜单
	- (void)showMenu:(id)cell {
	    if ([cell isHighlighted]) {
	        [cell becomeFirstResponder];
	
	        UIMenuController * menu = [UIMenuController sharedMenuController];
	        [menu setTargetRect: [cell frame] inView: [self view]];
	        [menu setMenuVisible: YES animated: YES];
	    }
	}
	- (void)readFromPasteboard:(id)sender {
	    [self setTitle:[NSString stringWithFormat:@"Pasteboard = %@",
	                      [[UIPasteboard generalPasteboard] string]]];
	}
	
	- (void)didReceiveMemoryWarning
	{
	    // Releases the view if it doesn't have a superview.
	    [super didReceiveMemoryWarning];
	
	    // Relinquish ownership any cached data, images, etc that aren't in use.
	}
	
	- (void)viewDidUnload
	{
	    [super viewDidUnload];
	    [self.tableView release];
	
	    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	    // For example: self.myOutlet = nil;
	}
复制一行数据：
点击右上角的按钮粘贴，将数据显示在title上：

######2、图片复制粘贴

   下面通过一个例子，将图片复制和剪贴到另外一个UIImageView中间。

* 1、在界面上放置两个uiimageview，一个是图片的数据源，一个是将图片粘贴到的地方。CopyPasteImageViewController 代码如下：

@interface CopyPasteImageViewController : UIViewController {
    UIImageView *imageView;
    UIImageView *pasteView;
    UIImageView *selectedView;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *pasteView;
@property (nonatomic, retain) UIImageView *selectedView;
- (void)placeImageOnPasteboard:(id)view;
@end
* 2、当触摸图片的时候我们显示快捷菜单：
***
	- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	    NSSet *copyTouches = [event touchesForView:imageView];
	    NSSet *pasteTouches = [event touchesForView:pasteView];
	
	    [self becomeFirstResponder];
	    if ([copyTouches count] > 0) {
	        [self performSelector:@selector(showMenu:)
	                   withObject:imageView afterDelay:0.9f];
	    }
	    else  if([pasteTouches count] > 0) {
	        [self performSelector:@selector(showMenu:)
	                   withObject:pasteView afterDelay:0.9f];
	    }
	    [super touchesBegan:touches withEvent:event];
	}
	
	- (void)showMenu:(id)view {
	    [self setSelectedView:view];
	
	    UIMenuController * menu = [UIMenuController sharedMenuController];
	    [menu setTargetRect: CGRectMake(5, 10, 1, 1) inView: view];
	    [menu setMenuVisible: YES animated: YES];
	}
这里的快捷菜单，显示三个菜单项：剪贴、粘贴、复制：
***
	- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
	    if (action == @selector(cut:)) {
	        return ([self selectedView] == imageView) ? YES : NO;
	    } else if (action == @selector(copy:)) {
	        return ([self selectedView] == imageView) ? YES : NO;
	    } else if (action == @selector(paste:)) {
	        return ([self selectedView] == pasteView) ? YES : NO;
	    } else if (action == @selector(select:)) {
	        return NO;
	    } else if (action == @selector(selectAll:)) {
	        return NO;
	    } else {
	        return [super canPerformAction:action withSender:sender];
	    }
	}
	- (void)cut:(id)sender {
	    [self copy:sender];
	    [imageView setHidden:YES];
	}
	- (void)copy:(id)sender {
	    [self placeImageOnPasteboard:[self imageView]];
	}
	- (void)paste:(id)sender {
	    UIPasteboard *appPasteBoard =
	    [UIPasteboard pasteboardWithName:@"CopyPasteImage" create:YES];
	    NSData *data =[appPasteBoard dataForPasteboardType:@"com.marizack.CopyPasteImage.imageView"];
	    pasteView.image = [UIImage imageWithData:data];
	}
	 


<!--more-->