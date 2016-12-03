//
//  SGDownloadManager.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadManager.h"
#import "SGDownloader.h"
#import "SGCacheManager.h"


static SGDownloadManager *_instance;

static SGDownloader *_downloader;

@interface SGDownloadManager ()

@property(nonatomic,strong) SGDownloader *downloader;

@end


@implementation SGDownloadManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:zone] init];
    });
    return _instance;
}

+ (instancetype)shareManager {
    return [[self alloc] init];
}

#pragma mark - configs
/** 配置任务等待时间 默认超时为-1 */
- (void)configRequestTimeOut:(NSTimeInterval)requestTimeOut {
    
}
/** 配置网络服务类型 */
- (void)configNetWorkServiceType:(SGNetworkServiceType) networkServiceType {
    
}

/** 配置最大下载量 */
- (void)configMaxDownloadTaskNumber:(NSInteger)maxTaskNumer {
    //self.maxDownloadNumber = maxTaskNumer;
}

#pragma mark - 外界交互
- (void)downloadWithURL:(NSURL *)url complete:(void(^)(NSDictionary *,NSError *))complete{
    [self downloadWithURL:url begin:nil progress:nil complete:complete];
}

- (void)downloadWithURL:(NSURL *)url progress:(void(^)(NSInteger,NSInteger ))progress complete:(void(^)(NSDictionary *,NSError *))complete {
    [self downloadWithURL:url begin:nil progress:progress complete:complete];
}

- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString *))begin progress:(void(^)(NSInteger,NSInteger))progress complete:(void(^)(NSDictionary *,NSError *))complete {
    
    //dispatch_semaphore_wait([self getSemaphore], DISPATCH_TIME_FOREVER);
    // 开启异步 操作
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 本地查找
        NSDictionary *fileInfo = [SGCacheManager queryFileInfoWithUrl:url.absoluteString];
        
        // 本地存在直接返回
        if ([fileInfo[isFinished] integerValue]) {
            !complete ? : complete(fileInfo,nil);
            
            //dispatch_semaphore_signal([self getSemaphore]);
            return;
        }
        
        // 交给downloader下载
        [self.downloader downloadWithURL:url begin:begin progress:progress complete:complete];
        
    });
    
}

#pragma mark - 
- (void)startDownLoadWithUrl:(NSString *)url {
    // 本地查找
    //dispatch_semaphore_wait([self getSemaphore], DISPATCH_TIME_FOREVER);
    NSDictionary *fileInfo = [SGCacheManager queryFileInfoWithUrl:url];
    
    if (fileInfo) {
       // dispatch_semaphore_signal([self getSemaphore]);
        return;
    }

    [self.downloader startDownLoadWithUrl:url];
}


- (void)supendDownloadWithUrl:(NSString *)url {
    
    [_downloader supendDownloadWithUrl:url];
}

- (void)cancelDownloadWithUrl:(NSString *)url {
    [_downloader cancelDownloadWithUrl:url];
}


/** 暂停当前所有的下载任务 下载任务不会从列队中删除 */
- (void)suspendAllDownloadTask {
    
}

/** 开启当前列队中所有被暂停的下载任务 */
- (void)startAllDownloadTask {

}

/** 停止当前所有的下载任务 调用此方法会清空所有列队下载任务 */
- (void)stopAllDownloads {
    
    [_downloader cancelAllDownloads];
    _downloader = nil;
}

/** 获取当前所有的下载任务 */
- (NSArray *)currentDownloadTasks {

    
    return nil;
}


#pragma mark - 
- (SGDownloader *)downloader {
    
    if (!_downloader) {
        _downloader = [[SGDownloader alloc] init];
    }
    return _downloader;
}



@end
