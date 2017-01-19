---
layout: post
title: "重整Linux一次就够了"
date: 2016-12-02 13:35:16 +0800
comments: true
categories: PHP-Lover
---

######前言：

因为之前学校有学过linux😂，而且这几年一直使用的Mac做开发，所以对Linux及相关命令还是有些接触的，只是没有机会，也没有刻意去专门研究或者整理，最近因为学习与工作的而需要开始了一次Linux之路，所以学习的过程中寻找资料并且整理了一下。


> 目前几乎大部分的互联网公司公司都是使用Linux



这里以Ubantu为例整理一套Linux命令，至于为什么是Ubantu，谁用谁知道，这里我是在Mac上面安装了一个VM然后直接安装Ubantu，相关教程请查看网上资料。好了废话不多说，开干🤔🤔🤔🤔🤔🤔🤔🤔


###目录


<!--more-->


+ 系统
+ 硬盘
+ 内存
+ 进程
+ 查看当前有哪些进程#ps -A
+ 网络
+ 服务
+ 设置
+ 中文
+ 文件
+ FTP
+ 解压缩
+ Nautilus
+ 程序
+ 数据库
+ 其它
+ Ubuntu命令行下修改网络配置
+ 安装AMP服务
+ 其他总结


查看软件xxx安装内容

	#dpkg -L xxx

查找软件

	#apt-cache search 正则表达式
查找文件属于哪个包

	#dpkg -S filename apt-file search filename

查询软件xxx依赖哪些包

	#apt-cache depends xxx

查询软件xxx被哪些包依赖

	#apt-cache rdepends xxx

增加一个光盘源

	#sudo apt-cdrom add

系统升级

	#sudo apt-get update
	#sudo apt-get upgrade
	#sudo apt-get dist-upgrade

清除所以删除包的残余配置文件

	#dpkg -l |grep ^rc|awk ‘{print $2}’ |tr [”"n”] [” “]|sudo xargs dpkg -P -

编译时缺少h文件的自动处理

	#sudo auto-apt run ./configure

查看安装软件时下载包的临时存放目录

	#ls /var/cache/apt/archives

备份当前系统安装的所有包的列表

	#dpkg –get-selections | grep -v deinstall > ~/somefile

从上面备份的安装包的列表文件恢复所有包

	#dpkg –set-selections < ~/somefile sudo dselect

清理旧版本的软件缓存

	#sudo apt-get autoclean

清理所有软件缓存

	#sudo apt-get clean

删除系统不再使用的孤立软件

	#sudo apt-get autoremove

查看包在服务器上面的地址

	#apt-get -qq –print-uris install ssh | cut -d"’ -f2
###系统

查看内核

	#uname -a

查看Ubuntu版本

	#cat /etc/issue

查看内核加载的模块

	#lsmod

查看PCI设备

	#lspci

查看USB设备

	#lsusb

查看网卡状态

	#sudo ethtool eth0


查看CPU信息

	#cat /proc/cpuinfo

显示当前硬件信息

	#lshw
###硬盘

查看硬盘的分区

	#sudo fdisk -l

查看IDE硬盘信息

	#sudo hdparm -i /dev/hda

查看STAT硬盘信息

	#sudo hdparm -I /dev/sda
	或
	#sudo apt-get install blktool
	#sudo blktool /dev/sda id

查看硬盘剩余空间

	#df -h
	#df -H

查看目录占用空间

	#du -hs 目录名

优盘没法卸载

	#sync fuser -km /media/usbdisk
###内存

查看当前的内存使用情况

	#free -m
###进程
查看当前有哪些进程

	#ps -A

中止一个进程

	#kill 进程号(就是ps -A中的第一列的数字) 或者 killall 进程名

强制中止一个进程(在上面进程中止不成功的时候使用)

	#kill -9 进程号 或者 killall -9 进程名

图形方式中止一个程序

	#xkill 出现骷髅标志的鼠标，点击需要中止的程序即可

查看当前进程的实时状况

	#top

查看进程打开的文件

	#lsof -p

ADSL 配置 ADSL

	#sudo pppoeconf

ADSL手工拨号

	#sudo pon dsl-provider

