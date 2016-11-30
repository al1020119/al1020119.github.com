---
layout: post
title: "多线程安全？应该不止这些😂！"
date: 2016-08-31 12:33:27 +0800
comments: true
categories: 
---

+ 前言
+ 介绍与使用
+ 总结
+ 其他实战使用





##一、前言

 
前段时间看了几个开源项目，发现他们保持线程同步的方式各不相同，有@synchronized、NSLock、dispatch_semaphore、NSCondition、pthread_mutex、OSSpinLock。后来网上查了一下，发现他们的实现机制各不相同，性能也各不一样。不好意思，我们平常使用最多的@synchronized是性能最差的。下面我们先分别介绍每个加锁方式的使用，在使用一个案例来对他们进行性能对比。

 
##二、介绍与使用

 
<!--more-->



####2.1、@synchronized

 

        NSObject *obj = [[NSObject alloc] init];

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            @synchronized(obj) {

                NSLog(@"需要线程同步的操作1 开始");

                sleep(3);

                NSLog(@"需要线程同步的操作1 结束");

            }

        });

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            sleep(1);

            @synchronized(obj) {

                NSLog(@"需要线程同步的操作2");

            }

        });

 

@synchronized(obj)指令使用的obj为该锁的唯一标识，只有当标识相同时，才为满足互斥，如果线程2中的@synchronized(obj)改为@synchronized(self),刚线程2就不会被阻塞，@synchronized指令实现锁的优点就是我们不需要在代码中显式的创建锁对象，便可以实现锁的机制，但作为一种预防措施，@synchronized块会隐式的添加一个异常处理例程来保护代码，该处理例程会在异常抛出的时候自动的释放互斥锁。所以如果不想让隐式的异常处理例程带来额外的开销，你可以考虑使用锁对象。

 

上面结果的执行结果为：

 

    2016-06-29 20:48:35.747 SafeMultiThread[35945:580107] 需要线程同步的操作1 开始

    2016-06-29 20:48:38.748 SafeMultiThread[35945:580107] 需要线程同步的操作1 结束

    2016-06-29 20:48:38.749 SafeMultiThread[35945:580118] 需要线程同步的操作2

 

####2.2、dispatch_semaphore

 

    dispatch_semaphore_t signal = dispatch_semaphore_create(1);

        dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            dispatch_semaphore_wait(signal, overTime);

                NSLog(@"需要线程同步的操作1 开始");

                sleep(2);

                NSLog(@"需要线程同步的操作1 结束");

            dispatch_semaphore_signal(signal);

        });

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            sleep(1);

            dispatch_semaphore_wait(signal, overTime);

                NSLog(@"需要线程同步的操作2");

            dispatch_semaphore_signal(signal);

        });

 

dispatch_semaphore是GCD用来同步的一种方式，与他相关的共有三个函数，分别是dispatch_semaphore_create，dispatch_semaphore_signal，dispatch_semaphore_wait。

 

######（1）dispatch_semaphore_create的声明为：

 

	dispatch_semaphore_t dispatch_semaphore_create(long value);

 

传入的参数为long，输出一个dispatch_semaphore_t类型且值为value的信号量。

 

值得注意的是，这里的传入的参数value必须大于或等于0，否则dispatch_semaphore_create会返回NULL。

 

######（2）dispatch_semaphore_signal的声明为：

 

	long dispatch_semaphore_signal(dispatch_semaphore_t dsema)

 

这个函数会使传入的信号量dsema的值加1；

 

######(3) dispatch_semaphore_wait的声明为：

 

	long dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout)；

 

这个函数会使传入的信号量dsema的值减1；这个函数的作用是这样的，如果dsema信号量的值大于0，该函数所处线程就继续执行下面的语句，并且将信号量的值减1；如果desema的值为0，那么这个函数就阻塞当前线程等待timeout（注意timeout的类型为dispatch_time_t，不能直接传入整形或float型数），如果等待的期间desema的值被dispatch_semaphore_signal函数加1了，且该函数（即dispatch_semaphore_wait）所处线程获得了信号量，那么就继续向下执行并将信号量减1。如果等待期间没有获取到信号量或者信号量的值一直为0，那么等到timeout时，其所处线程自动执行其后语句。

 

dispatch_semaphore 是信号量，但当信号总量设为 1 时也可以当作锁来。在没有等待情况出现时，它的性能比 pthread_mutex 还要高，但一旦有等待情况出现时，性能就会下降许多。相对于 OSSpinLock 来说，它的优势在于等待时不会消耗 CPU 资源。

 

