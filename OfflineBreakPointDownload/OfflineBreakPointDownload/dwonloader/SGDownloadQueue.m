//
//  SGDownloadQueue.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadQueue.h"
#import "SGDownloadOperation.h"


@interface SGDownloadQueue ()
// 列队管理集合
@property (nonatomic,strong) NSMutableSet <SGDownloadOperation *> *operations;
// 由downloader赋值 用于创建task任务 共享session
@property (nonatomic,strong) NSURLSession *session;

@end

@implementation SGDownloadQueue

- (instancetype)initWithSession:(NSURLSession *)sesseion {

    if (self = [super init]) {
        self.session = sesseion;
        
        // 监听完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResiveDownloadFileCompete:) name:SGDownloadCompleteNoti object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didResiveDownloadFileCompete:(NSNotification *)noti {
//    NSDictionary *dict = noti.userInfo;
//    
//    SGDownloadOperation *operation = [self operationWithUrl:dict[fileUrl]];
    
    SGDownloadOperation *operation = noti.object;
    
    !operation ? : [self.operations removeObject:operation];
}

#pragma mark - handle Out operations
- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString *))begin progress:(void(^)(NSInteger,NSInteger))progress complete:(void(^)(NSDictionary *,NSError *))complet {
    // 获取operation对象
    SGDownloadOperation *operation = [self operationWithUrl:url.absoluteString];
    
    if (!operation) {
        operation = [[SGDownloadOperation alloc] initWith:url.absoluteString session:self.session];
        
        if (!(operation.dataTask)) {
            // 没有下载任务代表已下载完成
            NSDictionary *fileInfo = [SGCacheManager queryFileInfoWithUrl:url.absoluteString];
            if (fileInfo && complet) {
                complet(fileInfo,nil);
            }
            return;
        }
        
        // 回调赋值operation
        operation.didReceiveResponse = begin;
        operation.didReceivData = progress;
        operation.didComplete = complet;
        [self.operations addObject:operation];
    }
    
    [operation.dataTask resume];
    
}

- (void)operateDownloadWithUrl:(NSString *)url handle:(DownloadHandleType)handle{
    
    SGDownloadOperation *operation = [self operationWithUrl:url];
    
    if (!operation) {
        return;
    } else if (!operation.dataTask) {
        if (!operation.didComplete || !(handle == DownloadHandleTypeStart)) {
            [self.operations removeObject:operation];
            return;
        }

        NSDictionary *fileInfo = [SGCacheManager queryFileInfoWithUrl:url];
        
        if (fileInfo) {
            operation.didComplete(fileInfo,nil);
        }
        
        [self.operations removeObject:operation];
        return;
    }
    
    
    switch (handle) {
        case DownloadHandleTypeStart:
            [operation.dataTask resume]; // 开始
            break;
        case DownloadHandleTypeSuspend:
            [operation.dataTask suspend]; // 暂停
            break;
        case DownloadHandleTypeCancel:
            [operation.dataTask cancel];  // 取消
            [self.operations removeObject:operation]; // 删除任务
            break;
    }
}

- (void)cancelAllTasks {
    // 取消所有的任务
    [_operations enumerateObjectsUsingBlock:^(SGDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.dataTask cancel];
    }];
    // 清理内存
    _operations = nil;
}

#pragma mark - query operation
- (SGDownloadOperation *)operationWithUrl:(NSString *)url{
    __block SGDownloadOperation *operation = nil;
    
    [self.operations enumerateObjectsUsingBlock:^(SGDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.url isEqualToString:url]) {
            operation = obj;
            *stop = YES;
        }
    }];
    
    return operation;
}

// 寻找operation
- (SGDownloadOperation *)oprationWithDataTask:(NSURLSessionTask *)dataTask {

    __block SGDownloadOperation *operation = nil;
    
    [self.operations enumerateObjectsUsingBlock:^(SGDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.dataTask == dataTask) {
            operation = obj;
            *stop = YES;
        }
    }];
    
    return operation;
}


#pragma mark - handle download
- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response {
    
    [[self oprationWithDataTask:dataTask] sg_didReceiveResponse:response];
}

- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self oprationWithDataTask:dataTask] sg_didReceivData:data];
}


- (void)task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [[self oprationWithDataTask:task] sg_didComplete:error];
}


#pragma mark - lazy load 
- (NSMutableSet<SGDownloadOperation *> *)operations {
    
    if (!_operations) {
        _operations = [NSMutableSet set];
    }
    return _operations;
}
@end
