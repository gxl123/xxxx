//
//  test.h
//  MySee
//
//  Created by tommy on 15/10/27.
//  Copyright © 2015年 ml . All rights reserved.
//
#ifndef _H264IPHONE_H_
#define _H264IPHONE_H_

#import "avcodec.h"
#import "swscale.h"

#define OS_IPHONE


#ifdef __cplusplus
extern "C" {
#endif //__cplusplus
    
    int InitDecoder();
#ifdef __cplusplus
}
#endif //__cplusplus

#endif