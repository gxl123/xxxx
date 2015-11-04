//
//  ViewController.m
//  MySee
//
//  Created by ml  on 14/11/2.
//  Copyright (c) 2014年 ml . All rights reserved.
//

#import "ViewController.h"
#import "Client.h"
#import "Utilities.h"
@interface ViewController ()

@end

@implementation ViewController{
    Client *client ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    client = [[Client alloc] init];
    client.delegate=self;
     //self.monitor.image=  [UIImage imageNamed:@"videoClip.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doConnect:(id)sender {
    [client start: @"LHN1WRB21X17E1LW45W1"];//@"AAAAAAAAAAAAAAAAAAAF"];//@"1AA8C63C8PSSEKBM111A"];// // Put your device's UID here.
}

- (IBAction)doDisconnect:(id)sender {
    [client Stop];
}

- (void) didReceiveRGBData:(const char*)data DataSize:(NSInteger)size{
  
    AVPicture tPicture;
    memcpy(&tPicture, data, size);
  //    [self rgbToImage:tPicture];
 //   dispatch_async(dispatch_get_main_queue(), ^{
    //[self updateimage];
 //   });
    UIImage* pImg= [self imageFromAVPicture:tPicture width:20 height:20];
//    NSLog(@"pImg=%@",pImg);
//    static int i=0;
//    i++;
//         UIImage *xx=[UIImage imageNamed:@"videoClip.png" ];
//    //[self savePPMPicture:tPicture width:640 height:352 index:i];
//         
//     //    self.monitor.image=  xx;//pImg;
//    dispatch_async(dispatch_get_main_queue(), ^{
         self.monitor.image=pImg;
//     });
//    
    
    
    
// CVImageBufferRef imageBuffer =CMSampleBufferGetImageBuffer(sampleBuffer);
//
//CVPixelBufferLockBaseAddress(imageBuffer, 0);
//void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
//size_t width = CVPixelBufferGetWidth(imageBuffer);
//size_t height = CVPixelBufferGetHeight(imageBuffer);
//size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
//size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
//
//CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
//
//CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaNoneSkipFirst|kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
    
   // NSData *data = data;//(NSData *)[dict valueForKey:@"rawData"];
 /*   NSNumber *width =[NSNumber numberWithInt:40];//(NSNumber *)[dict valueForKey:@"videoWidth"];
    NSNumber *height =[NSNumber numberWithInt:40];//(NSNumber *)[dict valueForKey:@"videoHeight"];
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, [width intValue] * [height intValue] * 3, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate([width intValue], [height intValue], 8, 24, [width intValue] * 3, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, true,  kCGRenderingIntentDefault);
    
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    self.monitor.image = [img copy];
    
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
    }*/
    

    
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
}/*
-(UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height {
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef cgImage = CGImageCreate(width,
                                       
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    CGDataProviderRelease(provider);
    
    CFRelease(data);
    
    
    
    return image;
}*/

-(void)savePPMPicture:(AVPicture)pict width:(int)width height:(int)height index:(int)iFrame {
    FILE *pFile;
    NSString *fileName;
    int  y;
    
    
    fileName = [Utilities documentsPath:[NSString stringWithFormat:@"image%04d.jpg",iFrame]];
    // Open file
    NSLog(@"write image file: %@",fileName);
    
    pFile=fopen([fileName cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    
    if(pFile==NULL)
        return;
    
    
    // Write header
    fprintf(pFile, "P6\n%d %d\n255\n", width, height);
    
    
    // Write pixel data
    for(y=0; y<height; y++)
        fwrite(pict.data[0]+y*pict.linesize[0], 1, width*3, pFile);
    
    
    // Close file
    fclose(pFile);
}
//- (UIImage*) toUIImage
//{
//    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
//    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, [self.data bytes], 20 * 20 * 3,kCFAllocatorNull);
//    NSAssert( [self.data length] == self.width * self.height * 3,
//             @"Fatal error: data length:%d, width:%d, height:%d, mul3=%d",
//             [self.data length],
//             self.width, self.height, self.width * self.height * 3 );
//    
//    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGImageRef cgImage = CGImageCreate(20,
//                                       20,
//                                       8,
//                                       24,
//                                       3 * 20,
//                                       colorSpace,
//                                       bitmapInfo,
//                                       provider,
//                                       NULL,
//                                       NO,
//                                       kCGRenderingIntentDefault);
//    UIImage *image = [UIImage imageWithCGImage:cgImage];
//    CGImageRelease(cgImage);
//    CGColorSpaceRelease(colorSpace);
//    CGDataProviderRelease(provider);
//    CFRelease(data);
    
//    return image;
//}

-(void)rgbToImage:(AVPicture)picture
{
    //    NSLog(@"rgb to rgba start");
//    if (rgbView == nil
//        || picture.data[0] == NULL
//        || frameWidth == 0
//        || frameHeight == 0) {
//        NSLog(@"rgb to rgba over - 0");
//        return;
//    }
    int frameWidth=20;//640;
    int frameHeight=20;//352;
    @try {
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
        CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, picture.data[0], picture.linesize[0]*frameHeight,kCFAllocatorNull);
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGImageRef cgImage = CGImageCreate(frameWidth,
                                           frameHeight,
                                           8,
                                           24,
                                           frameWidth*3,
                                           colorSpace,
                                           bitmapInfo,
                                           provider,
                                           NULL,
                                           NO,
                                           kCGRenderingIntentDefault);
        
        CGColorSpaceRelease(colorSpace);
        
        UIImage *image = [[UIImage alloc]initWithCGImage:cgImage];
        self.rgbImage = image;
       // [image release];
        
        CGImageRelease(cgImage);
        CGDataProviderRelease(provider);
        CFRelease(data);
    }
    @catch (NSException *exception) {
        NSLog(@"exception !!!!!");
    }
    @finally {
        //        NSLog(@"finally");
    }
    
    //    NSLog(@"rgb to rgba over - 1");
    
}
//不断更新图片到UI
-(void)updateimage
{
    self.monitor.image = self.rgbImage;
}

@end
