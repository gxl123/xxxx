//
//  test.m
//  MySee
//
//  Created by tommy on 15/10/27.
//  Copyright © 2015年 ml . All rights reserved.
//

#import "test.h"
int InitDecoder()
{
    avcodec_decode_video2(NULL, NULL, NULL, NULL);
    //AVCodecParserContext *s = av_parser_init(AV_CODEC_ID_H264);
	// av_parser_init(AV_CODEC_ID_MPEG4);
    return 0;
}