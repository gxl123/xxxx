//
//  VideoDecoder.m
//  MySee
//
//  Created by tommy on 15/10/22.
//  Copyright (c) 2015年 ml . All rights reserved.
//

#import "VideoDecoder.h"
#import "Common.h"
//#import "avcodec.h"
//#import "swscale.h"
//
//#import "avformat.h"

@implementation VideoDecoder{
    NSConditionLock *decVideoThreadLock,*screenAccessLock;
    NSMutableArray* FrameQueue;
    AVCodecParserContext *avpcx;
    AVCodecContext *avctx;
    BOOL bStop;
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
        [self creatFile];
        decVideoThreadLock=[[NSConditionLock alloc]init];
        screenAccessLock=[[NSConditionLock alloc]init];
        FrameQueue=[[NSMutableArray alloc]init];
        //初始化解码器
        avcodec_register_all();
        //注册所有的编解码器
        avpcx = av_parser_init(AV_CODEC_ID_H264);
        //查找解码器
        AVCodec *pCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
        if (!pCodec) {
            NSLog(@"Codec not found\n");
            return nil;
        }
        //为AVCodecContext分配内存
        avctx = avcodec_alloc_context3(pCodec);
        if (!avctx){
            printf("Could not allocate video codec context\n");
            return nil;
        }
        //打开解码器。
        if (avcodec_open2(avctx, pCodec, NULL) < 0) {
            printf("Could not open codec\n");
            return nil;
        }
        //开启解码线程
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self thread_DeocdeVideo];
        });
    }
    return self;
}
-(void)deInit {
    bStop=YES;
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:4];
    [decVideoThreadLock lockBeforeDate:timeoutDate];
    [decVideoThreadLock unlock];
    avcodec_free_context(&avctx);//释放AVCodecContext
}
-(void)thread_DeocdeVideo{
    [decVideoThreadLock lock];
    NSLog(@"=== thread_DeocdeVideo start ===");
    while (!bStop) {
        NSData *h264FrameData=(NSData*)[self pop];
        if (!h264FrameData) {
            usleep(500);
            continue;
        }
        //写文件h264
//        NSFileHandle *myHandle2 = [NSFileHandle fileHandleForWritingAtPath:self.videoPath];
//        [myHandle2 seekToEndOfFile];
//        [myHandle2 writeData:h264FrameData];
//        [myHandle2 closeFile];
        
        AVPicture tPicture;
        // Allocate RGB picture
        avpicture_alloc(&tPicture, PIX_FMT_RGB24,640, 352);
        AVPacket tPacket;
        av_init_packet(&tPacket);
        tPacket.data=(uint8_t *)[h264FrameData bytes];
        tPacket.size=[h264FrameData length];
        NSLog(@"tPacket.data 1=%@",[self _getHexString:(char*)tPacket.data Size:tPacket.size]);
        int ret=[self frameDecode:(char*)&tPacket inLen:sizeof(AVPacket) outData:(char*)&tPicture outLen:sizeof(AVPicture)];
        if (ret>0){
            
            UIImage *pImg_=[self imageFromAVPicture:tPicture width:640 height:352];
            //UIImage *pImg2_=[[UIImage alloc]initWithCGImage:pImg_.CGImage];//[[UIImage alloc]initWithCIImage:pImg_];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSDate *date = [NSDate date];
            [formatter setDateFormat:@"MM-dd-kk-mm-ss"];
            NSString *videoPath_ = [self.videoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h264",[formatter stringFromDate:date]]];
            NSLog(@"%@",videoPath_);
            NSLog(@"%@",pImg_);
            [self saveImageToFile:pImg_ :videoPath_];
            dispatch_async(dispatch_get_main_queue(), ^{
 
             /*
                if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveRGBData:DataSize:)]) {
                    // GLog( tCtrl, (@"--- uid:%@ avRecvIOCtrl( %d, %d, %X, %@)", self.uid, self.sessionID, channel.avIndex, type, [self _getHexString:recvIOCtrlBuff[nIdx] Size:readSize]));
                    [self.delegate didReceiveRGBData:(char*)&tPicture DataSize:sizeof(AVPicture)];
                }*/
            });
        }
        // Release old picture
        avpicture_free(&tPicture);
    }
    [decVideoThreadLock unlock];
    NSLog(@"=== thread_DeocdeVideo end ===");
}
/**
 *@param inData 是AVPacket
 *@param inLen  是sizeof(AVPacket)
 *@param outData是AVPictrue
 *@param outLen 是sizeof(AVPicture)
 */
-(int) frameDecode:(char*)inData inLen:(int)inLen
           outData:(char*)outData outLen:(int)outLen{
    
    
    //char* yUVData=malloc(<#size_t#>)
    
    
    AVFrame *pFrame=avcodec_alloc_frame();
    int ret=[self h264ToYUV:inData inLen:inLen outData:(char*)pFrame outLen:sizeof(AVFrame)];
    

    if (ret==1) {
        //AVPicture *pPicture=outData;
        int ret2=[self yUVToRGB:(char*)pFrame inLen:sizeof(AVFrame) outData:outData outLen:outLen];
        NSLog(@"the height of the output slice=%d",ret2);
        av_frame_free(&pFrame);//释放avFrame
        return ret2;
    }
    av_frame_free(&pFrame);//释放avFrame
    return 0;
}
    
//h264->YUV(AVPacket->AVFrame)
-(int) h264ToYUV:(char*)inData inLen:(int)inLen
         outData:(char*)outData outLen:(int)outLen{

    AVFrame *tpFrame=(AVFrame*)outData;
    AVPacket *tpAVPacket=(AVPacket*)inData;
    //int parserLen;
    int got_picture_ptr=0;//0表示没有帧被解压缩、否则有
    while(inLen){
        //av_init_packet(&tAVPacket);//初始化AVCodecParserContext
        //组帧,使用AVCodecParser从输入的数据流中分离出一帧一帧的压缩编码数据。
//        parserLen =av_parser_parse2(avpcx, avctx, &tAVPacket.data, tpAVPacket->size, (const uint8_t *)inData, inLen, AV_NOPTS_VALUE, AV_NOPTS_VALUE, AV_NOPTS_VALUE);//解析获得一个Packet。
//
//        inData += parserLen;
//        inLen  -= parserLen;
        //解码
//        if(tAVPacket.size)
        NSLog(@"tPacket.data 2=%@",[self _getHexString:(char*)tpAVPacket->data Size:tpAVPacket->size]);
//        NSLog(@"%@",self->avctx);
//         NSLog(@"%@",tpFrame);
//         NSLog(@"%d",got_picture_ptr);
//         NSLog(@"%@",tpAVPacket);
        int ret= avcodec_decode_video2(avctx, tpFrame, &got_picture_ptr, tpAVPacket);
        NSLog(@"avcodec_decode_video2 ret=%d",ret);
        if (got_picture_ptr) {
            //outLen=sizeof(AVFrame);
            //memcpy(outData, picture, outLen);
            //av_frame_free(&picture);//释放avFrame
#pragma mark-- 将YUV保存为文件
//            int p,i;
//            unsigned char *DisplayBuf;
//            DisplayBuf = (unsigned char *)malloc(sizeof(unsigned char)*(3 * 1280 * 720));
//            memset(DisplayBuf,0,3 * 1280 * 720);
//            unsigned char *yuv420[3];
//            yuv420[0]=DisplayBuf;
//            //6.将picture中的YUV数据显示或者保存到文件
//            p=0;
//            for(i=0; i<avctx->height; i++)
//            {
//                memcpy(DisplayBuf+p,tpFrame->data[0] + i * tpFrame->linesize[0], avctx->width);
//                p+=avctx->width;
//            }
//            
//            yuv420[1]=DisplayBuf+p;
//            
//            for(i=0; i<avctx->height/2; i++)
//            {
//                memcpy(DisplayBuf+p,tpFrame->data[1] + i * tpFrame->linesize[1], avctx->width/2);
//                p+=avctx->width/2;
//            }
//            
//            yuv420[2]=DisplayBuf+p;
//            
//            for(i=0; i<avctx->height/2; i++)
//            {
//                memcpy(DisplayBuf+p,tpFrame->data[2] + i * tpFrame->linesize[2], avctx->width/2);
//                p+=avctx->width/2;
//            }
//            NSData *data_=[NSData dataWithBytes:DisplayBuf length:p];
//            //写文件yuv
//            NSFileHandle *myHandle2 = [NSFileHandle fileHandleForWritingAtPath:self.videoPath];
//            [myHandle2 seekToEndOfFile];
//            [myHandle2 writeData:data_];
//            [myHandle2 closeFile];
//            free(DisplayBuf);

            
            
            return 1;
        }
        else{
            break;
        }
    }
    //av_frame_free(&picture);//释放avFrame
    return 0;
}
#define MAX_IMG_BUFFER_SIZE	(1920*1080*4)
//YUV->RGB(AVFrame->AVPicture)
-(int) yUVToRGB:(char*)inData inLen:(int)inLen
         outData:(char*)outData outLen:(int)outLen{
    AVFrame *tpFrame=(AVFrame*)inData;
    AVPicture *tpPicture=(AVPicture*)outData;
    enum AVPixelFormat srcFormat=avctx->pix_fmt;//一般是PIX_FMT_YUV420P
    enum AVPixelFormat dstFormat = PIX_FMT_RGB24;//RGBA与RGB24区别是？必须用RGB24,如果用RGBA图片会出现竖条纹
    int dstW=640;//暂时固定，由UI层下发
    int dstH=352;//暂时固定，由UI层下发
    int flags=SWS_BICUBLIN;//SWS_FAST_BILINEAR;//转换算法，还有很多种都有何区别？
    
    
    CVPixelBufferPoolRef pixelBufferPool;
    CVPixelBufferRef pixelBuffer;

    NSMutableDictionary* attributes;
    attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithInt:1920] forKey: (NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithInt:1080] forKey: (NSString*)kCVPixelBufferHeightKey];
    
    CVReturn err = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef) attributes, &pixelBufferPool);
    if( err != kCVReturnSuccess ) {
       // GLog( tCtrl, ( @"onSnapshot -- pixelBufferPool create failed!" ) );
    }
    err = CVPixelBufferPoolCreatePixelBuffer (NULL, pixelBufferPool, &pixelBuffer);
    if( err != kCVReturnSuccess ) {
        //GLog( tCtrl, ( @"onSnapshot -- pixelBuffer create failed!" ) );
    }
    
    /*
    //CVPixelBufferRef pixelBuff;
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    UInt8* pData_buff = CVPixelBufferGetBaseAddress(pixelBuffer);
    AVFrame* pFrameDst=av_frame_alloc();
  //  if (pFrameDst!=NULL) {
        avpicture_fill((AVPicture*)pFrameDst, pData_buff, dstFormat, dstW, dstH);
        struct SwsContext *c=sws_getContext(avctx->width, avctx->height, srcFormat,
                                            dstW, dstH, dstFormat,
                                            flags, NULL, NULL, NULL);
        
        const uint8_t *const *srcSlice=(const uint8_t *const *)tpFrame->data;
        const int *srcStride=tpFrame->linesize;
        int srcSliceY=0;
        int srcSliceH=avctx->height;
        //uint8_t *const *dst=(uint8_t *const *)tpPicture->data;
        //const int *dstStride=tpPicture->linesize;
        
        int result=sws_scale(c, srcSlice, srcStride, srcSliceY, srcSliceH, pFrameDst->data , pFrameDst->linesize);
  //  }
 //   CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    UInt8* srcBaseAddr = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    int nDataSize = (int)CVPixelBufferGetDataSize(pixelBuffer);
    char *imageFrame = (char *) malloc(MAX_IMG_BUFFER_SIZE);
    if(nDataSize>MAX_IMG_BUFFER_SIZE)
        memcpy( imageFrame, srcBaseAddr, MAX_IMG_BUFFER_SIZE);
    else
        memcpy( imageFrame, srcBaseAddr, nDataSize);
    
    
    sws_freeContext(c);
    
    av_frame_unref(pFrameDst);
    av_frame_free(&pFrameDst);
    

    UIImage *pImg_=[self getUIImage:imageFrame Width:dstW Height:dstH];
    [self saveImageToFile:pImg_ :self.videoPath];*/
    
    struct SwsContext *c=sws_getContext(avctx->width, avctx->height, srcFormat,
                                        dstW, dstH, dstFormat,
                                        flags, NULL, NULL, NULL);
    NSLog(@"sws_getContext s_w=%d,s_h=%d,s_f=%d,d_w=%d,d_h=%d,d_f=%d",avctx->width, avctx->height, srcFormat,
          dstW, dstH, dstFormat);
    const uint8_t *const *srcSlice=(const uint8_t *const *)tpFrame->data;
    const int *srcStride=tpFrame->linesize;
    int srcSliceY=0;
    int srcSliceH=avctx->height;
    uint8_t *const *dst=(uint8_t *const *)tpPicture->data;
    const int *dstStride=tpPicture->linesize;
    
    int result=sws_scale(c, srcSlice, srcStride, srcSliceY, srcSliceH, dst, dstStride);
    
    //UIImage *pImg_=[self imageFromAVPicture:*tpPicture width:dstW height:dstH];
    //[self saveImageToFile:pImg_ :self.videoPath];
    NSLog(@"result=%d;c=%d,s1=%d,s2=%d,sY=%d,sH=%d;d1=%d,d2=%d",result,c,srcSlice,srcStride,srcSliceY, srcSliceH, dst, dstStride);
    sws_freeContext(c);
    return result;
}
- (UIImage *) getUIImage:(char *)buff Width:(NSInteger)width Height:(NSInteger)height {
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buff, width * height * 3, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(width, height, 8, 24, width * 3, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, true,  kCGRenderingIntentDefault);
    
    
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    
    
    if (imgRef != nil) {
        CGImageRelease(imgRef);
        imgRef = nil;
    }
    
    if (colorSpace != nil) {
        CGColorSpaceRelease(colorSpace);
        colorSpace = nil;
    }
    
    if (provider != nil) {
        CGDataProviderRelease(provider);
        provider = nil;
    }
    
    return [img copy];
}
- (NSString *) _getHexString:(char *)buff Size:(int)size
{
    int i = 0;
    char *ptr = buff;
    
    NSMutableString *str = [[NSMutableString alloc] init];
    while(i++ < size) [str appendFormat:@"%02X ", *ptr++ & 0x00FF];
    return str;
}
-(UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height {
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);//CGDataProviderCreateWithData(NULL, pict.data[0], width * height * 3, NULL);//
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],//-》是640*3吗？
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,//true,//
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}
- (void)saveImageToFile:(UIImage *)image :(NSString *)imgFullName {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    //NSString *imgFullName = [self pathForDocumentsResource:fileName];
    
    [imgData writeToFile:imgFullName atomically:YES];
}
//BOOL YUVtoRGB2(AVFrame * pAVFrame, int width, int height, char *filename)
//
//{
//    
//    struct SwsContext *img_convert_ctx;
//    
//    strcat(filename, ".bmp");
//    
//    AVFrame *pAVFrameRGB;
//    
//    pAVFrameRGB = avcodec_alloc_frame();
//    
//    if (pAVFrameRGB == NULL)
//        
//    {
//        
//        return FALSE;
//        
//    }
//    
//    int numBytes = avpicture_get_size(PIX_FMT_RGB24, width, height);
//    
//    
//    NSMutableDictionary* attributes;
//    attributes = [NSMutableDictionary dictionary];
//    [attributes setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
//    [attributes setObject:[NSNumber numberWithInt:pScreenBmpStore->nWidth] forKey: (NSString*)kCVPixelBufferWidthKey];
//    [attributes setObject:[NSNumber numberWithInt:pScreenBmpStore->nHeight] forKey: (NSString*)kCVPixelBufferHeightKey];
//    
//    CVReturn err = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef) attributes, &mPixelBufferPool);
//    if( err != kCVReturnSuccess ) {
//        NSLog( @"mPixelBufferPool create failed!" );
//    }
//    err = CVPixelBufferPoolCreatePixelBuffer (NULL, mPixelBufferPool, &mPixelBuffer);
//    if( err != kCVReturnSuccess ) {
//        NSLog( @"mPixelBuffer create failed!" );
//    }
//    mSizePixelBuffer = CGSizeMake(pScreenBmpStore->nWidth, pScreenBmpStore->nHeight);
//    NSLog( @"CameraLiveViewController - mPixelBuffer created %dx%d nBytes_per_Row:%d", pScreenBmpStore->nWidth, pScreenBmpStore->nHeight, pScreenBmpStore->nBytes_per_Row );
//    
//    uint8_t  *buffer = (UINT8 *)av_malloc(numBytes*sizeof(uint8_t));
//    
//    
//    
//    avpicture_fill((AVPicture*)pAVFrameRGB, buffer, PIX_FMT_RGB24, width, height);//为已经分配的数据结构AVPicture挂上一段用于保存数据的空间
//    
//    
//    
//    img_convert_ctx = sws_getContext(
//                                     
//                                     width, height, PIX_FMT_YUVJ420P, width, height, PIX_FMT_RGB24,
//                                     
//                                     SWS_BICUBIC, NULL, NULL, NULL);
//    
//    sws_scale(img_convert_ctx, pAVFrame->data, pAVFrame->linesize,
//              
//              0, height, pAVFrameRGB->data, pAVFrameRGB->linesize);
//    
//    sws_freeContext(img_convert_ctx);
//    
//    av_free(buffer);
//    
//    
//    
//    DWORD w = width;
//    
//    DWORD h = height;
//    
//    DWORD BufferLen = WIDTHBYTES(w*24)*h;
//    
//    BYTE *pBuffer = new BYTE[BufferLen];
//    
//    memset(pBuffer, 0 , BufferLen);
//    
//    
//    
//    for (int i=0; i<height; i++)
//        
//    {
//        
//        //将图像转为bmp存到内存中,这里的图像是倒立的
//        
//        memcpy(pBuffer +(WIDTHBYTES(w*24)*i),pAVFrameRGB->data[0]+i*pAVFrameRGB->linesize[0],width*3);
//        
//    }
//    
//    
//    
//    LPBYTE pbmp = new BYTE[sizeof(BITMAPFILEHEADER) + sizeof(BITMAPFILEHEADER)+BufferLen];
//    
//    
//    
//    BITMAPFILEHEADER bitmapfileheader; memset( &bitmapfileheader, 0, sizeof( BITMAPFILEHEADER ) );
//    
//    bitmapfileheader.bfType = 'MB';
//    
//    bitmapfileheader.bfSize = sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER)+BufferLen ;
//    
//    bitmapfileheader.bfOffBits = sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER);
//    
//    memcpy(pbmp,&bitmapfileheader,sizeof(BITMAPFILEHEADER));
//    
//    
//    
//    BITMAPINFOHEADER fmtFrame; memset(&fmtFrame, 0, sizeof(fmtFrame));
//    
//    fmtFrame.biSize = sizeof(fmtFrame);
//    
//    fmtFrame.biPlanes  = 1;
//    
//    fmtFrame.biBitCount = 24;
//    
//    fmtFrame.biWidth =   w;
//    
//    fmtFrame.biHeight =  -h;//注意，这里的bmpinfo.bmiHeader.biHeight变量的正负决定bmp文件的存储方式，如果为负值，表示像素是倒过来的*/
//    
//    fmtFrame.biSizeImage = BufferLen;
//    
//    memcpy(pbmp+sizeof(BITMAPFILEHEADER),&fmtFrame,sizeof(BITMAPINFOHEADER));
//    
//    memcpy(pbmp+sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER),pBuffer, BufferLen);
//    
//    
//    
//    FILE * f = fopen(filename,"w+b");
//    
//    fwrite(pbmp,1,sizeof(BITMAPFILEHEADER)+sizeof(fmtFrame)+BufferLen, f );
//    
//    fclose(f) ; 
//    
//    
//    
//    delete [] pbmp; pbmp = NULL;
//    
//    delete [] pBuffer; pBuffer = NULL; 
//    
//    return TRUE;
//    
//}

