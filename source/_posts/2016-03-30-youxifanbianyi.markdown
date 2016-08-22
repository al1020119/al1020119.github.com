---
layout: post
title: "游戏反编译"
date: 2016-03-30 13:32:08 +0800
comments: true
categories: Reverse
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏


---

{% img /images/bgHeader.png Caption %}  




 ipa游戏反编译
看不懂的请飘过，不要继续。
这不是给新手看的，也代表你不需要解决程序的修改问题。
这些技巧不只用于游戏的修改。




下載 Windows 工具

Windows : 
winscp http://winscp.net/eng/download.php
PuTTY http://putty.very.rulez.org/latest/x86/putty.exe

Mac / Linux :
用內置的 Terminal 便可





<!--more-->





没 wifi 用 iPhone Tunnel Suite 3.0
http://bbs.weiphone.com/read-htm-tid-597149.html

苹果电脑用 iPhoneSSH
http://bbs.weiphone.com/read-htm-tid-720564.html



iPhone/iPod Touch 在 cydia 內安裝 deb 包
安装这些 deb 包最方便的方法是在 Cydia 内搜索及直接安装，这里提供的下载包及依赖包的链接下载点是方便手工安装时用

OpenSSH (openssh) 及 OpenSSL(openssl) （与iPhone/iPod Touch 终端操作）
http://apt.saurik.com/debs/openssh_5.2p1-8_iphoneos-arm.deb
http://apt.saurik.com/debs/openssl_0.9.8k-9_iphoneos-arm.deb

unzip 及 zip （解压缩及压缩打包工具）
http://apt.saurik.com/debs/unzip_5.52-5_iphoneos-arm.deb
http://apt.saurik.com/debs/zip_2.32-5_iphoneos-arm.deb

vbindiff (iPhone 上的十六进制查看差异及修改器)
http://apt.saurik.com/debs/vbindiff_3.0b1-3_iphoneos-arm.deb

Link Identity Editor (ldid) 及 Darwin CC Tools (odcctools)（修改后用 ldid 签名, odcctools 包括 otool, linker , assembler汇编)
http://apt.saurik.com/debs/ldid_610-5_iphoneos-arm.deb
http://apt.saurik.com/debs/odcctools_286-8_iphoneos-arm.deb
http://apt.saurik.com/debs/uuid_1.6.0-2_iphoneos-arm.deb

Diff Utilities (diffutils) (文本差异工具 diff)
http://apt.saurik.com/debs/diffutils_2.8.1-6_iphoneos-arm.deb

less (文本查看工具)
http://apt.saurik.com/debs/less_418-3_iphoneos-arm.deb

Vi IMproved (vim) 或 nano (文本编辑工具)
http://apt.saurik.com/debs/vim_7.1-3_iphoneos-arm.deb
http://apt.saurik.com/debs/ncurses_5.7-9_iphoneos-arm.deb
或
http://apt.saurik.com/debs/nano_2.0.7-5_iphoneos-arm.deb
http://apt.saurik.com/debs/ncurses_5.7-9_iphoneos-arm.deb

GNU Debugger (gdb) (程序调试工具) iOS 4.3.x 更新
http://apt.saurik.com/debs/gdb_1518-11_iphoneos-arm.deb
http://apt.saurik.com/debs/ncurses_5.7-9_iphoneos-arm.deb
http://apt.saurik.com/debs/readline_6.0-7_iphoneos-arm.deb
http://apt.saurik.com/debs/sqlite3_3.5.9-12_iphoneos-arm.deb
http://apt.saurik.com/debs/sqlite3-lib_3.5.9-2_iphoneos-arm.deb
http://apt.saurik.com/debs/sqlite3-dylib_3.5.9-1_iphoneos-arm.deb


GNU Debugger (gdb) (程序调试工具)
http://apt.saurik.com/debs/gdb_962-5_iphoneos-arm.deb
http://apt.saurik.com/debs/ncurses_5.7-9_iphoneos-arm.deb
http://apt.saurik.com/debs/readline_6.0-7_iphoneos-arm.deb
http://apt.saurik.com/debs/sqlite3_3.5.9-12_iphoneos-arm.deb
http://apt.saurik.com/debs/sqlite3-lib_3.5.9-1_iphoneos-arm.deb
http://apt.saurik.com/debs/sqlite3-dylib_3.5.9-1_iphoneos-arm.deb

adv-cmds (ps 工具)
http://apt.saurik.com/debs/adv-cmds_119-5_iphoneos-arm.deb

grep (grep 文本搜索工具)
http://apt.saurik.com/debs/grep_2.5.4-3_iphoneos-arm.deb


ARM 参考书籍

http://bbs.weiphone.com/read-htm-tid-363306.html

ARM指令集及使用方法

ARM System Developer's Guide (主要是看第三章 Chapter 3)

ARM Assembly Language Programming



修改及用 gdb 调试游戏流程

(1) 安装及试玩游戏，每个游戏的修改方法都不同，没有玩过这游戏，怎样知道要修改什么呢？
这教程用了 Final Fantasy 2 作例子

(2) 用 iTunes 安装 Final Fantasy 2 破解版本 (未破解的不能反汇编)

(3) 用putty / ssh 连接iPhone / iPod Touch，假设你的iPhone / iPod Touch 的IP地址是192.168.1.104

