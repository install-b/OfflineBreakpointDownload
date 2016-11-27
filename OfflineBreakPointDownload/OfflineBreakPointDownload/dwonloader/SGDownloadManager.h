//
//  SGDownloadManager.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 *  网络服务类型：
 *  提供一个提示让操作系统知道底层的流量是用于什么。
 *  该提示可以增强系统优先考虑交通的能力,确定需要多快醒来的蜂窝数据或无线wi - fi等等。
 *  通过提供准确的提示,系统可以提高系统的优化能力平衡电池寿命,性能,和其他方面的考虑。
 */
typedef enum : NSUInteger {
    SGNetworkServiceTypeDefule = 0, // Standard internet traffic
    SGNetworkServiceTypeVoIp,       // Voice over IP control traffic
    SGNetworkServiceTypeVideo,      // Video traffic
    SGNetworkServiceTypeBackground, // Background traffic
    SGNetworkServiceTypeVoice,      // Voice data

} SGNetworkServiceType;



@interface SGDownloadManager : NSObject
/** 实例化对象（单例） */
+ (instancetype)shareManager;

#pragma mark - 添加下载任务同时开启任务下载
/** 开启下载任务 监听完成下载 */
- (void)downloadWithURL:(NSURL *)url complete:(void(^)(NSDictionary *respose,NSError *error))complete;

/** 开启下载任务 监听下载进度、完成下载 */
- (void)downloadWithURL:(NSURL *)url progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complete;

/** 开启下载任务 监听开始下载信息、下载进度、完成下载 */
- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString * filePath))begin progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complete;


#pragma mark - 队列中的任务进行操作
/** 开始任务（不会自动添加任务，列队中没有就直接返回） */
- (void)startDownLoadWithUrl:(NSString *)url;
/** 暂停任务（暂停下载url内容的任务） */
- (void)supendDownloadWithUrl:(NSString *)url;
/** 取消任务（取消下载url内容的任务） */
- (void)cancelDownloadWithUrl:(NSString *)url;

#pragma mark - 配置操作
/** 配置任务等待时间 默认超时为-1 */
- (void)configRequestTimeOut:(NSTimeInterval)requestTimeOut;
/** 配置网络服务类型 */
- (void)configNetWorkServiceType:(SGNetworkServiceType) networkServiceType;

@end
