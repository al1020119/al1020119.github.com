---
layout: post
title: "Block深究"
date: 2015-09-06 17:43:24 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

 

## 目录


+ #####什么是block？
	- block编译转换结构
	- block实际结构
	
	
+ #####block的类型
	- NSConcreteGlobalBlock和NSConcreteStackBlock
	- NSConcreteMallocBlock
	
	
+ #####捕捉变量对block结构的影响
	- 局部变量
	- 全局变量
	- 局部静态变量
	- __block修饰的变量
	- self隐式循环引用
	
	
+ #####不同类型block的复制
	- 栈block
	- 堆block
	- 全局block
	
	
+ #####block辅助函数
	- __block修饰的基本类型的辅助函数
	- 对象的辅助函数

+ #####ARC中block的工作
	- block试验
	- block作为参数传递
	- block作为返回值
	- block属性



<!--more-->




### 参考博文


最近看了一些block的资料，并动手做了一些实践，摘录并添加了一些结论。

###什么是block？
首先，看一个极简的block：

		int main(int argc, const char * argv[]) {
		    @autoreleasepool {
		
		        ^{ };
		    }
		    return 0;
		}
#####block编译转换结构

对其执行clang -rewrite-objc编译转换成C++实现，得到以下代码：
	
		struct __block_impl {
		    void *isa;
		    int Flags;
		    int Reserved;
		    void *FuncPtr;
		};
		
		struct __main_block_impl_0 {
		  struct __block_impl impl;
		  struct __main_block_desc_0* Desc;
		  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
		    impl.isa = &_NSConcreteStackBlock;
		    impl.Flags = flags;
		    impl.FuncPtr = fp;
		    Desc = desc;
		  }
		};
		static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
		}
		
		static struct __main_block_desc_0 {
		  size_t reserved;
		  size_t Block_size;
		} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
		int main(int argc, const char * argv[]) {
		    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;
		        (void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA);
		    }
		    return 0;
		}
	
不难看出其中的__main_block_impl_0就是block的一个C++的实现(最后面的_0代表是main中的第几个block)，也就是说也是一个结构体。
其中__block_impl的定义如下：

	struct __block_impl {
	  void *isa;
	  int Flags;
	  int Reserved;
	  void *FuncPtr;
	};
其结构体成员如下：

* isa，指向所属类的指针，也就是block的类型
* flags，标志变量，在实现block的内部操作时会用到
* Reserved，保留变量
* FuncPtr，block执行时调用的函数指针
* 可以看出，它包含了isa指针（包含isa指针的皆为对象），也就是说block也是一个对象* (runtime里面，对象和类都是用结构体表示)。

__main_block_desc_0的定义如下：

		static struct __main_block_desc_0 {
		  size_t reserved;
		  size_t Block_size;
		} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};


其结构成员含义如下：

* reserved：保留字段
* Block_size：block大小(sizeof(struct __main_block_impl_0))
* 以上代码在定义__main_block_desc_0结构体时，同时创建了__main_block_desc_0_DATA，并给它赋值，以供在main函数中对__main_block_impl_0进行初始化。

__main_block_impl_0定义了显式的构造函数，其函数体如下：
	
	  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
	    impl.isa = &_NSConcreteStackBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
可以看出，

* __main_block_impl_0的isa指针指向了_NSConcreteStackBlock，
* 从main函数中看， __main_block_impl_0的FuncPtr指向了函数__main_block_func_0
* __main_block_impl_0的Desc也指向了定义__main_block_desc_0时就创建的__main_block_desc_0_DATA，其中纪录了block结构体大小等信息。
* 以上就是根据编译转换的结果，对一个简单block的解析，后面会将block操作不同类型的外部变量，对block结构的影响进行相应的说明。

#####block实际结构
接下来观察下Block_private.h文件中对block的相关结构体的真实定义：

	/* Revised new layout. */
	struct Block_descriptor {
	    unsigned long int reserved;
	    unsigned long int size;
	    void (*copy)(void *dst, void *src);
	    void (*dispose)(void *);
	};
	
	
	struct Block_layout {
	    void *isa;
	    int flags;
	    int reserved;
	    void (*invoke)(void *, ...);
	    struct Block_descriptor *descriptor;
	    /* Imported variables. */
	};
有了上文对编译转换的分析，这里只针对略微不同的成员进行分析：

invoke，同上文的FuncPtr，block执行时调用的函数指针，block定义时内部的执行代码都在这个函数中
Block_descriptor，block的详细描述

* copy/dispose，辅助拷贝/销毁函数，处理block范围外的变量时使用
* 总体来说，block就是一个里面存储了指向函数体中包含定义block时的代码块的函数指针，以及block外部上下文变量等信息的结构体。