Connection type: 选 SSH
Port 选 22
按 Open

 

PuTTY 连接 192.168.1.104 后

Login 打 root
Password(假设你没有更改密码) 打 alpine

Mac / Linux Terminal 内打
ssh root@192.168.1.104


(4) 进入游戏路径目录内(先决条件是已用 PuTTy / Terminal 连接iPhone / iPod Touch)
打
复制代码

    cd /var/mobile/Applications/*/FinalFantasy2.app



(5) 到上一层路径目录建立 cheat 临时工作路径目录及游戏程式临时修改档
打
复制代码

    cd ..
    mkdir -p cheat
    cd cheat
    cp -p ../FinalFantasy2.app/FinalFantasy2 FinalFantasy2.original



(6) 反汇编原游戏程式
复制代码

    otool -tv FinalFantasy2.original > FinalFantasy2.original.txt



(7) 查看反汇编代码分析并找出要修改的地方(每个游戏的修改地方都不同, 这点最难)
要修改游戏，你会有以下的困难或问题：

(i) 没有高阶源代码，只有反汇编代码 
反汇编代码分析是困难的但绝对不是不可能作分析，你可以找到些不错的ARM Assembly的参考书 
在上面亦已提供了一些很好的 ARM 指令参考 
常见的是以下这些基本的指令及其执行条件码：

MOV 或 MVN 寄存器数值的传送操作
ADD 或 SUB 加减的算术操作
CMP 或 CMN 比较操作
AND、ORR、EOR 逻辑操作
B、BL、BNE、BGE 分支/跳转指令
MUL 乘法操作 或 LSL 是 二进制左移，左移一位，即十进制乘2倍
LDR 或 STR 加载及存储数据


每个指令都可加上执行条件码根据上一个运算、逻辑或比较指令的结果决定是否执行指令

执行条件码 (Condition Codes)：
① CS 及 CC（Carry）进位条件码，CS＝进位，否则＝CC(不进位).
② EQ 及 NE （Equal 或 Zero）相等或零条件码，EQ＝运算结果为相等或零时，否则＝NE(不相等).
③ VS 及 VC（Overflow）溢出条件码。 VS=溢出，否则＝VC(不溢出)。
④ PL 及 MI 条件码。 PL（Plus/Positive）＝结果为正，MI（Minus/Negative）＝结果为负。

⑤ GT 及 LT 条件码。 GT（Greater Than）＝大于(PL+VC+NE / MI+VS+NE)，LT（Less Than）＝小于(MI+VC / PL+VS)。
⑥ GE 及 LE 条件码。 GE（Greater Than or Equal）＝大或等于(PL+VC / MI+VS)，LE（Less Than or Equal）＝小或等于(MI+VC / PL+VS / EQ)。
⑦ HI 及 LO 条件码。 HI（Higher Than）＝无符号数(unsigned)高于(CS+NE)，LO（Lower Than）＝无符号数(unsigned)低于(CC)。
⑧ HS 及 LS 条件码。 HS（Higher or Same）＝无符号数(unsigned)高于或相等(CS/EQ)，LS（Lower or Same）＝无符号数(unsigned)低于或相等(CC/EQ)。
⑨ AL 及 NV 条件码。 条件码默认为AL（Always）＝无条件执行，NV（Never）是AL的相反＝不执行。


例子及其注解意思
复制代码

CMP R0, R1       @寄存器数值 R0 及 R1 的比较
MOVGT R2, R0     @如果结果 R0 >(大于) R1，则执行MOV R2, R0即 R2＝R0
MOVLE R2, R1     @如果结果 R0 <=(小或等于) R1，则执行MOV R2, R1即 R2＝R1



复制代码

LDR R1, [R0]     @意思是 R1 = *R0，从R0指向的地址处的数据载入到寄存器 R1
STR R1, [R0]     @意思是 *R0 = R1，把寄存器 R1内的数据写到 R0 内指向的地址处



ARM 指令集及使用方法

(ii) 看不懂游戏程式流程，没法分析 
有很多人都喜欢用 IDA Pro Advanced 去做分析， 无疑这软件是个非常好的静态分析工具，它有图形视图显示代码流程作搜索及深层分析。除了可分析反汇编代码外，亦可反汇编一些 otool 不能处理的工作。 但 IDA Pro Advanced 在iPhone 的程式只适合做静态的分析。

你可以在这里下载 IDA Pro Advanced 5.2 及其参考书，建议你使用功能及视图比较强大的 Windows 版本。 
http://bbs.weiphone.com/read-htm-tid-363306.html 

只看代码是不能作分析，要配合动态调试去了解程式的细节在实际运行时发生的数据及变化。在第15步就有用 gdb 作动态调试的例子去设置断点、继续、跟踪及分析代码。gdb 的参考书可在上面的链接下载。

(iii) 找不到游戏的数据例如金钱，经验值，装备，等级暂存在那？

引用

方法一：在 gdb 设置断点分析
ARM CPU 有个特性便是一些加减计算要传送到CPU寄存器(register) 进行，因此你会经常看到这些要找的数据会先从内存用LDR 指令载入到寄存器, 经过一些计算(加或减)后及防溢位判断后便用STR 指令存储这寄存器回内存地址。

另外由于这些程式大多是用 Objective C 或 C++ 语言写成，这些程序员会用一些描述性的函数名，例如带有 Money, Price, Gold, Exp, Item, Life, Level 字段等。

利用这两点便可以将程序锁定在某些函数上，再利用 gdb 调试工具暂停在某些点一步一步地单步执行及查看一些寄存器，印证是否与你要找的数据是否有关。

    在FinalFantasy2 的这实例中, 是用这方法找到修改点
    用 less 工具去找寻 Money
    putty / Terminal 打
复制代码

    less FinalFantasy2.original.txt



    在 less 工具內打
复制代码

    /Money


    去开始找寻(按 N 键去继续找寻)，便会找到这段代码像是要存储金钱数据(SetMoney)，0007b218是进入这段代码的开始地址
复制代码

    __ZN14cFF2GlobalWork19sysGAMEPrm_SetMoneyEj:
    0007b218 e59f300c ldr r3, [pc, #12] ; 0x7b22c
    0007b21c e580120c str r1, [r0, #524]
    0007b220 e1510003 cmp r1, r3
    0007b224 8580320c strhi r3, [r0, #524]
    0007b228 e12fff1e bx lr



    首先在iPhone或iPod Touch 开始Final Fantasy 2 直至游戏已 Resume及进入游戏。


    ① 在PuTTY / Terminal 找FinalFantasy2 的运行中的进程编号(process id)

    PuTTY / Terminal 打
复制代码

    ps ax



    得到

复制代码

    1115   ??  Ss     1:30.86 /var/mobile/Applications/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/FinalFantasy2.app/FinalFantasy2



    找到FinalFantasy2 游戏现时运行中的进程编号是 1115

    ② 用gdb 进入调试运行中的进程编号1115
    PuTTY / Terminal 打
复制代码

    gdb -p 1115



    此时游戏会暂停，音乐也暂停

    ③ 用gdb 设定断点breakpoint在十六进制地址0x7b218

    PuTTY / Terminal 打
复制代码

    break *0x7b218



    ④ 继续 continue 游戏
    PuTTY / Terminal 打
复制代码

    c



    ⑤ 将Final Fantasy 2 游戏进入战斗，战胜后游戏会在十六进制地址0x7b218处停止

    ⑥ 暂停后，离开这分支__ZN14cFF2GlobalWork19sysGAMEPrm_SetMoneyEj
    PuTTY / Terminal 打
复制代码

    finish



    ⑦ 反汇编现时地址上面的代码
复制代码

    disassem $pc-28 $pc


    得到
复制代码

    0x0003baac <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG 180>: bl 0x78e30 <_ZN14cFF2GlobalWork8InstanceEv>
    0x0003bab0 <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG 184>: mov r4, r0
    0x0003bab4 <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG 188>: bl 0x78e30 <_ZN14cFF2GlobalWork8InstanceEv>
    0x0003bab8 <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG 192>: bl 0x7b230 <_ZN14cFF2GlobalWork19sysGAMEPrm_GetMoneyEv>
    0x0003babc <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG 196>: add r1, r0, r5
    0x0003bac0 <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG 200>: mov r0, r4
    0x0003bac4 <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG 204>: bl 0x7b218 <_ZN14cFF2GlobalWork19sysGAMEPrm_SetMoneyEj>



    这时会发现在_ZN14cFF2GlobalWork19sysGAMEPrm_GetMoneyEv
及_ZN14cFF2GlobalWork19sysGAMEPrm_SetMoneyEj
中间0x0003babc 地址的代码add r1, r0, r5 是最可疑的


    ⑧ 取消断点1及设定新断点breakpoint在十六进制地址0x0003babc 及重新继续continue 游戏
    PuTTY / Terminal 打
复制代码

    disable 1
    break *0x3babc
    c



    在iPhone或iPod Touch查看现时游戏的金钱例如是4888，将Final Fantasy 2 游戏进入战斗，战胜后游戏会新断点2地址0x3babc处停止

    ⑨ 当游戏在新断点2暂停时查看寄存器就发现 r0 是当时的金钱余额及 r5 是战胜后得到的金钱
    PuTTY / Terminal 打
复制代码

    i r $r0 $r1 $r5 $pc



    ⑩ 假设已找到应修改的地址是 0003babc，便可继续下面第(8)步



引用

方法二：在 gdb 搜索内存数据值及设置观察点(watchpoint) 

    游戏的数据都会暂存在堆(heap)内存, 于游戏退出前储存在 iPhone 或 iPod Touch的闪存记忆体内, 一些经验值或金钱的数字是比较独特，在内存重复出现的机会不多，这些唯一的数字便可用这方法去进行搜索。

    这里用了 Zenonia 2 v1.0 作例子，下面的游戏截图便看到用一个独特的经验值数字 672 去开始这方法

 

    ① 在 PuTTY / Terminal 用  ps ax  的指令找到 ZENONIA2 游戏现时运行中的进程编号是 1123

    ② 使用 gdb 进入运行中的进程编号 1123
    PuTTY / Terminal 打
复制代码

    gdb -p 1123



    此时游戏会暂停，音乐也暂停

    ③ 用 gdb 输入这些指令包括，内存开始地址(0x800000)、结束地址(0x880000)及要搜索的数字672如下:

    PuTTY / Terminal 打
复制代码

    set $x=0x800000
    while(*++$x!=672 && $x<0x880000)
    end



    ④ 输入 end 之后等候数十秒 ....，待gdb去搜索这段内存地址

    ⑤ gdb 搜索完毕后
    PuTTY / Terminal 打
复制代码

    p/x $x


    得到
复制代码

    $1 = 0x85e28c


这代表 gdb 已找到在 0x85e28c 的内存地址的存储数字是 672

    PuTTY / Terminal 打
复制代码

    x/dw 0x85e28c


    得到确认 0x85e28c 的内存地址的存储数字是 672
复制代码

    0x85e28c:    672



     ⑥ 用 gdb 继续搜索
    PuTTY / Terminal 打 (或按方向键 ↑ 4次，然后回车，免重复输入)
复制代码

    while(*++$x!=672 && $x<0x880000)
    end


    再等十多秒，gdb 搜索完毕后
    PuTTY / Terminal 打
复制代码

    p/x $x


    得到
复制代码

    $2 = 0x880000


这代表 gdb 已到结束的地址 0x880000，都没有找到。这也表示数字 672 是唯一出现在 0x85e28c 要找的内存范围内。

    ⑦ 用 gdb 更改内存地址 0x85e28c 的存储数字为 1000
    PuTTY / Terminal 打
复制代码

    set {int}0x85e28c=1000



    PuTTY / Terminal 打
复制代码

    x/dw 0x85e28c



    得到确认已成功更改数字
复制代码

    0x85e28c:    1000



    ⑧ 继续 continue 游戏
    PuTTY / Terminal 打
复制代码

    c



    ⑨ 在回到游戏里退出 STATUS 画面再进入 STATUS，画面内数据重刷后，确认已成功更改经验值数字为1000
 

    留意:由于游戏数据在堆(heap)内存的地址不是固定的，所以每次运行的进程都要再搜索新的内存地址。另外，搜索的内存地址范围也会改变，如果在 0x800000 至 0x880000 范围内找不到的话，就要往后试 0x880000 至 0x900000 新的范围。

         另外：用相同搜索方法也可以找到金钱数字在这次运行进程是在内存地址 0x874c04

    ⑩ 找到经验值地址后便可设置观察点(watchpoint)于内存地址 0x85e28c

    设置观察点的目的是当内存地址值被读或被写时，会显示数据及暂停程序

    PuTTY / Terminal 打
复制代码

    watch *0x85e28c


    及继续游戏
    PuTTY / Terminal 打
复制代码

    c


留意:游戏在观察点(watchpoint) 生效下运行是非常的慢，有些游戏是不能正常运作，有时候手机也要重启，所以下面的步骤是不一定可以进行的

    ⑪ 将游戏进入战斗打怪后程序便会暂停在 0x9f508 地址，gdb 会显示
复制代码

    Hardware watchpoint 1: *8774284
    Old value = 1000
    New value = 1086
    0x0009f508 in CMvPlayer::CheckLevelUp ()



    PuTTY / Terminal 打
复制代码

    x/14i $pc-16


    得到
复制代码

    0x9f4f8 <_ZN9CMvPlayer12CheckLevelUpEj+60>:    b.n    0x9f508 <_ZN9CMvPlayer12CheckLevelUpEj+76>
    0x9f4fa <_ZN9CMvPlayer12CheckLevelUpEj+62>:    adds    r0, r4, #0
    0x9f4fc <_ZN9CMvPlayer12CheckLevelUpEj+64>:    movs    r1, #1
    0x9f4fe <_ZN9CMvPlayer12CheckLevelUpEj+66>:    movs    r2, #0
    0x9f500 <_ZN9CMvPlayer12CheckLevelUpEj+68>:    subs    r5, r5, r3
    0x9f502 <_ZN9CMvPlayer12CheckLevelUpEj+70>:    bl    0x9f338 <_ZN9CMvPlayer9OnLevelUpEii>
    0x9f506 <_ZN9CMvPlayer12CheckLevelUpEj+74>:    movs    r3, #1
    0x9f508 <_ZN9CMvPlayer12CheckLevelUpEj+76>:    str    r5, [r4, r6]
    0x9f50a <_ZN9CMvPlayer12CheckLevelUpEj+78>:    cmp    r3, #0
    0x9f50c <_ZN9CMvPlayer12CheckLevelUpEj+80>:    beq.n    0x9f516 <_ZN9CMvPlayer12CheckLevelUpEj+90>
    0x9f50e <_ZN9CMvPlayer12CheckLevelUpEj+82>:    cmp    r5, #0
    0x9f510 <_ZN9CMvPlayer12CheckLevelUpEj+84>:    beq.n    0x9f516 <_ZN9CMvPlayer12CheckLevelUpEj+90>
    0x9f512 <_ZN9CMvPlayer12CheckLevelUpEj+86>:    movs    r5, #0
    0x9f514 <_ZN9CMvPlayer12CheckLevelUpEj+88>:    b.n    0x9f4c6 <_ZN9CMvPlayer12CheckLevelUpEj+10>



    PuTTY / Terminal 打
复制代码

    i r $r5 $r4 $r6 $pc
    p/x $r4+$r6


    得到
复制代码

    r5             0x43E    1086
    r4             0x85DC00    8772608
    r6             0x68c    1676
    pc             0x9f508    652552
    $5 = 0x85e28c



    这时确认了 0x9f508 地址这句代码
    str    r5, [r4, r6]
    的意思是，r4 + r6 = 0x85e28c ，把寄存器 r5 内的数字(1086) 写到 0x85e28c 的地址
　
    程序因要写进这0x85e28c 的地址，所以暂停了，这就是观察点(watchpoint) 的强大功能。

    PuTTY / Terminal 打
复制代码

    bt


    得到
复制代码

    #0  0x0009f508 in CMvPlayer::CheckLevelUp ()
    #1  0x0009ff2e in CMvPlayer::DoUpdate ()
    #2  0x00094744 in CMvObject::Update ()
    #3  0x000969cc in CMvObjectMgr::Update ()
    #4  0x000662e6 in CMvGameState::UpdateGame ()



    这时就可根据上面得到的信息在这段代码的前后范围进行跟踪、设置断点及进一步的分析



有新的方法时，再继续更新 ............

(iv) 不知道修改点在那及改为什么？

修改程序是不能插入程序代码，主要原因是移位后的程序是不能运行的。一般的做法是找到要修改的位置在原档案位置修改代码改为你需要的指令。 修改点一定要经过分析代码后再不断地用动态分析确定后，在适当的地方重覆试验及调试验证修改后的结果 。

* 一些RPG游戏的特性，例如是金钱或经验值是会在战斗后重算及更新，一般都是要找到及修改更新数据前的指令。金钱的修改点也可以修改在买卖装备时的指令。连续升级的修改主要是看该游戏是怎样升级，例如 Inotia 2是根据经验值去升级，只要找到判断经验值的指令代码地址，修改其判断的指令便可。

对于游戏来说，一般的指令修改例子如下：

① 修改寄存器的增加数字例如 
    Final Fantasy II 增加战胜后所得金钱 
    地址 0003babc 
    add r1, r0, r5 
    改为 
    add r1, r0, r5, lsl #5 

② 修改寄存器减少的数字为零例如 
    Inotia 2 v 1.1.0 不扣技能点 
    地址 00021b9c 
    sub r3, #1 
    改为 
    sub r3, #0 

    地址 00037b46 
    sub r1, #1 
    改为 
    sub r1, #0 

③ 修改比较的寄存器例如 
    花儿朵朵开-v1.0 不死作弊版 (这里 r2 寄存器是花朵已绽放的数量)
    地址 00004ee8 
    cmp r2, r3 
    改为 
    cmp r2, #1 ; 0x1 

④ 修改arm 32 位为两个arm thumb 16 位代码例如 
    Inotia 2 v 1.1.0 roll点全18 
    地址 0005c404 
    bl 0x9914 
    改为 
    mov r0, #9 
    mov r0, #9 

    地址 0005c404, 0005c40e, 0005c41c, 0005c426 
    bl 0x9914 
    改为 
    mov r0, #9 
    mov r0, #9 

⑤ 要删除代码便要用 nop (no operation) 取代 
    thumb 16 bits nop 是 46c0  
    arm 32 bits nop 是 e1a00000


(8) 在FinalFantasy2 的这实例中，假设已找到应修改的地址是 0003babc，代码是 e0801005
复制代码

    0003bab8        eb00fddc        bl 0x7b230
    0003babc        e0801005        add r1, r0, r5   @意思是 r1 = r0 +r5 ; r0 是当时的金钱余额; r5 是战胜后得到的金钱
    0003bac0        e1a00004        mov r0, r4
    0003bac4        eb00fdd3        bl 0x7b218     @分支到函数名 __ZN14cFF2GlobalWork19sysGAMEPrm_SetMoneyEj 去更新金錢余额



(9) 修改目标 : 将所得金钱乘大32倍
0003babc的应修改目标代码是
复制代码

    add r1, r0, r5, lsl#5 @意思是 r1 = r0 +( r5 二进制左移五位,即十进制乘大32倍)



(10) 找新ARM指令代码
add r1, r0, r5 的ARM指令代码是 e0801005
修改目标是要找到 add r1, r0, r5, lsl#5 的ARM指令代码 ?

用 vim 或 nano 建立 armtest.s 如下
复制代码

        .file "armtest.s"
        .globl _main
        .code 32
    _main:
        add r1, r0, r5
        add r1, r0, r5, lsl #5



留意: 一些程式反汇编后是ARM Thumb, ARM Thumb 是16 bits 而ARM 是32 bits. ARM 32 bits 及 ARM Thumb 的分别请找上面 ARM Assembler 的参考(ARM Thumb 的可用指令是比 ARM 32 bits 少)。 如果要找 ARM Thumb 代码要将上面的.code 32改为.code 16 及加上 .thumb_func _main 如下
复制代码

        .code 16
        .thumb_func _main





汇编 arm 打
复制代码

    as armtest.s -o armtest.o ; otool -tv armtest.o



便看到

复制代码

    (__TEXT,__text) section
    _main:
    00000000    e0801005    add r1, r0, r5
    00000004    e0801285    add r1, r0, r5, lsl #5



及得到add r1, r0, r5, lsl #5 目标ARM指令代码为 e0801285

(11) 建立修改程式第一版FinalFantasy2.v1及用十六进制修改器修改代码

打
复制代码

    cp -p FinalFantasy2.original FinalFantasy2.v1      
    vbindiff FinalFantasy2.v1


进入vibindiff 后按G及输入地址3AABC跳到要修改的位置如下

 

留意: 在第8步时找到的位置是0003Babc，但修改程式的位置要减去十六进制0x1000得到3Aabc
(0x3babc 减 0x1000 等于 0x3aabc)

按E键开始修改，将
05 10 80 E0
改为
85 12 80 E0

然后按Esc键及Y键确认修改

最后按Q键离开 vbindiff 修改器

如下

 

留意: 修改器显示的05 10 80 E0与反汇编的代码e0801005的位置顺序是倒的

(12) 反汇编修改程式第一版 v1 及比较原版本 original
打
复制代码

    otool -tv FinalFantasy2.v1 > FinalFantasy2.v1.txt
    diff FinalFantasy2.original.txt FinalFantasy2.v1.txt



也可以用 otool -otV


得到 

复制代码

    < FinalFantasy2.original:
    ---
    > FinalFantasy2.v1:
    59597c59597
    < 0003babc    e0801005    add    r1, r0, r5
    ---
    > 0003babc    e0801285    add    r1, r0, r5, lsl #5



(13) 对修改程式第一版重新签名
打
复制代码

    ldid -s FinalFantasy2.v1



(14) 将签名后的程式放回程式路径进行测试
首先备份原程式(留意:要用mv移动不要用cp)
打
复制代码

    mv ../FinalFantasy2.app/FinalFantasy2 ../FinalFantasy2.app/FinalFantasy2.bak



安装修改后的程式及更新权限
打
复制代码

    cp -p FinalFantasy2.v1 ../FinalFantasy2.app/FinalFantasy2
    chown mobile:mobile ../FinalFantasy2.app/FinalFantasy2
    chmod 0755 ../FinalFantasy2.app/FinalFantasy2



(15) 用 gdb 调试游戏

调试是用 gdb，在这里的目的是设置断点使游戏暂停，查看CPU的寄存器，印证修改是否成功。由于游戏占用很多内存，在游戏运行时调试再加ssh 连接很多时候都会崩溃。所以用 iPod Touch 3代 或 iPhone 3GS 做这项工作会有优势。

首先在iPhone或iPod Touch 开始Final Fantasy 2 直至游戏已Resume及进入游戏。

在iPhone或iPod Touch查看现时游戏的金钱例如是 7223

① 在putty / Terminal 找 FinalFantasy2 的运行中的进程编号 (process id)

PuTTY / Terminal 打
复制代码

    ps ax



得到

复制代码

    1115   ??  Ss     1:30.86 /var/mobile/Applications/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/FinalFantasy2.app/FinalFantasy2



找到 FinalFantasy2 游戏现时运行中的进程编号是 1115

② 用 gdb 进入调试运行中的进程编号 1115
PuTTY / Terminal 打
复制代码

    gdb -p 1115



此时游戏会暂停，音乐也暂停

③ 用 gdb 设定断点breakpoint在十六进制地址 0x3babc (即在第8步时找到的位置0003babc)
PuTTY / Terminal 打
复制代码

    break *0x3babc



④ 继续 continue 游戏
PuTTY / Terminal 打
复制代码

    c



⑤ 将Final Fantasy 2 游戏进入战斗，战胜后游戏会在十六进制地址 0x3babc处停止


⑥ 暂停后，查看 CPU 寄存器 register (info register 指令)
PuTTY / Terminal 打
复制代码

    i r $r0 $r1 $r5 $pc



得到

复制代码

    r0             0x1c37    7223
    r1             0x25    37
    r5             0x25    37
    pc             0x3babc    244412



印证了 r0=7223 是现时的金钱
游戏暂停在 pc=0x3babc


⑦ 查看下一步将要运行的反汇编指令
PuTTY / Terminal 打
复制代码

    x/i $pc



得到 add r1, r0, r5, lsl #5，印证成功修改指令

复制代码

    0x3babc <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG+196>:    add    r1, r0, r5, lsl #5



⑧ 运行下一步 stepi 指令
PuTTY / Terminal 打
复制代码

    si



查看 CPU 寄存器 register (info register 指令)
PuTTY / Terminal 打
复制代码

    i r $r0 $r1 $r5 $pc



得到
复制代码

    r0             0x1c37    7223
    r1             0x20d7    8407
    r5             0x25    37
    pc             0x3bac0    244416



此时印证了 r1 = r0 +( r5 x 32)
            = 7223 + (27 x 32)
            = 8407

查看下一步将要运行的反汇编指令
putty / Terminal 打
复制代码

    x/i $pc



得到

复制代码

    0x3bac0 <_ZN10FF2cBattle12SENRIHIN_CHKEP12thBATMonsterP6X86REG+200>:    mov    r0, r4



⑨ 继续 continue 游戏
PuTTY / Terminal 打
复制代码

    c



⑩ Final Fantasy 2 游戏显示战胜后得到37的金钱，但实际金钱余额是 8407，印证修改游戏已成功。

⑪ 离开 gdb

按下Ctrl+C 组合键停止执行进程

PuTTY / Terminal 打
复制代码

    quit



及按 y 键确认离开 gdb


留意:在上面第⑥步暂停时，你可以输入指令去更改CPU 寄存器 register
例如打
set $r5=1000
去试试增加金钱数目


(16) 假设已调试完成，便可将修改后的程式打包发布

进入游戏路径目录内，打
复制代码

    cd /var/mobile/Applications/*/FinalFantasy2.app



