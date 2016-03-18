---
layout: post
title: "怎么封装一个控件"
date: 2014-11-05 17:44:16 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---



一个控件从外在特征来说，主要是封装这几点：

* 交互方式
* 显示样式
* 数据使用

对外在特征的封装，能让我们在多种环境下达到 PM 对产品的要求，并且提到代码复用率，使维护工作保持在一个相对较小的范围内；而一个好的控件除了有对外一致的体验之外，还有其内在特征：

* 灵活性
* 低耦合
* 易拓展
* 易维护



<!--more-->





通常特征之间需要做一些取舍，比如灵活性与耦合度，有时候接口越多越能适应各种环境，但是接口越少对外产生的依赖就越少，维护起来也更容易。通常一些前期看起来还不错的代码，往往也会随着时间加深慢慢“成长”，功能的增加也会带来新的接口，很不自觉地就加深了耦合度，在开发中时不时地进行一些重构工作很有必要。总之，尽量减少接口的数量，但有足够的定制空间，可以在一开始把接口全部隐藏起来，再根据实际需要慢慢放开。

自定义控件在 iOS 项目里很常见，通常页面之间入口很多，而且使用场景极有可能大不相同，比如一个 UIView 既可以以代码初始化，也可以以 xib 的形式初始化，而我们是需要保证这两种操作都能产生同样的行为。本文将会讨论到以下几点：

* 选择正确的初始化方式
* 调整布局的时机
* 正确的处理 touches 方法
* drawRectCALayer 与动画
* UIControl 与 UIButton
* 更友好的支持 xib
* 不规则图形和事件触发范围（事件链的简单介绍以及处理）
* 合理使用 KVO


如果这些问题你一看就懂的话就不用继续往下看了。

设计方针

选择正确的初始化方式

UIView 的首要问题就是既能从代码中初始化，也能从 xib 中初始化，两者有何不同? UIView 是支持 NSCoding 协议的，当在 xib 或 storyboard 里存在一个 UIView 的时候，其实是将 UIView 序列化到文件里（xib 和 storyboard 都是以 XML 格式来保存的），加载的时候反序列化出来，所以：

* 当从代码实例化 UIView 的时候，initWithFrame 会执行；
* 当从文件加载 UIView 的时候，initWithCoder 会执行。


从代码中加载

虽然 initWithFrame 是 UIView 的Designated Initializer，理论上来讲你继承自 UIView 的任何子类，该方法最终都会被调用，但是有一些类在初始化的时候没有遵守这个约定，如 UIImageView 的 initWithImage 和 UITableViewCell 的 initWithStyle:reuseIdentifier: 的构造器等，所以我们在写自定义控件的时候，最好只假设父视图的 Designated Initializer 被调用。

如果控件在初始化或者在使用之前必须有一些参数要设置，那我们可以写自己的 Designated Initializer 构造器，如：

	- (instancetype)initWithName:(NSString *)name;
在实现中一定要调用父类的 Designated Initializer，而且如果你有多个自定义的 Designated Initializer，最终都应该指向一个全能的初始化构造器：

	- (instancetype)initWithName:(NSString *)name {
	    self = [self initWithName:name frame:CGRectZero];
	    return self;
	}
	- (instancetype)initWithName:(NSString *)name frame:(CGRect)frame {
	    self = [super initWithFrame:frame];
	    if (self) {
	        self.name = name;
	    }
	    return self;
	}
并且你要考虑到，因为你的控件是继承自 UIView 或 UIControl 的，那么用户完全可以不使用你提供的构造器，而直接调用基类的构造器，所以最好重写父类的 Designated Initializer，使它调用你提供的 Designated Initializer ，比如父类是个 UIView：

	- (instancetype)initWithFrame:(CGRect)frame {
	    self = [self initWithName:nil frame:frame];
	    return self;
	}
这样当用户从代码里初始化你的控件的时候，就总是逃脱不了你需要执行的初始化代码了，哪怕用户直接调用 init 方法，最终还是会回到父类的 Designated Initializer 上。