###block的类型
block的常见类型有3种：

* _NSConcreteGlobalBlock（全局）
* _NSConcreteStackBlock（栈）
* _NSConcreteMallocBlock（堆）

附上APUE的进程虚拟内存段分布图：

{% img /images/block001.png Caption %}  

进程虚拟内存空间分布

* 其中前2种在Block.h种声明，后1种在Block_private.h中声明，所以最后1种基本不会在源码中出现。
* 由于无法直接创建_NSConcreteMallocBlock类型的block，所以这里只对前面2种进行手动创建分析，最后1种通过源代码分析。

#####NSConcreteGlobalBlock和NSConcreteStackBlock
首先，根据前面两种类型，编写以下代码：
	
	void (^globalBlock)() = ^{
	
	};
	
	int main(int argc, const char * argv[]) {
	    @autoreleasepool {
	        void (^stackBlock1)() = ^{
	
	        };
	    }
	    return 0;
	}
对其进行编译转换后得到以下缩略代码：

	// globalBlock
	struct __globalBlock_block_impl_0 {
	  struct __block_impl impl;
	  struct __globalBlock_block_desc_0* Desc;
	  __globalBlock_block_impl_0(void *fp, struct __globalBlock_block_desc_0 *desc, int flags=0) {
	    impl.isa = &_NSConcreteGlobalBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
	};
	...
	
	// stackBlock
	struct __main_block_impl_0 {
	  struct __block_impl impl;
	  struct __main_block_desc_0* Desc;
	  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
	    impl.isa = &_NSConcreteStackBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
	};
	...
	int main(int argc, const char * argv[]) {
	    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;
	        void (*stackBlock)() = (void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA);
	    }
	    return 0;
	}
可以看出globalBlock的isa指向了_NSConcreteGlobalBlock，即在全局区域创建，编译时具体的代码就已经确定在上图中的代码段中了，block变量存储在全局数据存储区；stackBlock的isa指向了_NSConcreteStackBlock，即在栈区创建。

#####NSConcreteMallocBlock

* 接下来是在堆中的block，堆中的block无法直接创建，其需要由_NSConcreteStackBlock类型的block拷贝而来(也就是说block需要执行copy之后才能存放到堆中)。由于block的拷贝最终都会调用_Block_copy_internal函数，所以观察这个函数就可以知道堆中block是如何被创建的了：
		
		static void *_Block_copy_internal(const void *arg, const int flags) {
		    struct Block_layout *aBlock;
		    ...
		    aBlock = (struct Block_layout *)arg;
		    ...
		    // Its a stack block.  Make a copy.
		    if (!isGC) {
		        // 申请block的堆内存
		        struct Block_layout *result = malloc(aBlock->descriptor->size);
		        if (!result) return (void *)0;
		        // 拷贝栈中block到刚申请的堆内存中
		        memmove(result, aBlock, aBlock->descriptor->size); // bitcopy first
		        // reset refcount
		        result->flags &= ~(BLOCK_REFCOUNT_MASK);    // XXX not needed
		        result->flags |= BLOCK_NEEDS_FREE | 1;
		        // 改变isa指向_NSConcreteMallocBlock，即堆block类型
		        result->isa = _NSConcreteMallocBlock;
		        if (result->flags & BLOCK_HAS_COPY_DISPOSE) {
		            //printf("calling block copy helper %p(%p, %p)...\n", aBlock->descriptor->copy, result, aBlock);
		            (*aBlock->descriptor->copy)(result, aBlock); // do fixup
		        }
		        return result;
		    }
		    else {
		        ...
		    }
		}
从以上代码以及注释可以很清楚的看出，函数通过memmove将栈中的block的内容拷贝到了堆中，并使isa指向了_NSConcreteMallocBlock。
block主要的一些学问就出在栈中block向堆中block的转移过程中了。

捕捉变量对block结构的影响
接下来会编译转换捕捉不同变量类型的block，以对比它们的区别。

#####局部变量
前：

	- (void)test
	{
	    int a;
	    ^{a;};
	}