到上一层路径目录
复制代码

    cd ..



建立 IPA 所要的路径及档案及删除不需要的备份档案

复制代码

    rm -fr Payload
    mkdir -p Payload
    cp -pr FinalFantasy2.app Payload/
    rm -fr Payload/FinalFantasy2.app/FinalFantasy2*.bak



打包 ipa 为 FinalFantasy2_v1.ipod4g.ipa
复制代码

    zip -r FinalFantasy2_v1.ipod4g.ipa Payload iTunesArtwork



找现时的路径
复制代码

    pwd



得到 

复制代码

    /var/mobile/Applications/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX



用 winscp 或Terminal 的 scp 指令传送这档作发布

复制代码

    /var/mobile/Applications/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/FinalFantasy2_v1.ipod4g.ipa



XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX 是随机路径


(17) 其他有用的技巧

① 由于修改游戏的程式代码是很少量, 相对重覆调试及动态分析工作比较多，此教程便介绍了用iPhone 的工具直接做修改及反汇编。这样对于少量修改程式代码及重覆在iPhone调试是比较要传回PC做修改是更有效率的。

② 调试的工具 gdb 是比较难用，但有些方法是可提高使用 gdb 的效率。

例如：在 gdb 建立宏 macro define
在 iphone 建立这档案(~/.gdbinit) 内容为
复制代码

    define ascii_char
    set $_c=*(unsigned char *)($arg0)
    if ( $_c < 0x20 || $_c > 0x7E )
    printf "."
    else
    printf "%c", $_c
    end
    end
    document ascii_char
    Print the ASCII value of arg0 or '.' if value is unprintable
    end
    define hex_quad
    printf "%02X %02X %02X %02X  %02X %02X %02X %02X",  \
    *(unsigned char*)($arg0), *(unsigned char*)($arg0 + 1),  \
    *(unsigned char*)($arg0 + 2), *(unsigned char*)($arg0 + 3), \
    *(unsigned char*)($arg0 + 4), *(unsigned char*)($arg0 + 5), \
    *(unsigned char*)($arg0 + 6), *(unsigned char*)($arg0 + 7)
    end
    document hex_quad
    Print eight hexadecimal bytes starting at arg0
    end
    define hexdump
    printf "%08X : ", $arg0
    hex_quad $arg0
    printf " - "
    hex_quad ($arg0+8)
    printf " "
    ascii_char ($arg0)
    ascii_char ($arg0+1)
    ascii_char ($arg0+2)
    ascii_char ($arg0+3)
    ascii_char ($arg0+4)
    ascii_char ($arg0+5)
    ascii_char ($arg0+6)
    ascii_char ($arg0+7)
    ascii_char ($arg0+8)
    ascii_char ($arg0+9)
    ascii_char ($arg0+0xA)
    ascii_char ($arg0+0xB)
    ascii_char ($arg0+0xC)
    ascii_char ($arg0+0xD)
    ascii_char ($arg0+0xE)
    ascii_char ($arg0+0xF)
    printf "\n"
    end
    document hexdump
    Display a 16-byte hex/ASCII dump of arg0
    end
    define hexdump1
    hexdump $arg0
    x/8h $arg0
    printf "\n"
    disassem $arg0 $arg0+16
    printf "\n"
    end
    document hexdump1
    Display a 16-byte hex/ASCII dump and disassembly of arg0
    end



