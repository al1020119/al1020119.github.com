---

layout: post
title: "XMPP使用总结"
date: 2015-4-12 00:21:39 +0800
comments: true
categories: 高级开发

---


 
引言：
最近面试被问到了一个问题，笔者当时就懵了：什么XMPP，平时怎么使用，使用过程中遇到什么问题？。

但是还是通过记忆，简单的说了一下自己所知道了，不过那并没有撒卵用，所以你懂的
 
 
########XMPPFramework是一个OS X/iOS平台的开源项目，使用Objective-C实现了XMPP协议（RFC-3920），同时还提供了用于读写XML的工具，大大简化了基于XMPP的通信应用的开发。



 
### 关于连接的

	//此方法在stream开始连接服务器的时候调用
	 - (void)xmppStreamDidConnect:(XMPPStream *)sender
	 //此方法在stream连接断开的时候调用
	 - (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error;
 

### 关于验证的

	//验证失败后调用
	 - (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
	//验证成功后调用
	 - (void)xmppStreamDidAuthenticate:(XMPPStream *)sender

###  关于通信的

	//收到消息后调用
	- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
	//接受到好友状态更新
	- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
 

#### 简单实战



###### 登录和好友上下线

##### XMPP中常用对象们

	XMPPStream：xmpp基础服务类
	XMPPRoster：好友列表类
	XMPPRosterCoreDataStorage：好友列表（用户账号）在core data中的操作类
	XMPPvCardCoreDataStorage：好友名片（昵称，签名，性别，年龄等信息）在core data中的操作类
	XMPPvCardTemp：好友名片实体类，从数据库里取出来的都是它
	xmppvCardAvatarModule：好友头像
	XMPPReconnect：如果失去连接,自动重连
	XMPPRoom：提供多用户聊天支持
XMPPPubSub：发布订阅
##### 登录操作，也就是连接xmpp服务器

	- (void)connect {
	    if (self.xmppStream == nil) {
	        self.xmppStream = [[XMPPStream alloc] init];
	        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	    }
	    if (![self.xmppStream isConnected]) {
	        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	        XMPPJID *jid = [XMPPJID jidWithUser:username domain:@"lizhen" resource:@"Ework"];
	        [self.xmppStream setMyJID:jid];
	        [self.xmppStream setHostName:@"10.4.125.113"];
	        NSError *error = nil;
	        if (![self.xmppStream connect:&error]) {
	            NSLog(@"Connect Error: %@", [[error userInfo] description]);
	        }
	    }
	}
connect成功之后会依次调用XMPPStreamDelegate的方法，首先调用

	- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
 
...
然后

- (void)xmppStreamDidConnect:(XMPPStream *)sender
在该方法下面需要使用xmppStream 的authenticateWithPassword方法进行密码验证，成功的话会响应delegate的方法，就是下面这个

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender

##### 上线
实现 - (void)xmppStreamDidAuthenticate:(XMPPStream *)sender 委托方法

	- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
	     XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
	    [self.xmppStream sendElement:presence];
	 }

##### 退出并断开连接

	 - (void)disconnect {
	     XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	    [self.xmppStream sendElement:presence];
	       
	      [self.xmppStream disconnect];
	  }

##### 好友状态
获取好友状态，通过实现

	- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
 
...
方法，当接收到 presence 标签的内容时，XMPPFramework 框架回调该方法 

	presence 的状态：
	available 上线
	away 离开
	do not disturb 忙碌
	unavailable 下线

	- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
	    NSString *presenceType = [presence type];
	    NSString *presenceFromUser = [[presence from] user];
	    if (![presenceFromUser isEqualToString:[[sender myJID] user]]) {
	        if ([presenceType isEqualToString:@"available"]) {
	            //
	        } else if ([presenceType isEqualToString:@"unavailable"]) {
	            //
	        }
	    }
	}

###  接收消息和发送消息
##### 接收消息
通过实现

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message;
当接收到 message 标签的内容时，XMPPFramework 框架回调该方法
根据 XMPP 协议，消息体的内容存储在标签 body 内

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSString *messageBody = [[message elementForName:@"body"] stringValue];
}

##### 发送消息
发送消息，我们需要根据 XMPP 协议，将数据放到标签内

	- (void)sendMessage:(NSString *) message toUser:(NSString *) user {
	    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
	    [body setStringValue:message];
	    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
	    [message addAttributeWithName:@"type" stringValue:@"chat"];
	    NSString *to = [NSString stringWithFormat:@"%@@example.com", user];
	    [message addAttributeWithName:@"to" stringValue:to];
	    [message addChild:body];
	    [self.xmppStream sendElement:message];
	}

### 获取好友信息和删除好友
##### 好友列表和好友名片

	[_xmppRoster fetchRoster];//获取好友列表
	//获取到一个好友节点
	- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item
	//获取完好友列表
	- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
	//到服务器上请求联系人名片信息
	- (void)fetchvCardTempForJID:(XMPPJID *)jid;
	//请求联系人的名片，如果数据库有就不请求，没有就发送名片请求
	- (void)fetchvCardTempForJID:(XMPPJID *)jid ignoreStorage:(BOOL)ignoreStorage;
	//获取联系人的名片，如果数据库有就返回，没有返回空，并到服务器上抓取
	- (XMPPvCardTemp *)vCardTempForJID:(XMPPJID *)jid shouldFetch:(BOOL)shouldFetch;
	//更新自己的名片信息
	- (void)updateMyvCardTemp:(XMPPvCardTemp *)vCardTemp;
	//获取到一盒联系人的名片信息的回调
	- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
	        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
	                     forJID:(XMPPJID *)jid

