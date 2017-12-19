//
//  SGCacheManager.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGCacheManager.h"
#import "NSString+SGHashString.h"

static NSMutableDictionary *_downloadList;

static dispatch_semaphore_t _semaphore;


NSString const * filePath   =  @"filePath";
NSString const * fileSize   =  @"fileSize";
NSString const * fileName   =  @"fileName";
NSString const * fileUrl    =  @"fileUrl";
NSString const * isFinished =  @"isFinished";
NSString const * totalSize  =  @"totalSize";



#define SGDownloadInfoPath [KFullDirector stringByAppendingString:@"downloadInfo.plist"]

#define SGDownloadList [self getDownloadList]

@interface SGCacheManager ()
+ (NSMutableDictionary *)getDownloadList;

@end



@implementation SGCacheManager

+ (void)initialize {
    _semaphore = dispatch_semaphore_create(1);
    
}


+ (NSMutableDictionary *)getDownloadList {
    
    if (!_downloadList) { // 内存没有
        _downloadList = [[NSDictionary dictionaryWithContentsOfFile:SGDownloadInfoPath] mutableCopy]; // 本地加载
        if (!_downloadList) { // 本地没有，分配内存
            _downloadList = [NSMutableDictionary dictionary];
        }
    }
    return _downloadList;
}

#pragma mark - save
//+ (void)didReciveDownloadCompleteNoti:(NSNotification *)noti {
//
//    // 缓存记录
//    NSMutableDictionary *dictM = [noti.userInfo mutableCopy];
//    
//    // 从磁盘获取到下载了
//    if ([noti.object integerValue] == 2 && ([self queryFileInfoWithUrl:dictM[fileUrl]])) {
//        return;
//    }
//    
//    // 缓存记录
//    [dictM setObject:@(YES) forKey:isFinished];
//    NSString *key = [dictM[fileUrl] sg_md5HashString];
//    
//    [SGDownloadList setObject:dictM forKey:key];
//    
//    [SGDownloadList writeToFile:SGDownloadInfoPath atomically:YES];
//    
//}

#pragma mark - query
+ (NSDictionary *)queryFileInfoWithUrl:(NSString *)url {
    // 本地查找
    NSString *key = [url sg_md5HashString];
    //NSMutableDictionary *dictM = [[SGUserDefaults objectForKey:key] mutableCopy];
    
    NSMutableDictionary *dictM  = [[SGDownloadList objectForKey:key] mutableCopy];
    
    if (dictM) {
        NSString *path = [KFullDirector stringByAppendingString:dictM[fileName]];
        [dictM setObject:path forKey:filePath];
    }
    
    return dictM;
    
}

+ (NSInteger)totalSizeWith:(NSString *)url {
    //NSNumber *size = [self queryFileInfoWithUrl:url][totalSize];
    
    return [[self queryFileInfoWithUrl:url][totalSize] integerValue];
}

/** 记录要下载的文件大小 */
+ (BOOL)saveTotalSizeWithSize:(NSInteger)size forURL:(NSString *)url {
    
    return YES;
}

/**  增加配置信息 */
+ (BOOL)saveFileInfoWithDict:(NSDictionary *)dict {
    
    // 线程等待 (信号量 + 1)
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    NSString *key = [dict[fileUrl] sg_md5HashString];
    NSMutableDictionary *dictM =  SGDownloadList;
    [dictM setObject:dict forKey:key];
    BOOL flag = [dictM writeToFile:SGDownloadInfoPath atomically:YES];
    
    // 线程结束 （信号量 - 1）
    dispatch_semaphore_signal(_semaphore);
    
    return flag;
    
}

/**  删除配置信息 */
+ (BOOL)deleteFileWithUrl:(NSString *)url {
    // 线程等待 分配信号量 (信号量 + 1)
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    NSString *key = [url sg_md5HashString];
    NSDictionary *dict = SGDownloadList[key];
    BOOL flag = [[NSFileManager defaultManager] removeItemAtPath:dict[filePath] error:nil];
    [SGDownloadList removeObjectForKey:key];
    BOOL writeFlag = [SGDownloadList writeToFile:SGDownloadInfoPath atomically:YES];
    
    // 线程结束 释放信号量（信号量 - 1）
    dispatch_semaphore_signal(_semaphore);
    return (flag && writeFlag);
}



#pragma mark - 

+ (BOOL)clearDisks {
    // 1.删除所有的文件下载信息关联表
    // 2.删除cache 下的download文件夹
   return  [[NSFileManager defaultManager] removeItemAtPath:KFullDirector error:nil];
      
}

/**  取消所有当前下载的文件 清理内存缓存的数据 */
+ (BOOL)clearMemory {
    // 删除信息关联
    _downloadList = nil;
    
    return YES;
}

/**  取消所有当前下载的文件 删除磁盘所有的下载 清理内存缓存的数据 */
+ (BOOL)clearMemoryAndDisk {
    return ([self clearMemory] && [self clearDisks]);
}




@end
