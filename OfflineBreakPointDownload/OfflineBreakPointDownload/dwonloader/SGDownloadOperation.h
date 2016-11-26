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

@property (nonatomic, copy)NSString *url;

@property (nonatomic,strong)NSURLSessionDataTask *dataTask;


@property (nonatomic, copy) void(^didReceiveResponse)(NSURLResponse *response);

@property (nonatomic, copy) void (^completionHandler)(NSURLSessionResponseDisposition disposition);

@property (nonatomic, copy) void(^didReceivData)(NSData *data);

@property (nonatomic, copy) void(^didComplete)(NSError *error);

// 供queue管理方法
- (void)sg_didReceiveResponse:(NSURLResponse *)response;

- (void)sg_didReceivData:(NSData *)data;

- (void)sg_didComplete:(NSError *)error;

@end