##### 添加好友

	//name为用户账号
	    - (void)XMPPAddFriendSubscribe:(NSString *)name
	    {
	        //XMPPHOST 就是服务器名，  主机名
	        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,XMPPHOST]];
	        //[presence addAttributeWithName:@"subscription" stringValue:@"好友"];
	        [xmppRoster subscribePresenceToUser:jid];
	
	    }

##### 收到添加好友的请求

	- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
	    {
	        //取得好友状态
	        NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
	        //请求的用户
	        NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
	        NSLog(@"presenceType:%@",presenceType);
	
	        NSLog(@"presence2:%@  sender2:%@",presence,sender);
	
	        XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
	        //接收添加好友请求
	        [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
	
	    }
 

##### 删除好友

	//删除好友，name为好友账号
	- (void)removeBuddy:(NSString *)name  
	{  
	    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,XMPPHOST]];  
	
	    [self xmppRoster] removeUser:jid];  
	}

##### 聊天室
初始化聊天室

	     XMPPJID *roomJID = [XMPPJID jidWithString:ROOM_JID];
	
	    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:self jid:roomJID];
	
	    [xmppRoom activate:xmppStream];
	     [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
创建聊天室成功

	`- (void)xmppRoomDidCreate:(XMPPRoom *)sender
	{
	    DDLogInfo(@"%@: %@", THIS_FILE, THIS_METHOD);
	}`

加入聊天室，使用昵称

 
    [xmppRoom joinRoomUsingNickname:@"quack" history:nil];
    
获取聊天室信息

	- (void)xmppRoomDidJoin:(XMPPRoom *)sender
	    {
	        [xmppRoom fetchConfigurationForm];
	        [xmppRoom fetchBanList];
	        [xmppRoom fetchMembersList];
	        [xmppRoom fetchModeratorsList];
	    }
    
    
如果房间存在，会调用委托

	    // 收到禁止名单列表
	
	    - (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items;
	    // 收到好友名单列表
	
	    - (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items;
	    // 收到主持人名单列表
	
	    - (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items;
	房间不存在，调用委托
	
	    - (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError;
	    - (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError;
	    - (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError;
	    
离开房间

	[xmppRoom deactivate:xmppStream];
 


XMPPRoomDelegate的其他代理方法:


离开聊天室

	    - (void)xmppRoomDidLeave:(XMPPRoom *)sender
	    {
	        DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	    }
	    
新人加入群聊

	    - (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID
	     {
	         DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	    }
	    
有人退出群聊

	    - (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID
	    {
	        DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	    }
	    
有人在群里发言

	    - (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
	     {
	         DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	    }

##### 消息回执
这个是XEP－0184协议的内容
发送消息时附加回执请求 
代码实现

	NSString *siID = [XMPPStream generateUUID];
	    //发送消息
	    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid elementID:siID];
	    NSXMLElement *receipt = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
	    [message addChild:receipt];
	    [message addBody:@"测试"];
	    [self.xmppStream sendElement:message];

收到回执请求的消息，发送回执
 

	- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
	    {
	        //回执判断
	        NSXMLElement *request = [message elementForName:@"request"];
	        if (request)
	        {
	            if ([request.xmlns isEqualToString:@"urn:xmpp:receipts"])//消息回执
	            {
	                //组装消息回执
	                XMPPMessage *msg = [XMPPMessage messageWithType:[message attributeStringValueForName:@"type"] to:message.from elementID:[message attributeStringValueForName:@"id"]];
	                NSXMLElement *recieved = [NSXMLElement elementWithName:@"received" xmlns:@"urn:xmpp:receipts"];
	                [msg addChild:recieved];
	
	                //发送回执
	                [self.xmppStream sendElement:msg];
	            }
	        }else
	        {
	            NSXMLElement *received = [message elementForName:@"received"];
	            if (received)
	            {
	                if ([received.xmlns isEqualToString:@"urn:xmpp:receipts"])//消息回执
	                {
	                    //发送成功
	                    NSLog(@"message send success!");
	                }  
	            }  
	        }  
	
	        //消息处理  
	        //...  
	    }

##### 添加AutoPing

为 了监听服务器是否有效，增加心跳监听。用XEP-0199协议，在XMPPFrameWork框架下，封装了 XMPPAutoPing 和 XMPPPing两个类都可以使用，因为XMPPAutoPing已经组合进了XMPPPing类，所以XMPPAutoPing使用起来更方便。

	//初始化并启动ping
	-(void)autoPingProxyServer:(NSString*)strProxyServer
	{
	    _xmppAutoPing = [[XMPPAutoPingalloc] init];
	    [_xmppAutoPingactivate:_xmppStream];
	    [_xmppAutoPingaddDelegate:selfdelegateQueue:  dispatch_get_main_queue()];
	    _xmppAutoPing.respondsToQueries = YES;
	    _xmppAutoPing.pingInterval=2;//ping 间隔时间
	    if (nil != strProxyServer)
	    {
	       _xmppAutoPing.targetJID = [XMPPJID jidWithString: strProxyServer ];//设置ping目标服务器，如果为nil,则监听socketstream当前连接上的那个服务器
	    }
	}
	//卸载监听
	 [_xmppAutoPing   deactivate];
	  [_xmppAutoPing   removeDelegate:self];
	   _xmppAutoPing = nil;
	//ping XMPPAutoPingDelegate的委托方法:
	- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
	{
	    NSLog(@"- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender");
	}
	- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
	{
	    NSLog(@"- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender");
	}
	
	- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
	{
	    NSLog(@"- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender");
	}
 