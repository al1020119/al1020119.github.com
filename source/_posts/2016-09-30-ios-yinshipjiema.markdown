---
layout: post
title: "音视频编解码技术"
date: 2016-09-30 18:16:05 +0800
comments: true
categories: 
--- 

####目录

1. 音频编解码：AudioToolbox
2. 视频编解码：VideoToolbox
3. 总结


#视频编解码：VideoToolbox
 

###关于H264

H.264是目前很流行的编码层视频压缩格式，目前项目中的协议层有rtmp与http，但是视频的编码层都是使用的H.264。
在熟悉H.264的过程中，为更好的了解H.264，尝试用VideoToolbox硬编码与硬解码H.264的原始码流。


###H.264组成

    1、网络提取层 (Network Abstraction Layer，NAL)
    2、视讯编码层 (Video Coding Layer，VCL)



<!--more-->


H.264由视讯编码层(Video Coding Layer，VCL)与网络提取层(Network Abstraction Layer，NAL)组成。
H.264包含一个内建的NAL网络协议适应层，藉由NAL来提供网络的状态，让VCL有更好的编译码弹性与纠错能力。



###视频相关的框架

    AVKit
    AVFoundation
    Video Toolbox
    Core Media
    Core Video

其中的AVKit和AVFoudation、VideoToolbox都是使用硬编码和硬解码。


###VideoToolbox

VideoToolbox是iOS8以后开放的硬编码与硬解码的API，一组用C语言写的函数。使用流程如下：

    1、-initVideoToolBox中调用VTCompressionSessionCreate创建编码session，然后调用VTSessionSetProperty设置参数，最后调用VTCompressionSessionPrepareToEncodeFrames开始编码；
    2、开始视频录制，获取到摄像头的视频帧，传入-encode:，调用VTCompressionSessionEncodeFrame传入需要编码的视频帧，如果返回失败，调用VTCompressionSessionInvalidate销毁session，然后释放session；
    3、每一帧视频编码完成后会调用预先设置的编码函数didCompressH264，如果是关键帧需要用CMSampleBufferGetFormatDescription获取CMFormatDescriptionRef，然后用
    CMVideoFormatDescriptionGetH264ParameterSetAtIndex取得PPS和SPS；
    最后把每一帧的所有NALU数据前四个字节变成0x00 00 00 01之后再写入文件；
    4、调用VTCompressionSessionCompleteFrames完成编码，然后销毁session：VTCompressionSessionInvalidate，释放session。

##VideoToolbox编码H264实现

创建session

         int width = 480, height = 640;
         OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self),  &EncodingSession);

设置session属性

         // 设置实时编码输出（避免延迟）
         VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
         VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
         // 设置关键帧（GOPsize)间隔
         int frameInterval = 10;
         CFNumberRef  frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
         VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
         // 设置期望帧率
         int fps = 10;
         CFNumberRef  fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
         VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef); 
         //设置码率，上限，单位是bps
         int bitRate = width * height * 3 * 4 * 8;
         CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
         VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
         //设置码率，均值，单位是byte
         int bitRateLimit = width * height * 3 * 4;
         CFNumberRef bitRateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRateLimit);
         VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimitRef);

传入编码帧

     CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
     // 帧时间，如果不设置会导致时间轴过长。
     CMTime presentationTimeStamp = CMTimeMake(frameID++, 1000);
     VTEncodeInfoFlags flags;
     OSStatus statusCode = VTCompressionSessionEncodeFrame(EncodingSession,
                                                           imageBuffer,
                                                           presentationTimeStamp,
                                                           kCMTimeInvalid,
                                                           NULL, NULL, &flags);

