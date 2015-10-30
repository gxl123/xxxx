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
     dispatch_async(dispatch_get_main_queue(), ^{
    AVPicture tPicture;
    memcpy(&tPicture, data, size);
    UIImage* pImg= [self imageFromAVPicture:tPicture width:20 height:20];
    static int i=0;
    i++;
    //[self savePPMPicture:tPicture width:640 height:352 index:i];
    self.monitor.image=  pImg;
     });
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
    
}

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
}

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
@end