在用 gdb 调试时打
复制代码

    hexdump1 $pc


便可列出$pc位置后十六位的内容及反汇编的代码


③ 在断点设定一些要自动运行的指令

下面的意思是建立断点１
及在断点１停止时运行查看一些暂存器(i r $r0 $r1 $r5 $pc)及反汇编下四个指令代码(x/4i $pc)

复制代码

    break *0x3babc
    commands 1
    i r $r0 $r1 $r5 $pc
    x/4i $pc
    end



④ 在 gdb 断点暂停时，是可改变内存及指令
FinalFantasy2 的例子，0x0003babc地址的指令是
打
复制代码

    x/i 0x0003babc


得到代码是
复制代码

    add r1, r0, r5


打
复制代码

    x/xw 0x0003babc


得到代码数值是
复制代码

    0xe0801005



改变指令代码数值打
复制代码

    set {int}0x0003babc = 0xe0801285



检查改变后的指令打
复制代码

    x/i 0x0003babc



得到改变后的指令代码是
复制代码

    add r1, r0, r5, lsl #5



这样就不用离开 gdb 即时看到修改代码后的效果


⑤ gdb 执行到程序中其他地址的命令

    例子：
    stepi                           单步执行一个机器指令(命令步入函数)
    nexti                           单步执行一个机器指令(命令步过函数)
    nexti 2                        继续执行机器指令的数目为 2 个指令
    finish                          继续执行至当前函数结束后，停止于其调用点
    until *0x7b224            继续执行至特定地址*0x7b224
    jump *0x3baac           跳转至特定地址*0x3baac 执行


