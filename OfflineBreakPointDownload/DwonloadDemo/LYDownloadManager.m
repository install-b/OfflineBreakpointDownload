//
//  LYDownloadManager.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 2017/9/8.
//  Copyright © 2017年 Shangen Zhang. All rights reserved.
//

#import "LYDownloadManager.h"

@implementation LYDownloadManager
+ (instancetype)shareManager {
    static LYDownloadManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithBackgroundSessionConfigurationWithIdentifier:@"com.zhangsg.OfflineBreakPointDownload"];
    });
    return _instance;
}
@end