后：
	
	struct __Person__test_block_impl_0 {
	  struct __block_impl impl;
	  struct __Person__test_block_desc_0* Desc;
	  int a;
	  // a(_a)是构造函数的参数列表初始化形式，相当于a = _a。从_I_Person_test看，传入的就是a
	  __Person__test_block_impl_0(void *fp, struct __Person__test_block_desc_0 *desc, int _a, int flags=0) : a(_a) {
	    impl.isa = &_NSConcreteStackBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
	};
	static void __Person__test_block_func_0(struct __Person__test_block_impl_0 *__cself) {
	  int a = __cself->a; // bound by copy
	a;}
	
	static struct __Person__test_block_desc_0 {
	  size_t reserved;
	  size_t Block_size;
	} __Person__test_block_desc_0_DATA = { 0, sizeof(struct __Person__test_block_impl_0)};
	
	static void _I_Person_test(Person * self, SEL _cmd) {
	    int a;
	    (void (*)())&__Person__test_block_impl_0((void *)__Person__test_block_func_0, &__Person__test_block_desc_0_DATA, a);
	}
可以看到，block相对于文章开头增加了一个int类型的成员变量，他就是用来存储外部变量a的。可以看出，这次拷贝只是一次值传递。并且当我们想在block中进行以下操作时，将会发生错误

	^{a = 10;};
编译器会提示

{% img /images/block002.png Caption %}  

错误提示
。因为_I_Person_test函数中的a和Persontest_block_func_0函数中的a并没有在同一个作用域，所以在block对a进行赋值是没有意义的，所以编译器给出了错误。我们可以通过地址传递来消除以上错误：

	- (void)test
	{
	    int a = 0;
	    // 利用指针p存储a的地址
	    int *p = &a;
	
	    ^{
	        // 通过a的地址设置a的值
	        *p = 10;
	    };
	}
但是变量a的生命周期是和方法test的栈相关联的，当test运行结束，栈随之销毁，那么变量a就会被销毁，p也就成为了野指针。如果block是作为参数或者返回值，这些类型都是跨栈的，也就是说再次调用会造成野指针错误。

#####全局变量
前：
	
	// 全局静态
	static int a;
	// 全局
	int b;
	- (void)test
	{
	
	    ^{
	        a = 10;
	        b = 10;
	    };
	}
后：

	static int a;
	int b;
	
	struct __Person__test_block_impl_0 {
	  struct __block_impl impl;
	  struct __Person__test_block_desc_0* Desc;
	  __Person__test_block_impl_0(void *fp, struct __Person__test_block_desc_0 *desc, int flags=0) {
	    impl.isa = &_NSConcreteStackBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
	};
	static void __Person__test_block_func_0(struct __Person__test_block_impl_0 *__cself) {
	
	        a = 10;
	        b = 10;
	    }
	
	static struct __Person__test_block_desc_0 {
	  size_t reserved;
	  size_t Block_size;
	} __Person__test_block_desc_0_DATA = { 0, sizeof(struct __Person__test_block_impl_0)};
	
	static void _I_Person_test(Person * self, SEL _cmd) {
	
	    (void (*)())&__Person__test_block_impl_0((void *)__Person__test_block_func_0, &__Person__test_block_desc_0_DATA);
	}
可以看出，因为全局变量都是在静态数据存储区，在程序结束前不会被销毁，所以block直接访问了对应的变量，而没有在Persontest_block_impl_0结构体中给变量预留位置。

#####局部静态变量
前

	- (void)test
	{
	    static int a;
	    ^{
	        a = 10;
	    };
	}
后：

	struct __Person__test_block_impl_0 {
	  struct __block_impl impl;
	  struct __Person__test_block_desc_0* Desc;
	  int *a;
	  __Person__test_block_impl_0(void *fp, struct __Person__test_block_desc_0 *desc, int *_a, int flags=0) : a(_a) {
	    impl.isa = &_NSConcreteStackBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
	};
	static void __Person__test_block_func_0(struct __Person__test_block_impl_0 *__cself) {
	  int *a = __cself->a; // bound by copy
	        // 这里通过局部静态变量a的地址来对其进行修改
	        (*a) = 10;
	    }
	
	static struct __Person__test_block_desc_0 {
	  size_t reserved;
	  size_t Block_size;
	} __Person__test_block_desc_0_DATA = { 0, sizeof(struct __Person__test_block_impl_0)};
	
	static void _I_Person_test(Person * self, SEL _cmd) {
	    static int a;
	    // 传入a的地址
	    (void (*)())&__Person__test_block_impl_0((void *)__Person__test_block_func_0, &__Person__test_block_desc_0_DATA, &a);
	}
需要注意一点的是静态局部变量是存储在静态数据存储区域的，也就是和程序拥有一样的生命周期，也就是说在程序运行时，都能够保证block访问到一个有效的变量。但是其作用范围还是局限于定义它的函数中，所以只能在block通过静态局部变量的地址来进行访问。
关于变量的存储我原来的这篇博客有提及：c语言臆想--全局---局部变量

#####__block修饰的变量
前：

	- (void)test
	{
	   __block int a;
	    ^{
	        a = 10;
	    };
	}
后：

	struct __Block_byref_a_0 {
	  void *__isa;
	__Block_byref_a_0 *__forwarding;
	 int __flags;
	 int __size;
	 int a;
	};
	
	struct __Person__test_block_impl_0 {
	  struct __block_impl impl;
	  struct __Person__test_block_desc_0* Desc;
	  __Block_byref_a_0 *a; // by ref
	  __Person__test_block_impl_0(void *fp, struct __Person__test_block_desc_0 *desc, __Block_byref_a_0 *_a, int flags=0) : a(_a->__forwarding) {
	    impl.isa = &_NSConcreteStackBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
	};
	static void __Person__test_block_func_0(struct __Person__test_block_impl_0 *__cself) {
	  __Block_byref_a_0 *a = __cself->a; // bound by ref
	        // 注意，这里的_forwarding用来保证操作的始终是堆中的拷贝a，而不是栈中的a
	        (a->__forwarding->a) = 10;
	    }
	static void __Person__test_block_copy_0(struct __Person__test_block_impl_0*dst, struct __Person__test_block_impl_0*src) {_Block_object_assign((void*)&dst->a, (void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);}
	
	static void __Person__test_block_dispose_0(struct __Person__test_block_impl_0*src) {_Block_object_dispose((void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);}
	
	static struct __Person__test_block_desc_0 {
	  size_t reserved;
	  size_t Block_size;
	  void (*copy)(struct __Person__test_block_impl_0*, struct __Person__test_block_impl_0*);
	  void (*dispose)(struct __Person__test_block_impl_0*);
	} __Person__test_block_desc_0_DATA = { 0, sizeof(struct __Person__test_block_impl_0), __Person__test_block_copy_0, __Person__test_block_dispose_0};
	
	static void _I_Person_test(Person * self, SEL _cmd) {
	    // __block将a包装成了一个对象
	   __attribute__((__blocks__(byref))) __Block_byref_a_0 a = {(void*)0,(__Block_byref_a_0 *)&a, 0, sizeof(__Block_byref_a_0)};
	;
	    (void (*)())&__Person__test_block_impl_0((void *)__Person__test_block_func_0, &__Person__test_block_desc_0_DATA, (__Block_byref_a_0 *)&a, 570425344);
	}
可以看到，对比上面的结果，明显多了__Block_byref_a_0结构体，这个结构体中含有isa指针，所以也是一个对象，它是用来包装局部变量a的。当block被copy到堆中时，__Person__test_block_impl_0的拷贝辅助函数__Person__test_block_copy_0会将__Block_byref_a_0拷贝至堆中，所以即使局部变量所在堆被销毁，block依然能对堆中的局部变量进行操作。其中__Block_byref_a_0成员指针__forwarding用来指向它在堆中的拷贝，其依据源码如下：

	static void _Block_byref_assign_copy(void *dest, const void *arg, const int flags) {
	    struct Block_byref **destp = (struct Block_byref **)dest;
	    struct Block_byref *src = (struct Block_byref *)arg;
	
	    ...
	    // 堆中拷贝的forwarding指向它自己
	    copy->forwarding = copy; // patch heap copy to point to itself (skip write-barrier)
	    // 栈中的forwarding指向堆中的拷贝
	    src->forwarding = copy;  // patch stack to point to heap copy
	    ...
	}
这样做是为了保证操作的值始终是堆中的拷贝，而不是栈中的值。（处理在局部变量所在栈还没销毁，就调用block来改变局部变量值的情况，如果没有__forwarding指针，则修改无效）
至于block如何实现对局部变量的拷贝，下面会详细说明。

#####self隐式循环引用
前：
	
	@implementation Person
	{
	    int _a;
	    void (^_block)();
	}
	- (void)test
	{
	  void (^_block)() = ^{
	        _a = 10;
	    };
	}
	
	@end
后：
	
	struct __Person__test_block_impl_0 {
	  struct __block_impl impl;
	  struct __Person__test_block_desc_0* Desc;
	  // 可以看到，block强引用了self
	  Person *self;
	  __Person__test_block_impl_0(void *fp, struct __Person__test_block_desc_0 *desc, Person *_self, int flags=0) : self(_self) {
	    impl.isa = &_NSConcreteStackBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
	};
	static void __Person__test_block_func_0(struct __Person__test_block_impl_0 *__cself) {
	  Person *self = __cself->self; // bound by copy
	
	        (*(int *)((char *)self + OBJC_IVAR_$_Person$_a)) = 10;
	    }
	static void __Person__test_block_copy_0(struct __Person__test_block_impl_0*dst, struct __Person__test_block_impl_0*src) {_Block_object_assign((void*)&dst->self, (void*)src->self, 3/*BLOCK_FIELD_IS_OBJECT*/);}
	
	static void __Person__test_block_dispose_0(struct __Person__test_block_impl_0*src) {_Block_object_dispose((void*)src->self, 3/*BLOCK_FIELD_IS_OBJECT*/);}
	
	static struct __Person__test_block_desc_0 {
	  size_t reserved;
	  size_t Block_size;
	  void (*copy)(struct __Person__test_block_impl_0*, struct __Person__test_block_impl_0*);
	  void (*dispose)(struct __Person__test_block_impl_0*);
	} __Person__test_block_desc_0_DATA = { 0, sizeof(struct __Person__test_block_impl_0), __Person__test_block_copy_0, __Person__test_block_dispose_0};
	
	static void _I_Person_test(Person * self, SEL _cmd) {
	  void (*_block)() = (void (*)())&__Person__test_block_impl_0((void *)__Person__test_block_func_0, &__Person__test_block_desc_0_DATA, self, 570425344);
	}
如果在编译转换前，将_a改成self.a，能很明显地看出是产生了循环引用(self强引用block，block强引用self)。那么使用_a呢？经过编译转换后，依然可以在__Person__test_block_impl_0看见self的身影。且在函数_I_Person_test中，传入的参数也是self。通过以下语句，可以看出，不管是用什么形式访问实例变量，最终都会转换成self+变量内存偏移的形式。所以在上面例子中使用_a也会造成循环引用。
	
	static void __Person__test_block_func_0(struct __Person__test_block_impl_0 *__cself) {
	  Person *self = __cself->self; // bound by copy
	        // self＋实例变量a的偏移值
	        (*(int *)((char *)self + OBJC_IVAR_$_Person$_a)) = 10;
	    }
	    
###不同类型block的复制
block的复制代码在_Block_copy_internal函数中。

#####栈block
从以下代码可以看出，栈block的复制不仅仅复制了其内容，还添加了一些额外的东西

	* 1、往flags中并入了BLOCK_NEEDS_FREE（这个标志表明block需要释放，在release以及再次拷贝时会用到）

	* 2、如果有辅助copy函数（BLOCK_HAS_COPY_DISPOSE），那么就调用（这个辅助copy函数是用来拷贝block捕获的变量的）

	struct Block_layout *result = malloc(aBlock->descriptor->size);
	if (!result) return (void *)0;
	  memmove(result, aBlock, aBlock->descriptor->size); // bitcopy first
	// reset refcount
	result->flags &= ~(BLOCK_REFCOUNT_MASK);    // XXX not needed
	result->flags |= BLOCK_NEEDS_FREE | 1;
	result->isa = _NSConcreteMallocBlock;
	if (result->flags & BLOCK_HAS_COPY_DISPOSE) {
	      //printf("calling block copy helper %p(%p, %p)...\n", aBlock->descriptor->copy, result, aBlock);
	      (*aBlock->descriptor->copy)(result, aBlock); // do fixup
	  }
	  return result;
#####堆block
从以下代码看出，如果block的flags中有BLOCK_NEEDS_FREE标志（block从栈中拷贝到堆时添加的标志），就执行latching_incr_int操作，其功能就是让block的引用计数加1。所以堆中block的拷贝只是单纯地改变了引用计数

	  ...
	  if (aBlock->flags & BLOCK_NEEDS_FREE) {
	        // latches on high
	        latching_incr_int(&aBlock->flags);
	        return aBlock;
	    }
	  ...
#####全局block
从以下代码看出，对于全局block，函数没有做任何操作，直接返回了传入的block


	else if (aBlock->flags & BLOCK_IS_GLOBAL) {
	      return aBlock;
	}

###block辅助函数

* 上文提及到了block辅助copy与dispose处理函数，这里分析下这两个函数的内部实现。在捕* 获变量为__block修饰的基本类型，或者为对象时，block才会有这两个辅助函数。
* block捕捉变量拷贝函数为_Block_object_assign。在调用复制block的函数_Block_copy_internal时，会根据block有无辅助函数来对捕捉变量拷贝函数_Block_object_assign进行调用。而在_Block_object_assign函数中，也会判断捕捉变量包装而成的对象(Block_byref结构体)是否有辅助函数，来进行调用。

#####__block修饰的基本类型的辅助函数
编写以下代码：
	
	typedef void(^Block)();
	int main(int argc, const char * argv[]) {
	    @autoreleasepool {
	        __block int a;
	        Block block = ^ {
	            a;
	        };
	}
转换成C++代码后：

	typedef void(*Block)();
	// __block int a
	struct __Block_byref_a_0 {
	  void *__isa;
	__Block_byref_a_0 *__forwarding;
	 int __flags;
	 int __size;
	 int a;
	};
	
	// block
	struct __main_block_impl_0 {
	  struct __block_impl impl;
	  struct __main_block_desc_0* Desc;
	  __Block_byref_a_0 *a; // by ref
	  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_a_0 *_a, int flags=0) : a(_a->__forwarding) {
	    impl.isa = &_NSConcreteStackBlock;
	    impl.Flags = flags;
	    impl.FuncPtr = fp;
	    Desc = desc;
	  }
	};
	
	// block函数体
	static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
	  __Block_byref_a_0 *a = __cself->a; // bound by ref
	
	            (a->__forwarding->a);
	        }
	// 辅助copy函数
	static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->a, (void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);}
	
	// 辅助dispose函数
	static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);}
	
	static struct __main_block_desc_0 {
	  size_t reserved;
	  size_t Block_size;
	  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
	  void (*dispose)(struct __main_block_impl_0*);
	} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
	int main(int argc, const char * argv[]) {
	    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;
	        // 这里创建了，并将a的flags设置为0
	        __attribute__((__blocks__(byref))) __Block_byref_a_0 a = {(void*)0,(__Block_byref_a_0 *)&a, 0, sizeof(__Block_byref_a_0)};
	;
	        Block block = (void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_a_0 *)&a, 570425344);
	    }
	    return 0;
	}
从上面代码中，被__block修饰的a变量变为了__Block_byref_a_0类型，根据这个格式，从源码中查看得到相似的定义：

	struct Block_byref {
	    void *isa;
	    struct Block_byref *forwarding;
	    int flags; /* refcount; */
	    int size;
	    void (*byref_keep)(struct Block_byref *dst, struct Block_byref *src);
	    void (*byref_destroy)(struct Block_byref *);
	    /* long shared[0]; */
	};
	
	// 做下对比
	struct __Block_byref_a_0 {
	  void *__isa;
	__Block_byref_a_0 *__forwarding;
	 int __flags;
	 int __size;
	 int a;
	};
	
	// flags/_flags类型
	enum {
	        /* See function implementation for a more complete description of these fields and combinations */
	        // 是一个对象
	        BLOCK_FIELD_IS_OBJECT   =  3,  /* id, NSObject, __attribute__((NSObject)), block, ... */
	        // 是一个block
	        BLOCK_FIELD_IS_BLOCK    =  7,  /* a block variable */
	        // 被__block修饰的变量
	        BLOCK_FIELD_IS_BYREF    =  8,  /* the on stack structure holding the __block variable */
	        // 被__weak修饰的变量，只能被辅助copy函数使用
	        BLOCK_FIELD_IS_WEAK     = 16,  /* declared __weak, only used in byref copy helpers */
	        // block辅助函数调用（告诉内部实现不要进行retain或者copy）
	        BLOCK_BYREF_CALLER      = 128  /* called from __block (byref) copy/dispose support routines. */
	    };
可以看出，__block将原来的基本类型包装成了对象。因为以上两个结构体的前4个成员的类型都是一样的，内存空间排列一致，所以可以进行以下操作：
	
	// 转换成C++代码
	static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->a, (void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);}
	
	// _Block_object_assign源码
	void _Block_object_assign(void *destAddr, const void *object, const int flags) {
	...
	    else if ((flags & BLOCK_FIELD_IS_BYREF) == BLOCK_FIELD_IS_BYREF)  {
	        // copying a __block reference from the stack Block to the heap
	        // flags will indicate if it holds a __weak reference and needs a special isa
	        _Block_byref_assign_copy(destAddr, object, flags);
	    }
	...
	}
	
	// _Block_byref_assign_copy源码
	static void _Block_byref_assign_copy(void *dest, const void *arg, const int flags) {
	    // 这里因为前面4个成员的内存分布一样，所以直接转换后，使用Block_byref的成员变量名，能访问到__Block_byref_a_0的前面4个成员
	    struct Block_byref **destp = (struct Block_byref **)dest;
	    struct Block_byref *src = (struct Block_byref *)arg;
	...
	    else if ((src->forwarding->flags & BLOCK_REFCOUNT_MASK) == 0) {
	        // 从main函数对__Block_byref_a_0的初始化，可以看到初始化时将flags赋值为0
	        // 这里表示第一次拷贝，会进行复制操作，并修改原来flags的值
	        // static int _Byref_flag_initial_value = BLOCK_NEEDS_FREE | 2;
	        // 可以看出，复制后，会并入BLOCK_NEEDS_FREE，后面的2是block的初始引用计数
	        ...
	        copy->flags = src->flags | _Byref_flag_initial_value;
	        ...
	    }
	    // 已经拷贝到堆了，只增加引用计数
	    else if ((src->forwarding->flags & BLOCK_NEEDS_FREE) == BLOCK_NEEDS_FREE) {
	        latching_incr_int(&src->forwarding->flags);
	    }
	    // 普通的赋值，里面最底层就*destptr = value;这句表达式
	    _Block_assign(src->forwarding, (void **)destp);
	}