⑥ gdb 调试记录的命令

    例子：
    set logging file ./log1.txt      设定记录档
    set logging on                     开始记录
    set logging off                     停止记录


⑦ 学习别人修改程序的方法 
看别人修改程序是最好的学习方法，只要你有原版本及修改后的版本，就可以知道修改的地址及方法
例如： 
下载花儿朵朵开-v1.0.rar 原版本 

下载花儿朵朵开-v1.0.rar 不死作弊修改版 

解压后将两个 ipa 文件，用 winscp 传到iPhone 路径 /var/root/flower 内

在 PuTTY / Terminal 连接iPhone / iPod Touch后 

打 
复制代码

    cd /var/root/flower



解压原游戏版本程序 
在 PuTTY / Terminal 打 
复制代码

    unzip *-v1.0.ipa
    mv Payload/FlowerChainCN.app/FlowerChainCN FlowerChainCN.original



删除不需要的的路径及档案 
在 PuTTY / Terminal 打 
复制代码

    rm -fr Payload/ iTunesArtwork *.ipa



解压不死作弊修改版程序 
在 PuTTY / Terminal 打 
复制代码

    unzip *-v1.0.ipod4g.ipa
    mv Payload/FlowerChainCN.app/FlowerChainCN FlowerChainCN.patched



