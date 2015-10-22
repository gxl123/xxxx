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
    
    //h264->YUV
-(int) h264ToYUV:(char*)inData inLen:(int)inLen
         outData:(char*)outData outLen:(int)outLen{
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