主要操作都在代码注释中了，总体来说，__block修饰的基本类型会被包装为对象，并且只在最初block拷贝时复制一次，后面的拷贝只会增加这个捕获变量的引用计数。

#####对象的辅助函数
没有__block修饰

	typedef void(^Block)();
	int main(int argc, const char * argv[]) {
	    @autoreleasepool {
	        NSObject *a = [[NSObject alloc] init];
	        Block block = ^ {
	            a;
	        };
	    }
	    return 0;
	}
首先，在没有__block修饰时，对象编译转换的结果如下，删除了一些变化不大的代码：

	static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
	  NSObject *a = __cself->a; // bound by copy
	            a;
	        }
	static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->a, (void*)src->a, 3/*BLOCK_FIELD_IS_OBJECT*/);}
	
	static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->a, 3/*BLOCK_FIELD_IS_OBJECT*/);}
	
	static struct __main_block_desc_0 {
	  size_t reserved;
	  size_t Block_size;
	  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
	  void (*dispose)(struct __main_block_impl_0*);
	} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0),

对象在没有__block修饰时，并没有产生__Block_byref_a_0结构体，只是将标志位修改为BLOCK_FIELD_IS_OBJECT。而在_Block_object_assign中对应的判断分支代码如下：


	else if ((flags & BLOCK_FIELD_IS_OBJECT) == BLOCK_FIELD_IS_OBJECT) {
	    _Block_retain_object(object);
	    _Block_assign((void *)object, destAddr);
	}

