---
layout: post
title: "iOS装逼篇——响应式编程"
date: 2016-10-14 23:49:39 +0800
comments: true
categories: 
---
##开篇

    在网上流传一个非常经典的解释｀响应式编程的概念｀
    在程序开发中：
    a ＝ b ＋ c
    赋值之后 b 或者 c 的值变化后，a 的值不会跟着变化
    响应式编程，目标就是，如果 b 或者 c 的数值发生变化，a 的数值会同时发生变化；
Reactive Cocoa就是一个响应式编程的经典作品！
###一、简介

ReactiveCocoa（其简称为RAC）是函数响应式编程框架。RAC具有函数式编程和响应式编程的特性。它主要吸取了.Net的 Reactive Extensions的设计和实现。
函数式编程 (Functional Programming)

函数式编程也可以写N篇,它是完全不同于OO的编程模式，这里主要讲一下这个框架使用到的函数式思想。

######1) 高阶函数：在函数式编程中，把函数当参数来回传递，而这个，说成术语，我们把他叫做高阶函数。在oc中，blocks是被广泛使用的参数传递，它实际上是匿名函数。  

高阶函数调用过程有点像linux命令里的pipeline（管道），一个命令调用后的输出当作另一个命令输入，多个命令之间可以串起来操作。来个例子:
 
        RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;      
    // Contains: 22 44 66 88  
    RACSequence *doubleNumber = [[numbers filter:^ BOOL (NSString *value) {  
        return (value.intValue % 2) == 0;  
    }] map:^id(id value) {  
        return [value stringByAppendingString:value];  
    }];  


上面的例子是数组里的值先进行过滤，得到偶数，然后再将每个值进行stringByAppendingString，最终输出
	
	22 44 66 88.


######2),惰性（或延迟）求值：Sequences对象等，只有当被使用到时，才会对其求值。

关于函数编程，有兴趣的大家可以研究下haskell或者clojure，不过目前好多语言都在借用函数式的思想。
响应式编程(Functional Reactive Programming:FRP)

	响应式编程是一种和事件流有关的编程模式，关注导致状态值改变的行为事件，一系列事件组成了事件流。

一系列事件是导致属性值发生变化的原因。FRP非常类似于设计模式里的观察者模式。

> 响应式编程是一种针对数据流和变化传递的编程模式，其执行引擎可以自动的在数据流之间传递数据的变化。比如说，在一种命令式编程语言中，a: = b + c 表示 a 是 b + c 表达式的值，但是在RP语言中，它可能意味着一个动态的数据流关系：当c或者b的值发生变化时，a的值自动的发生变化。

RP已经被证实是一种最有效的处理交互式用户界面、实时模式下的动画的开发模式，但本质上是一种基本的编程模式。现在最为热门的JavaFX脚本语言中，引入的bind就是RP的一个概念实现。
响应式编程其关键点包括：

	 输入被视为"行为"，或者说一个随时间而变化的事件流
	
	 连续的、随时间而变化的值
	
	 按时间排序的离散事件序列

FRP与普通的函数式编程相似，但是每个函数可以接收一个输入值的流，如果其中，一个新的输入值到达的话，这个函数将根据最新的输入值重新计算，并且产生一个新的输出。这是一种”数据流"编程模式。


###二、为什么我们要用它

	1） 开发过程中，状态以及状态之间依赖过多,RAC更加有效率地处理事件流，而无需显式去管理状态。在OO或者过程式编程中，状态变化是最难跟踪，最头痛的事。这个也是最重要的一点。
	
	2） 减少变量的使用，由于它跟踪状态和值的变化，因此不需要再申明变量不断地观察状态和更新值。
	
	3） 提供统一的消息传递机制，将oc中的通知，action，KVO以及其它所有UIControl事件的变化都进行监控，当变化发生时，就会传递事件和值。
	
	4） 当值随着事件变换时，可以使用map，filter，reduce等函数便利地对值进行变换操作。
###三、何时使用

