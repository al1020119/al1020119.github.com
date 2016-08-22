---

layout: post
title: "环信高级篇-透传和拓展"
date: 2016-05-20 13:53:19 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏



---  

{% img /images/bgHeader.png Caption %}  


由于App开发中遇到了：送花和打赏，但是我们使用的即时通讯是环信，并没有直接的接口实现，而是需要我们使用里面比较特殊的技术：拓展和透传

透传：传递用户头像和昵称
拓展：实现非正常消息（打赏，送花，送礼物）



<!--more-->


环信高级篇-透传和拓展
 
////////////////////////////////////////////////////////////////////////////////////////////////////
  透传
////////////////////////////////////////////////////////////////////////////////////////////////////

方法一 从APP服务器获取昵称和头像

    昵称和头像的获取：当收到一条消息（群消息）时，得到发送者的用户ID，然后查找手机本地数据库是否有此用户ID的昵称和头像，如没有则调用APP服务器接口通过用户ID查询出昵称和头像，然后保存到本地数据库和缓存，下次此用户发来信息即可直接查询缓存或者本地数据库，不需要再次向APP服务器发起请求

    昵称和头像的更新：当点击发送者头像时加载用户详情时从APP服务器查询此用户的具体信息然后更新本地数据库和缓存。当用户自己更新昵称或头像时，也可以发送一条透传消息到其他用户和用户所在的群，来更新该用户的昵称和头像。

方法二 从消息扩展中获取昵称和头像

    昵称和头像的获取：把用户基本的昵称和头像的URL放到消息的扩展中，通过消息传递给接收方，当收到一条消息时，则能通过消息的扩展得到发送者的昵称和头像URL，然后保存到本地数据库和缓存。当显示昵称和头像时，请从本地或者缓存中读取，不要直接从消息中把赋值拿给界面（否则当用户昵称改变后，同一个人会显示不同的昵称）。

    昵称和头像的更新：当扩展消息中的昵称和头像URI与当前本地数据库和缓存中的相应数据不同的时候，需要把新的昵称保存到本地数据库和缓存，并下载新的头像并保存到本地数据库和缓存。


透传的实现
	
	- (void)sendTouChuanMessage:(int)count
	{
	    
	    GiFHUD *gif = [[GiFHUD alloc] init];
	    
	    //Setup GiFHUD image
	    [gif setGifWithImageName:@"pika.gif"];
	    [gif showWithOverlay];
	    
	    // dismiss after 2 seconds
	    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
	    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
	        [gif dismiss];
	        
	        
	        
	        //                    EMChatCommand *cmdChat = [[EMChatCommand alloc] init];
	        //                    cmdChat.cmd = @"{"type":1, @"data":"{"count":count}"}";
	        //                    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:cmdChat];
	        //                    // 生成message
	        //                    EMMessage *message = [[EMMessage alloc] initWithReceiver:@"6001" bodies:@[body]];
	        //                    message.messageType = eMessageTypeChat; // 设置为单聊消息
	        //                    //message.messageType = eConversationTypeGroupChat;// 设置为群聊消息
	        //                    //message.messageType = eConversationTypeChatRoom;// 设置为聊天室消息
	        
	        
	        //通过透传发送当前位置信息给领导
	        
	        EMChatCommand *shareCommand = [[EMChatCommand alloc] init];
	        
	        shareCommand.cmd = @"ResponseLocation";            // 当前cmd消息的关键字
	        
	        EMCommandMessageBody *lovesMsgBody = [[EMCommandMessageBody alloc] initWithChatObject:shareCommand];
	        
	        //设置要发给谁, fromToken是环信用户username或者群聊groupid
	        
	        EMMessage *lovesMsg = [[EMMessage alloc] initWithReceiver:self.uid bodies:@[lovesMsgBody]];
	        
	        lovesMsg.messageType = eMessageTypeChat;   // 单聊或者群聊
	        
	        
	        //                    //IM透传消息格式
	        //
	        //                    {"type":1 "data":""}
	        //                    //type 消息类型，1送花
	        //                    //data 根据消息类型的不同，消息的数据体
	        //
	        //                    1 送花
	        //                    data数据：{"count":99}	//count 送出花的个数
	        lovesMsg.ext = @{
	                         @"type":@(1),
	                         @"data":@{@"count":@(count)},
	                         
	                         };
	        [[EaseMob sharedInstance].chatManager asyncSendMessage:lovesMsg progress:nil];
	    });
	}
	
	- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
	{
	    /**
	     *  {"messageId":"177936556470829584","messageType":0,"from":"47","bodies":["{\"type\":\"cmd\",\"action\":\"ResponseLocation\"}"],"ext":{"type":1,"data":{"count":1}},"isAcked":false,"to":"57","timestamp":1458993883065,"requireEncryption":false}
	     */
	    NSString *type = [cmdMessage.ext objectForKey:@"type"];
	    NSString *count = [[cmdMessage.ext objectForKey:@"data"] objectForKey:@"count"];
	    
	}
	
	- (void)ReciveMessageExtension
	{
	
	}


 