可以看到，block复制时，会retain捕捉对象，以增加其引用计数。

有__block修饰

	typedef void(^Block)();
	int main(int argc, const char * argv[]) {
	    @autoreleasepool {
	        __block NSObject *a = [[NSObject alloc] init];
	        Block block = ^ {
	            a;
	        };
	    }
	    return 0;
	}
	
在这种情况下，编译转换的部分结果如下：
	
	struct __Block_byref_a_0 {
	  void *__isa;
	__Block_byref_a_0 *__forwarding;
	 int __flags;
	 int __size;
	 void (*__Block_byref_id_object_copy)(void*, void*);
	 void (*__Block_byref_id_object_dispose)(void*);
	 NSObject *a;
	};
	int main(int argc, const char * argv[]) {
	    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;
	attribute__((__blocks__(byref))) __Block_byref_a_0 a = {(void*)0,(__Block_byref_a_0 *)&a, 33554432, sizeof(__Block_byref_a_0), __Block_byref_id_object_copy_131, __Block_byref_id_object_dispose_131,....};
	Block block = (void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_a_0 *)&a, 570425344);
	}

	// 以下的40表示__Block_byref_a_0对象a的位移（4个指针(32字节)＋2个int变量(8字节)＝40字节）
		static void __Block_byref_id_object_copy_131(void *dst, void *src) {
		 _Block_object_assign((char*)dst + 40, *(void * *) ((char*)src + 40), 131);
		}
		static void __Block_byref_id_object_dispose_131(void *src) {
		 _Block_object_dispose(*(void * *) ((char*)src + 40), 131);
		}
		
