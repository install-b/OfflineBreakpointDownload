//
//  SGDownloadQueue.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 下载处理 */
typedef  enum : NSUInteger {
    DownloadHandleTypeStart,    // 开始下载
    DownloadHandleTypeSuspend,  // 暂停下载
    DownloadHandleTypeCancel,   // 取消下载
} DownloadHandleType;


@interface SGDownloadQueue : NSObject

// 添加下载任务
- (void)addDownloadWithSession:(NSURLSession *)session
                        URL:(NSURL *)url
                      begin:(void(^)(NSString * filePath))begin
                   progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress
                   complete:(void(^)(NSDictionary *respose,NSError *error))complet;

// 对当前任务进行操作
- (void)operateDownloadWithUrl:(NSString *)url handle:(DownloadHandleType)handle;

// 取消所有任务
- (void)cancelAllTasks;
- (void)suspendAllTasks;
- (void)startAllTasks;

// 供downloader 处理下载调用
- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response;

- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;

- (void)task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
@end