关键帧获取SPS和PPS

     bool keyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
     // 判断当前帧是否为关键帧
     // 获取sps & pps数据
     if (keyframe)
     {
         CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
         size_t sparameterSetSize, sparameterSetCount;
         const uint8_t *sparameterSet;
         OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
         if (statusCode == noErr)
         {
             // Found sps and now check for pps
             size_t pparameterSetSize, pparameterSetCount;
             const uint8_t *pparameterSet;
             OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
             if (statusCode == noErr)
             {
                 // Found pps
                 NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                 NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                 if (encoder)
                 {
                     [encoder gotSpsPps:sps pps:pps];
                 }
             }
         }
     }

写入数据

     CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
     size_t length, totalLength;
     char *dataPointer;
     OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
     if (statusCodeRet == noErr) {
         size_t bufferOffset = 0;
         static const int AVCCHeaderLength = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length

         // 循环获取nalu数据
         while (bufferOffset < totalLength - AVCCHeaderLength) {
             uint32_t NALUnitLength = 0;
             // Read the NAL unit length
             memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);

             // 从大端转系统端
             NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);

             NSData* data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
             [encoder gotEncodedData:data isKeyFrame:keyframe];

             // Move to the next NAL unit in the block buffer
             bufferOffset += AVCCHeaderLength + NALUnitLength;
         }
     }



##VideoToolbox解码码H264实现

核心思路

用NSInputStream读入原始H.264码流，用CADisplayLink控制显示速率，用NALU的前四个字节识别SPS和PPS并存储，当读入IDR帧的时候初始化VideoToolbox，并开始同步解码；解码得到的CVPixelBufferRef会传入OpenGL ES类进行解析渲染。
具体细节
1、把原始码流包装成CMSampleBuffer

1、替换头字节长度；

             uint32_t nalSize = (uint32_t)(packetSize - 4);
             uint32_t *pNalSize = (uint32_t *)packetBuffer;
             *pNalSize = CFSwapInt32HostToBig(nalSize);

2、用CMBlockBuffer把NALUnit包装起来；

         CMBlockBufferRef blockBuffer = NULL;
         OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                               (void*)packetBuffer, packetSize,
                                                               kCFAllocatorNull,
                                                               NULL, 0, packetSize,
                                                               0, &blockBuffer);

3、把SPS和PPS包装成CMVideoFormatDescription；

         const uint8_t* parameterSetPointers[2] = {mSPS, mPPS};
         const size_t parameterSetSizes[2] = {mSPSSize, mPPSSize};
         OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
			                                                                               2, //param count
			                                                                               parameterSetPointers,
			                                                                               parameterSetSizes,
			                                                                               4, //nal start code size
			                                                                               &mFormatDescription);

4、添加CMTime时间；

        （WWDC视频上说有，但是我在实现过程没有找到添加的地方，可能是我遗漏了）

5、创建CMSampleBuffer；

             CMSampleBufferRef sampleBuffer = NULL;
             const size_t sampleSizeArray[] = {packetSize};
             status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                                blockBuffer,
                                                mFormatDescription,
                                                1, 0, NULL, 1, sampleSizeArray,
                                                &sampleBuffer);

2、解码并显示

1、传入CMSampleBuffer

                 VTDecodeFrameFlags flags = 0;
                 VTDecodeInfoFlags flagOut = 0;
                 // 默认是同步操作。
                 // 调用didDecompress，返回后再回调
                 OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(mDecodeSession,
                                                                           sampleBuffer,
                                                                           flags,
                                                                           &outputPixelBuffer,
                                                                           &flagOut);

2、回调didDecompress

    void didDecompress(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
     CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
     *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
    }

3、显示解码的结果

    [self.mOpenGLView displayPixelBuffer:pixelBuffer];

仔细对比硬编码和硬解码的图像，会发现硬编码的图像被水平镜像过。

    当遇到IDR帧时，更合适的做法是通过
    VTDecompressionSessionCanAcceptFormatDescription判断原来的session是否能接受新的SPS和PPS，如果不能再新建session。




#音频编解码：AudioToolbox

###AAC高级音频编码

