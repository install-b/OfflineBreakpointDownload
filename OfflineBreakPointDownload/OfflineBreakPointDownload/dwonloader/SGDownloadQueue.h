//
//  SGDownloadQueue.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef  enum : NSUInteger {
    DownloadHandleTypeStart,
    DownloadHandleTypeSuspend,
    DownloadHandleTypeCancel,
}  DownloadHandleType;


@interface SGDownloadQueue : NSObject

- (instancetype)initWithSession:(NSURLSession *)sesseion;


- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString * filePath))begin progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complet;

- (void)operateDownloadWithUrl:(NSString *)url handle:(DownloadHandleType)handle;

- (NSURLSessionDataTask *)dataTaskWithUrl:(NSString *)url;
// 供download下载调用
- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response;

- (void)dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;

- (void)task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
@end
