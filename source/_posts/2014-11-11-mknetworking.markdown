---

layout: post
title: "MKNetWorking是撒？"
date: 2014-11-11 13:53:19 +0800
comments: true
categories: 高级开发 

---  

常用框架比如：

* AFNetworking
* ASIHttpRequest
* SDWebImage
* MKNetWorKit等。

iOS5已出来这么久了，而ASIHttpRequest的作者已经申明不更新了，在iOS5环境下，其实还是有些问题的。

现在MKNetWorkKi吸取了ASIHttpRequest与AFNetWorking的优点，并加入了自己特有的功能。

下载：

	gitHub地址：https://github.com/MugunthKumar/MKNetworkKit.git

	官方使用说明：http://blog.mugunthkumar.com/products/ios-framework-introducing-mknetworkkit/

github下载了该项目后，如果想运行其demo，一定要打开MKNetworkKit.xcworkspace该文件，若单独打开，则编译时会提示缺少libMKNetworkKit-iOS.a文件！！！

######安装：
克隆下来之后把其中的 MKNetworkKit文件夹拖入项目，然后引入3个framework：

* CFNetwork.Framework 
* SystemConfiguration.framework
* Security.framework

   {% img /images/MKNet001.png Caption %}     
 
> 注意：由于MKNetworkKit支持ARC，我们在项目中要开启ARC，不然会报错

{% img /images/MKNet002.png Caption %}  
 
开启ARC自动内存控制机制：(开启ARC之后项目中所有的dealloc 、release 、autorelease都得注释掉)

 {% img /images/MKNet003.png Caption %}  
######使用方法：
  在需要使用的地方导入：#import"MKNetworkKit.h"

#http方式：
 
###GET请求：      
 
	MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"192.168.2.176:3000" customHeaderFields:nil];  
	MKNetworkOperation *op = [engine operationWithPath:@"/index" params:nil httpMethod:@"GET" ssl:NO];  
	[op addCompletionHandler:^(MKNetworkOperation *operation) {  
	    NSLog(@"[operation responseData]-->>%@", [operation responseString]);  
	}errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {  
	    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);  
	}];  
	[engine enqueueOperation:op];  

###POST请求： 
 
	MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"192.168.2.176:3000" customHeaderFields:nil];  
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];  
	[dic setValue:@"admin" forKey:@"username"];  
	[dic setValue:@"123" forKey:@"password"];  
	  
	MKNetworkOperation *op = [engine operationWithPath:@"/login" params:dic httpMethod:@"POST"];  
	[op addCompletionHandler:^(MKNetworkOperation *operation) {  
	    NSLog(@"[operation responseData]-->>%@", [operation responseString]);  
	}errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {  
	    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);  
	}];  
	[engine enqueueOperation:op];  

#https方式： 
 
	#define serverHost               @"192.168.1.84:5558"  
	  
	- (NSDictionary *)getDataFromURL:(NSString *)Path params:(NSDictionary *)data  
	{  
	    NSLog(@"MKNetwork request URL:  %@%@   \n Data: %@",serverHost,Path,data);  
	      
	    __block NSDictionary *responseJSON;  
	    __block NSError *error = nil;  
	    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:serverHost customHeaderFields:nil];  
	    MKNetworkOperation *op = [engine operationWithPath:Path  params:data httpMethod:@"POST" ssl:YES];  
	//    在请求中添加证书  
	    op.clientCertificate = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"client.p12"];  
	    op.clientCertificatePassword = @"test";  
	//   当服务器端证书不合法时是否继续访问  
	    op.shouldContinueWithInvalidCertificate=YES;  
	    [op addCompletionHandler:^(MKNetworkOperation *operation) {  
	        NSLog(@"[operation responseData]-->>%@", [operation responseString]);  
	        responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];  
	        if(error) {  
	            NSLog(@"JSONSerialization failed! - error: %@", error);  
	        };  
	        error=nil;  
	    } errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {  
	        error=err;  
	    }];  
	    [engine enqueueOperation:op];  
	    while(!error&&!responseJSON){}  
	    if (error) {  
	        NSLog(@"MKNetwork request error : %@", error);  
	        return nil;  
	    }  
	    if(responseJSON){  
	        NSLog(@"JSONSerialization successed! - responseJSON: %@", responseJSON);  
	    }  
	    return responseJSON;  
	}  
	  
	  
	    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:@"admin",@"userName", @"123",@"password", nil];  
	    NSDictionary *responseDict = [self getDataFromURL:@"/login" params:params];  
 
