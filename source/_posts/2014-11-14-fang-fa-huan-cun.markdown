---
layout: post
title: "方法缓存"
date: 2014-11-14 17:42:41 +0800
comments: true
categories: Bottom
---

 

> 摘要
只要用到Objective-C，我们每天都会跟方法调用打交道。我们都知道Objective-C的方法决议是动态的，但是在底层一个方法究竟是怎么找到的，方法缓存又是怎么运作的却鲜为人知。本文主要从源码角度探究了Objective-C在runtime层的方法决议（Method resolving）过程和方法缓存（Method cache）的实现。

简介
本文作者来自美团酒店旅游事业群iOS研发组。我们致力于创造价值、提升效率、追求卓越。欢迎大家加入我们（简历请发送到邮箱 majia03@meituan.com ）。

本文系学习Objective-C的runtime源码时整理所成，主要剖析了Objective-C在runtime层的方法决议过程和方法缓存，内容包括：

* 从消息决议说起
* 缓存为谁而生
* 追本溯源，何为方法缓存
* 缓存和散列
* 十万个为什么
* 缓存 - 性能优化的万金油？
* 优化，永无止境
* 从消息决议说起



<!--more-->




我们都知道，在Objective-C里调用一个方法是这样的：

	[object methodA];
这表示我们想去调用object的methodA。
但是在Objective-C里面调用一个方法到底意味着什么呢，是否和C++一样，任何一个非虚方法都会被编译成一个唯一的符号，在调用的时候去查找符号表，找到这个方法然后调用呢？
答案是否定的。在Objective-C里面调用一个方法的时候，runtime层会将这个调用翻译成

	objc_msgSend(id self, SEL op, ...)
而objc_msgSend具体又是如何分发的呢？ 我们来看下runtime层objc_msgSend的源码。
在objc-msg-arm.s中，objc_msgSend的代码如下：
（ps：Apple为了高度优化objc_msgSend的性能，这个文件是汇编写成的，不过即使我们不懂汇编，详尽的注释也可以让我们一窥其真面目）

	ENTRY objc_msgSend
	# check whether receiver is nil
	teq     a1, #0
	    beq     LMsgSendNilReceiver
	
	# save registers and load receiver's class for CacheLookup
	stmfd   sp!, {a4,v1}
	ldr     v1, [a1, #ISA]
	
	# receiver is non-nil: search the cache
	CacheLookup a2, v1, LMsgSendCacheMiss
	
	# cache hit (imp in ip) and CacheLookup returns with nonstret (eq) set, restore registers and call
	ldmfd   sp!, {a4,v1}
	bx      ip
	
	# cache miss: go search the method lists
	LMsgSendCacheMiss:
	ldmfd sp!, {a4,v1}
	b _objc_msgSend_uncached
	
	LMsgSendNilReceiver:
	    mov     a2, #0
	    bx      lr
	
	LMsgSendExit:
	END_ENTRY objc_msgSend
	
	
	STATIC_ENTRY objc_msgSend_uncached
	
	# Push stack frame
	stmfd sp!, {a1-a4,r7,lr}
	add     r7, sp, #16
	
	# Load class and selector
	ldr a3, [a1, #ISA] /* class = receiver->isa  */
	/* selector already in a2 */
	/* receiver already in a1 */
	
	# Do the lookup
	MI_CALL_EXTERNAL(__class_lookupMethodAndLoadCache3)
	MOVE    ip, a1
	
	# Prep for forwarding, Pop stack frame and call imp
	teq v1, v1 /* set nonstret (eq) */
	ldmfd sp!, {a1-a4,r7,lr}
	bx ip
从上述代码中可以看到，objc_msgSend（就arm平台而言）的消息分发分为以下几个步骤：

判断receiver是否为nil，也就是objc_msgSend的第一个参数self，也就是要调用的那个方法所属对象
从缓存里寻找，找到了则分发，否则
利用objc-class.mm中_class_lookupMethodAndLoadCache3（为什么有个这么奇怪的方法。本文末尾会解释）方法去寻找selector

如果支持GC，忽略掉非GC环境的方法（retain等）
从本class的method list寻找selector，如果找到，填充到缓存中，并返回selector，否则
寻找父类的method list，并依次往上寻找，直到找到selector，填充到缓存中，并返回selector，否则
调用_class_resolveMethod，如果可以动态resolve为一个selector，不缓存，方法返回，否则
转发这个selector，否则
报错，抛出异常
缓存为谁而生
从上面的分析中我们可以看到，当一个方法在比较“上层”的类中，用比较“下层”（继承关系上的上下层）对象去调用的时候，如果没有缓存，那么整个查找链是相当长的。就算方法是在这个类里面，当方法比较多的时候，每次都查找也是费事费力的一件事情。
考虑下面的一个调用过程：

	for ( int i = 0; i < 100000; ++i) {
	    MyClass *myObject = myObjects[i];
	    [myObject methodA];
	}
当我们需要去调用一个方法数十万次甚至更多地时候，查找方法的消耗会变的非常显著。
就算我们平常的非大规模调用，除非一个方法只会调用一次，否则缓存都是有用的。在运行时，那么多对象，那么多方法调用，节省下来的时间也是非常可观的。

追本溯源，何为方法缓存
本着源码面前，了无秘密的原则，我们看下源码中的方法缓存到底是什么，在objc-cache.mm中，objc_cache的定义如下：

	struct objc_cache {
	    uintptr_t mask;            /* total = mask + 1 */
	    uintptr_t occupied;       
	    cache_entry *buckets[1];
	};
嗯，objc_cache的定义看起来很简单，它包含了下面三个变量：

* 1)、mask：可以认为是当前能达到的最大index（从0开始的），所以缓存的size（total）是mask+1
* 2)、occupied：被占用的槽位，因为缓存是以散列表的形式存在的，所以会有空槽，而occupied表示当前被占用的数目
* 3)、buckets：用数组表示的hash表，cache_entry类型，每一个cache_entry代表一个方法缓存
(buckets定义在objc_cache的最后，说明这是一个可变长度的数组)