AAC（Advanced Audio Coding），中文名：高级音频编码，出现于1997年，基于MPEG-2的音频编码技术。由Fraunhofer IIS、杜比实验室、AT&T、Sony等公司共同开发，目的是取代MP3格式。

AAC音频格式有ADIF和ADTS：

    ADIF：Audio Data Interchange Format 音频数据交换格式。这种格式的特征是可以确定的找到这个音频数据的开始，不需进行在音频数据流中间开始的解码，即它的解码必须在明确定义的开始处进行。故这种格式常用在磁盘文件中。
    ADTS：Audio Data Transport Stream 音频数据传输流。这种格式的特征是它是一个有同步字的比特流，解码可以在这个流中任何位置开始。它的特征类似于mp3数据流格式。

###AudioToolbox

AudioToolbox这个库是C的接口，偏向于底层，用于在线流媒体音乐的播放，可以调用该库的相关接口自己封装一个在线播放器类，AudioStreamer是老外封装的一个播放器类


        •   数据类型  
    1.AudioFileStreamID             文件流  
    2.AudioQueueRef                     播放队列   
    3.AudioStreamBasicDescription   格式化音频数据  
    4.AudioQueueBufferRef             数据缓冲  
      
        •   回调函数  
    1.AudioFileStream_PacketsProc       解析音频数据回调  
    2.AudioSessionInterruptionListener  音频会话被打断  
    3.AudioQueueOutputCallback          一个AudioQueueBufferRef播放完  
      
        •   主要函数  
    0.AudioSessionInitialize (NULL, NULL, AudioSessionInterruptionListener, self);  
    初始化音频会话  
      
    1.AudioFileStreamOpen(  
                            (void*)self,                            
                            &AudioFileStreamPropertyListenerProc,   
                            &AudioFileStreamPacketsProc,            
                            0,                                      
                            &audio_file_stream);              
    建立一个文件流AudioFileStreamID，传输解析的数据  
      
    2.AudioFileStreamParseBytes(  
                              audio_file_stream,  
                              datalen,  
                              [data bytes],  
                              kAudioFileStreamProperty_FileFormat);   
    解析音频数据  
      
    3.AudioQueueNewOutput(&audio_format, AudioQueueOutputCallback, (void*)self, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopCommonModes, 0, &audio_queue);  
    创建音频队列AudioQueueRef  
      
    4.AudioQueueAllocateBuffer(queue, [data length], &buffer);  
    创建音频缓冲数据AudioQueueBufferRef  
      
    5.AudioQueueEnqueueBuffer(queue, buffer, num_packets, packet_descriptions);  
    把缓冲数据排队加入到AudioQueueRef等待播放  
      
    6.AudioQueueStart(audio_queue, nil);    播放  
    7.AudioQueueStop(audio_queue, true);  
     AudioQueuePause(audio_queue);          停止、暂停  
      
        •   断点续传  
    1。在http请求头中设置数据的请求范围，请求头中都是key-value成对  
        key：Range           value:bytes=0-1000  
        [request setValue:range  forHTTPHeaderField:@"Range"];  
    可以实现，a.网络断开后再连接能继续从原来的断点下载  
                b.可以实现播放进度可随便拉动  


###编码实现

iOS上把PCM音频编码成AAC音频流

    1、设置编码器（codec），并开始录制；
    2、收集到PCM数据，传给编码器；
    3、编码完成回调callback，写入文件。

具体步骤
1、创建并配置AVCaptureSession

创建AVCaptureSession，然后找到音频的AVCaptureDevice，根据音频device创建输入并添加到session，最后添加output到session。

