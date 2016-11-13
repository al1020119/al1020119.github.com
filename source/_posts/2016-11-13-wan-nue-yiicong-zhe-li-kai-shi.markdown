---
layout: post
title: "完虐Yii从这里开始😱😂"
date: 2016-11-13 18:16:05 +0800
comments: true
categories: 
---

前提条件

1. 安装：XAMPP、MAMPP，WAMPP。。。。
2. 下载好了Yii Advanced



######这里大概说说一下上面几点及遇到的问题

####1：简单配置概述

因为我一直都是用Mac，所以首选XAMPP，这个安转很简单安装好了之后直接操作这些就可以

{% img /images/Yiichushihua0001.png Caption %}  

关于XAMMP（。。）的安装，MyAdmin的使用，数据库的简单配置，或者Navicat的基本使用与操作等可以网站找到一大堆，或者你也可以不使用集成工具，自己配置一套，但是作为初学者跟人感觉没有必要，中间肯定会遇到什么问题的，搞不好你还要花一段时间专门解决这些问题，更夸张的是实在搞定不了还会让你放弃这条路，哈哈！

>所以这里首选：XAMPP+Navicat

####2：Yii安装

Yii分基础班和高级版，区别就是，高级版里面自带数据库及相关配置，分前后台，具体相关请查看官方介绍

{% img /images/Yiichushihua0002.png Caption %}  


1. 安装基础版

解压-拷贝到-XAMPP的安装目录/htdocs文件夹里面（路径地址：/Applications/XAMPP/htdocs），然后在浏览器输入：http://127.0.0.1/basic/web/（这里是你前面配置完成的情况下），就会出现这个界面：

{% img /images/Yiichushihua0003.png Caption %}  

2. 安装高级版

同基础版一样，拷贝到基础班的同级目录，然后在浏览器输入（这里分前后端）

1. 前段：http://127.0.0.1/Yii/frontend/web/index.php
2. 后端：http://127.0.0.1/advanced/backend/web 这里会自动跳到：http://127.0.0.1/advanced/backend/web/index.php?r=site%2Flogin

分别就会出现一个网站的前后端。

#####这里说说中间遇到比较多的一个问题：

	Failed to create directory '/Applications/XAMPP/xamppfiles/htdocs/advanced/backend/runtime/logs': mkdir(): Permission denied


分析： 那是因为权限问题，类似Permission denied的应该都与权限有关

######解决方式：

首先：基础版的时候出现类似Permission denied问题我使用类似下面的代码就可以解决问题。

	chmod 777 对应的名字
	chmod 777 *

但是在高级版的时候发现还是不行，网站狂搜一顿，发现需要使用超级管理员开启权限

	sudo chmod -R 0777 /Applications/XAMPP/xamppfiles/htdocs/

输入密码就可以了


好了前戏就到这里，下面正式开始

#####这里我使用的是PhpStorm，别问我为什么是他，任性！！！！！


>注意

>关于URL模式，文件夹含义，相关方法介绍，浏览器输入的形式等这里都不会做相关介绍，请查看官方文档，或者google。

###数据库实战

######1. 配置数据库

在advance/backend/config里面的main-local.php文件中，有个$config中的components，里面已经有一个request，我们需要增加我们的数据库配置，后面插入如下代码（这里我的数据库密码是空的）。

        'db'=>[
            'class'=>'yii\db\Connection',
            'dsn'=>'mysql:host=127.0.0.1;dbname=WWWiCocos',
            'username'=>'root',
            'password'=>'',
            'charset'=>'utf8',
        ]

######2. 查看数据库中的表
在advance/backend/controllers里面的SiteController中插入查询数据库的方法

    public function actionGetList(){
        $allTables = Yii::$app->db->createCommand("show tables")->queryAll();
        print_r($allTables);exit;

    }

这里需要注意的是，

1. 要先在behaviors方法内部的最前面输入return [];防止Yii的忽略模式, 
2. Yii中所有方法默认一action开头，浏览器输入的时候可以不用输入action，直接输入后面的名字就可以
3. Yii中大写会转成-，所以输入应该是get-list

输入：http://127.0.0.1/advanced/backend/web/index.php?r=site&a=get-list，既可以查看我数据库对应的表。

######3. 创建表（这里为了方便使用的是可视化，高手都用代码，哈哈）
打开navicat，链接并打开WWWiCocos数据库，新建一张表，设置相关字段，然后保存为YiiDB

{% img /images/Yiichushihua0004.png Caption %}  

######4. 打开Gii
使用gii实现数据库模型文件的生成与CRUD

	输入http://127.0.0.1/advanced/backend/web/index.php?r=gii

点击star，出现下面的界面，就可以开始做数据库的操作了。

{% img /images/Yiichushihua0005.png Caption %}  