从 xib 或 storyboard 中加载

当控件从 xib 或 storyboard 中加载的时候，情况就变得复杂了，首先我们知道有 initWithCoder 方法，该方法会在对象被反序列化的时候调用，比如从文件加载一个 UIView 的时候：

	UIView *view = [[UIView alloc] init];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:view];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"KeyView"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	data = [[NSUserDefaults standardUserDefaults] objectForKey:@"KeyView"];
	view = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSLog(@"%@", view);
执行 unarchiveObjectWithData 的时候， initWithCoder 会被调用，那么你有可能会在这个方法里做一些初始化工作，比如恢复到保存之前的状态，当然前提是需要在 encodeWithCoder 中预先保存下来。

不过我们很少会自己直接把一个 View 保存到文件中，一般是在 xib 或 storyboard 中写一个 View，然后让系统来完成反序列化的工作，此时在 initWithCoder 调用之后，awakeFromNib 方法也会被执行，既然在 awakeFromNib 方法里也能做初始化操作，那我们如何抉择?

一般来说要尽量在 initWithCoder 中做初始化操作，毕竟这是最合理的地方，只要你的控件支持序列化，那么它就能在任何被反序列化的时候执行初始化操作，这里适合做全局数据、状态的初始化工作，也适合手动添加子视图。

awakeFromNib 相较于 initWithCoder 的优势是：当 awakeFromNib 执行的时候，各种 IBOutlet 也都连接好了；而 initWithCoder 调用的时候，虽然子视图已经被添加到视图层级中，但是还没有引用。如果你是基于 xib 或 storyboard 创建的控件，那么你可能需要对 IBOutlet 连接的子控件进行初始化工作，这种情况下，你只能在 awakeFromNib 里进行处理。同时 xib 或 storyboard 对灵活性是有打折的，因为它们创建的代码无法被继承，所以当你选择用 xib 或 storyboard 来实现一个控件的时候，你已经不需要对灵活性有很高的要求了，唯一要做的是要保证用户一定是通过 xib 创建的此控件，否则可能是一个空的视图，可以在 initWithFrame 里放置一个 断言 或者异常来通知控件的用户。

最后还要注意视图层级的问题，比如你要给 View 放置一个背景，你可能会在 initWithCoder 或 awakeFromNib 中这样写：

	[self addSubview:self.backgroundView]; // 通过懒加载一个背景 View，然后添加到视图层级上
你的本意是在控件的最下面放置一个背景，却有可能将这个背景覆盖到控件的最上方，原因是用户可能会在 xib 里写入这个控件，然后往它上面添加一些子视图，这样一来，用户添加的这些子视图会在你添加背景之前先进入视图层级，你的背景被添加后就挡住了用户的子视图。如果你想支持用户的这种操作，可以把 addSubview 替换成 insertSubview:atIndex:。

同时支持从代码和文件中加载

如果你要同时支持 initWithFrame 和 initWithCoder ，那么你可以提供一个 commonInit 方法来做统一的初始化：

	- (id)initWithCoder:(NSCoder *)aDecoder {
	    self = [super initWithCoder:aDecoder];
	    if (self) {
	        [self commonInit];
	    }
	    return self;
	}
	- (id)initWithFrame:(CGRect)frame {
	    self = [super initWithFrame:frame];
	    if (self) {
	        [self commonInit];
	    }
	    return self;
	}
	- (void)commonInit {
	    // do something ...
	}
awakeFromNib 方法里就不要再去调用 commonInit 了。

调整布局的时机

当一个控件被初始化以及开始使用之后，它的 frame 仍然可能发生变化，我们也需要接受这些变化，因为你提供的是 UIView 的接口，UIView 有很多种初始化方式：initWithFrame、initWithCoder、init 和类方法 new，用户完全可以在初始化之后再设置 frame 属性，而且用户就算使用 initWithFrame 来初始化也避免不了 frame 的改变，比如在横竖屏切换的时候。为了确保当它的 Size 发生变化后其子视图也能同步更新，我们不能一开始就把布局写死（使用约束除外）。