删除不需要的的路径及档案 
在 PuTTY / Terminal 打 
复制代码

    rm -fr Payload/ iTunesArtwork *.ipa



反汇编原游戏程式及保存反汇编文本文件为 FlowerChainCN.original.txt 
在 PuTTY / Terminal 打 
复制代码

    otool -tv FlowerChainCN.original > FlowerChainCN.original.txt



反汇编不死作弊修改版程式及保存反汇编文本文件为 FlowerChainCN.patched.txt
在 PuTTY / Terminal 打 
复制代码

    otool -tv FlowerChainCN.patched > FlowerChainCN.patched.txt



比较两个版本及找出差异 
在 PuTTY / Terminal 打 
复制代码

    diff FlowerChainCN.original.txt FlowerChainCN.patched.txt



得到 
复制代码

    < FlowerChainCN.original:
    ---
    > FlowerChainCN.patched:
    3060c3060
    < 00004ee8 e1520003 cmp r2, r3
    ---
    > 00004ee8 e3520001 cmp r2, #1 ; 0x1



原版本列在左边及把差异列在右边并输出差异文本保存为 FlowerChainCN.diff.txt
在 PuTTY / Terminal 打 
复制代码

    diff -y --left-column FlowerChainCN.original.txt FlowerChainCN.patched.txt > FlowerChainCN.diff.txt