audioFileHandle是NSFileHandle，用户写入编码后的AAC音频到文件。
demo中，此段代码还包括Video的设置。为了缩短篇幅，去掉了video相关的配置。

	- (void)startCapture {
	    self.mCaptureSession = [[AVCaptureSession alloc] init];
	    mCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	    mEncodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] lastObject];
	    self.mCaptureAudioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
	    if ([self.mCaptureSession canAddInput:self.mCaptureAudioDeviceInput]) {
	        [self.mCaptureSession addInput:self.mCaptureAudioDeviceInput];
	    }
	    self.mCaptureAudioOutput = [[AVCaptureAudioDataOutput alloc] init];
	
	    if ([self.mCaptureSession canAddOutput:self.mCaptureAudioOutput]) {
	        [self.mCaptureSession addOutput:self.mCaptureAudioOutput];
	    }
	    [self.mCaptureAudioOutput setSampleBufferDelegate:self queue:mCaptureQueue];
	
	    NSString *audioFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"abc.aac"];
	    [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
	    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
	    audioFileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
	
	    [self.mCaptureSession startRunning];
	}

2、创建转换器

AudioStreamBasicDescription是输出流的结构体描述，
配置好outAudioStreamBasicDescription后，
根据AudioClassDescription（编码器），
调用AudioConverterNewSpecific创建转换器。

	/**
	 *  设置编码参数
	 *
	 *  @param sampleBuffer 音频
	 */
	- (void) setupEncoderFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	    AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
	
	    AudioStreamBasicDescription outAudioStreamBasicDescription = {0}; // 初始化输出流的结构体描述为0. 很重要。
	    outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate; // 音频流，在正常播放情况下的帧率。如果是压缩的格式，这个属性表示解压缩后的帧率。帧率不能为0。
	    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC; // 设置编码格式
	    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC; // 无损编码 ，0表示没有
	    outAudioStreamBasicDescription.mBytesPerPacket = 0; // 每一个packet的音频数据大小。如果的动态大小，设置为0。动态大小的格式，需要用AudioStreamPacketDescription 来确定每个packet的大小。
	    outAudioStreamBasicDescription.mFramesPerPacket = 1024; // 每个packet的帧数。如果是未压缩的音频数据，值是1。动态帧率格式，这个值是一个较大的固定数字，比如说AAC的1024。如果是动态大小帧数（比如Ogg格式）设置为0。
	    outAudioStreamBasicDescription.mBytesPerFrame = 0; //  每帧的大小。每一帧的起始点到下一帧的起始点。如果是压缩格式，设置为0 。
	    outAudioStreamBasicDescription.mChannelsPerFrame = 1; // 声道数
	    outAudioStreamBasicDescription.mBitsPerChannel = 0; // 压缩格式设置为0
	    outAudioStreamBasicDescription.mReserved = 0; // 8字节对齐，填0.
	    AudioClassDescription *description = [self
	                                          getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC
	                                          fromManufacturer:kAppleSoftwareAudioCodecManufacturer]; //软编
	
	    OSStatus status = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, description, &_audioConverter); // 创建转换器
	    if (status != 0) {
	        NSLog(@"setup converter: %d", (int)status);
	    }
	}

获取编码器的方法

	/**
	 *  获取编解码器
	 *
	 *  @param type         编码格式
	 *  @param manufacturer 软/硬编
	 *
	 编解码器（codec）指的是一个能够对一个信号或者一个数据流进行变换的设备或者程序。这里指的变换既包括将 信号或者数据流进行编码（通常是为了传输、存储或者加密）或者提取得到一个编码流的操作，也包括为了观察或者处理从这个编码流中恢复适合观察或操作的形式的操作。编解码器经常用在视频会议和流媒体等应用中。
	 *  @return 指定编码器
	 */
	- (AudioClassDescription *)getAudioClassDescriptionWithType:(UInt32)type
	                                           fromManufacturer:(UInt32)manufacturer
	{
	    static AudioClassDescription desc;
	
	    UInt32 encoderSpecifier = type;
	    OSStatus st;
	
	    UInt32 size;
	    st = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
	                                    sizeof(encoderSpecifier),
	                                    &encoderSpecifier,
	                                    &size);
	    if (st) {
	        NSLog(@"error getting audio format propery info: %d", (int)(st));
	        return nil;
	    }
	
	    unsigned int count = size / sizeof(AudioClassDescription);
	    AudioClassDescription descriptions[count];
	    st = AudioFormatGetProperty(kAudioFormatProperty_Encoders,
	                                sizeof(encoderSpecifier),
	                                &encoderSpecifier,
	                                &size,
	                                descriptions);
	    if (st) {
	        NSLog(@"error getting audio format propery: %d", (int)(st));
	        return nil;
	    }
	
	    for (unsigned int i = 0; i < count; i++) {
	        if ((type == descriptions[i].mSubType) &&
	            (manufacturer == descriptions[i].mManufacturer)) {
	            memcpy(&desc, &(descriptions[i]), sizeof(desc));
	            return &desc;
	        }
	    }
	
	    return nil;
	}