基于 frame

如果你是直接基于 frame 来布局的，你应该确保在初始化的时候只添加视图，而不去设置它们的frame，把设置子视图 frame 的过程全部放到 layoutSubviews 方法里：

	- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	    self = [super initWithCoder:aDecoder];
	    if (self) {
	        [self commonInit];
	    }
	    return self;
	}
	- (instancetype)initWithFrame:(CGRect)frame {
	    self = [super initWithFrame:frame];
	    if (self) {
	        [self commonInit];
	    }
	    return self;
	}
	- (void)layoutSubviews {
	    [super layoutSubviews];
	    self.label.frame = CGRectInset(self.bounds, 20, 0);
	}
	- (void)commonInit {
	    [self addSubview:self.label];
	}
	- (UILabel *)label {
	    if (_label == nil) {
	        _label = [UILabel new];
	        _label.textColor = [UIColor grayColor];
	    }
	    return _label;
	}
这么做就能保证 label 总是出现在正确的位置上。 

使用 layoutSubviews 方法有几点需要注意：

不要依赖前一次的计算结果，应该总是根据当前最新值来计算
由于 layoutSubviews 方法是在自身的 bounds 发生改变的时候调用， 因此 UIScrollView 会在滚动时不停地调用，当你只关心 Size 有没有变化的时候，可以把前一次的 Size 保存起来，通过与最新的 Size 比较来判断是否需要更新，在大多数情况下都能改善性能
基于 Auto Layout 约束

如果你是基于 Auto Layout 约束来进行布局，那么可以在 commonInit 调用的时候就把约束添加上去，不要重写 layoutSubviews 方法，因为这种情况下它的默认实现就是根据约束来计算 frame。最重要的一点，把 translatesAutoresizingMaskIntoConstraints 属性设为 NO，以免产生 NSAutoresizingMaskLayoutConstraint 约束，如果你使用 Masonry 框架的话，则不用担心这个问题，mas_makeConstraints 方法会首先设置这个属性为 NO:

	- (void)commonInit {
	    ...
	    [self setupConstraintsForSubviews];
	}
	- (void)setupConstraintsForSubviews {
	    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
	        ...
	    }];
	}
支持 sizeToFit

如果你的控件对尺寸有严格的限定，比如有一个统一的宽高比或者是固定尺寸，那么最好能实现系统给出的约定成俗的接口。

sizeToFit 用在基于 frame 布局的情况下，由你的控件去实现 sizeThatFits: 方法：

	- (CGSize)sizeThatFits:(CGSize)size {
	    CGSize fitSize = [super sizeThatFits:size];
	    fitSize.height += self.label.frame.size.height;
	    // 如果是固定尺寸，就像 UISwtich 那样返回一个固定 Size 就 OK 了
	    return fitSize;
	}
然后在外部调用该控件的 sizeToFit 方法，这个方法内部会自动调用 sizeThatFits 并更新自身的 Size：

[self.customView sizeToFit];
在 ViewController 里调整视图布局

当执行 viewDidLoad 方法时，不要依赖 self.view 的 Size。很多人会这样写：

	- (void)viewDidLoad {
	    ...
	    self.label.width = self.view.width;
	}
这样是不对的，哪怕看上去没问题也只是碰巧没问题而已。当 viewDidLoad 方法被调用的时候，self.view 才刚刚被初始化，此时它的容器还没有对它的 frame 进行设置，如果 view 是从 xib 加载的，那么它的 Size 就是 xib 中设置的值；如果它是从代码加载的，那么它的 Size 和屏幕大小有关系，除了 Size 以外，Origin 也不会准确。整个过程看起来像这样：

