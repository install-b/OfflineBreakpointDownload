//
//  SGDownloader.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadSession.h"
#import "SGDownloadQueue.h"

@interface SGDownloadSession () <NSURLSessionDataDelegate>

/** session 可以支持多个任务下载，创建一次就可以 */
@property (nonatomic,strong) NSURLSession *session;

/** 下载列队管理 专门负责接收到数据时分配给不同operation */
@property (nonatomic,strong) SGDownloadQueue *queue;

@end


@implementation SGDownloadSession
// 添加任务
- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString *))begin progress:(void(^)(NSInteger,NSInteger))progress complete:(void(^)(NSDictionary *,NSError *))complet {
    // 交给列队管理
    [self.queue addDownloadWithSession:self.session URL:url begin:begin progress:progress complete:complet];
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
        // 取消所有session的任务
        // 耗时操作
        // 会调用 URLSession:task:didCompleteWithError: 方法抛出error取消
        [self.session invalidateAndCancel];
    });
}
- (void)startAllDownloads {
    [_queue startAllTasks];
}
- (void)suspendAllDownloads {
    [_queue suspendAllTasks];
}

#pragma mark - <NSURLSessionDataDelegate>

// ssl 服务 证书信任
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge   completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if(![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        return;
    }
    
    // 信任该插件
    NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    // 第一个参数 告诉系统如何处置
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

//当请求协议是https的时候回调用该方法
//Challenge 挑战 质询(受保护空间)
//NSURLAuthenticationMethodServerTrust 服务器信任证书
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    
    if(![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        return;
    }
    
    // 信任该插件
    NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    // 第一个参数 告诉系统如何处置
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    
}


// 接受到响应调用
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    // 将响应交给列队处理
    [self.queue dataTask:dataTask didReceiveResponse:response];
    
    // 允许下载
    completionHandler(NSURLSessionResponseAllow);
}

// 接受到数据碎片 的时候调用，调用多次
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    // 接收到session 下载碎片交个列队管理
    [self.queue dataTask:dataTask didReceiveData:data];
}

// <NSURLSessionDataDelegate> 完成下载
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.queue task:task didCompleteWithError:error];
}


#pragma mark - lazy load
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 设置请求超时
        config.timeoutIntervalForRequest = -1;
//        config.networkServiceType = NSURLNetworkServiceTypeVideo;
//        config.timeoutIntervalForResource = -1;
//        config.TLSMaximumSupportedProtocol = kSSLProtocolAll;
        
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    }
    
    return _session;
}

- (SGDownloadQueue *)queue {
    if (!_queue) {
        _queue = [[SGDownloadQueue alloc] init];
    }
    return _queue;
}
@end
