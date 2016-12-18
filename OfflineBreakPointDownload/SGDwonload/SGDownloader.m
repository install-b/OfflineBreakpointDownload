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
- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString *))begin progress:(void(^)(NSInteger,NSInteger))progress complete:(void(^)(NSDictionary *,NSError *))complet {
    
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

- (void)cancelAllDownloads {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 取消所有session的任务 // 耗时操作
        [_session invalidateAndCancel]; // 会调用 URLSession:task:didCompleteWithError: 方法抛出error取消
        
    });
    
}

#pragma mark - <NSURLSessionDataDelegate>

// ssl 服务 证书信任
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge   completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{

    
    completionHandler(NSURLSessionAuthChallengeUseCredential,challenge.proposedCredential);

}

// 接受到响应调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    // 将响应交给列队处理
    [self.queue dataTask:dataTask didReceiveResponse:response];
    
    // 允许下载
    completionHandler(NSURLSessionResponseAllow);
}

// 接受到数据碎片 的时候调用，调用多次
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
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 设置请求超时
        config.timeoutIntervalForRequest = -1;
        config.networkServiceType = NSURLNetworkServiceTypeVideo;
        config.timeoutIntervalForResource = -1;
        config.TLSMaximumSupportedProtocol = kSSLProtocolAll;
        
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];

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
