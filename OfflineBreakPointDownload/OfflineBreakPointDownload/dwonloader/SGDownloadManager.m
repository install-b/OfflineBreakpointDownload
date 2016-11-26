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

#pragma mark - 外界交互
- (void)downloadWithURL:(NSURL *)url complete:(void(^)(NSDictionary *respose,NSError *error))complete{
    [self downloadWithURL:url begin:nil progress:nil complete:complete];
}

- (void)downloadWithURL:(NSURL *)url progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complete {
    [self downloadWithURL:url begin:nil progress:progress complete:complete];
}

- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString * filePath))begin progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complete {
    
    // 本地查找
    NSDictionary *fileInfo = [[SGCacheManager shareManager] fileInfoWithUrl:url.absoluteString];
   
    if (fileInfo) {
        !complete ? : complete(fileInfo,nil);
        return;
    }
    
    // 交给downloader下载
    [self.downloader downloadWithURL:url begin:begin progress:progress complete:complete];

}


- (void)startDownLoadWithUrl:(NSString *)url {
    // 本地查找
    NSDictionary *fileInfo = [[SGCacheManager shareManager] fileInfoWithUrl:url];
    
    if (fileInfo) {
        return;
    }

    [self startDownLoadWithUrl:url];
}


- (void)supendDownloadWithUrl:(NSString *)url {
    [self.downloader supendDownloadWithUrl:url];
}

- (void)cancelDownloadWithUrl:(NSString *)url {
    [self.downloader cancelDownloadWithUrl:url];
}

#pragma mark - 本地查询

- (void)cheakOutFileWithUrl:(NSURL *)url {
    
}

#pragma mark - 
- (SGDownloader *)downloader {
    
    if (!_downloader) {
        _downloader = [[SGDownloader alloc] init];
    }
    return _downloader;
}

@end