而cache_entry的定义如下：

	typedef struct {
	    SEL name;     // same layout as struct old_method
	    void *unused;
	    IMP imp;  // same layout as struct old_method
	} cache_entry;
cache_entry定义也包含了三个字段，分别是：

* 1)、name，被缓存的方法名字
* 2)、unused，保留字段，还没被使用。
* 3)、imp，方法实现

缓存和散列
缓存的存储使用了散列表。
为什么要用散列表呢？因为散列表检索起来更快，我们来看下是方法缓存如何散列和检索的：
	
	// Scan for the first unused slot and insert there.
	// There is guaranteed to be an empty slot because the 
	// minimum size is 4 and we resized at 3/4 full.
	buckets = (cache_entry **)cache->buckets;
	for (index = CACHE_HASH(sel, cache->mask); 
	     buckets[index] != NULL; 
	     index = (index+1) & cache->mask)
	{
	    // empty
	}
	buckets[index] = entry;
这是往方法缓存里存放一个方法的代码片段，我们可以看到sel被散列后找到一个空槽放在buckets中，而CACHE_HASH的定义如下：

	#define CACHE_HASH(sel, mask) (((uintptr_t)(sel)>>2) & (mask))
这段代码就是利用了sel的指针地址和mask做了一下简单计算得出的。
而从散列表取缓存则是利用汇编语言写成的（是为了高度优化objc_msgSend而使用汇编的）。我们看objc-msg-arm.mm 里面的CacheLookup方法：

	.macro CacheLookup /* selReg, classReg, missLabel */
	
	 MOVE r9, $0, LSR #2          /* index = (sel >> 2) */
	 ldr     a4, [$1, #CACHE]        /* cache = class->cache */
	 add     a4, a4, #BUCKETS        /* buckets = &cache->buckets */
	
	/* search the cache */
	/* a1=receiver, a2 or a3=sel, r9=index, a4=buckets, $1=method */
	1:
	 ldr     ip, [a4, #NEGMASK]      /* mask = cache->mask */
	 and     r9, r9, ip              /* index &= mask           */
	 ldr     $1, [a4, r9, LSL #2]    /* method = buckets[index] */
	 teq     $1, #0                  /* if (method == NULL)     */
	 add     r9, r9, #1              /* index++                 */
	 beq     $2                      /*     goto cacheMissLabel */
	
	 ldr     ip, [$1, #METHOD_NAME]  /* load method->method_name        */
	 teq     $0, ip                  /* if (method->method_name != sel) */
	 bne     1b                      /*     retry                       */
	
	/* cache hit, $1 == method triplet address */
	/* Return triplet in $1 and imp in ip      */
	 ldr     ip, [$1, #METHOD_IMP]   /* imp = method->method_imp */
	
	.endmacro
虽然是汇编，但是注释太详尽了，理解起来并不难，还是求hash，去buckets里找，找不到按照hash冲突的规则继续向下，直到最后。

十万个为什么
了解了方法缓存的定义之后，我们提出几个问题并一一解答

方法缓存存在什么地方？
让我们去翻看类的定义，在Objective-C 2.0中，Class的定义大致是这样的（见objc-runtime.mm）

	  struct _class_t {
	  struct _class_t *isa;
	  struct _class_t *superclass;
	  void *cache;
	  void *vtable;
	  struct _class_ro_t *ro;
	  };
我们看到在类的定义里就有cache字段，没错，类的所有缓存都存在metaclass上，所以每个类都只有一份方法缓存，而不是每一个类的object都保存一份。
父类方法的缓存只存在父类么，还是子类也会缓存父类的方法？
在第一节对objc_msgSend的追溯中我们可以看到，即便是从父类取到的方法，也会存在类本身的方法缓存里。而当用一个父类对象去调用那个方法的时候，也会在父类的metaclass里缓存一份。
类的方法缓存大小有没有限制？
要回答这个问题，我们需要再看一下源码，在objc-cache.mm有一个变量定义如下：

	  /* When _class_slow_grow is non-zero, any given cache is actually grown
	   * only on the odd-numbered times it becomes full; on the even-numbered
	   * times, it is simply emptied and re-used.  When this flag is zero,
	   * caches are grown every time. */
	  static const int _class_slow_grow = 1;
其实不用再看进一步的代码片段，仅从注释我们就可以看到问题的答案。注释中说明，当_class_slow_grow是非0值的时候，只有当方法缓存第奇数次满（使用的槽位超过3/4）的时候，方法缓存的大小才会增长（会清空缓存，否则hash值就不对了）；当第偶数次满的时候，方法缓存会被清空并重新利用。 如果_class_slow_grow值为0，那么每一次方法缓存满的时候，其大小都会增长。
所以单就问题而言，答案是没有限制，虽然这个值被设置为1，方法缓存的大小增速会慢一点，但是确实是没有上限的。
为什么类的方法列表不直接做成散列表呢，做成list，还要单独缓存，多费事？
这个问题么，我觉得有以下三个原因：

散列表是没有顺序的，Objective-C的方法列表是一个list，是有顺序的；Objective-C在查找方法的时候会顺着list依次寻找，并且category的方法在原始方法list的前面，需要先被找到，如果直接用hash存方法，方法的顺序就没法保证。
list的方法还保存了除了selector和imp之外其他很多属性
散列表是有空槽的，会浪费空间
缓存 - 性能优化的万金油？
非也，就算有了有了Objective-C本身的方法缓存，我们还是有很多调用方法的优化空间，对于这件事情，这篇文章讲的非常详细，大家可以自行移步观摩http://www.mulle-kybernetik.com/artikel/Optimization/opti-3-imp-deluxe.html （强烈推荐，虽然我们一般不会遇到需要这么强度优化的地方，但是这种精神和思想是值得我们学习的）

优化，永无止境
在文章末尾，我们再来回答一下第一节提出的问题：“为什么会有_class_lookupMethodAndLoadCache3这个方法？”
这个方法的实现如下所示：

	/***********************************************************************
	* _class_lookupMethodAndLoadCache.
	* Method lookup for dispatchers ONLY. OTHER CODE SHOULD USE lookUpImp().
	* This lookup avoids optimistic cache scan because the dispatcher
	* already tried that.
	**********************************************************************/
	IMP _class_lookupMethodAndLoadCache3(id obj, SEL sel, Class cls)
	{
	    return lookUpImpOrForward(cls, sel, obj, 
	                              YES/*initialize*/, NO/*cache*/, YES/*resolver*/);
	}
如果单纯看方法名，这个方法应该会从缓存和方法列表中查找一个方法，但是如第一节所讲，在调用这个方法之前，我们已经是从缓存无法找到这个方法了，所以这个方法避免了再去扫描缓存查找方法的过程，而是直接从方法列表找起。从Apple代码的注释，我们也完全可以了解这一点。不顾一切地追求完美和性能，是一种品质。

后记
本文是Objective-C runtime源码研究的第二篇，主要对Objective-C的方法决议和方法缓存做了剖析。runtime的源代码可以在 http://www.opensource.apple.com/tarballs/ 下载。如有错误，敬请指正。