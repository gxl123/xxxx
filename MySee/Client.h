//
//  Client.h
//  Sample_AVAPIs
//
//  Created by tutk on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDecoder.h"
@interface Client : NSObject
@property int avIndex;
@property Boolean isRunningRecvVideoThread;
@property Boolean isRunningRecvAudioThread;
@property (nonatomic, assign) id<VideoDecoderDelegate> delegate;
- (void)start:(NSString *)UID;
-(void)Stop;
@end
