---
layout: post
title: "服务器搭建"
date: 2014-02-21 22:59:16 +0800
comments: true
categories: 项目实战
---



###一、简单说明

说明：提前下载好相关软件，且安装目录最好安装在全英文路径下。如果路径有中文名，那么可能会出现一些莫名其妙的问题。

提示：提前准备好的软件

* apache-tomcat-6.0.41.tar

* eclipse-jee-kepler-SR2-macosx-cocoa-x86_64.tar.gz

* jdk-8u5-macosx-x64.dmg



<!--more-->




###二、安装和配置本地服务器环境（java）步骤：

* (1)在文档路径下，新建一个文件夹（NetWord），解压eclipse压缩包文件

{% img /images/fuwuqi001.png Caption %}  


* (2)先安装jdk

{% img /images/fuwuqi002.png Caption %}  

* (3)点击安装eclipse，设置工作空间，点击确定。

{% img /images/fuwuqi003.png Caption %}  

设置工作空间
{% img /images/fuwuqi004.png Caption %}  
  
{% img /images/fuwuqi0004.png Caption %}  

* (4)把提前写好的服务器代码，拷贝到工作空间中。

 {% img /images/fuwuqi005.png Caption %}  
 
 {% img /images/fuwuqi006.png Caption %}  

* (5)导入项目，导入已经存在的项目到工作空间中。
{% img /images/fuwuqi007.png Caption %}  
{% img /images/fuwuqi008.png Caption %}  
{% img /images/fuwuqi009.png Caption %}  
    

* (6)导入项目之后，项目报错且格式乱码，下面进行调整。

{% img /images/fuwuqi010.png Caption %}  
{% img /images/fuwuqi011.png Caption %}  
{% img /images/fuwuqi012.png Caption %}  



   

* (7)配置容器，apache-tomcat.

   {% img /images/fuwuqi013.png Caption %}      
 {% img /images/fuwuqi014.png Caption %}  
      
 {% img /images/fuwuqi015.png Caption %}          

点击ok。创建一个新的容器

{% img /images/fuwuqi016.png Caption %}  


选择容器的路径


{% img /images/fuwuqi017.png Caption %}  

安装好后显示如下：


{% img /images/fuwuqi018.png Caption %}  

* (8)启动服务器。以debug的方式启动，方便做一些调试

{% img /images/fuwuqi019.png Caption %}  


测试：server已经成功启动。


{% img /images/fuwuqi020.png Caption %}  

* (9)部署程序

{% img /images/fuwuqi021.png Caption %}  
   
{% img /images/fuwuqi022.png Caption %}        


{% img /images/fuwuqi023.png Caption %}  

* (10)在火狐浏览器中输入服务器的地址，访问项目

{% img /images/fuwuqi024.png Caption %}  

至此本地服务器环境搭建完成。



### 访问服务器的资源

{% img /images/fuwuqi025.png Caption %}  

{% img /images/fuwuqi026.png Caption %}  


使用模拟器上的浏览器也可以访问本地服务器。输入地址192.168.1.53：8080/MJServer

补充：浏览器打开页面，文字乱码调整。

{% img /images/fuwuqi027.png Caption %}  

 