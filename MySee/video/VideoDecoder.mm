//
//  VideoDecoder.m
//  MySee
//
//  Created by tommy on 15/10/22.
//  Copyright (c) 2015年 ml . All rights reserved.
//

#import "VideoDecoder.h"
#import "Common.h"
@implementation VideoDecoder{
    NSMutableArray* FrameQueue;
    BOOL bStop;
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
        FrameQueue=[[NSMutableArray alloc]init];
        //开启解码线程
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self thread_ReceiveVideo];
        });
    }
    return self;
}
-(void)deInit {
    bStop=YES;
}
-(void)thread_ReceiveVideo{
    while (!bStop) {
        NSObject *h264FrameData=[self pop];
        int ret=[self frameDecode:nil inLen:0 outData:nil outLen:0];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveRGBData:DataSize:)]) {
           // GLog( tCtrl, (@"--- uid:%@ avRecvIOCtrl( %d, %d, %X, %@)", self.uid, self.sessionID, channel.avIndex, type, [self _getHexString:recvIOCtrlBuff[nIdx] Size:readSize]));
            [self.delegate didReceiveRGBData:nil DataSize:0];
        }
    }
}
-(int) frameDecode:(char*)inData inLen:(int)inLen
           outData:(char*)outData outLen:(int)outLen{
    
    return 0;
}
    
//h264->YUV(AVPacket->AVFrame)
-(int) h264ToYUV:(char*)inData inLen:(int)inLen
         outData:(char*)outData outLen:(int)outLen{
  /*  AVCodecParserContext *s = av_parser_init(AV_CODEC_ID_H264);
    AVCodec *codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    AVCodecContext *avctx = avcodec_alloc_context3(codec);
    AVPacket tAVPacket;
    while(in_len){
        //组帧
        av_parser_parse2(s, avctx, &tAVPacket.data, &tAVPacket.size, <#const uint8_t *buf#>, <#int buf_size#>, <#int64_t pts#>, <#int64_t dts#>, <#int64_t pos#>)
        
        len = av_parser_parse2(myparser, AVCodecContext, &data, &size,
                               in_data, in_len,
                               pts, dts, pos);
        in_data += len;
        in_len  -= len;
        
        if(size)
            decode_frame(data, size);
    }

    char buf[FF_INPUT_BUFFER_PADDING_SIZE];
    memset(buf, 0, FF_INPUT_BUFFER_PADDING_SIZE);
    
    AVFrame *picture=av_frame_alloc();
   
    
    AVCodecContext.get_buffer2();
    av_frame_unref(<#AVFrame *frame#>);
    av_frame_is_writable(<#AVFrame *frame#>);
    
    int got_picture_ptr=0;//没有字幕
    
    AVPacket pkt;
    av_init_packet(&pkt);
    memcpy(pkt->data,inData,inLen);
    pkt->size=inLen;
    
    avcodec_decode_video2(<#AVCodecContext *avctx#>, <#AVFrame *picture#>, &got_picture_ptr, <#const AVPacket *avpkt#>);*/
    return 0;
}
//YUV->RGB
-(int) yUVToRGB:(char*)inData inLen:(int)inLen
         outData:(char*)outData outLen:(int)outLen{
    return 0;
}

-(void)push:(NSObject *)obj
{
    [FrameQueue addObject:obj];
}
-(NSObject *)pop
{
    NSObject *ret=[FrameQueue lastObject];
    ret=[ret copy];
    [FrameQueue removeLastObject];
    return ret;
}

@end
