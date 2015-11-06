//
//  AppDelegate.m
//  MySee
//
//  Created by ml  on 14/11/2.
//  Copyright (c) 2014年 ml . All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
            [self creatFile];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)creatFile {
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    //NSString *videoPath_ = [documentsDirectory stringByAppendingPathComponent:@"/video"];
    //NSString *sourcePath_ = [videoPath_ stringByAppendingString:[NSString stringWithFormat:@"/%@",@"Recorder"]];
    
    //    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath_]) {
    //        [[NSFileManager defaultManager] createDirectoryAtPath:videoPath_ withIntermediateDirectories:NO attributes:nil error:&error];
    //    }
    //    if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath_]) {
    //        [[NSFileManager defaultManager] createDirectoryAtPath:sourcePath_ withIntermediateDirectories:NO attributes:nil error:&error];
    //    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    [formatter setDateFormat:@"MM-dd-kk-mm-ss"];
    
    NSString *directory_ = @"/video";
    NSString *dataPath_ = [documentsDirectory stringByAppendingPathComponent:directory_];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath_]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath_ withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *videoPath_ = [dataPath_ stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h264",[formatter stringFromDate:date]]];
    self.videoPath = videoPath_;
    NSString *videoH264Path_ = [dataPath_ stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_2.h264",[formatter stringFromDate:date]]];
    self.videoH264Path = videoH264Path_;
    NSString *videoYuvPath_ = [dataPath_ stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.yuv",[formatter stringFromDate:date]]];
    self.videoYuvPath = videoYuvPath_;
    
    //    NSString *mixPath_ = [dataPath_ stringByAppendingPathComponent:@"ace.raw"];
    //    self.mixPath = mixPath_;
    //    NSString *refPath_ = [dataPath_ stringByAppendingPathComponent:@"ref.raw"];
    //    self.refPath = refPath_;
    
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:self.videoPath] != YES)
    {
        [filemgr createFileAtPath:self.videoPath contents:nil attributes:nil];
    }
    if ([filemgr fileExistsAtPath:self.videoH264Path] != YES)
    {
        [filemgr createFileAtPath:self.videoH264Path contents:nil attributes:nil];
    }
    if ([filemgr fileExistsAtPath:self.videoYuvPath] != YES)
    {
        [filemgr createFileAtPath:self.videoYuvPath contents:nil attributes:nil];
    }
    
    //    if ([filemgr fileExistsAtPath:self.mixPath] != YES)
    //    {
    //        [filemgr createFileAtPath:self.mixPath contents:nil attributes:nil];
    //    }
    //    if ([filemgr fileExistsAtPath:self.refPath] != YES)
    //    {
    //        [filemgr createFileAtPath:self.refPath contents:nil attributes:nil];
    //    }
    
    
}

@end
