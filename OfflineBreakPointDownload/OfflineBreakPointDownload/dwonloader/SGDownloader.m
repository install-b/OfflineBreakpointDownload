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

@end

@implementation SGDownloader
- (void)startDownLoadWithUrl:(NSString *)url {
    
    [[self.queue dataTaskWithUrl:url Session:self.session] resume];
}

- (void)supendDownloadWithUrl:(NSString *)url {
    [[self.queue dataTaskWithUrl:url Session:self.session] suspend];
}

- (void)cancelDownloadWithUrl:(NSString *)url {
     [[self.queue dataTaskWithUrl:url Session:self.session] cancel];
}



#pragma mark - <NSURLSessionDataDelegate>
// 接受到响应调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    
    completionHandler(NSURLSessionResponseAllow);
}

// 接受到数的时候调用，调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
}

// <NSURLSessionDataDelegate> 完成下载
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    
 
}


#pragma mark - lazy load
- (NSURLSession *)session {
    
    if (!_session) {
         _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
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
