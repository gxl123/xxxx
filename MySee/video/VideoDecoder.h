//
//  VideoDecoder.h
//  MySee
//
//  Created by tommy on 15/10/22.
//  Copyright (c) 2015年 ml . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "avcodec.h"
#import "swscale.h"
@protocol VideoDecoderDelegate;
@interface VideoDecoder : NSObject

@property (nonatomic, assign) id<VideoDecoderDelegate> delegate;
@end

@protocol VideoDecoderDelegate <NSObject>
- (void) didReceiveRGBData:(const char*)data DataSize:(NSInteger)size;
@end