如上的代码，如果超时时间overTime设置成>2，可完成同步操作。如果overTime

 

上面代码的执行结果为：

 

    2016-06-29 20:47:52.324 SafeMultiThread[35945:579032] 需要线程同步的操作1 开始

    2016-06-29 20:47:55.325 SafeMultiThread[35945:579032] 需要线程同步的操作1 结束

    2016-06-29 20:47:55.326 SafeMultiThread[35945:579033] 需要线程同步的操作2

 

如果把超时时间设置为

 

    2016-06-30 18:53:24.049 SafeMultiThread[30834:434334] 需要线程同步的操作1 开始

    2016-06-30 18:53:25.554 SafeMultiThread[30834:434332] 需要线程同步的操作2

    2016-06-30 18:53:26.054 SafeMultiThread[30834:434334] 需要线程同步的操作1 结束

 

####2.3、NSLock

 

       NSLock *lock = [[NSLock alloc] init];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            //[lock lock];

            [lock lockBeforeDate:[NSDate date]];

                NSLog(@"需要线程同步的操作1 开始");

                sleep(2);

                NSLog(@"需要线程同步的操作1 结束");

            [lock unlock];

     

        });

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            sleep(1);

            if ([lock tryLock]) {//尝试获取锁，如果获取不到返回NO，不会阻塞该线程

                NSLog(@"锁可用的操作");

                [lock unlock];

            }else{

                NSLog(@"锁不可用的操作");

            }

     

            NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:3];

            if ([lock lockBeforeDate:date]) {//尝试在未来的3s内获取锁，并阻塞该线程，如果3s内获取不到恢复线程, 返回NO,不会阻塞该线程

                NSLog(@"没有超时，获得锁");

                [lock unlock];

            }else{

                NSLog(@"超时，没有获得锁");

            }

     

        });

 

NSLock是Cocoa提供给我们最基本的锁对象，这也是我们经常所使用的，除lock和unlock方法外，NSLock还提供了tryLock和lockBeforeDate:两个方法，前一个方法会尝试加锁，如果锁不可用(已经被锁住)，刚并不会阻塞线程，并返回NO。lockBeforeDate:方法会在所指定Date之前尝试加锁，如果在指定时间之前都不能加锁，则返回NO。

 

上面代码的执行结果为：

 

    2016-06-29 20:45:08.864 SafeMultiThread[35911:575795] 需要线程同步的操作1 开始

    2016-06-29 20:45:09.869 SafeMultiThread[35911:575781] 锁不可用的操作

    2016-06-29 20:45:10.869 SafeMultiThread[35911:575795] 需要线程同步的操作1 结束

    2016-06-29 20:45:10.870 SafeMultiThread[35911:575781] 没有超时，获得锁

 

源码定义如下：

 

    @protocol NSLocking

     

    - (void)lock;

    - (void)unlock;

     

    @end

     

    @interface NSLock : NSObject  {

    <a href="http://www.jobbole.com/members/kaishu6296">@private</a>

        void *_priv;

    }

     

    - (BOOL)tryLock;

    - (BOOL)lockBeforeDate:(NSDate *)limit;

     

    @property (nullable, copy) NSString *name NS_AVAILABLE(10_5, 2_0);

     

    @end

 

####2.4、NSRecursiveLock递归锁

 

        //NSLock *lock = [[NSLock alloc] init];

        NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

     

            static void (^RecursiveMethod)(int);

     

            RecursiveMethod = ^(int value) {

     

                [lock lock];

                if (value > 0) {

     

                    NSLog(@"value = %d", value);

                    sleep(1);

                    RecursiveMethod(value - 1);

                }

                [lock unlock];

            };

     

            RecursiveMethod(5);

        });

 

NSRecursiveLock实际上定义的是一个递归锁，这个锁可以被同一线程多次请求，而不会引起死锁。这主要是用在循环或递归操作中。

 

这段代码是一个典型的死锁情况。在我们的线程中，RecursiveMethod是递归调用的。所以每次进入这个block时，都会去加一次锁，而从第二次开始，由于锁已经被使用了且没有解锁，所以它需要等待锁被解除，这样就导致了死锁，线程被阻塞住了。调试器中会输出如下信息：

 

    2016-06-30 19:08:06.393 SafeMultiThread[30928:449008] value = 5

    2016-06-30 19:08:07.399 SafeMultiThread[30928:449008] -[NSLock lock]: deadlock ( ‘(null)’)

    2016-06-30 19:08:07.399 SafeMultiThread[30928:449008] Break on _NSLockError() to debug.

 

