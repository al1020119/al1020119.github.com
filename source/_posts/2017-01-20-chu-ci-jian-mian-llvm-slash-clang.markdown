---
layout: post
title: "初次见面-LLVM/Clang"
date: 2017-01-20 23:34:34 +0800
comments: true
categories: 
---



做了几个小时的车，终于到了世界上最美的地方-《家》，虽然有点累，但是还是很开心，总有种说不出的激动。

+ 虽然过年，但是像我这么爱学习的孩子，肯定不会停止学习，因为在车上用电脑看了孙源将的Clang的视频，所以打算自己也去摸索一下，哪怕是瞎扯一番，希望以后也有机会能用到实战或者工作中。

开始之前，祝大家新年快乐，身体健康，万事如意，也祝各位单身狗早日脱单（虽然我也是单身狗），相信过年都还坐在电脑前的不是单身狗就是技术狂。

好了，废话也不多说，come on....


<!--more-->



###介绍

	iOS 开发中 Objective-C 和 Swift 都用的是 Clang / LLVM 来编译的。LLVM是一个模块化和可重用的编译器和工具链技术的集合，Clang 是 LLVM 的子项目，是 C，C++ 和 Objective-C 编译器，目的是提供惊人的快速编译，比 GCC 快3倍，其中的 clang static analyzer 主要是进行语法分析，语义分析和生成中间代码，当然这个过程会对代码进行检查，出错的和需要警告的会标注出来。LLVM 核心库提供一个优化器，对流行的 CPU 做代码生成支持。lld 是 Clang / LLVM 的内置链接器，clang 必须调用链接器来产生可执行文件。
	
	LLVM 比较有特色的一点是它能提供一种代码编写良好的中间表示 IR，这意味着它可以作为多种语言的后端，这样就能够提供语言无关的优化同时还能够方便的针对多种 CPU 的代码生成。
	
	
###总结一句

	LLVM是编译器和工具链技的集合，Clang才是真正的编译器，Clang必须调用链接器(内置lldb)来产生可执行文件。