//- (CVPixelBufferRef)createPixelBuffer:(FourCharCode)aFmtTypeKey width:(int)aWidth height:(int)aHeight
//{
//    if(mPixelBuffer) {
//        CVPixelBufferRelease(mPixelBuffer);
//        CVPixelBufferPoolRelease(mPixelBufferPool);
//        mPixelBuffer = nil;
//        mPixelBufferPool = nil;
//    }
//    
//    NSMutableDictionary* attributes;
//    attributes = [NSMutableDictionary dictionary];
//    [attributes setObject:[NSNumber numberWithInt:aFmtTypeKey] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
//    [attributes setObject:[NSNumber numberWithInt:aWidth] forKey: (NSString*)kCVPixelBufferWidthKey];
//    [attributes setObject:[NSNumber numberWithInt:aHeight] forKey: (NSString*)kCVPixelBufferHeightKey];
//    [attributes setObject:[NSDictionary dictionary] forKey: (NSString*)kCVPixelBufferIOSurfacePropertiesKey];
//    [attributes setObject:[NSNumber numberWithBool:YES] forKey: (NSString*)kCVPixelBufferOpenGLESCompatibilityKey];
//    
//    CVReturn err = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef) attributes, &mPixelBufferPool);
//    if( err != kCVReturnSuccess ) {
//        GLog( tAll, ( @"mPixelBufferPool create failed!" ) );
//        return nil;
//    }
//    err = CVPixelBufferPoolCreatePixelBuffer (NULL, mPixelBufferPool, &mPixelBuffer);
//    if( err != kCVReturnSuccess ) {
//        GLog( tAll, ( @"mPixelBuffer create failed!" ) );
//        
//        CVPixelBufferPoolRelease(mPixelBufferPool);
//        mPixelBufferPool = nil;
//        return nil;
//    }
//    
//    GLog( tCtrl, (@"channel createPixelBuffer - mPixelBuffer created %dx%d bIsPlanar:%@ DataSize:%d bytes", aWidth, aHeight, (CVPixelBufferIsPlanar(mPixelBuffer)?@"YES":@"NO"), (int)CVPixelBufferGetDataSize(mPixelBuffer) ) );
//    
//    return mPixelBuffer;
//}
//
//- (void)releaseVideoBuffer
//{
//    if(mPixelBuffer) {
//        CVPixelBufferRelease(mPixelBuffer);
//        CVPixelBufferPoolRelease(mPixelBufferPool);
//        mPixelBuffer = nil;
//        mPixelBufferPool = nil;
//    }
//}