//////////////////////////////////////////////////////////////////////////////////////////////////////
//  自定义消息扩展
//////////////////////////////////////////////////////////////////////////////////////////////////////

	环信官方的解释： 当 SDK 提供的消息类型不满足需求时，开发者可以通过扩展自 SDK 提供的文本、语音、图片、位置等消息类型，从而生成自己需要的消息类型。 
	
	
	- (void)SendMessageExtension:(int)count
	{
	    
	    GiFHUD *gif = [[GiFHUD alloc] init];
	    
	    //Setup GiFHUD image
	    [gif setGifWithImageName:@"pika.gif"];
	    [gif showWithOverlay];
	    
	    // dismiss after 2 seconds
	    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
	    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
	        [gif dismiss];
	        
	        NSDictionary *dict = @{@"type":@(1),@"data":@{@"count":@(count)}};
	        NSError *error = nil;
	        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
	                                                           options:NSJSONWritingPrettyPrinted
	                                                             error:&error];
	        NSString *jsonString = [[NSString alloc] initWithData:jsonData
	                                                     encoding:NSUTF8StringEncoding];
	
	        
	        // 创建一个聊天文本对象
	        EMChatText *chatText = [[EMChatText alloc] initWithText:jsonString];
	        //#warning 不同的消息类型对应不同的消息体
	        // 创建文本消息体
	        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:chatText];
	        
	        // 创建消息对象
	        EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
	        
	        msgObj.messageType = eMessageTypeChat; // 设置为单聊消息
	        msgObj.deliveryState = eMessageDeliveryState_Delivered;
	//        msgObj.ext = @{@"1":@(count)};
	        msgObj.ext = @{@"msg_type":@(1)};
	        // 发消息
	        [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
	            NSLog(@"准备发送消息");
	        } onQueue:nil completion:^(EMMessage *message, EMError *error) {
	            if (!error) {
	                NSLog(@"消息发送成功");
	            }else{
	                NSLog(@"消息发送失败");
	                iCocosLog(@"%@=====================", error);
	            }
	        } onQueue:nil];
	        
	        iCocosLog(@"%@", msgObj.ext);
	        
	        
	        // 把发送的消息添加到数据源,显示
	        //    [self.dataSources addObject:msgObj];
	        [self addMessageToDataSource:msgObj];
	        [self.tableView reloadData];
	        [self scrollToBottom];
	    });
	}


    Q Q：2211523682/790806573

    微信：18370997821/13148454507
    
    微博WB:http://weibo.com/u/3288975567?is_hot=1
    
	git博文：http://al1020119.github.io/
	
	github：https://github.com/al1020119


{% img /images/iCocosCoder.jpg Caption %}  

{% img /images/iCocosPublic.jpg Caption %}  