当访问 ViewController 的 view 的时候，ViewController 会先执行 loadViewIfRequired 方法，如果 view 还没有加载，则调用 loadView，然后是 viewDidLoad 这个钩子方法，最后是返回 view，容器拿到 view 后，根据自身的属性（如 edgesForExtendedLayout、判断是否存在 tabBar、判断 navigationBar 是否透明等）添加约束或者设置 frame。

你至少应该设置 autoresizingMask 属性：

	- (void)viewDidLoad {
	    ...
	    self.label.width = self.view.width;
	    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}
或者在 viewDidLayoutSubviews 里处理：

	- (void)viewDidLayoutSubviews {
	    [super viewDidLayoutSubviews];
	    self.label.width = self.view.width;
	}
如果是基于 Auto Layout 来布局，则在 viewDidLoad 里添加约束即可。

正确的处理 touches 方法

如果你需要重写 touches 方法，那么应该完整的重写这四个方法：

	- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
	- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
	- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
	- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
当你的视图在这四个方法执行的时候，如果已经对事件进行了处理，就不要再调用 super 的 touches 方法，super 的 touches 方法默认实现是在响应链里继续转发事件（UIView 的默认实现）。如果你的基类是 UIScrollView 或者 UIButton 这些已经重写了事件处理的类，那么当你不想处理事件的时候可以调用 self.nextResponder 的 touches 方法来转发事件，其他的情况就调用 super 的 touches 方法来转发，比如 UIScrollView 可以这样来转发 触摸 事件：

	- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	    if (!self.dragging) {
	        [self.nextResponder touchesBegan: touches withEvent:event]; 
	    }       
	    [super touchesBegan: touches withEvent: event];
	}
	- (void)touchesMoved...
	- (void)touchesEnded...
	- (void)touchesCancelled...
这么实现以后，当你仅仅只是“碰”一个 UIScrollView 的时候，该事件就有可能被 nextResponder 处理。 

