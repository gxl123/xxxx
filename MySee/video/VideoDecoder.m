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
    NSConditionLock *decVideoThreadLock;
    NSMutableArray* FrameQueue;
    AVCodecParserContext *avpcx;
    AVCodecContext *avctx;
    BOOL bStop;
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
        decVideoThreadLock=[[NSConditionLock alloc]init];
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
        AVPicture tPicture;
        avpicture_alloc(&tPicture, PIX_FMT_RGB24,640, 352);
        AVPacket tPacket;
        av_init_packet(&tPacket);
        tPacket.data=(uint8_t *)[h264FrameData bytes];
        tPacket.size=[h264FrameData length];
        NSLog(@"tPacket.data 1=%@",[self _getHexString:(char*)tPacket.data Size:tPacket.size]);
        int ret=[self frameDecode:(char*)&tPacket inLen:sizeof(AVPacket) outData:(char*)&tPicture outLen:sizeof(AVPicture)];
        if (ret>0){
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveRGBData:DataSize:)]) {
                // GLog( tCtrl, (@"--- uid:%@ avRecvIOCtrl( %d, %d, %X, %@)", self.uid, self.sessionID, channel.avIndex, type, [self _getHexString:recvIOCtrlBuff[nIdx] Size:readSize]));
                [self.delegate didReceiveRGBData:(char*)&tPicture DataSize:sizeof(AVPicture)];
            }
        }
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
            return 1;
        }
        else{
            break;
        }
    }
    //av_frame_free(&picture);//释放avFrame
    return 0;
}
//YUV->RGB(AVFrame->AVPicture)
-(int) yUVToRGB:(char*)inData inLen:(int)inLen
         outData:(char*)outData outLen:(int)outLen{
    AVFrame *tpFrame=(AVFrame*)inData;
    AVPicture *tpPicture=(AVPicture*)outData;
    enum AVPixelFormat srcFormat=avctx->pix_fmt;//一般是PIX_FMT_YUV420P
    enum AVPixelFormat dstFormat = PIX_FMT_RGBA;//RGBA与RGB24区别是？
    int dstW=640;//暂时固定，由UI层下发
    int dstH=352;//暂时固定，由UI层下发
    int flags=SWS_FAST_BILINEAR;//转换算法，还有很多种都有何区别？
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
    NSLog(@"result=%d;c=%d,s1=%d,s2=%d,sY=%d,sH=%d;d1=%d,d2=%d",result,c,srcSlice,srcStride,srcSliceY, srcSliceH, dst, dstStride);
    sws_freeContext(c);
    return result;
}
- (NSString *) _getHexString:(char *)buff Size:(int)size
{
    int i = 0;
    char *ptr = buff;
    
    NSMutableString *str = [[NSMutableString alloc] init];
    while(i++ < size) [str appendFormat:@"%02X ", *ptr++ & 0x00FF];
    return str;
}

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

@end