在这种情况下，我们就可以使用NSRecursiveLock。它可以允许同一线程多次加锁，而不会造成死锁。递归锁会跟踪它被lock的次数。每次成功的lock都必须平衡调用unlock操作。只有所有达到这种平衡，锁最后才能被释放，以供其它线程使用。

 

如果我们将NSLock代替为NSRecursiveLock，上面代码则会正确执行。

 

    2016-06-30 19:09:41.414 SafeMultiThread[30949:450684] value = 5

    2016-06-30 19:09:42.418 SafeMultiThread[30949:450684] value = 4

    2016-06-30 19:09:43.419 SafeMultiThread[30949:450684] value = 3

    2016-06-30 19:09:44.424 SafeMultiThread[30949:450684] value = 2

    2016-06-30 19:09:45.426 SafeMultiThread[30949:450684] value = 1

 

如果需要其他功能，源码定义如下：

 

    @interface NSRecursiveLock : NSObject  {

    <a href="http://www.jobbole.com/members/kaishu6296">@private</a>

        void *_priv;

    }

     

    - (BOOL)tryLock;

    - (BOOL)lockBeforeDate:(NSDate *)limit;

     

    @property (nullable, copy) NSString *name NS_AVAILABLE(10_5, 2_0);

     

    @end

 

##2.5、NSConditionLock条件锁

 

        NSMutableArray *products = [NSMutableArray array];

     

        NSInteger HAS_DATA = 1;

        NSInteger NO_DATA = 0;

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            while (1) {

                [lock lockWhenCondition:NO_DATA];

                [products addObject:[[NSObject alloc] init]];

                NSLog(@"produce a product,总量:%zi",products.count);

                [lock unlockWithCondition:HAS_DATA];

                sleep(1);

            }

     

        });

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            while (1) {

                NSLog(@"wait for product");

                [lock lockWhenCondition:HAS_DATA];

                [products removeObjectAtIndex:0];

                NSLog(@"custome a product");

                [lock unlockWithCondition:NO_DATA];

            }

     

        });

 

当我们在使用多线程的时候，有时一把只会lock和unlock的锁未必就能完全满足我们的使用。因为普通的锁只能关心锁与不锁，而不在乎用什么钥匙才能开锁，而我们在处理资源共享的时候，多数情况是只有满足一定条件的情况下才能打开这把锁：

 

在线程1中的加锁使用了lock，所以是不需要条件的，所以顺利的就锁住了，但在unlock的使用了一个整型的条件，它可以开启其它线程中正在等待这把钥匙的临界地，而线程2则需要一把被标识为2的钥匙，所以当线程1循环到最后一次的时候，才最终打开了线程2中的阻塞。但即便如此，NSConditionLock也跟其它的锁一样，是需要lock与unlock对应的，只是lock,lockWhenCondition:与unlock，unlockWithCondition:是可以随意组合的，当然这是与你的需求相关的。

 

上面代码执行结果如下：

 

    2016-06-30 20:31:58.699 SafeMultiThread[31282:521698] wait for product

    2016-06-30 20:31:58.699 SafeMultiThread[31282:521708] produce a product,总量:1

    2016-06-30 20:31:58.700 SafeMultiThread[31282:521698] custome a product

    2016-06-30 20:31:58.700 SafeMultiThread[31282:521698] wait for product

    2016-06-30 20:31:59.705 SafeMultiThread[31282:521708] produce a product,总量:1

    2016-06-30 20:31:59.706 SafeMultiThread[31282:521698] custome a product

    2016-06-30 20:31:59.706 SafeMultiThread[31282:521698] wait for product

    2016-06-30 20:32:00.707 SafeMultiThread[31282:521708] produce a product,总量:1

    2016-06-30 20:32:00.708 SafeMultiThread[31282:521698] custome a product

 

