//
//  SGCacheManager.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGCacheManager.h"
#import "NSString+SGHashString.h"

static SGCacheManager *_instance;


NSString const * filePath = @"filePath";
NSString const * fileSize = @"fileSize";
NSString const * fileName = @"fileName";
NSString const * fileUrl  = @"fileUrl";

NSString  * SGDownloadCompleteNoti = @"SGDownloadCompleteNoti";


@implementation SGCacheManager

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:zone] init];
        
    });
    return _instance;
}
+ (instancetype)shareManager {
    return [self alloc];
}


- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveDownloadCompleteNoti:) name:SGDownloadCompleteNoti object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReciveDownloadCompleteNoti:(NSNotification *)noti {
    
    // 缓存记录

    
}

#pragma mark -
- (NSDictionary *)fileInfoWithUrl:(NSString *)url {
    
    // 本地查找
    
    return nil;
}


@end