用 less 工具打开差异文本 FlowerChainCN.diff.txt
在 PuTTY / Terminal 打 
复制代码

    less FlowerChainCN.diff.txt



在 less 工具内搜寻差异分隔字符 |
在 less 工具内打 
复制代码

    /\|


得到下面差异的显示去做进一步分析
复制代码

    00004ee8 e1520003 cmp r2, r3 | 00004ee8 e3520001 cmp r2, #1 ; 0x1




在 PuTTY / Terminal 打这句也可看到原版本上下的代码
复制代码

    grep -C5 '|' FlowerChainCN.diff.txt


或
复制代码

    grep -C5 00004ee8  FlowerChainCN.original.txt



⑧ 最后送上我自购破解的一个很实用的iPhone小工具 - 64位计算器
这小工具除了可以做64位的计算外，还可以输入文字及显示Unicode的代码


	64 Bit Calculator
	
	 64_Bit_Calc-v1.2.ipod4g.ipa (788 K) 下载次数:233 
 



	64 Bit Calculator (iPad)   64_Bit_Calc_iPad-v1.2.ipa (1521 K) 下载次数:116 





关于 FinalFantasy2 1.0.4 版本 ldid 签名时出现错误信息 Segmentation fault

初代 iPhone 使用ARMv6 指令集, 直到3GS, iPad, IPhone 4设备苹果开始采用了 ARMv7 指令集