-(void)push:(NSObject *)obj
{
    [FrameQueue addObject:obj];
}
-(NSObject *)pop
{
    NSObject *ret=[FrameQueue lastObject];
    if(ret){
        ret=[ret copy];
        [FrameQueue removeLastObject];
    }
    return ret;
}

- (void)creatFile {
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *videoPath_ = [documentsDirectory stringByAppendingPathComponent:@"/video"];
    //NSString *sourcePath_ = [videoPath_ stringByAppendingString:[NSString stringWithFormat:@"/%@",@"Recorder"]];
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath_]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:videoPath_ withIntermediateDirectories:NO attributes:nil error:&error];
//    }
//    if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath_]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:sourcePath_ withIntermediateDirectories:NO attributes:nil error:&error];
//    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    [formatter setDateFormat:@"MM-dd-kk-mm-ss"];
    
    NSString *directory_ = @"/video";
    NSString *dataPath_ = [documentsDirectory stringByAppendingPathComponent:directory_];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath_]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath_ withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
//    NSString *videoPath_ = [dataPath_ stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h264",[formatter stringFromDate:date]]];
    self.videoPath = videoPath_;
//    NSString *mixPath_ = [dataPath_ stringByAppendingPathComponent:@"ace.raw"];
//    self.mixPath = mixPath_;
//    NSString *refPath_ = [dataPath_ stringByAppendingPathComponent:@"ref.raw"];
//    self.refPath = refPath_;
    
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:self.videoPath] != YES)
    {
        [filemgr createFileAtPath:self.videoPath contents:nil attributes:nil];
    }
//    if ([filemgr fileExistsAtPath:self.mixPath] != YES)
//    {
//        [filemgr createFileAtPath:self.mixPath contents:nil attributes:nil];
//    }
//    if ([filemgr fileExistsAtPath:self.refPath] != YES)
//    {
//        [filemgr createFileAtPath:self.refPath contents:nil attributes:nil];
//    }
    
    
}
@end
