//
//  SGDownloadOperation.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGCacheManager.h"


SG_EXTERN NSString * const SGDownloadCompleteNoti;

typedef void(^SGReceiveResponseOperation)(NSString *filePath);
typedef void(^SGReceivDataOperation)(NSInteger completeSize,NSInteger expectSize);
typedef void(^SGCompleteOperation)(NSDictionary *respose,NSError *error);


@protocol SGDownloadOperationProtocol <NSObject>
                                    
// 供queue管理方法

// 处理响应值
- (void)operateWithResponse:(NSURLResponse *)response;
// 处理接收到的碎片
- (void)operateWithReceivingData:(NSData *)data;
// 处理完成回调
- (void)operateWithComplete:(NSError *)error;


/**
 设置block回调

 @param didReceiveResponse 开始下载的回调
 @param didReceivData 接收到下载的回调
 @param didComplete 下载完成的回调
 */
- (void)configCallBacksWithDidReceiveResponse:(SGReceiveResponseOperation)didReceiveResponse
                                didReceivData:(SGReceivDataOperation)didReceivData
                                  didComplete:(SGCompleteOperation)didComplete;

@end

@interface SGDownloadOperation : NSObject <SGDownloadOperationProtocol>

// 创建下载操作任务
- (instancetype)initWith:(NSString *)url session:(NSURLSession *)session;

// 绑定的标示及task的创建
@property (readonly,nonatomic, copy)NSString *url;

// 下载任务
@property (readonly,nonatomic,strong)NSURLSessionDataTask *dataTask;

@end