如果你打指令

复制代码

    otool -f FinalFantasy2



就会看到

复制代码

    architecture 0
        cputype 12
        cpusubtype 6
    architecture 1
        cputype 12
        cpusubtype 9



你可以把 FinalFantasy2 切开为 FinalFantasy2V6

复制代码

    lipo -thin armv6  FinalFantasy2 -output FinalFantasy2V6
    chmod +x FinalFantasy2V6
    chown mobile:mobile FinalFantasy2V6



及切开为 FinalFantasy2V7

复制代码

    cp -p FinalFantasy2 FinalFantasy2tmp
    echo -ne "\x09" | dd bs=1 seek=15 conv=notrunc status=noxfer of=FinalFantasy2tmp
    echo -ne "\x06" | dd bs=1 seek=35 conv=notrunc status=noxfer of=FinalFantasy2tmp
    lipo -thin armv6 FinalFantasy2tmp -output FinalFantasy2V7
    rm FinalFantasy2tmp
    chmod +x FinalFantasy2V7
    chown mobile:mobile FinalFantasy2V7



但 iPhone 的 otool 不支持反汇编 ARMv7 指令集, 你要用新版本的 IDA Pro 反汇编

在 iPhone 你只可以反汇编 FinalFantasy2V6, 修改及用 ldid 去签名

FinalFantasy2V6 签名后便可替代原版本使用, 游戏来说ARMv6 指令集也可以, 只不过在新的设备上使用时不是最优化.


 
.


===

    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  