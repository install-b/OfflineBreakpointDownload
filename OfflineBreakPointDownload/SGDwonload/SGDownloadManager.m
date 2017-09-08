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




@interface SGDownloadManager ()

@property(nonatomic,strong) SGDownloader *downloader;

/** 唯一标识 */
@property (nonatomic,copy)NSString * identifier;

@end


@implementation SGDownloadManager

- (instancetype)init {
    return [self initWithBackgroundSessionConfigurationWithIdentifier:nil];
}

- (instancetype)initWithBackgroundSessionConfigurationWithIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        _identifier = identifier;
    }
    return self;
}

+ (instancetype)shareManager {
    static SGDownloadManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:   (URLSessionCompleteHandler)completionHandler {
    [self.downloader handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
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
    
    if (![url isKindOfClass:NSURL.class]) {
        if ([url isKindOfClass:NSString.class]) {
            url = [NSURL URLWithString:(NSString *)url];
        }else {
            
            return;
        }
    }
   
    // 开启异步 操作
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 本地查找
        NSDictionary *fileInfo = [SGCacheManager queryFileInfoWithUrl:url.absoluteString];
        
        // 本地存在直接返回
        if ([fileInfo[isFinished] integerValue]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                !complete ? : complete(fileInfo,nil);
            });
            
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
- (NSURLSession *)backgroundURLSession {
    return _downloader.backgroundURLSession;
}
- (SGDownloader *)downloader {
    
    if (!_downloader) {
        _downloader = [[SGDownloader alloc] initWithIdentifier:_identifier];
    }
    return _downloader;
}

@end