摘自[https://linuxtoy.org/archives/llvm-and-clang.html](https://linuxtoy.org/archives/llvm-and-clang.html)

	LLVM（Low Level Virtual Machine）：编译器的后台——进行程序语言的编译期优化、链接优化、在线编译优化、代码生成（优化以任意程序语言编写的程序的编译时间(compile-time)、链接时间(link-time)、运行时间(run-time)以及空闲时间(idle-time)）
	Clang:：编译器（LLVM）的前端— 是一个 C++ 编写、基于 LLVM、发布于 LLVM BSD 许可证下的 C/C++/Objective C/Objective C++ 编译器，其目标（之一）就是超越 GCC


######LLVM其他用途

	LLVM 还被用在 Gallium3D 中进行 JIT 优化，Xorg 中的 pixman 也有考虑使用 LLVM 来优化执行速度，llvm-lua 使用 LLVM 来编译 Lua 代码，gpuocelot 使用 LLVM 可以令 CUDA 程序无需重新编译即可运行在多核 X86CPU、IBM Cell、支持 OpenCL 的设备之上... 

	LLVM，做语法树分析，实现语言转换、字符串加密。编写ClangPlugin，扩展功能。编写Pass，代码混淆优化。

###区别于优势：

######总结：Clang 具有如下优点：

    编译速度快：在某些平台上，Clang 的编译速度显著的快过 GCC。
    占用内存小：Clang 生成的 AST 所占用的内存是 GCC 的五分之一左右。
    模块化设计：Clang 采用基于库的模块化设计，易于 IDE 集成及其他用途的重用。
    诊断信息可读性强：在编译过程中，Clang 创建并保留了大量详细的元数据 (metadata)，有利于调试和错误报告。

######Clang缺陷：

    支持更多语言：GCC 除了支持 C/C++/Objective-C, 还支持 Fortran/Pascal/Java/Ada/Go 和其他语言。Clang 目前支持的语言有 C/C++/Objective-C/Objective-C++。
    加强对 C++ 的支持：Clang 对 C++ 的支持依然落后于 GCC，Clang 还需要加强对 C++ 提供全方位支持。
    支持更多平台：GCC 流行的时间比较长，已经被广泛使用，对各种平台的支持也很完备。Clang 目前支持的平台有 Linux/Windows/Mac OS。

    

######当然，GCC 也有其优势：
	
	GCC 原名为GNU C语言编译器
    支持 JAVA/ADA/FORTRAN
    当前的 Clang 的 C++ 支持落后于 GCC，参见。（近日 Clang 已经可以自编译，见）
    GCC 支持更多平台
    GCC 更流行，广泛使用，支持完备
    GCC 基于 C，不需要 C++ 编译器即可编译

	
	
###关于Clang
######clang分三个实体概念：

    clang驱动：利用现有OS、编译环境以及参数选项来驱动整个编译过程的工具。
    clang编译器：利用clang前端组件及库打造的编译器，其入口为cc1_main; 参数为clang -cc1 或者 -Xclang；
    clang前端组件及库：包括Support、Basic、Diagnostics、Preprocessor、Lexer、Sema、CodeGen等；


#####Clang架构图

{% img /images/clang0001.png Caption %}  

#####Clang流程图


{% img /images/clang0002.png Caption %}  


#####关于编译器：

	编译器前端负责产生机器无关的中间代码
	编译器后端负责对中间代码进行优化并转化为目标机器代码，

###编译过程：


    预处理（Pre-process）：把宏替换，删除注释，展开头文件，产生 .i 文件。

    编译（Compliling）：把之前的 .i 文件转换成汇编语言，产生 .s文件。

    汇编（Asembly）：把汇编语言文件转换为机器码文件，产生 .o 文件。

    链接（Link）：对.o文件中的对于其他的库的引用的地方进行引用，生成最后的可执行文件（同时也包括多个 .o 文件进行 link）。


######曾经看到有人对ios编译流程做了更加详细的理解

    编译信息写入辅助文件，创建文件架构 .app 文件
    处理文件打包信息
    执行 CocoaPod 编译前脚本，checkPods Manifest.lock
    编译.m文件，使用 CompileC 和 clang 命令
    链接需要的 Framework
    编译 xib
    拷贝 xib ，资源文件
    编译 ImageAssets
    处理 info.plist
    执行 CocoaPod 脚本
    拷贝标准库
    创建 .app 文件和签名

######期间包括了各种特性与底层

+ 预处理(宏的替换，头文件的导入，#if的处理)
+ 词法分析(把代码切成一个个 Token，大小括号，等于号,字符串)
+ 语法分析(法是否正确,将所有节点组成抽象语法树 AST)
+ IR中间代码的生成
+ CodeGen 会负责将语法树自顶向下遍历逐步翻译成 LLVM IR(IR 是编译过程的前端的输出后端的输入,Pass 是 LLVM 优化工作的一个节点，一个节点做些事，一起加起来就构成了 LLVM 完整的优化和转化。)
+ 开启了 bitcode 苹果会做进一步的优化，有新的后端架构还是可以用这份优化过的 bitcode 去生成。
+ 生成汇编
+ 生成目标文件
+ 生成可执行文件

###点击Run做了什么（上面的详细版）：

	预处理 -> 词法分析 （token ） ->语法分析 ->语义分析 ->中间代码生成 -> 生成字节码-> 优化 -> 生成汇编代码 -> Link -> 目标文件 ->生层可执行文件。

######预处理
	预处理：处理源文件中#开头的预编译命令，宏的替换
######编译
	词法分析 （token ）：把代码切成一个个Token（词法/代码符号），大小括号，等于号,字符串
	语法分析：符号化的字符串，转化抽象为可以被计算机存储的树形结构，即抽象语法树（AST），检测正确性 
	语义分析：语义分析器就会发现类型不匹配，编译器提出相应的错误警告。主要是类型检查、以及符号表管理
	中间代码生成：编译器前端负责产生机器无关的中间代码，编译器后端负责对中间代码进行优化并转化为目标机器代码
	生成字节码/目标代码：编译器后端主要包括代码生成器、代码优化器。代码生成器将中间代码转换为目标代码，代码优化器主要是进行一些优化，比如删除多余指令，选择合适寻址方式等
######汇编
目标代码需要经过汇编器处理，才能变成机器上可以执行的指令。生成对应的.o文件

######链接
链接器（这里指的是静态链接器）将多个目标文件合并为一个可执行文件，在 OS X 和 iOS中的可执行文件是 Mach-O，对于Mach-O的文件格式可以参考这里，刚才所描述的过程其实可以用 sunnyxx的一页 ppt来进行总结

+ 动态：静态链接：在编译链接期间发挥作用，把目标文件和静态库一起链接形成可执行文件
+ 静态：动态链接：链接过程推迟到运行时再进行。

######区别

    如果多个程序都用到了一个库，那么每个程序都要将其链接到可执行文件中，非常冗余，动态链接的话，多个程序可以共享同一段代码，不需要在磁盘上存多份拷贝，但是动态链接发生在启动或运行时，增加了启动时间，造成一些性能的影响。
    静态库不方便升级，必须重新编译，动态库的升级更加方便

######签名（.app）

.app目录中，有又一个叫_CodeSignature的子目录，这是一个 plist文件，里面包含了程序的代码签名，你的程序一旦签名，就没有办法更改其中的任何东西，包括资源文件，可执行文件等，iOS系统会检查这个签名。

	签名过程本身是由命令行工具 codesign 来完成的。如果你在 Xcode中build一个应用，这个应用构建完成之后会自动调用codesign 命令进行签名，这也是Link之后的一个关键步骤。

######启动

启动过程中，dyld（动态链接器） 起了很重要的作用，进行动态链接，进行符号和地址的一个绑定


    加载所依赖的dylibs
    Fix-ups：Rebase修正地址偏移，因为 OS X和 iOS 搞了一个叫 ASLR的东西来做地址偏移（随机化）来避免收到攻击
    Fix-ups：Binding确定 Non-Lazy Pointer地址，进行符号地址绑定。
    ObjC runtime初始化：加载所有类
    Initializers：执行load 方法和__attribute__((constructor))修饰的函数


###扯在最后

        宏观的LLVM，指的是整个的LLVM的框架，它肯定包含了Clang，因为Clang是LLVM的框架的一部分，是它的一个C/C++的前端。虽然这个前端占的比重比较大，但是它依然只是个前端，LLVM框架可以有很多个前端和很多个后端，只要你想继续扩展。
        微观的LLVM指的是以实际开发过程中，包括实际使用过程中，划分出来的LLVM。比如编译LLVM和Clang的时候，LLVM的源码包是不包含Clang的源码包的，需要单独下载Clang的源码包。
        所以这里想讨论的就是微观的LLVM和Clang的关系。从编译器用户的角度，Clang使用了LLVM中的一些功能，目前所知道的主要就是对中间格式代码的优化，或许还有一部分生成代码的功能。从Clang和微观LLVM的源码位置可以看出，Clang是基于微观的LLVM的一个工具。而从功能的角度来说，微观的LLVM可以认为是一个编译器的后端，而Clang是一个编译器的前端，它们的关系就更加的明了了，一个编译器前端想要程序最终变成可执行文件，是缺少不了对编译器后端的介绍的。
	




===
===


######微信号：
	
clpaial10201119（Q Q：2211523682）
    
######微博WB:

[http://weibo.com/u/3288975567?is_hot=1](http://weibo.com/u/3288975567?is_hot=1)

######gitHub：


[https://github.com/al1020119](https://github.com/al1020119)
	
######博客

[http://al1020119.github.io/](http://al1020119.github.io/)

===

{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  