激活 ADSL

	#sudo /etc/ppp/pppoe_on_boot

断开 ADSL

	#sudo poff

查看拨号日志

	#sudo plog

如何设置动态域名

	#首先去http://www.3322.org申请一个动态域名
	#然后修改 /etc/ppp/ip-up 增加拨号时更新域名指令 sudo vim /etc/ppp/ip-up
	#在最后增加如下行 w3m -no-cookie -dump
###网络

根据IP查网卡地址

	#arping IP地址

查看当前IP地址

	#ifconfig eth0 |awk ‘/inet/ {split($2,x,”:”);print x[2]}’

查看当前外网的IP地址

	#w3m -no-cookie -dumpwww.edu.cn|grep-o‘[0-9]"{1,3"}".[0-9]"{1,3"}".[0-9]"{1,3"}".[0-9]"{1,3"}’
	#w3m -no-cookie -dumpwww.xju.edu.cn|grep-o’[0-9]"{1,3"}".[0-9]"{1,3"}".[0-9]"{1,3"}".[0-9]"{1,3"}’
	#w3m -no-cookie -dump ip.loveroot.com|grep -o’[0-9]"{1,3"}".[0-9]"{1,3"}".[0-9]"{1,3"}".[0-9]"{1,3"}’

查看当前监听80端口的程序

	#lsof -i :80

查看当前网卡的物理地址

	#arp -a | awk ‘{print $4}’ ifconfig eth0 | head -1 | awk ‘{print $5}’

立即让网络支持nat

	#sudo echo 1 > /proc/sys/net/ipv4/ip_forward
	#sudo iptables -t nat -I POSTROUTING -j MASQUERADE

查看路由信息

	#netstat -rn sudo route -n

手工增加删除一条路由

	#sudo route add -net 192.168.0.0 netmask 255.255.255.0 gw 172.16.0.1
	#sudo route del -net 192.168.0.0 netmask 255.255.255.0 gw 172.16.0.1

修改网卡MAC地址的方法

	#sudo ifconfig eth0 down 关闭网卡
	#sudo ifconfig eth0 hw ether 00:AA:BB:CC:DD:EE 然后改地址
	#sudo ifconfig eth0 up 然后启动网卡

统计当前IP连接的个数

	#netstat -na|grep ESTABLISHED|awk ‘{print $5}’|awk -F: ‘{print $1}’|sort|uniq -c|sort -r -n
	#netstat -na|grep SYN|awk ‘{print $5}’|awk -F: ‘{print $1}’|sort|uniq -c|sort -r -n

统计当前20000个IP包中大于100个IP包的IP地址

	#tcpdump -tnn -c 20000 -i eth0 | awk -F “.” ‘{print $1″.”$2″.”$3″.”$4}’ | sort | uniq -c | sort -nr | awk ‘ $1 > 100 ‘

屏蔽IPV6

	#echo “blacklist ipv6″ | sudo tee /etc/modprobe.d/blacklist-ipv6
###服务

添加一个服务

	#sudo update-rc.d 服务名 defaults 99

删除一个服务

	#sudo update-rc.d 服务名 remove

临时重启一个服务

	#/etc/init.d/服务名 restart

临时关闭一个服务

	#/etc/init.d/服务名 stop

临时启动一个服务
	#/etc/init.d/服务名 start
###设置

配置默认Java使用哪个

	#sudo update-alternatives –config java

修改用户资料

	#sudo chfn userid

给apt设置代理

	#export http_proxy=http://xx.xx.xx.xx:xxx

修改系统登录信息

	#sudo vim /etc/motd
###中文

转换文件名由GBK为UTF8

	#sudo apt-get install convmv convmv -r -f cp936 -t utf8 –notest –nosmart *

批量转换src目录下的所有文件内容由GBK到UTF8

	#find src -type d -exec mkdir -p utf8/{} "; find src -type f -exec iconv -f GBK -t UTF-8 {} -o utf8/{} "; mv utf8/* src rm -fr utf8

转换文件内容由GBK到UTF8

	#iconv -f gbk -t utf8 $i > newfile

转换 mp3 标签编码

	#sudo apt-get install python-mutagen find . -iname “*.mp3” -execdir mid3iconv -e GBK {} ";

