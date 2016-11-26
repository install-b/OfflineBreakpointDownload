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

@property (nonatomic,strong) NSMutableSet <SGDownloadOperation *>*operations;

@property (nonatomic,strong) NSURLSession *session;

@end

@implementation SGDownloadQueue

- (instancetype)initWithSession:(NSURLSession *)sesseion {

    if (self = [super init]) {
        self.session = sesseion;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - handle Out operations
- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString * filePath))begin progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complet {
    // 获取operation对象
    SGDownloadOperation *operation = [self operationWithUrl:url.absoluteString];
    
    // 回调赋值operation
    operation.didReceiveResponse = begin;
    operation.didReceivData = progress;
    operation.didComplete = complet;
    
    // 开启下载
    [operation.dataTask resume];
}

- (void)operateDownloadWithUrl:(NSString *)url handle:(DownloadHandleType)handle{
    
    SGDownloadOperation *operation = [self operationWithUrl:url];
    
    switch (handle) {
        case DownloadHandleTypeStart:
            [operation.dataTask resume];
            break;
        case DownloadHandleTypeSuspend:
            [operation.dataTask suspend];
            break;
        case DownloadHandleTypeCancel:
            [operation.dataTask cancel];
            break;
    }
}

#pragma mark - query operation
- (SGDownloadOperation *)operationWithUrl:(NSString *)url {
    __block SGDownloadOperation *operation = nil;
    
    [self.operations enumerateObjectsUsingBlock:^(SGDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.url isEqualToString:url]) {
            operation = obj;
            *stop = YES;
        }
    }];
    
    if (!operation) {
        SGDownloadOperation *operation = [[SGDownloadOperation alloc] initWith:url session:self.session];
    
        [self.operations addObject:operation];
    }
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
