//
//  AppDelegate.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "AppDelegate.h"
#import "LYDownloadManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}



- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
//    NSURLSession *backgroundSession = [[SGDownloadManager shareManager] backgroundURLSession];
//    NSLog(@"Rejoining session with identifier %@ %@", identifier, backgroundSession);
    // 保存 completion handler 以在处理 session 事件后更新 UI
    NSLog(@"identifier:%@",identifier);
    [[LYDownloadManager shareManager] handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

@end