如果你没有实现自己的事件处理，也没有调用 nextResponder 和 super，那么响应链就会断掉。另外，尽量用手势识别器去处理自定义事件，它的好处是你不需要关心响应链，逻辑处理起来也更加清晰，事实上，UIScrollView 也是通过手势识别器实现的：

	@property(nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer NS_AVAILABLE_IOS(5_0); 
	@property(nonatomic, readonly) UIPinchGestureRecognizer *pinchGestureRecognizer NS_AVAILABLE_IOS(5_0);
drawRect、CALayer 与动画

drawRect 方法很适合做自定义的控件，当你需要更新 UI 的时候，只要用 setNeedsDisplay 标记一下就行了，这么做又简单又方便；控件也常常用于封装动画，但是动画却有可能被移除掉。 

需要注意的地方：

1. 在 drawRect 里尽量用 CGContext 绘制 UI。如果你用 addSubview 插入了其他的视图，那么当系统在每次进入绘制的时候，会先把当前的上下文清除掉（此处不考虑 clearsContextBeforeDrawing 的影响），然后你也要清除掉已有的 subviews，以免重复添加视图；用户可能会往你的控件上添加他自己的子视图，然后在某个情况下清除所有的子视图（我就喜欢这么做）：

[subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
2. 用 CALayer 代替 UIView。CALayer 节省内存，而且更适合去做一个“图层”，因为它不会接收事件、也不会成为响应链中的一员，但是它能够响应父视图（或 layer）的尺寸变化，这种特性很适合做单纯的数据展示：

	CALayer *imageLayer = [CALayer layer];
	imageLayer.frame = rect;
	imageLayer.contents = (id)image;
	[self.view.layer addSublayer:imageLayer];
3. 如果有可能的话使用 setNeedsDisplayInRect 代替 setNeedsDisplay 以优化性能，但是遇到性能问题的时候应该先检查自己的绘图算法和绘图时机，我个人其实从来没有使用过 setNeedsDisplayInRect。

4. 当你想做一个无限循环播放的动画的时候，可能会创建几个封装了动画的 CALayer，然后把它们添加到视图层级上，就像我在 iOS 实现脉冲雷达以及动态增减元素 By Swift 中这么做的： 

{% img /images/kongjianfengzhuang001.gif Caption %}  

效果还不错，实现又简单，但是当你按下 Home 键并再次返回到 app 的时候，原本好看的动画就变成了一滩死水：

这是因为在按下 Home 键的时候，所有的动画被移除了，具体的，每个 layer 都调用了 removeAllAnimations 方法。

如果你想重新播放动画，可以监听 UIApplicationDidBecomeActiveNotification 通知，就像我在 上述博客 中做的那样。

5. UIImageView 的 drawRect 永远不会被调用：

		Special Considerations
		The UIImageView class is optimized to draw its images to the display. UIImageView will not call drawRect: in a subclass. If your subclass needs custom drawing code, it is recommended you use UIView as the base class.
6. UIView 的 drawRect 也不一定会调用，我在 12 年的博客：定制UINavigationBar 中曾经提到过 UIKit 框架的实现机制：

众所周知一个视图如何显示是取决于它的 drawRect 方法，因为调这个方法之前 UIKit 也不知道如何显示它，但其实 drawRect 方法的目的也是画图（显示内容），而且我们如果以其他的方式给出了内容（图）的话， drawRect 方法就不会被调用了。

注：实际上 UIView 是 CALayer 的delegate，如果 CALayer 没有内容的话，会回调给 UIView 的 displayLayer: 或者 drawLayer:inContext: 方法，UIView 在其中调用 drawRect ，draw 完后的图会缓存起来，除非使用 setNeedsDisplay 或是一些必要情况，否则都是使用缓存的图。

UIView 和 CALayer 都是模型对象，如果我们以这种方式给出内容的话，drawRect 也就不会被调用了：

	self.customView.layer.contents = (id)[UIImage imageNamed:@"AppIcon"];
	// 哪怕是给它一个 nil，这两句等价
	self.customView.layer.contents = nil;
我猜测是在 CALayer 的 setContents 方法里有个标记，无论传入的对象是什么都会将该标记打开，但是调用 setNeedsDisplay 的时候会将该标记去除。

UIControl 与 UIButton

如果要做一个可交互的控件，那么把 UIControl 作为基类就是首选，这个完美的基类支持各种状态：

* enabled
* selected
* highlighted
* tracking
* ……
还支持多状态下的观察者模式：

		@property(nonatomic,readonly) UIControlState state;
		- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
		- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
这个基类可以很方便地为视图添加各种点击状态，最常见的用法就是将 UIViewController 的 view 改成 UIControl，然后就能快速实现 resignFirstResponder。

UIButton 自带图文接口，支持更强大的状态切换，titleEdgeInsets 和 imageEdgeInsets 也比较好用，配合两个基类的属性更好，先设置对齐规则，再设置 insets：
	
	@property(nonatomic) UIControlContentVerticalAlignment contentVerticalAlignment;    
	@property(nonatomic) UIControlContentHorizontalAlignment contentHorizontalAlignment;
UIControl 和 UIButton 都能很好的支持 xib，可以设置各种状态下的显示和 Selector，但是对 UIButton 来说这些并不够，因为 Normal 、Highlighted 和 Normal | Highlighted 是三种不同的状态，如果你需要实现根据当前状态显示不同高亮的图片，可以参考我下面的代码： 


{% img /images/kongjianfengzhuang002.png Caption %}  

	- (void)updateStates {
	    [super setTitle:[self titleForState:UIControlStateNormal] forState:UIControlStateNormal | UIControlStateHighlighted];
	    [super setImage:[self imageForState:UIControlStateNormal] forState:UIControlStateNormal | UIControlStateHighlighted];
	    [super setTitle:[self titleForState:UIControlStateSelected] forState:UIControlStateSelected | UIControlStateHighlighted];
	    [super setImage:[self imageForState:UIControlStateSelected] forState:UIControlStateSelected | UIControlStateHighlighted];
	}
或者使用初始化设置：

	- (void)commonInit {
	    [self setImage:[UIImage imageNamed:@"Normal"] forState:UIControlStateNormal];
	    [self setImage:[UIImage imageNamed:@"Selected"] forState:UIControlStateSelected];
	    [self setImage:[UIImage imageNamed:@"Highlighted"] forState:UIControlStateHighlighted];
	    [self setImage:[UIImage imageNamed:@"Selected_Highlighted"] forState:UIControlStateSelected | UIControlStateHighlighted];
	}
总之尽量使用原生类的接口，或者模仿原生类的接口。

大多数情况下根据你所需要的特性来选择现有的基类就够了，或者用 UIView + 手势识别器 的组合也是一个好方案，尽量不要用 touches 方法（userInteractionEnabled 属性对 touches 和手势识别器的作用一样），这是我在 DKCarouselView 中内置的一个可点击的 ImageView，也可以继承 UIButton，不过 UIButton 更侧重于状态，ImageView 侧重于图片本身：

	typedef void(^DKCarouselViewTapBlock)();
	@interface DKClickableImageView : UIImageView
	@property (nonatomic, assign) BOOL enable;
	@property (nonatomic, copy) DKCarouselViewTapBlock tapBlock;
	@end
	@implementation DKClickableImageView
	- (instancetype)initWithFrame:(CGRect)frame {
	    if ((self = [super initWithFrame:frame])) {
	        [self commonInit];
	    }
	    return self;
	}
	- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	    if ((self = [super initWithCoder:aDecoder])) {
	        [self commonInit];
	    }
	    return self;
	}
	- (void)commonInit {
	    self.userInteractionEnabled = YES;
	    self.enable = YES;
	    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
	    [self addGestureRecognizer:tapGesture];
	}
	- (IBAction)onTap:(id)sender {
	    if (!self.enable) return;
	    if (self.tapBlock) {
	        self.tapBlock();
	    }
	}
	@end
更友好的支持 xib

你的控件现在应该可以正确的从文件、代码中初始化了，但是从 xib 中初始化以后可能还需要通过代码来进行一些设置，你或许觉得像上面那样设置 Button 的状态很恶心而且不够直观，但是也没办法，这是由于 xib 虽然对原生控件，如 UIView、UIImageView、UIScrollView 等支持较好（想设置圆角、边框等属性也没办法，只能通过 layer 来设置），但是对自定义控件却没有什么办法，当你拖一个 UIView 到 xib 中，然后把它的 Class 改成你自己的子类后，xib 如同一个瞎子一样，不会有任何变化。————好在这些都成了过去。

Xcode 6 引入了两个新的宏：IBInspectable 和 IBDesignable。

IBInspectable

该宏会让 xib 识别属性，它支持这些数据类型：布尔、字符串、数字（NSNumber）、 CGPoint、CGSize、CGRect、UIColor 、 NSRange 和 UIImage。 

比如我们要让自定义的 Button 能在 xib 中设置 UIControlStateSelected | UIControlStateHighlighted 状态的图片，就可以这么做：

	// CustomButton
	@property (nonatomic, strong) IBInspectable UIImage *highlightSelectedImage;
	- (void)setHighlightSelectedImage:(UIImage *)highlightSelectedImage {
	    _highlightSelectedImage = highlightSelectedImage;
	    [self setImage:highlightSelectedImage forState:UIControlStateHighlighted | UIControlStateSelected];
	}
只需要在属性上加个 IBInspectable 宏即可，然后 xib 中就能显示这个自定义的属性： 

{% img /images/kongjianfengzhuang003.png Caption %} 


xib 会把属性名以大驼峰样式显示，如果有多个属性，xib 也会自动按属性名的第一个单词分组显示，如： 


{% img /images/kongjianfengzhuang004.png Caption %} 

通过使用 IBInspectable 宏，你可以把原本只能通过代码来设置的属性，也放到 xib 里来，代码就显得更加简洁了。

IBDesignable

xib 配合 IBInspectable 宏虽然可以让属性设置变得简单化，但是只有在运行期间你才能看到控件的真正效果，而使用 IBDesignable 可以让 Interface Builder 实时渲染控件，这一切只需要在类名加上 IBDesignable 宏即可：

	IB_DESIGNABLE
	@interface CustomButton : UIButton
	@property (nonatomic, strong) IBInspectable UIImage *highlightSelectedImage;
	@end
这样一来，当你在 xib 中调整属性的时候，画布也会实时更新。

关于对 IBInspectable / IBDesignable 的详细介绍可以看这里：http://nshipster.cn/ibinspectable-ibdesignable/ 

这是 Twitter 上其他开发者做出的效果： 

{% img /images/kongjianfengzhuang005.png Caption %} 

{% img /images/kongjianfengzhuang006.png Caption %} 

相信通过使用 IBInspectable / IBDesignable ，会让控件使用起来更加方便、也更加有趣。

不规则图形和事件触发范围

不规则图形在 iOS 上并不多见，想来设计师也怕麻烦。不过 iOS 上的控件说到底都是各式各样的矩形，就算你修改 cornerRadius，让它看起来像这样： 

{% img /images/kongjianfengzhuang007.png Caption %} 

也只是看起来像这样罢了，它的实际事件触发范围还是一个矩形。

问题描述

想象一个复杂的可交互的控件，它并不是单独工作的，可能需要和另一个控件交互，而且它们的事件触发范围可能会重叠，像这个选择联系人的列表：

{% img /images/kongjianfengzhuang008.gif Caption %} 

在设计的时候让上面二级菜单在最大的范围内可以被点击，下面的一级菜单也能在自己的范围内很好的工作，正常情况下它们的触发范围是这样的：

{% img /images/kongjianfengzhuang009.png Caption %} 

我们想要的是这样的：

{% img /images/kongjianfengzhuang010.png Caption %} 

想要实现这样的效果需要对事件分发有一定的了解。首先我们来想想，当触摸屏幕的时候发生了什么?

当触摸屏幕的时候发生了什么?

当屏幕接收到一个 touch 的时候，iOS 需要找到一个合适的对象来处理事件（ touch 或者手势），要寻找这个对象，需要用到这个方法：

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
该方法会首先在 application 的 keyWindow 上调用（UIWindow 也是 UIView 的子类），并且该方法的返回值将被用来处理事件。如果这个 view（无论是 window 还是普通的 UIView） 的 userInteractionEnabled 属性被设置为 NO，则它的 hitTest: 永远返回 nil，这意味着它和它的子视图没有机会去接收和处理事件。如果 userInteractionEnabled 属性为 YES，则会先判断产生触摸的 point 是否发生在自己的 bounds 内，如果没有也将返回 nil；如果 point 在自己的范围内，则会为自己的每个子视图调用 hitTest: 方法，只要有一个子视图通过这个方法返回一个 UIView 对象，那么整个方法就一层一层地往上返回；如果没有子视图返回 UIView 对象，则父视图将会把自己返回。

所以，在事件分发中，有这么几个关键点：

如果父视图不能响应事件（userInteractionEnabled 为 NO），则其子视图也将无法响应事件。

如果子视图的 frame 有一半在外面，就像这样： 

{% img /images/kongjianfengzhuang011.png Caption %} 

则在外面的部分是无法响应事件的，因为它超出了父视图的范围。

整个事件链只会返回一个 Hit-Test View 来处理事件。

子视图的顺序会影响到 Hit-Test View 的选择：最先通过 hitTest: 方法返回的 UIView 才会被返回，假如有两个子视图平级，并且它们的 frame 一样，但是谁是后添加的谁就优先返回。

了解了事件分发的这些特点后，还需要知道最后一件事：UIView 如何判断产生事件的 point 是否在自己的范围内? 答案是通过 pointInside 方法，这个方法的默认实现类似于这样：

	// point 被转化为对应视图的坐标系统
	- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	    return CGRectContainsPoint(self.bounds, point);
	}