控制台下显示中文

	#sudo apt-get install zhcon 使用时，输入zhcon即可
###文件

快速查找某个文件

	#whereis filename
	#find 目录 -name 文件名

查看文件类型

	#file filename

显示xxx文件倒数6行的内容

	#tail -n 6 xxx

让tail不停地读地最新的内容

	#tail -n 10 -f /var/log/apache2/access.log

查看文件中间的第五行（含）到第10行（含）的内容

	#sed -n ‘5,10p’ /var/log/apache2/access.log

查找包含xxx字符串的文件

	#grep -l -r xxx .

全盘搜索文件(桌面可视化)

	gnome-search-tool

查找关于xxx的命令

	#apropos xxx man -k xxx

通过ssh传输文件

	#scp -rp /path/filenameusername@remoteIP:/path
	#将本地文件拷贝到服务器上
	#scp -rpusername@remoteIP:/path/filename/path
	#将远程文件从服务器下载到本地

查看某个文件被哪些应用程序读写

	#lsof 文件名

把所有文件的后辍由rm改为rmvb

	#rename ’s/.rm$/.rmvb/’ *

把所有文件名中的大写改为小写

	#rename ‘tr/A-Z/a-z/’ *

删除特殊文件名的文件，如文件名：–help.txt

	#rm — –help.txt 或者 rm ./–help.txt

查看当前目录的子目录

	#ls -d */. 或 echo */.

将当前目录下最近30天访问过的文件移动到上级back目录

	#find . -type f -atime -30 -exec mv {} ../back ";

将当前目录下最近2小时到8小时之内的文件显示出来

	#find . -mmin +120 -mmin -480 -exec more {} ";

删除修改时间在30天之前的所有文件

	#find . -type f -mtime +30 -mtime -3600 -exec rm {} ";

查找guest用户的以avi或者rm结尾的文件并删除掉

	#find . -name ‘*.avi’ -o -name ‘*.rm’ -user ‘guest’ -exec rm {} ";

查找的不以java和xml结尾,并7天没有使用的文件删除掉

	#find . ! -name *.java ! -name ‘*.xml’ -atime +7 -exec rm {} ";

统计当前文件个数

	#ls /usr/bin|wc -w

统计当前目录个数

	#ls -l /usr/bin|grep ^d|wc -l

显示当前目录下2006-01-01的文件名

	#ls -l |grep 2006-01-01 |awk ‘{print $8}’
###FTP

上传下载文件工具-filezilla

	#sudo apt-get install filezilla

filezilla无法列出中文目录？
站点->字符集->自定义->输入：GBK

######本地中文界面
1）下载filezilla中文包到本地目录，如~/
2）#unrar x Filezilla3_zhCN.rar
3) 如果你没有unrar的话，请先安装rar和unrar

	#sudo apt-get install rar unrar
	#sudo ln -f /usr/bin/rar /usr/bin/unrar
4）先备份原来的语言包,再安装；实际就是拷贝一个语言包。

	#sudo cp /usr/share/locale/zh_CN/filezilla.mo /usr/share/locale/zh_CN/filezilla.mo.bak
	
	#sudo cp ~/locale/zh_CN/filezilla.mo /usr/share/locale/zh_CN/filezilla.mo
5）重启filezilla,即可！
###解压缩

解压缩 xxx.tar.gz

	#tar -zxvf xxx.tar.gz

解压缩 xxx.tar.bz2

	#tar -jxvf xxx.tar.bz2

压缩aaa bbb目录为xxx.tar.gz

	#tar -zcvf xxx.tar.gz aaa bbb

压缩aaa bbb目录为xxx.tar.bz2

	#tar -jcvf xxx.tar.bz2 aaa bbb

######解压缩 RAR 文件
1) 先安装

	#sudo apt-get install rar unrar
	#sudo ln -f /usr/bin/rar /usr/bin/unrar
2) 解压

	#unrar x aaaa.rar

######解压缩 ZIP 文件
1) 先安装

	#sudo apt-get install zip unzip
	#sudo ln -f /usr/bin/zip /usr/bin/unzip
2) 解压

	#unzip x aaaa.zip
###Nautilus

显示隐藏文件

	Ctrl+h