###下载文件： 
 
	+(MKNetworkOperation*) downloadFatAssFileFrom:(NSString*) remoteURL toFile:(NSString*) filePath {  
	    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"127.0.0.1:5558" customHeaderFields:nil];  
	    MKNetworkOperation *op = [engine operationWithURLString:remoteURL  
	                                                   params:nil  
	                                               httpMethod:@"GET"];  
	      
	    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath  
	                                                            append:YES]];  
	    [engine enqueueOperation:op];  
	    return op;  
	}  
	+(void)testDownload{  
	    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);  
	    NSString *cachesDirectory = [paths objectAtIndex:0];  
	    NSString *downloadPath = [cachesDirectory stringByAppendingPathComponent:@"DownloadedFile.pdf"];  
	      
	    MKNetworkOperation *downloadOperation=[HttpManager downloadFatAssFileFrom:@"http://127.0.0.1:5558/QQ"  
	                                                                      toFile:downloadPath];  
	      
	    [downloadOperation onDownloadProgressChanged:^(double progress) {  
	        //下载进度  
	        NSLog(@"download progress: %.2f", progress*100.0);  
	    }];  
	    //事件处理  
	    [downloadOperation addCompletionHandler:^(MKNetworkOperation* completedRequest) {  
	        NSLog(@"download file finished!");  
	    }  errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {  
	        NSLog(@"download file error: %@", err);  
	    }];  
	}  
###上传文件： 
 
	+(MKNetworkOperation*) uploadImageFromFile:(NSString*) filePath mimeType:(NSString *)fileType{  
	    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"127.0.0.1:5558" customHeaderFields:nil];  
	    MKNetworkOperation *op = [engine operationWithPath:@"upload"  
	                                              params:[NSDictionary dictionaryWithObjectsAndKeys:  
	                                                      @"admin", @"username",  
	                                                      @"123", @"password",nil]  
	                                          httpMethod:@"POST"];  
	      
	    [op addFile:filePath forKey:@"media" mimeType:fileType];  
	      
	    // setFreezable uploads your images after connection is restored!  
	    [op setFreezable:YES];  
	      
	    [op addCompletionHandler:^(MKNetworkOperation* completedOperation) {  
	          
	        NSString *responseString = [completedOperation responseString];  
	        NSLog(@"server response: %@",responseString);  
	    } errorHandler:^(MKNetworkOperation *errorOp, NSError* err){  
	          
	        NSLog(@"Upload file error: %@", err);  
	    }];  
	      
	    [engine enqueueOperation:op];  
	      
	    return op;  
	}  
	  
	+(void)testUpload{  
	    NSString *uploadPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SampleImage.jpg"];  
	    //    NSData *myData = [NSData dataWithContentsOfFile:uploadPath];  
	    //    NSLog(@">>>>>>>>%@",myData);  
	    MKNetworkOperation *uploadOperation = [HttpManager uploadImageFromFile:uploadPath mimeType:@"jpg"];  
	    [uploadOperation onUploadProgressChanged:^(double progress) {  
	        //        上传进度  
	        DLog(@"Upload file progress: %.2f", progress*100.0);  
	    }];  
	}  

###上传文件时服务器端程序(Node.Js): 
 
	var express = require('express')  
	    ,fs=require('fs');  
	  
	var app = module.exports = express.createServer();  
	// Configuration  
	app.configure(function(){  
	    app.use(express.bodyParser());  
	    app.use(express.methodOverride());  
	    app.use(app.router);  
	});  
	// Routes  
	app.post('/upload', function(req, res) {  
	    console.log(req);  
	    var tmp_path = req.files.media.path; // 获得文件的临时路径  
	    var target_path = './'+req.files.media.name;// 指定文件上传后的目录  
	    fs.rename(tmp_path, target_path, function(err) { // 移动文件  
	        if (err) throw err;  
	        fs.unlink(tmp_path, function() {// 删除临时文件夹文件,  
	            if (err) throw err;  
	            res.send({server:'success'});  
	            res.end();  
	        });  
	    });  
	});  
	app.listen(5558);  
	console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);  