如果你需要其他功能，源码定义如下：

 

    @interface NSConditionLock : NSObject  {

    <a href="http://www.jobbole.com/members/kaishu6296">@private</a>

        void *_priv;

    }

     

    - (instancetype)initWithCondition:(NSInteger)condition NS_DESIGNATED_INITIALIZER;

     

    @property (readonly) NSInteger condition;

    - (void)lockWhenCondition:(NSInteger)condition;

    - (BOOL)tryLock;

    - (BOOL)tryLockWhenCondition:(NSInteger)condition;

    - (void)unlockWithCondition:(NSInteger)condition;

    - (BOOL)lockBeforeDate:(NSDate *)limit;

    - (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;

     

    @property (nullable, copy) NSString *name NS_AVAILABLE(10_5, 2_0);

     

    @end

 

####2.6、NSCondition

 

       NSCondition *condition = [[NSCondition alloc] init];

     

        NSMutableArray *products = [NSMutableArray array];

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            while (1) {

                [condition lock];

                if ([products count] == 0) {

                    NSLog(@"wait for product");

                    [condition wait];

                }

                [products removeObjectAtIndex:0];

                NSLog(@"custome a product");

                [condition unlock];

            }

     

        });

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            while (1) {

                [condition lock];

                [products addObject:[[NSObject alloc] init]];

                NSLog(@"produce a product,总量:%zi",products.count);

                [condition signal];

                [condition unlock];

                sleep(1);

            }

     

        });

 

######一种最基本的条件锁。手动控制线程wait和signal。

 

[condition lock];一般用于多线程同时访问、修改同一个数据源，保证在同一时间内数据源只被访问、修改一次，其他线程的命令需要在lock 外等待，只到unlock ，才可访问

 

	[condition unlock];与lock 同时使用
	
	 
	
	[condition wait];让当前线程处于等待状态
	
	 
	
	[condition signal];CPU发信号告诉线程不用在等待，可以继续执行

 

上面代码执行结果如下：

 

    2016-06-30 20:21:25.295 SafeMultiThread[31256:513991] wait for product

    2016-06-30 20:21:25.296 SafeMultiThread[31256:513994] produce a product,总量:1

    2016-06-30 20:21:25.296 SafeMultiThread[31256:513991] custome a product

    2016-06-30 20:21:25.297 SafeMultiThread[31256:513991] wait for product

    2016-06-30 20:21:26.302 SafeMultiThread[31256:513994] produce a product,总量:1

    2016-06-30 20:21:26.302 SafeMultiThread[31256:513991] custome a product

    2016-06-30 20:21:26.302 SafeMultiThread[31256:513991] wait for product

    2016-06-30 20:21:27.307 SafeMultiThread[31256:513994] produce a product,总量:1

    2016-06-30 20:21:27.308 SafeMultiThread[31256:513991] custome a product

 

####2.7、pthread_mutex

 

        __block pthread_mutex_t theLock;

        pthread_mutex_init(&theLock, NULL);

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                pthread_mutex_lock(&theLock);

                NSLog(@"需要线程同步的操作1 开始");

                sleep(3);

                NSLog(@"需要线程同步的操作1 结束");

                pthread_mutex_unlock(&theLock);

     

        });

     

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                sleep(1);

                pthread_mutex_lock(&theLock);

                NSLog(@"需要线程同步的操作2");

                pthread_mutex_unlock(&theLock);

     

        });

 

c语言定义下多线程加锁方式。

 

	1：pthread_mutex_init(pthread_mutex_t mutex,const pthread_mutexattr_t attr);
	
	初始化锁变量mutex。attr为锁属性，NULL值为默认属性。
	
	2：pthread_mutex_lock(pthread_mutex_t mutex);加锁
	
	3：pthread_mutex_tylock(*pthread_mutex_t *mutex);加锁，但是与2不一样的是当锁已经在使用的时候，返回为EBUSY，而不是挂起等待。
	
	4：pthread_mutex_unlock(pthread_mutex_t *mutex);释放锁
	
	5：pthread_mutex_destroy(pthread_mutex_t* mutex);使用完后释放

 

代码执行操作结果如下：

 

    2016-06-30 21:13:32.440 SafeMultiThread[31429:548869] 需要线程同步的操作1 开始

    2016-06-30 21:13:35.445 SafeMultiThread[31429:548869] 需要线程同步的操作1 结束

    2016-06-30 21:13:35.446 SafeMultiThread[31429:548866] 需要线程同步的操作2

 

####2.8、pthread_mutex(recursive)

 


这是pthread_mutex为了防止在递归的情况下出现死锁而出现的递归锁。作用和NSRecursiveLock递归锁类似。

 