显示地址栏

	Ctrl+l

特殊 URI 地址

	* computer:/// - 全部挂载的设备和网络
	* network:/// - 浏览可用的网络
	* burn:/// - 一个刻录 CDs/DVDs 的数据虚拟目录
	* smb:/// - 可用的 windows/samba 网络资源
	* x-nautilus-desktop:/// - 桌面项目和图标
	*file:///- 本地文件
	* trash:/// - 本地回收站目录
	* ftp:// - FTP 文件夹
	* ssh:// - SSH 文件夹
	* fonts:/// - 字体文件夹，可将字体文件拖到此处以完成安装
	* themes:/// - 系统主题文件夹

查看已安装字体

	在nautilus的地址栏里输入”fonts:///“，就可以查看本机所有的fonts
###程序

详细显示程序的运行信息

	#strace -f -F -o outfile

######日期和时间

设置日期

	#date -s mm/dd/yy

设置时间

	#date -s HH:MM

将时间写入CMOS

	#hwclock –systohc

读取CMOS时间

	#hwclock –hctosys

从服务器上同步时间

	#sudo ntpdate time.nist.gov
	#sudo ntpdate time.windows.com

######控制台

不同控制台间切换

	Ctrl + ALT + ← Ctrl + ALT + →

指定控制台切换

	Ctrl + ALT + Fn(n:1~7)

控制台下滚屏

	SHIFT + pageUp/pageDown

控制台抓图

	#setterm -dump n(n:1~7)
###数据库

mysql的数据库存放在地方

	#/var/lib/mysql

从mysql中导出和导入数据

	#mysqldump 数据库名 > 文件名 #导出数据库
	#mysqladmin create 数据库名 #建立数据库
	#mysql 数据库名 < 文件名 #导入数据库

忘了mysql的root口令怎么办

	#sudo /etc/init.d/mysql stop
	#sudo mysqld_safe –skip-grant-tables
	#sudo mysqladmin -u user password ‘newpassword”
	#sudo mysqladmin flush-privileges

修改mysql的root口令

	#sudo mysqladmin -uroot -p password ‘你的新密码’
###其它

下载网站文档

	#wget -r -p -np -khttp://www.21cn.com
	· r：在本机建立服务器端目录结构；
	· -p: 下载显示HTML文件的所有图片；
	· -np：只下载目标站点指定目录及其子目录的内容；
	· -k: 转换非相对链接为相对链接。

如何删除Totem电影播放机的播放历史记录

	#rm ~/.recently-used

如何更换gnome程序的快捷键
点击菜单，鼠标停留在某条菜单上，键盘输入任意你所需要的键，可以是组合键，会立即生效； 如果要清除该快捷键，请使用backspace

vim 如何显示彩色字符

	#sudo cp /usr/share/vim/vimcurrent/vimrc_example.vim /usr/share/vim/vimrc

如何在命令行删除在会话设置的启动程序

	#cd ~/.config/autostart rm 需要删除启动程序

如何提高wine的反应速度

	#sudo sed -ie ‘/GBK/,/^}/d’ /usr/share/X11/locale/zh_CN.UTF-8/XLC_LOCALE

	#chgrp
语法: chgrp [-R] 文件组 文件…
说明： 文件的GID表示文件的文件组，文件组可用数字表示， 也可用一个有效的组名表示，此命令改变一个文件的GID，可参看chown。
-R 递归地改变所有子目录下所有文件的存取模式
例子:

	＃chgrp group file 将文件 file 的文件组改为 group

	#chmod
语法: chmod [-R] 模式 文件…
或 chmod [ugoa] {+|-|=} [rwxst] 文件…
说明: 改变文件的存取模式，存取模式可表示为数字或符号串，例如：
＃chmod nnnn file ， n为0-7的数字，意义如下:

	4000 运行时可改变UID
	2000 运行时可改变GID
	1000 置粘着位
	0400 文件主可读
	0200 文件主可写
	0100 文件主可执行
	0040 同组用户可读
	0020 同组用户可写
	0010 同组用户可执行
	0004 其他用户可读
	0002 其他用户可写
	0001 其他用户可执行