3、获取到PCM数据并传入编码器

用CMSampleBufferGetDataBuffer获取到CMSampleBufferRef里面的CMBlockBufferRef，再通过CMBlockBufferGetDataPointer获取到_pcmBufferSize和_pcmBuffer；
调用AudioConverterFillComplexBuffer传入数据，并在callBack函数调用填充buffer的方法。

        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &_pcmBufferSize, &_pcmBuffer);
        NSError *error = nil;
        if (status != kCMBlockBufferNoErr) {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        memset(_aacBuffer, 0, _aacBufferSize);

        AudioBufferList outAudioBufferList = {0};
        outAudioBufferList.mNumberBuffers = 1;
        outAudioBufferList.mBuffers[0].mNumberChannels = 1;
        outAudioBufferList.mBuffers[0].mDataByteSize = (int)_aacBufferSize;
        outAudioBufferList.mBuffers[0].mData = _aacBuffer;
        AudioStreamPacketDescription *outPacketDescription = NULL;
        UInt32 ioOutputDataPacketSize = 1;
        // Converts data supplied by an input callback function, supporting non-interleaved and packetized formats.
        // Produces a buffer list of output data from an AudioConverter. The supplied input callback function is called whenever necessary.
        status = AudioConverterFillComplexBuffer(_audioConverter, inInputDataProc, (__bridge void *)(self), &ioOutputDataPacketSize, &outAudioBufferList, outPacketDescription);

Callback函数

	/**
	 *  A callback function that supplies audio data to convert. This callback is invoked repeatedly as the converter is ready for new input data.
	
	 */
	OSStatus inInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
	{
	    AACEncoder *encoder = (__bridge AACEncoder *)(inUserData);
	    UInt32 requestedPackets = *ioNumberDataPackets;
	
	    size_t copiedSamples = [encoder copyPCMSamplesIntoBuffer:ioData];
	    if (copiedSamples < requestedPackets) {
	        //PCM 缓冲区还没满
	        *ioNumberDataPackets = 0;
	        return -1;
	    }
	    *ioNumberDataPackets = 1;
	
	    return noErr;
	}
	
	/**
	 *  填充PCM到缓冲区
	 */
	- (size_t) copyPCMSamplesIntoBuffer:(AudioBufferList*)ioData {
	    size_t originalBufferSize = _pcmBufferSize;
	    if (!originalBufferSize) {
	        return 0;
	    }
	    ioData->mBuffers[0].mData = _pcmBuffer;
	    ioData->mBuffers[0].mDataByteSize = (int)_pcmBufferSize;
	    _pcmBuffer = NULL;
	    _pcmBufferSize = 0;
	    return originalBufferSize;
	}

4、得到rawAAC码流，添加ADTS头，并写入文件

AudioConverterFillComplexBuffer返回的是AAC原始码流，需要在AAC每帧添加ADTS头，调用adtsDataForPacketLength方法生成，最后把数据写入audioFileHandle的文件。

        if (status == 0) {
            NSData *rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
            NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
            [fullData appendData:rawAAC];
            data = fullData;
        } else {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        if (completionBlock) {
            dispatch_async(_callbackQueue, ^{
                completionBlock(data, error);
            });
        }

网上的ADTS头生成方法

	/**
	 *  Add ADTS header at the beginning of each and every AAC packet.
	 *  This is needed as MediaCodec encoder generates a packet of raw
	 *  AAC data.
	 *
	 *  Note the packetLen must count in the ADTS header itself.
	 *  See: http://wiki.multimedia.cx/index.php?title=ADTS
	 *  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
	 **/
	- (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength {
	    int adtsLength = 7;
	    char *packet = malloc(sizeof(char) * adtsLength);
	    // Variables Recycled by addADTStoPacket
	    int profile = 2;  //AAC LC
	    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
	    int freqIdx = 4;  //44.1KHz
	    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
	    NSUInteger fullLength = adtsLength + packetLength;
	    // fill in ADTS data
	    packet[0] = (char)0xFF; // 11111111     = syncword
	    packet[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
	    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
	    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
	    packet[4] = (char)((fullLength&0x7FF) >> 3);
	    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
	    packet[6] = (char)0xFC;
	    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
	    return data;
	}

###播放ACC

在iOS设备上播放音频，可以使用AVAudioPlayer（AVFoundation框架内），但是不支持流式播放。

本文尝试两种播放方式：

    使用AudioServicesPlaySystemSound（音频小于等于30s）；
    使用Audio Queue Services音频队列；
1、使用AudioServicesPlaySystemSound

	AudioServicesCreateSystemSoundID创建系统声音
	AudioServicesAddSystemSoundCompletion设置回调
	AudioServicesPlaySystemSound开始播放
	
	- (void)onClick:(UIButton *)button {
	    [self.mButton setHidden:YES];
	    NSURL *audioURL=[[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"aac"];
	    SystemSoundID soundID;
	    //Creates a system sound object.
	    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioURL), &soundID);
	    //Registers a callback function that is invoked when a specified system sound finishes playing.
	    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, &playCallback, (__bridge void * _Nullable)(self));
	    //    AudioServicesPlayAlertSound(soundID);
	    AudioServicesPlaySystemSound(soundID);
	}
	- (void)onPlayCallback {
	    [self.mButton setHidden:NO];
	}

以下是API的限制

        No longer than 30 seconds in duration
        In linear PCM or IMA4 (IMA/ADPCM) format
        Packaged in a .caf, .aif, or .wav file

    虽然AAC音频不在支持列表里面，但是经过测试，播放是可以的。

2、使用Audio Queue Services音频队列

Audio Queue Services的播放步骤如下：

    1，给buffer填充数据，并把buffer放入就绪的buffer queue；
    2，应用通知队列开始播放；
    3、队列播放第一个填充的buffer；
    4、队列返回已经播放完毕的buffer，并开始播放下面一个填充好的buffer；
    5、队列调用之前设置的回调函数，填充播放完毕的buffer；
    6、回调函数中把buffer填充完毕，并放入buffer queue中。


######遇到的问题

问题1：malloc错误

    malloc: *** error for object 0x154e58498: incorrect checksum for freed object - object was probably modified after being freed.
    Set a breakpoint in malloc_error_break to debug.

问题2：selector调用错误

    Method cache corrupted. This may be a message to an invalid object, or a memory error somewhere else.
    objc[12730]: receiver 0x13fe1d4f0, SEL 0x10004e2d8, isa 0x100051828, cache 0x100051838, buckets 0x13fd86650, mask 0x7, occupied 0x1
    objc[12730]: receiver 112 bytes, buckets 128 bytes
    objc[12730]: selector 'fillBuffer:'
    objc[12730]: isa 'AACPlayer'
    objc[12730]: Method cache corrupted.

这两个问题是出现在AudioQueueAllocateBuffer方法和fillBuffer的调用，而且是时而正常，时而崩溃。
先查看参数是否正确，通过xcode的debug工具，我们可以看到以下的数据：

	(AudioStreamBasicDescription) $0 = {
	  mSampleRate = 44100
	  mFormatID = 1633772320
	  mFormatFlags = 0
	  mBytesPerPacket = 0
	  mFramesPerPacket = 1024
	  mBytesPerFrame = 0
	  mChannelsPerFrame = 1
	  mBitsPerChannel = 0
	  mReserved = 0
	}
	maxSize = 768
	packetNums = 85
	(mStartOffset = 0, mVariableFramesInPacket = 0, mDataByteSize = 23)

AudioStreamBasicDescription的参数很熟悉，因为就是我们上一篇的编码所设置的参数。
AudioQueueAllocateBuffer的参数audioQueue、buffer_size、audioBuffers都很正常，暂时排除存在问题的可能性。

	fillBuffer方法中，有AudioFileReadPackets和AudioQueueEnqueueBuffer两个方法。AudioQueueEnqueueBuffer是把buffer放入到AudioQueue，参数检查没有问题。初步判断是AudioFileReadPackets存在问题。
通过多次调试，发现AudioFileReadPackets在偶然情况下回返回-60的情况，这时会导致崩溃。
通过google查到-60对应的是kAudioFilePositionError，回来检查AudioFileReadPackets的参数，发现参数没有初始化，每次调用的参数都不同。
查API文档知道AudioFileReadPackets的参数除了audioFileID和cache、packet长度，均为传入参数，参数是否初始化并不会影响。至此，fillBuffer方法的线索断了。
回顾了一下整体的流程，决定从malloc错误入手，在so上找到以下解释。

        you are freeing an object twice,
        you are freeing a pointer that was never allocated
        you are writing through an invalid pointer which previously pointed to an object which was already freed

内存访问越界，怎么会和selector调用错误扯上关系？百思不得其解。

最后，几经波折终于找到罪魁祸首。就是以下这行代码：

	audioStreamPacketDescrption = malloc(sizeof(audioStreamPacketDescrption) * packetNums);

当我打过一次audioStreamPacketDescrption，再打AudioStreamPacketDescrption的时候，Xcode会自动索引为audioStreamPacketDescrption，导致sizeof会计算出不同的大小。

    PS：按理说对一个结构体的类和结构体的实例进行sizeof，应该是一样的大小（不算动态分配）。
    这个并没有错，可是为了方便我把audioStreamPacketDescrption定义成指针了！

两个教训：

	1、不要起和类名一样的变量；
	2、指针和实例的区别要从名字即可分清；


##总结

######合并H264+ACC=MP4：

	ffmpeg -i abc.h264 -i abc.aac -vcodec copy -f mp4 abc.mp4
	

######点播的核心思路：[实现地址](http://www.jianshu.com/p/39a1a8e78675)

	用FFmpeg把H.264和AAC码流封装成mp4格式再打包成TS流，把生成的ts和m3u8文件放到Nginx的服务器目录下，用Safari访问对应的m3u8文件实现HLS的点播。
	安装Homebrow->安装Nginx->安装FFmpeg->打包ts流并放入服务器==>直播和推流
	
######推流的核心思路:[实现地址](http://www.jianshu.com/p/ba5045da282c)(LFLiveKit)

	配置Nginx以支持HLS的推流与拉流，iOS系统使用LFLiveKit推流，OS X系统使用FFmpeg推流，拉流端可以使用Safari浏览器或者VLC播放器。

	配置Nginx，支持http协议拉流->配置Nginx，支持rtmp协议推流->重启Nginx->OS X系统推流->iOS系统推流->Safari浏览器拉流->VLC播放器拉流
	
######相关常识

+ 采集视频源和音频源的数据，视频采用H264编码，音频采用AAC编码
+ 视频和音频数据使用FFmpeg封装为MPEG-TS包和MP4文件
+ 使用FFmpeg推流(LFLiveKit)
+ 使用拉流ijkPlayer






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