1. 可以看到，对于对象，__Block_byref_a_0另外增加了两个辅助函数__Block_byref_id_object_copy、__Block_byref_id_object_dispose,以实现对对象

2. 内存的管理。其中两者的最后一个参数131表示BLOCK_BYREF_CALLER|BLOCK_FIELD_IS_OBJECT，BLOCK_BYREF_CALLER表示在内部实现中不对a对象进行retain或copy；以下为相关源码
***
	if ((flags & BLOCK_BYREF_CALLER) == BLOCK_BYREF_CALLER) {
	    ...
	    else {
	        // do *not* retain or *copy* __block variables whatever they are
	        _Block_assign((void *)object, destAddr);
	    }
	}

_Block_byref_assign_copy函数的以下代码会对上面的辅助函数（__Block_byref_id_object_copy_131）进行调用；570425344表示BLOCK_HAS_COPY_DISPOSE|BLOCK_HAS_DESCRIPTOR，所以会执行以下相关源码：
	
	if (src->flags & BLOCK_HAS_COPY_DISPOSE) {
	    // Trust copy helper to copy everything of interest
	    // If more than one field shows up in a byref block this is wrong XXX
	    copy->byref_keep = src->byref_keep;
	    copy->byref_destroy = src->byref_destroy;
	    (*src->byref_keep)(copy, src);
	}
