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
NSString const * isFinished = @"isFinished";

NSString  * SGDownloadCompleteNoti = @"SGDownloadCompleteNoti";

#define SGUserDefaults [NSUserDefaults standardUserDefaults]

@interface SGCacheManager ()
@end


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


#pragma mark - save
- (void)didReciveDownloadCompleteNoti:(NSNotification *)noti {
    // 缓存记录
    NSMutableDictionary *dictM = [noti.userInfo mutableCopy];
    
    // 从磁盘获取到下载了
    if ([noti.object integerValue] == 2 && ([self fileInfoWithUrl:dictM[fileUrl]])) {
        return;
    }
    
    // 缓存记录
    [dictM setObject:@(YES) forKey:isFinished];
    NSString *key = [dictM[fileUrl] sg_md5HashString];
    
    [SGUserDefaults setObject:dictM forKey:key];
    [SGUserDefaults synchronize];
}

#pragma mark - query
- (NSDictionary *)fileInfoWithUrl:(NSString *)url {
    
    // 本地查找
    NSString *key = [url sg_md5HashString];
    NSMutableDictionary *dictM = [[SGUserDefaults objectForKey:key] mutableCopy];
    
    if (dictM) {
        NSString *path = [KFullDirector stringByAppendingString:dictM[fileName]];
        [dictM setObject:path forKey:filePath];
    }
    
    return dictM;
}


@end
