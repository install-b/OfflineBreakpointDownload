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
        
        // 监听完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResiveDownloadFileCompete:) name:SGDownloadCompleteNoti object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didResiveDownloadFileCompete:(NSNotification *)noti {
    NSDictionary *dict = noti.userInfo;
    
    SGDownloadOperation *operation = [self operationWithUrl:dict[fileUrl]];
    
    !operation ? : [self.operations removeObject:operation];
}

#pragma mark - handle Out operations
- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString * filePath))begin progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complet {
    // 获取operation对象
    SGDownloadOperation *operation = [self operationWithUrl:url.absoluteString];
    
//    
    if (!operation) {
        operation = [[SGDownloadOperation alloc] initWith:url.absoluteString session:self.session];
        
        if (!(operation.dataTask)) {
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
            [self.operations removeObject:operation]; // 删除任务
            [operation.dataTask cancel];  // 取消
            break;
    }
}

#pragma mark - query operation
//- (NSURLSessionDataTask *)dataTaskWithUrl:(NSString *)url {
//    
//    __block NSURLSessionDataTask *task = nil;
//    
//    
//    [self.operations enumerateObjectsUsingBlock:^(SGDownloadOperation * _Nonnull obj, BOOL * _Nonnull stop) {
//        if ([obj.url isEqualToString:url]) {
//            task = obj.dataTask;
//            
//            *stop = YES;
//        }
//    }];
//    
//    if (!task) {
//        SGDownloadOperation *opt = [[SGDownloadOperation alloc] initWith:url session:self.session];
//        [self.operations addObject:opt];
//        task = opt.dataTask;
//    }
//    
//    return task;
//}
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