###ARC中block的工作

{% img /images/block003.png Caption %}  

苹果说明

苹果文档提及，在ARC模式下，在栈间传递block时，不需要手动copy栈中的block，即可让block正常工作。主要原因是ARC对栈中的block自动执行了copy，将_NSConcreteStackBlock类型的block转换成了_NSConcreteMallocBlock的block。

#####block试验
下面对block做点实验：

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int i = 10;
        void (^block)() = ^{i;};

        __weak void (^weakBlock)() = ^{i;};

        void (^stackBlock)() = ^{};

        // ARC情况下

        // 创建时，都会在栈中
        // <__NSStackBlock__: 0x7fff5fbff730>
        NSLog(@"%@", ^{i;});

        // 因为stackBlock为strong类型，且捕获了外部变量，所以赋值时，自动进行了copy
        // <__NSMallocBlock__: 0x100206920>
        NSLog(@"%@", block);

        // 如果是weak类型的block，依然不会自动进行copy
        // <__NSStackBlock__: 0x7fff5fbff728>
        NSLog(@"%@", weakBlock);

        // 如果block是strong类型，并且没有捕获外部变量，那么就会转换成__NSGlobalBlock__
        // <__NSGlobalBlock__: 0x100001110>
        NSLog(@"%@", stackBlock);

        // 在非ARC情况下，产生以下输出
        // <__NSStackBlock__: 0x7fff5fbff6d0>
        // <__NSStackBlock__: 0x7fff5fbff730>
        // <__NSStackBlock__: 0x7fff5fbff700>
        // <__NSGlobalBlock__: 0x1000010d0>
    }
    return 0;
}

