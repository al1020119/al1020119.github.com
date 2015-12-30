---
layout: post
title: "重量级-MVC-MVVM-DC"
date: 2016-01-01 16:21:08 +0800
comments: true
categories: Summary
---



首先再这里祝大家新年快乐.......



新的一年来点重量级的东西，那么是什么呢？


相信你既然能看到这篇文章，那么一定听说过MVC，什么没有听过？出门左转找度娘，不送！
如果你听说过MVC，那么或许你听说过MVVM，这里可能很多人对MVVM并不了解，或许只是听过，但是没有用过，有些就算用过还是不请求，里面的关系，只是搬砖而已。
对了，今天我们讨论的就是一个MVVM的技术，也就是在MVVM上面的一个增强版！
MVVM不正是MVC的增强版吗？

好了下面正式开始，新年不能耽误大家太多时间搬砖，，哈哈！

##Model-View-Controller



首先我们来看看MVC，这里MVC具体细节就不多说了。

* Model(M)：模型数据
* View(V)：视图
* Controller(C)：控制器

{% img /images/zhongliangji001.png Caption %}  


######有点：
* 易学习
* 易开发
* 同哟欧诺个成熟

######缺点：

* Massive View Controller

##Model-View-ViewModel

然后来看看现在比较热得话题（架构）MVVM
* Model（M）:模型
* View(V）:视图
* ViewModel（VM）:模型（逻辑）

{% img /images/zhongliangji002.png Caption %}  


######View与ViewModule连接可以通过下面的方式

* Binding Data：实现数据的传递

* Command：实现操作的调用

* AttachBehavior：实现控件加载过程中的操作


#####View没有大量代码逻辑。

- 结合WPF、Silverlight绑定机制，MVP演变出了MVVM，充分利用了WPF、Silverlight的优势，将大量代码逻辑、状态转到ViewModel，可以说MVVM是专门为WPF、Silverlight打造的。

- View绑定到ViewModel，然后执行一些命令在向它请求一个动作。而反过来，ViewModel跟Model通讯，告诉它更新来响应UI。这样便使得为应用构建UI非常的容易。往一个应用程序上贴一个界面越容易，外观设计师就越容易使用Blend来创建一个漂亮的界面。同时，当UI和功能越来越松耦合的时候，功能的可测试性就越来越强。




######优点：

* 减轻ViewController的负担
* 提高了测试性
* 强大的绑定机制

######缺点：

* 极高的学习成本和开发成本
* 数据绑定是的bug更难调试
* View Model的职责任然很重
* 据本人了解，MVVM结合RAC使用能够发挥最大的效率

总上我们可以得知：

* 每个V都有一个对应的VM，V的数据展示盒样式都由其定制
* 不引入双想绑定机制或者观察机制，而是通过传统的代理回调或者通知将UI事件传给外界
* VC只负责将VM装配给V，接受UI事件


或许细心地能发现下面的好处

* View可以完全解耦，只需要确定好ViewModel和回调接口即可
* View Controller层可以尽可能少得和View的具体表现打交道，将这不分职责转给了View Model，减轻了* View Controller的负担
* 使用回调的传统回调机制，学习成本低，数据和事件流入和流出易观察而且更易控制，降低维护和回调成本

##Model-View-ViewModel-DataController-Model


好了重量级的东西来了，MVVM-DM（MVVM Without Binding With Data Controller）

* Model（M）:模型
* View(V）:视图
* ViewModel（VM）:加工后的数据）
* Data Controller：相关逻辑
* Model：对应Data Controller

{% img /images/zhongliangji003.png Caption %}  


或许有些人看到上面的文字就能知道我本文的含义了，对没错，就是为了解决MVVM中View Model臃肿情况！


######优点：

* 避免了传统的MVVM架构VM层有可能变得臃肿的情况，更加清晰的模块职责
* 业务逻辑解耦，数据的加工和处理都放在Data Controller中，View Controiller不用关心数据如何获得，如何处理，Data Controller不用关心界面如何展示，如何交互
* Data Controller与界面无关，所以可以有更好的可测试性和可服用性

######缺点：

暂时没有发现（难度：一下比较难接受）



####具体思路是：

* 1.每个Viewcontroller会有一个对应的Data Controller（包含页面的所有相关逻辑：View Related data Controller） ，在View的ViewDidLoad方法中初始化View，layoutSubViews中布局
* 2.Viewcongtroller向Data Controller发送请求，Data Controller包含只是纯粹的Model相关逻辑（当然你也可以复用更小的Data Controller）如：网络请求，数据持久（请求），数据加工，其他。
* 3.Data Controller将请求到得数据加工返回给View Controller
* 4.View Controller将Data Controller返回的加工好的数据生成ViewModel（展示View所需要的数据），
* 5.View Controller协调控制并将生成的View Model装配到View（每个View都有一个对应的View Model，可以有子View Model）上面显示，这里相当于使用ViewModel数据来渲染界面



综上：

* 将处理数据和获取数据的职责从传统的MVVM的Vm中抽取出来，成为Data Controller
* VC请求数据和将一些数据修改的事件（可以是UI事件触发）传递给Data Controller
* Data Controller收到VC的请求后，向M获取数据和更新数据，并将加工后的数据返回
* Data Controller还负责网络层和持久化层的逻辑

> 总结：

> * 层次清晰，职责明确。
> * 耦合性低，复用性高
> * 测试性高
> * 低学习成本，低开发成本
> * 高实施性，无需整体重构

本文借鉴猿题库客户端架构设计，最后附上[唐巧大V](blog.devtang.com)得博客，以表敬意