所以，当我们想改变一个 View 的事件触发范围的时候，重写 pointInside 方法就可以了。

回到问题

针对这种视图一定要处理它们的事件触发范围，也就是 pointInside 方法，一般来说，我们先判断 point 是不是在自己的范围内（通过调用 super 来判断），然后再判断该 point 符不符合我们的处理要求：

这个例子我用 Swift 来写

	override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
	    let inside = super.pointInside(point, withEvent: event)
	    if inside {
	        let radius = self.layer.cornerRadius
	        let dx = point.x - self.bounds.size.width / 2
	        let dy = point.y - radius
	        let distace = sqrt(dx * dx + dy * dy)
	        return distace < radius
	    }
	    return inside
	}
如果你要实现非矩形的控件，那么请在开发时处理好这类问题。 

这里附上一个很容易测试的小 Demo：

	class CustomView: UIControl {
	    override init(frame: CGRect) {
	        super.init(frame: frame)
	        self.backgroundColor = UIColor.redColor()
	    }
	    required init(coder aDecoder: NSCoder) {
	        super.init(coder: aDecoder)
	        self.backgroundColor = UIColor.redColor()
	    }
	    override func layoutSubviews() {
	        super.layoutSubviews()
	        self.layer.cornerRadius = self.bounds.size.width / 2
	    }
	    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
	        self.backgroundColor = UIColor.grayColor()
	        return super.beginTrackingWithTouch(touch, withEvent: event)
	    }
	    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
	        super.endTrackingWithTouch(touch, withEvent: event)
	        self.backgroundColor = UIColor.redColor()
	    }
	    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
	        let inside = super.pointInside(point, withEvent: event)
	        if inside {
	            let radius = self.layer.cornerRadius
	            let dx = point.x - self.bounds.size.width / 2
	            let dy = point.y - radius
	            let distace = sqrt(dx * dx + dy * dy)
	            return distace < radius
	        }
	        return inside
	    }
	}
	