如果使用pthread_mutex_init(&theLock, NULL);初始化锁的话，上面的代码会出现死锁现象。如果使用递归锁的形式，则没有问题。

 

####2.9、OSSpinLock

 


OSSpinLock 自旋锁，性能最高的锁。原理很简单，就是一直 do while 忙等。它的缺点是当等待时会消耗大量 CPU 资源，所以它不适用于较长时间的任务。 不过最近YY大神在自己的博客不再安全的 OSSpinLock中说明了OSSpinLock已经不再安全，请大家谨慎使用。

 

三、性能对比

 

对以上各个锁进行1000000此的加锁解锁的空操作时间如下：

 

    OSSpinLock: 46.15 ms

    dispatch_semaphore: 56.50 ms

    pthread_mutex: 178.28 ms

    NSCondition: 193.38 ms

    NSLock: 175.02 ms

    pthread_mutex(recursive): 172.56 ms

    NSRecursiveLock: 157.44 ms

    NSConditionLock: 490.04 ms

    @synchronized: 371.17 ms

 

##三.总的来说：

 

+ OSSpinLock和dispatch_semaphore的效率远远高于其他。

 

+ @synchronized和NSConditionLock效率较差。

 

+ 鉴于OSSpinLock的不安全，所以我们在开发中如果考虑性能的话，建议使用dispatch_semaphore。

 

+ 如果不考虑性能，只是图个方便的话，那就使用@synchronized。



  >  总感觉这个标题怪怪的,但是我自身词汇有限,也不知道怎么描述好了.用一个简单的需求来解释一下吧.我之前开发的一个项目,需要向服务器上传图片,多图片上传,然后每次上传之后会返回一个图片的AID, 然后需要所有图片上传完成之后, 拿着一个全是AID的数组作为参数进行另一个异步请求...好吧,我感觉又绕了...

    前几天,我在一个技术交流圈,看到一个朋友去JINGDONG的面试题, 其中一个题目的描述是:有a、b、c、d 4个异步请求，如何判断a、b、c、d都完成执行？, 跟我上面的需求大同小异.

    所以在这儿,我把我工作中曾经用到过的一些方法做一个小的总结,有遗漏的或者错误的地方,请大家留意指正,非常感谢哈!!!

    特别注意:所有的代码都基于JINGDONG这道面试题, 不过我只打印了A和B而已..

##四.实战应用

我们公司App前段时间刚好有一个功能需求，就是关于发动态的时候图片上传的需求。以前一般来说的话，我们是讲所有图片打包一起发给服务器，但是这依稀不一样的是，必须每一张每一张的传，具体为什么老大说了一各位自己体会。

需求是：

+ 1：每次上传图片的时候必须一张一张的传。
+ 2：上传完一张之后服务器返回给我们一个url，把他存起来
+ 3：全部传完之后再把所有存起来的url一起通过json格式发送给服务器

这里试了各种方法，问了各种大牛都没找到好的方法，只能说有些能解决，但是达不到非常满意的效果。这里总结一下常见的使用。


1. RunLoop

    需要注意一点: 这儿用的是NSURLSession, 不是AFN, 所以block里面的线程是子线程,不是主线程, 不能直接使用CFRunLoopGetCurrent
    
	    CFRunLoopGetCurrent : Returns the CFRunLoop object for the current thread.
	    CFRunLoopGetMain: Returns the main CFRunLoop object.
		
		NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		        NSLog(@"A");
		        CFRunLoopStop(CFRunLoopGetMain());
		    }] ;
		    [task resume];
		 CFRunLoopRun();
		 NSLog(@"B");

2. GCD的group

    dispatch_group_notify就是需要等queue里面的子线程都执行完毕之后才会执行
    这种方法比较常见, 不多说
	
		dispatch_group_t group = dispatch_group_create();
		    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
		    dispatch_group_async(group, queue, ^{
		        NSLog(@"A");
		    });
		    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
		        NSLog(@"B");
		    });

3. dispatch_barrier_async

    barrier的中文意思就是障碍, 屏障
    一般使用dispatch_barrier_async, 会让barrier之前的线程执行完成之后才会执行barrier后面的操作

		 dispatch_queue_t queue =  dispatch_queue_create(0, DISPATCH_QUEUE_CONCURRENT);
		    dispatch_async(queue, ^{
		        NSLog(@"A");
		    });
		    dispatch_async(queue, ^{
		        NSLog(@"C");
		    });
		    dispatch_barrier_async(queue, ^{
		        NSLog(@"拿到了A的值");
		    });
		
		    dispatch_async(queue, ^{
		        NSLog(@"D");
		    });
		    dispatch_async(queue, ^{
		        NSLog(@"E");
		    });dispatch_async(queue, ^{
		        NSLog(@"F");
		    });

