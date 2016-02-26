//
//  QueueObj.h
//  MySee
//
//  Created by tommy on 16/1/14.
//  Copyright (c) 2016年 ml . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueueObj : NSObject

- (void) addObject:(id)obj;
- (id) lastObject;
- (void) removeLastObject;

-(int)count;
- (NSString*)getlist;
@end