####合理使用 KVO

某些视图的接口比较宝贵，被你用掉后外部的使用者就无法使用了，比如 UITextField 的 delegate，好在 UITextField 还提供了通知和 UITextInput 方法可以使用；像 UIScrollView 或者基于 UIScrollView 的控件，你既不能设置它的 delegate，又没有其他的替代方法可以使用，对于像以下这种需要根据某些属性实时更新的控件来说，KVO 真是极好的：

这是一个动态高度 Header 的例子（DKStickyHeaderView）： 


两者都是基于 UIScrollView、基于 KVO ，不依赖外部参数：

	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer) {
	    if keyPath == KEY_PATH_CONTENTOFFSET {
	        let scrollView = self.superview as! UIScrollView
	        var delta: CGFloat = 0.0
	        if scrollView.contentOffset.y < 0.0 {
	            delta = fabs(min(0.0, scrollView.contentOffset.y))
	        }
	        var newFrame = self.frame
	        newFrame.origin.y = -delta
	        newFrame.size.height = self.minHeight + delta
	        self.frame = newFrame
	    } else {
	        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
	    }
	}
对容器类的 ViewController 来说也一样有用。在 iOS8 之前没有 UIContentContainer 这个正式协议，如果你要实现一个很长的、非列表、可滚动的 ViewController，那么你可能会将其中的功能分散到几个 ChildViewController 里，然后把它们组合起来，这样一来，这些 ChildViewController 既能被单独作为一个 ViewController 展示，也可以被组合到一起。作为组合到一起的前提，就是需要一个至少有以下两个方法的协议：

提供一个统一的输入源，大多是一个 Model 或者像 userId 这样的
能够返回你所需要的高度，比如设置 preferredContentSize 属性
ChildViewController 动态地设置 contentSize，容器监听 contentSize 的变化动态地设置约束或者 frame。

