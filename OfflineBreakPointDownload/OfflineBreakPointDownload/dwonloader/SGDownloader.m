//
//  SGDownloader.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloader.h"
#import "SGDownloadQueue.h"

@interface SGDownloader () <NSURLSessionDataDelegate>

/** session 可以支持多个任务下载，创建一次就可以 */
@property (nonatomic,strong) NSURLSession *session;

/** 下载列队管理 专门负责接收到数据时分配给不同operation */
@property (nonatomic,strong) SGDownloadQueue *queue;

/** 下载配置 */
@property (nonatomic,strong) NSURLSessionConfiguration *sessionConfig;
@end

@implementation SGDownloader

// 添加任务
- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString * filePath))begin progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complet {
    
    // 交给列队管理
    [self.queue downloadWithURL:url begin:begin progress:progress complete:complet];
    
}

#pragma mark - 操作任务接口

- (void)startDownLoadWithUrl:(NSString *)url {

    [self.queue operateDownloadWithUrl:url handle:DownloadHandleTypeStart];
}

- (void)supendDownloadWithUrl:(NSString *)url {
    [self.queue operateDownloadWithUrl:url handle:DownloadHandleTypeSuspend];
}

- (void)cancelDownloadWithUrl:(NSString *)url {
    [self.queue operateDownloadWithUrl:url handle:DownloadHandleTypeCancel];
}



#pragma mark - <NSURLSessionDataDelegate>
// 接受到响应调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    [self.queue dataTask:dataTask didReceiveResponse:response];
    completionHandler(NSURLSessionResponseAllow);
}

// 接受到数的时候调用，调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.queue dataTask:dataTask didReceiveData:data];
}

// <NSURLSessionDataDelegate> 完成下载
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    [self.queue task:task didCompleteWithError:error];
}


#pragma mark - lazy load
- (NSURLSession *)session {
    
    if (!_session) {
       _session = [NSURLSession sessionWithConfiguration:self.sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _session;
}


- (NSURLSessionConfiguration *)sessionConfig {
    if (!_sessionConfig) {
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionConfig.timeoutIntervalForRequest = -1;
    }
    return _sessionConfig;
}

- (SGDownloadQueue *)queue {

    if (!_queue) {
        _queue = [[SGDownloadQueue alloc] initWithSession:self.session];
    }
    return _queue;
}

@end