######5. Model Generato

开始Model Generator，去链接并生成数据库对应的表数据

{% img /images/Yiichushihua0006.png Caption %}  


填写相关信息,这里的namespace其实就是命名空间，会直接指定文件的路径，放在哪个文件夹，这里因为是数据库操作，不管前后端都会用到，所以我放在common里面的models中，


{% img /images/Yiichushihua0007.png Caption %}  

点击Preview，就可以预料生成数据库Model文件的路，并且提示你点击Generate去生成php文件


{% img /images/Yiichushihua0008.png Caption %}  

点击Generate就会生成文件成

{% img /images/Yiichushihua0009.png Caption %}  


然后我们回到PhpStorm，查看Common文件夹里面的models中就会多了一个文件叫iCocosYiiSearch.php

{% img /images/Yiichushihua0010.png Caption %}  

里面就会有我们所建数据库的信息

	<?php
	
	namespace common\models;
	
	use Yii;
	
	/**
	 * This is the model class for table "YiiDB".
	 *
	 * @property integer $id
	 * @property string $name
	 * @property integer $age
	 * @property string $sex
	 * @property string $love
	 */
	class iCocosYiiDBSearch extends \yii\db\ActiveRecord
	{
	    /**
	     * @inheritdoc
	     */
	    public static function tableName()
	    {
	        return 'YiiDB';
	    }
	
	    /**
	     * @inheritdoc
	     */
	    public function rules()
	    {
	        return [
	            [['id', 'name', 'age', 'sex', 'love'], 'required'],
	            [['id', 'age'], 'integer'],
	            [['name'], 'string', 'max' => 20],
	            [['sex', 'love'], 'string', 'max' => 255]
	        ];
	    }
	
	    /**
	     * @inheritdoc
	     */
	    public function attributeLabels()
	    {
	        return [
	            'id' => 'ID',
	            'name' => 'Name',
	            'age' => 'Age',
	            'sex' => 'Sex',
	            'love' => 'Love',
	        ];
	    }
	}

不信你可看看数据库中对应的字典和相关信息是否一样。

######6. 生成数据库对应的模型php文件

然后回到gii点击CRUD进行数据库增删查改对应php文件的生成

在界面填写相关信息，但是有两点需要注意，需要填写对应的路径，不能直接名字，因为我们生成的CRUD对应的php文件需要文件分层，还有一个需要注意的就是类的文件名首写字母必须大写。

{% img /images/Yiichushihua0011.png Caption %}  


点击PreView预览


{% img /images/Yiichushihua0012.png Caption %}  


点击Generate生成


{% img /images/Yiichushihua0013.png Caption %}  


回到PhpStorm查看对应的上面文件路径的文件生成就会一一对应

{% img /images/Yiichushihua0014.png Caption %}  

然后在浏览器输入下面的地址执行CocosdbController中对应的index方法就可以看到如下界面，

http://127.0.0.1/advanced/backend/web/index.php?r=cocosdb/index

{% img /images/Yiichushihua0014.png Caption %}  


开始使用gii创建用户数据，点击Genertor，生成之后可以对表数据进行相应的更改

{% img /images/Yiichushihua0015.png Caption %}  


{% img /images/Yiichushihua0016.png Caption %}  

回到表界面可以看到一条数据已经生成

{% img /images/Yiichushihua0017.png Caption %}  

然后就是使用代码来做你想做的事情了

#### 附加福利

这里我们做一些简单的界面处理

1.标题：backend/Views/cocosdb打开index.php（还有一个create.php），最上面一行


	$this->title = 'iCocos用户管理';

2.字段相关提示：common/model打开iCocosYiiDBSearch.php，修改attributeLabels方法，这里改完之后里面CRUD也会改

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'id' => '用户ID',
            'name' => '用户昵称',
            'age' => '用户年龄',
            'sex' => '用户性别',
            'love' => '用户兴趣',
        ];
    }
    
    
   
{% img /images/Yiichushihua0018.png Caption %}   

3.backend/Views/cocosdb打开view.php中Div里面增加附加标签（这是在Yii有些功能满足不了我们的要求的时候使用，拓张更多想要的东西）。


    <?= DetailView::widget([
        'model' => $model,
        'attributes' => [
            'id',
            'name',
            'age',
            'sex',
            'love',
            ['label'=>'附加信息','value'=>'<span onclick="fun()">附加字段</span>','format'=>'html'],

        ],
    ]) ?>



{% img /images/Yiichushihua0019.png Caption %}   

同时可以结合js是哪一些想要的效果。



######尾声：
>######好了，到这里就已经基本上结束了，在下一次，我将开始先在项目中新建一个文件夹API，专门用来实现接口，给前段，后端，移动端的调用。


===





    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  