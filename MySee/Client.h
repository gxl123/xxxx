//
//  Client.h
//  Sample_AVAPIs
//
//  Created by tutk on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Client : NSObject
@property int avIndex;
@property Boolean isRunningRecvVideoThread;
@property Boolean isRunningRecvAudioThread;
- (void)start:(NSString *)UID;
-(void)Stop;
@end