######1） 处理异步或者事件驱动的数据变化

    static voidvoid *ObservationContext = &ObservationContext;  
      
    - (void)viewDidLoad {  
        [super viewDidLoad];  
      
        [LoginManager.sharedManager addObserver:self forKeyPath:@"loggingIn" options:NSKeyValueObservingOptionInitial context:&ObservationContext];  
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loggedOut:) name:UserDidLogOutNotification object:LoginManager.sharedManager];  
      
        [self.usernameTextField addTarget:self action:@selector(updateLogInButton) forControlEvents:UIControlEventEditingChanged];  
        [self.passwordTextField addTarget:self action:@selector(updateLogInButton) forControlEvents:UIControlEventEditingChanged];  
        [self.logInButton addTarget:self action:@selector(logInPressed:) forControlEvents:UIControlEventTouchUpInside];  
    }  
      
    - (void)dealloc {  
        [LoginManager.sharedManager removeObserver:self forKeyPath:@"loggingIn" context:ObservationContext];  
        [NSNotificationCenter.defaultCenter removeObserver:self];  
    }  
      
    - (void)updateLogInButton {  
        BOOL textFieldsNonEmpty = self.usernameTextField.text.length > 0 && self.passwordTextField.text.length > 0;  
        BOOL readyToLogIn = !LoginManager.sharedManager.isLoggingIn && !self.loggedIn;  
        self.logInButton.enabled = textFieldsNonEmpty && readyToLogIn;  
    }  
      
    - (IBAction)logInPressed:(UIButton *)sender {  
        [[LoginManager sharedManager]  
            logInWithUsername:self.usernameTextField.text  
            password:self.passwordTextField.text  
            success:^{  
                self.loggedIn = YES;  
            } failure:^(NSError *error) {  
                [self presentError:error];  
            }];  
    }  
      
    - (void)loggedOut:(NSNotification *)notification {  
        self.loggedIn = NO;  
    }  
      
    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(voidvoid *)context {  
        if (context == ObservationContext) {  
            [self updateLogInButton];  
        } else {  
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];  
        }  
    }  
      
    // RAC实现：  
      
    - (void)viewDidLoad {  
        [super viewDidLoad];  
      
        @weakify(self);  
      
        RAC(self.logInButton, enabled) = [RACSignal  
            combineLatest:@[  
                self.usernameTextField.rac_textSignal,  
                self.passwordTextField.rac_textSignal,  
                RACObserve(LoginManager.sharedManager, loggingIn),  
                RACObserve(self, loggedIn)  
            ] reduce:^(NSString *username, NSString *password, NSNumber *loggingIn, NSNumber *loggedIn) {  
                return @(username.length > 0 && password.length > 0 && !loggingIn.boolValue && !loggedIn.boolValue);  
            }];  
      
        [[self.logInButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {  
            @strongify(self);  
      
            RACSignal *loginSignal = [LoginManager.sharedManager  
                logInWithUsername:self.usernameTextField.text  
                password:self.passwordTextField.text];  
      
                [loginSignal subscribeError:^(NSError *error) {  
                    @strongify(self);  
                    [self presentError:error];  
                } completed:^{  
                    @strongify(self);  
                    self.loggedIn = YES;  
                }];  
        }];  
      
        RAC(self, loggedIn) = [[NSNotificationCenter.defaultCenter  
            rac_addObserverForName:UserDidLogOutNotification object:nil]  
            mapReplace:@NO];  
    }  

######2） 链式的依赖操作

    [client logInWithSuccess:^{  
        [client loadCachedMessagesWithSuccess:^(NSArray *messages) {  
            [client fetchMessagesAfterMessage:messages.lastObject success:^(NSArray *nextMessages) {  
                NSLog(@"Fetched all messages.");  
            } failure:^(NSError *error) {  
                [self presentError:error];  
            }];  
        } failure:^(NSError *error) {  
            [self presentError:error];  
        }];  
    } failure:^(NSError *error) {  
        [self presentError:error];  
    }];  
           // RAC实现：  
    [[[[client logIn]  
        then:^{  
            return [client loadCachedMessages];  
        }]  
        flattenMap:^(NSArray *messages) {  
            return [client fetchMessagesAfterMessage:messages.lastObject];  
        }]  
        subscribeError:^(NSError *error) {  
            [self presentError:error];  
        } completed:^{  
            NSLog(@"Fetched all messages.");  
        }];  

###3） 并行依赖操作：


    __block NSArray *databaseObjects;  
    __block NSArray *fileContents;  
      
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];  
    NSBlockOperation *databaseOperation = [NSBlockOperation blockOperationWithBlock:^{  
        databaseObjects = [databaseClient fetchObjectsMatchingPredicate:predicate];  
    }];  
      
    NSBlockOperation *filesOperation = [NSBlockOperation blockOperationWithBlock:^{  
        NSMutableArray *filesInProgress = [NSMutableArray array];  
        for (NSString *path in files) {  
            [filesInProgress addObject:[NSData dataWithContentsOfFile:path]];  
        }  
      
        fileContents = [filesInProgress copy];  
    }];  
      
    NSBlockOperation *finishOperation = [NSBlockOperation blockOperationWithBlock:^{  
        [self finishProcessingDatabaseObjects:databaseObjects fileContents:fileContents];  
        NSLog(@"Done processing");  
    }];  
      
    [finishOperation addDependency:databaseOperation];  
    [finishOperation addDependency:filesOperation];  
    [backgroundQueue addOperation:databaseOperation];  
    [backgroundQueue addOperation:filesOperation];  
    [backgroundQueue addOperation:finishOperation];  
    //RAC  
    RACSignal *databaseSignal = [[databaseClient  
        fetchObjectsMatchingPredicate:predicate]  
        subscribeOn:[RACScheduler scheduler]];  
      
    RACSignal *fileSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {  
        NSMutableArray *filesInProgress = [NSMutableArray array];  
        for (NSString *path in files) {  
            [filesInProgress addObject:[NSData dataWithContentsOfFile:path]];  
        }  
      
        [subscriber sendNext:[filesInProgress copy]];  
        [subscriber sendCompleted];  
    }];  
      
    [[RACSignal  
        combineLatest:@[ databaseSignal, fileSignal ]  
        reduce:^ id (NSArray *databaseObjects, NSArray *fileContents) {  
            [self finishProcessingDatabaseObjects:databaseObjects fileContents:fileContents];  
            return nil;  
        }]  
        subscribeCompleted:^{  
            NSLog(@"Done processing");  
        }];  
      
    __block NSArray *databaseObjects;  
    __block NSArray *fileContents;  
      
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];  
    NSBlockOperation *databaseOperation = [NSBlockOperation blockOperationWithBlock:^{  
        databaseObjects = [databaseClient fetchObjectsMatchingPredicate:predicate];  
    }];  
      
    NSBlockOperation *filesOperation = [NSBlockOperation blockOperationWithBlock:^{  
        NSMutableArray *filesInProgress = [NSMutableArray array];  
        for (NSString *path in files) {  
            [filesInProgress addObject:[NSData dataWithContentsOfFile:path]];  
        }  
      
        fileContents = [filesInProgress copy];  
    }];  
      
    NSBlockOperation *finishOperation = [NSBlockOperation blockOperationWithBlock:^{  
        [self finishProcessingDatabaseObjects:databaseObjects fileContents:fileContents];  
        NSLog(@"Done processing");  
    }];  
      
    [finishOperation addDependency:databaseOperation];  
    [finishOperation addDependency:filesOperation];  
    [backgroundQueue addOperation:databaseOperation];  
    [backgroundQueue addOperation:filesOperation];  
    [backgroundQueue addOperation:finishOperation];  
    //RAC  
    RACSignal *databaseSignal = [[databaseClient  
        fetchObjectsMatchingPredicate:predicate]  
        subscribeOn:[RACScheduler scheduler]];  
      
    RACSignal *fileSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {  
        NSMutableArray *filesInProgress = [NSMutableArray array];  
        for (NSString *path in files) {  
            [filesInProgress addObject:[NSData dataWithContentsOfFile:path]];  
        }  
      
        [subscriber sendNext:[filesInProgress copy]];  
        [subscriber sendCompleted];  
    }];  
      
    [[RACSignal  
        combineLatest:@[ databaseSignal, fileSignal ]  
        reduce:^ id (NSArray *databaseObjects, NSArray *fileContents) {  
            [self finishProcessingDatabaseObjects:databaseObjects fileContents:fileContents];  
            return nil;  
        }]  
        subscribeCompleted:^{  
            NSLog(@"Done processing");  
        }];  

###4）简化集合操作


    NSMutableArray *results = [NSMutableArray array];  
    for (NSString *str in strings) {  
        if (str.length < 2) {  
            continue;  
        }  
      
        NSString *newString = [str stringByAppendingString:@"foobar"];  
        [results addObject:newString];  
    }  
      
    RAC实现：  
    RACSequence *results = [[strings.rac_sequence  
        filter:^ BOOL (NSString *str) {  
            return str.length >= 2;  
        }]  
        map:^(NSString *str) {  
            return [str stringByAppendingString:@"foobar"];  
        }];  

下载地址：

[https://github.com/ReactiveCocoa/ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)




===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  