nnnn 就是上列数字相加得到的，例如 chmod 0777 file 是指将文件 file 存取权限置为所有用户可读可写可执行。
-R 递归地改变所有子目录下所有文件的存取模式

	u 文件主
	g 同组用户
	o 其他用户
	a 所有用户
	+ 增加后列权限
	- 取消后列权限
	= 置成后列权限
	r 可读
	w 可写
	x 可执行
	s 运行时可置UID
	t 运行时可置GID
例子:

	＃chmod 0666 file1 file2 将文件 file1 及 file2 置为所有用户可读可写
	＃chmod u+x file 对文件 file 增加文件主可执行权限
	＃chmod o-rwx 对文件file 取消其他用户的所有权限

	#chown

语法: chown [-R] 文件主 文件…

说明: 文件的UID表示文件的文件主，文件主可用数字表示， 也可用一个有效的用户名表示，此命令改变一个文件的UID，仅当此文件的文件主或超级用户可使用。
-R 递归地改变所有子目录下所有文件的存取模式
例子:

	#chown mary file 将文件 file 的文件主改为 mary
	#chown 150 file 将文件 file 的UID改为150
###Ubuntu命令行下修改网络配置

以eth0为例
######以DHCP方式配置网卡
编辑文件/etc/network/interfaces:
	
	#sudo vi /etc/network/interfaces
并用下面的行来替换有关eth0的行:
	
	# The primary network interface - use DHCP to find our address
	auto eth0
	iface eth0 inet dhcp
用下面的命令使网络设置生效:
	
	#sudo /etc/init.d/networking restart
当然,也可以在命令行下直接输入下面的命令来获取地址
	
	#sudo dhclient eth0

######为网卡配置静态IP地址
编辑文件/etc/network/interfaces:
	
		#sudo vi /etc/network/interfaces
并用下面的行来替换有关eth0的行:
	
		# The primary network interface
		auto eth0
		iface eth0 inet static
		address 192.168.3.90
		gateway 192.168.3.1
		netmask 255.255.255.0
		network 192.168.3.0
		broadcast 192.168.3.255
将上面的ip地址等信息换成你自己就可以了.

用下面的命令使网络设置生效:
	
	#sudo /etc/init.d/networking restart

######设定第二个IP地址(虚拟IP地址)
编辑文件/etc/network/interfaces:
	
		#sudo vi /etc/network/interfaces

在该文件中添加如下的行:

	auto eth0:1
	iface eth0:1 inet static
	address 192.168.1.60
	netmask 255.255.255.0
	network x.x.x.x
	broadcast x.x.x.x
	gateway x.x.x.x
根据你的情况填上所有诸如address,netmask,network,broadcast和gateways等信息.
用下面的命令使网络设置生效:

	#sudo /etc/init.d/networking restart

######设置主机名称(hostname)

使用下面的命令来查看当前主机的主机名称:

	#sudo /bin/hostname

使用下面的命令来设置当前主机的主机名称:

	#sudo /bin/hostname newname
系统启动时,它会从/etc/hostname来读取主机的名称.

######配置DNS
首先,你可以在/etc/hosts中加入一些主机名称和这些主机名称对应的IP地址,这是简单使用本机的静态查询.
要访问DNS 服务器来进行查询,需要设置/etc/resolv.conf文件.
假设DNS服务器的IP地址是192.168.3.2, 那么/etc/resolv.conf文件的内容应为:

		search test.com
		nameserver 192.168.3.2


###安装AMP服务

如果采用Ubuntu Server CD开始安装时，可以选择安装，这系统会自动装上apache2,php5和mysql5。下面主要说明一下如果不是安装的Ubuntu server时的安装方法。
用命令在Ubuntu下架设Lamp其实很简单，用一条命令就完成。在终端输入以下命令：
	
	#sudo apt-get install apache2 mysql-server php5 php5-mysql php5-gd #phpmyadmin
装好后，mysql管理员是root，无密码，通过http://localhost/phpmyadmin就可以访问mysql了

######修改 MySql 密码
终端下输入：

	#mysql -u root
	#mysql> GRANT ALL PRIVILEGES ON *.* TO root@localhost IDENTIFIED BY “123456″;
