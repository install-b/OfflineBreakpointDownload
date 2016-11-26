//
//  SGDownloadOperation.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGDownloadOperation : NSObject

- (instancetype)initWith:(NSString *)url session:(NSURLSession *)session;

//  绑定的标示及task的创建
@property (nonatomic, copy)NSString *url;

@property (nonatomic,strong)NSURLSessionDataTask *dataTask;

// 回调的方法
@property (nonatomic, copy) void(^didReceiveResponse)(NSString *filePath);

//@property (nonatomic, copy) void (^completionHandler)(NSURLSessionResponseDisposition disposition);

@property (nonatomic, copy) void(^didReceivData)(NSInteger completeSize,NSInteger expectSize);

@property (nonatomic, copy) void(^didComplete)(NSDictionary *respose,NSError *error);

// 供queue管理方法
- (void)sg_didReceiveResponse:(NSURLResponse *)response;

- (void)sg_didReceivData:(NSData *)data;

- (void)sg_didComplete:(NSError *)error;

@end