4.NSOperationQueue

   主要就是用到NSOperationQueue的一个对象方法-addDependency
   需要注意一点: waitUntilFinished如果是YES,必须等到queue中所有Operation执行完毕之后, 才会打印HAHA, 反之的话, HAHA的打印顺序是随机的了,就看哪个线程跑得快了...

	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	    NSBlockOperation *p1 = [NSBlockOperation blockOperationWithBlock:^{
	        NSLog(@"A");
	    }];
	    NSBlockOperation *p2 = [NSBlockOperation blockOperationWithBlock:^{
	        NSLog(@"B");
	    }];
	    NSBlockOperation *p3 = [NSBlockOperation blockOperationWithBlock:^{
	        NSLog(@"C");
	    }];
	    [p3 addDependency:p1];
	    [p3 addDependency:p2];
	    // waitUntilFinished是否阻塞当前线程
	    [queue addOperations:@[p1,p2,p3] waitUntilFinished:NO];
	
	    // 如果是NO,那么这行打印就是随机的, 反之就是等A,B,C都打印完之后才执行
	    NSLog(@"HAHA");

5. 使用AFN中的batchOfRequestOperations

    这个和GCD一样, 我工作中比较常用的一种方法
    batchOfRequestOperations方法其实是AFHTTPRequestOperation的父类AFURLConnectionOperation的一个方法.
    这儿的waitUntilFinished同4. NSOperationQueue
    progressBlock一般用在进度计算中, 比如执行了多少百分比, 可以自定义一些炫酷动画

		AFHTTPRequestOperation *queue = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
		    [queue setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		        NSLog(@"A");
		    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		        NSLog(@"A");
		    }];
		    [queue resume];
	
	    AFHTTPRequestOperation *queue2 = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
	    [queue2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
	        NSLog(@"B");
	    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	        NSLog(@"B");
	    }];
	    [queue2 resume];
	
	    NSArray *operations = [AFHTTPRequestOperation batchOfRequestOperations:@[queue, queue2] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
	        NSLog(@"%ld/%ld", numberOfFinishedOperations, totalNumberOfOperations);
	    } completionBlock:^(NSArray *operations) {
	        NSLog(@"C");
	    }];
	
	    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];

6.其他

    老早以前, 我一般是在一个异步请求中的completionBlock或者successBlock中拿到需要的值, 为空判断后,直接在block里面再写一个异步线程...其实这样的写法可能很多人都用过,但是代码的阅读性太弱了,花括号太多,看的眼花缭乱的...
    其实还可以设置flag进行判断等等方法...
    暂时就想到这么多, 还有别的方案的话, 欢迎留言哈,大家共同学习!!!