可以看出，ARC对类型为strong且捕获了外部变量的block进行了copy。并且当block类型为strong，但是创建时没有捕获外部变量，block最终会变成__NSGlobalBlock__类型（这里可能因为block中的代码没有捕获外部变量，所以不需要在栈中开辟变量，也就是说，在编译时，这个block的所有内容已经在代码段中生成了，所以就把block的类型转换为全局类型）

#####block作为参数传递
再来看下使用在栈中的block需要注意的情况：

	NSMutableArray *arrayM;
	void myBlock()
	{
	    int a = 5;
	    Block block = ^ {
	        NSLog(@"%d", a);
	    };
	
	    [arrayM addObject:block];
	    NSLog(@"%@", block);
	}
	
	int main(int argc, const char * argv[]) {
	    @autoreleasepool {
	        arrayM = @[].mutableCopy;
	
	        myBlock();
	
	        Block block = [arrayM firstObject];
	        // 非ARC这里崩溃
	        block();
	 }

	// ARC情况下输出
	// <__NSMallocBlock__: 0x100214480>
	
	// 非ARC情况下输出
	// <__NSStackBlock__: 0x7fff5fbff738>
	// 崩溃，野指针错误
	
可以看到，ARC情况下因为自动执行了copy，所以返回类型为__NSMallocBlock__，在函数结束后依然可以访问；而非ARC情况下，需要我们手动调用[block copy]来将block拷贝到堆中，否则因为栈中的block生命周期和函数中的栈生命周期关联，当函数退出后，相应的堆被销毁，block也就不存在了。
如果把block的以下代码删除：

	NSLog(@"%d", a);
	那么block就会变成全局类型，在main中访问也不会出崩溃。
	
#####block作为返回值
	在非ARC情况下，如果返回值是block，则一般这样操作：
	
	return [[block copy] autorelease];
	
对于外部要使用的block，更趋向于把它拷贝到堆中，使其脱离栈生命周期的约束。

#####block属性
这里还有一点关于block类型的ARC属性。上文也说明了，ARC会自动帮strong类型且捕获外部变量的block进行copy，所以在定义block类型的属性时也可以使用strong，不一定使用copy。也就是以下代码：

	/** 假如有栈block赋给以下两个属性 **/
	
	// 这里因为ARC，当栈block中会捕获外部变量时，这个block会被copy进堆中
	// 如果没有捕获外部变量，这个block会变为全局类型
	// 不管怎么样，它都脱离了栈生命周期的约束
	
	@property (strong, nonatomic) Block *strongBlock;
	
	// 这里都会被copy进堆中
	@property (copy, nonatomic) Block *copyBlock;
	
参考博文
谈Objective-C Block的实现(http://blog.devtang.com/blog/2013/07/28/a-look-inside-blocks/)
iOS中block实现的探究(http://blog.csdn.net/jasonblog/article/details/7756763)
A look inside blocks: Episode 3
runtime.c
Block_private.h