’123456‘是root的密码，可以自由设置，但最好是设个安全点的。
	#mysql> quit; 退出mysql

######apache2的操作命令

	启动：#sudo /etc/init.d/apache2 start
	重启：#sudo /etc/init.d/apache2 restart
	关闭：#sudo /etc/init.d/apache2 stop
	apache2的默认主目录：/var/www/
	
###总结

######一、文件/文件夹管理


	ls 列出当前目录文件（不包括隐含文件）
	ls -a 列出当前目录文件（包括隐含文件）
	ls -l 列出当前目录下文件的详细信息
	
	cd .. 回当前目录的上一级目录
	cd - 回上一次所在的目录
	cd ~ 或 cd 回当前用户的宿主目录
	mkdir 目录名 创建一个目录
	rmdir 空目录名 删除一个空目录
	rm 文件名 文件名 删除一个文件或多个文件
	rm -rf 非空目录名 删除一个非空目录下的一切
	
	mv 路经/文件 /经/文件移动相对路经下的文件到绝对路经下
	mv 文件名 新名称 在当前目录下改名
	find 路经 -name “字符串” 查找路经所在范围内满足字符串匹配的文件和目录

######二、系统管理

	fdisk fdisk -l 查看系统分区信息
	fdisk fdisk /dev/sdb 为一块新的SCSI硬盘进行分区
	chown chown root /home 把/home的属主改成root用户
	chgrp chgrp root /home 把/home的属组改成root组
	
	Useradd 创建一个新的用户
	Groupadd 组名 创建一个新的组
	Passwd 用户名 为用户创建密码
	Passwd -d用户名 删除用户密码也能登陆
	Passwd -S用户名 查询账号密码
	Usermod -l 新用户名 老用户名 为用户改名
	Userdel–r 用户名 删除用户一切
	
	service [servicename] start/stop/restart 系统服务控制操作
	/etc/init.d/[servicename] start/stop/restart 系统服务控制操作
	
	uname -a 查看内核版本
	cat /etc/issue 查看ubuntu版本
	lsusb 查看usb设备
	sudo ethtool eth0 查看网卡状态
	cat /proc/cpuinfo 查看cpu信息
	lshw 查看当前硬件信息
	sudo fdisk -l 查看磁盘信息
	df -h 查看硬盘剩余空间
	free -m 查看当前的内存使用情况
	ps -A 查看当前有哪些进程
	kill 进程号(就是ps -A中的第一列的数字)或者 killall 进程名( 杀死一个进程)
	kill -9 进程号 强制杀死一个进程
	
	reboot Init 6 重启LINUX系统
	Halt Init 0 Shutdown –h now 关闭LINUX系统

######三、打包/解压

	tar -c 创建包 –x 释放包 -v 显示命令过程 –z 代表压缩包
	tar –cvf benet.tar /home/benet 把/home/benet目录打包
	tar –zcvf benet.tar.gz /mnt 把目录打包并压缩
	tar –zxvf benet.tar.gz 压缩包的文件解压恢复
	tar –jxvf benet.tar.bz2 解压缩

######四、make编译
	
	make 编译
	make install 安装编译好的源码包

######五、apt命令

	apt-cache search package 搜索包
	apt-cache show package 获取包的相关信息，如说明、大小、版本等
	sudo apt-get install package 安装包
	sudo apt-get install package - - reinstall 重新安装包
	sudo apt-get -f install 修复安装”-f = –fix-missing”
	sudo apt-get remove package 删除包
	sudo apt-get remove package - - purge 删除包，包括删除配置文件等
	sudo apt-get update 更新源
	sudo apt-get upgrade 更新已安装的包
	sudo apt-get dist-upgrade 升级系统
	sudo apt-get dselect-upgrade 使用 dselect 升级
	apt-cache depends package 了解使用依赖
	apt-cache rdepends package 是查看该包被哪些包依赖
	sudo apt-get build-dep package 安装相关的编译环境
	apt-get source package 下载该包的源代码
	sudo apt-get clean && sudo apt-get autoclean 清理无用的包
	sudo apt-get check 检查是否有损坏的依赖
	sudo apt-get clean 清理所有软件缓存（即缓存在/var/cache/apt/archives目录里的deb包）








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