7.使用与性能对比

	//
	//  ViewController.m
	//  iOSLockBenckmark
	//
	//  Created by ibireme on 16/1/14.
	//  Copyright © 2016 ibireme. All rights reserved.
	//
	
	#import "ViewController.h"
	#import <pthread.h>
	#import <libkern/OSAtomic.h>
	#import <QuartzCore/QuartzCore.h>
	
	typedef NS_ENUM(NSUInteger, LockType) {
	    LockTypeOSSpinLock = 0,
	    LockTypedispatch_semaphore,
	    LockTypepthread_mutex,
	    LockTypeNSCondition,
	    LockTypeNSLock,
	    LockTypepthread_mutex_recursive,
	    LockTypeNSRecursiveLock,
	    LockTypeNSConditionLock,
	    LockTypesynchronized,
	    LockTypeCount,
	};
	
	
	NSTimeInterval TimeCosts[LockTypeCount] = {0};
	int TimeCount = 0;
	
	@interface ViewController ()
	
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad {
	    [super viewDidLoad];
	    
	    int buttonCount = 5;
	    for (int i = 0; i < buttonCount; i++) {
	        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	        button.frame = CGRectMake(0, 0, 200, 50);
	        button.center = CGPointMake(self.view.frame.size.width / 2, i * 60 + 160);
	        button.tag = pow(10, i + 3);
	        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	        [button setTitle:[NSString stringWithFormat:@"run (%d)",(int)button.tag] forState:UIControlStateNormal];
	        [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
	        [self.view addSubview:button];
	    }
	}
	
	- (void)tap:(UIButton *)sender {
	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	        [self test:(int)sender.tag];
	    });
	}
	
	- (IBAction)clear:(id)sender {
	    for (NSUInteger i = 0; i < LockTypeCount; i++) {
	        TimeCosts[i] = 0;
	    }
	    TimeCount = 0;
	    printf("---- clear ----\n\n");
	}
	
	- (IBAction)log:(id)sender {
	    printf("OSSpinLock:               %8.2f ms\n", TimeCosts[LockTypeOSSpinLock] * 1000);
	    printf("dispatch_semaphore:       %8.2f ms\n", TimeCosts[LockTypedispatch_semaphore] * 1000);
	    printf("pthread_mutex:            %8.2f ms\n", TimeCosts[LockTypepthread_mutex] * 1000);
	    printf("NSCondition:              %8.2f ms\n", TimeCosts[LockTypeNSCondition] * 1000);
	    printf("NSLock:                   %8.2f ms\n", TimeCosts[LockTypeNSLock] * 1000);
	    printf("pthread_mutex(recursive): %8.2f ms\n", TimeCosts[LockTypepthread_mutex_recursive] * 1000);
	    printf("NSRecursiveLock:          %8.2f ms\n", TimeCosts[LockTypeNSRecursiveLock] * 1000);
	    printf("NSConditionLock:          %8.2f ms\n", TimeCosts[LockTypeNSConditionLock] * 1000);
	    printf("@synchronized:            %8.2f ms\n", TimeCosts[LockTypesynchronized] * 1000);
	    printf("---- fin (sum:%d) ----\n\n",TimeCount);
	}
	
	
	- (void)test:(int)count {
	    NSTimeInterval begin, end;
	    TimeCount += count;
	    
	    {
	        OSSpinLock lock = OS_SPINLOCK_INIT;
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            OSSpinLockLock(&lock);
	            OSSpinLockUnlock(&lock);
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypeOSSpinLock] += end - begin;
	        printf("OSSpinLock:               %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    
	    {
	        dispatch_semaphore_t lock =  dispatch_semaphore_create(1);
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
	            dispatch_semaphore_signal(lock);
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypedispatch_semaphore] += end - begin;
	        printf("dispatch_semaphore:       %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    
	    {
	        pthread_mutex_t lock;
	        pthread_mutex_init(&lock, NULL);
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            pthread_mutex_lock(&lock);
	            pthread_mutex_unlock(&lock);
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypepthread_mutex] += end - begin;
	        pthread_mutex_destroy(&lock);
	        printf("pthread_mutex:            %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    
	    {
	        NSCondition *lock = [NSCondition new];
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            [lock lock];
	            [lock unlock];
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypeNSCondition] += end - begin;
	        printf("NSCondition:              %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    
	    {
	        NSLock *lock = [NSLock new];
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            [lock lock];
	            [lock unlock];
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypeNSLock] += end - begin;
	        printf("NSLock:                   %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    
	    {
	        pthread_mutex_t lock;
	        pthread_mutexattr_t attr;
	        pthread_mutexattr_init(&attr);
	        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
	        pthread_mutex_init(&lock, &attr);
	        pthread_mutexattr_destroy(&attr);
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            pthread_mutex_lock(&lock);
	            pthread_mutex_unlock(&lock);
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypepthread_mutex_recursive] += end - begin;
	        pthread_mutex_destroy(&lock);
	        printf("pthread_mutex(recursive): %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    
	    {
	        NSRecursiveLock *lock = [NSRecursiveLock new];
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            [lock lock];
	            [lock unlock];
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypeNSRecursiveLock] += end - begin;
	        printf("NSRecursiveLock:          %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    
	    {
	        NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1];
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            [lock lock];
	            [lock unlock];
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypeNSConditionLock] += end - begin;
	        printf("NSConditionLock:          %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    
	    {
	        NSObject *lock = [NSObject new];
	        begin = CACurrentMediaTime();
	        for (int i = 0; i < count; i++) {
	            @synchronized(lock) {}
	        }
	        end = CACurrentMediaTime();
	        TimeCosts[LockTypesynchronized] += end - begin;
	        printf("@synchronized:            %8.2f ms\n", (end - begin) * 1000);
	    }
	    
	    printf("---- fin (%d) ----\n\n",count);
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