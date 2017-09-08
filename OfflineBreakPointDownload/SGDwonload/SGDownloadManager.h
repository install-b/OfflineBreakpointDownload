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
 *  该提示可以增强系统优先考虑网络状况,确定需要多快醒来的蜂窝数据或无线wi-fi等等。
 *  通过提供准确的提示,系统可以提高系统的优化能力平衡电池寿命,性能,和其他方面的考虑。
 */
typedef enum : NSUInteger {
    SGNetworkServiceTypeDefule = 0, // Standard internet traffic
    SGNetworkServiceTypeVoIp,       // Voice over IP control traffic
    SGNetworkServiceTypeVideo,      // Video traffic
    SGNetworkServiceTypeBackground, // Background traffic
    SGNetworkServiceTypeVoice,      // Voice data

} SGNetworkServiceType;


typedef void(^SGDownloadBeginBlock)(NSString * filePath);
typedef void(^SGDownloadProgressBlock)(NSInteger completeSize,NSInteger expectSize);
typedef void(^SGDownloadCompleteBlock)(NSDictionary *respose,NSError *error);

typedef void(^URLSessionCompleteHandler)(void);


@interface SGDownloadManager : NSObject


/**
 构造方法

 @param identifier 后台session下载配置唯一标识
 @return 实例化对象
 */
- (instancetype)initWithBackgroundSessionConfigurationWithIdentifier:(NSString *)identifier;

/** 实例化对象（单例） */
+ (instancetype)shareManager;


- (NSURLSession *)backgroundURLSession;

- (void)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(URLSessionCompleteHandler)completionHandler;

#pragma mark - 添加下载任务同时开启任务下载
/** 开启下载任务 监听完成下载 */
- (void)downloadWithURL:(NSURL *)url complete:(SGDownloadCompleteBlock)complete;

/** 开启下载任务 监听下载进度、完成下载 */
- (void)downloadWithURL:(NSURL *)url progress:(SGDownloadProgressBlock)progress complete:(void(^)(NSDictionary *respose,NSError *error))complete;

/** 开启下载任务 监听开始下载信息、下载进度、完成下载 */
- (void)downloadWithURL:(NSURL *)url begin:(SGDownloadBeginBlock)begin progress:(SGDownloadProgressBlock)progress complete:(SGDownloadCompleteBlock)complete;


#pragma mark - 队列中的任务进行操作
/** 开始任务（不会自动添加任务，列队中没有就直接返回） */
- (void)startDownLoadWithUrl:(NSString *)url;

/** 暂停任务（暂停下载url内容的任务） */
- (void)supendDownloadWithUrl:(NSString *)url;

/** 取消任务（取消下载url内容的任务） */
- (void)cancelDownloadWithUrl:(NSString *)url;


/** 暂停当前所有的下载任务 下载任务不会从列队中删除 */
- (void)suspendAllDownloadTask;

/** 开启当前列队中所有被暂停的下载任务 */
- (void)startAllDownloadTask;

/** 停止当前所有的下载任务 调用此方法会清空所有列队下载任务 */
- (void)stopAllDownloads;

/** 获取当前所有的下载任务 */
- (NSArray *)currentDownloadTasks;

#pragma mark - 配置操作（下载之前配置） <暂未开通>
///** 配置任务等待时间 默认超时为-1 */
//- (void)configRequestTimeOut:(NSTimeInterval)requestTimeOut;
//
///** 配置网络服务类型 */
//- (void)configNetWorkServiceType:(SGNetworkServiceType) networkServiceType;
//
///** 配置最大下载量默认为3 设置为0也是默认为3 */
//- (void)configMaxDownloadTaskNumber:(NSInteger)maxTaskNumer;

@end

/*
 Xcode控制台输出的log:
 nw_socket_set_common_sockopts setsockopt SO_NOAPNFALLBK failed: [42] Protocol not available, dumping backtrace:
 [x86_64] libnetcore-856.1.8
 0   libsystem_network.dylib             0x000000010b23380e __nw_create_backtrace_string + 123
 1   libnetwork.dylib                    0x000000010c032194 nw_socket_add_input_handler + 3002
 2   libnetwork.dylib                    0x000000010c00fdb8 nw_endpoint_flow_attach_protocols + 3768
 3   libnetwork.dylib                    0x000000010c00edd5 nw_endpoint_flow_setup_socket + 563
 4   libnetwork.dylib                    0x000000010c00db34 -[NWConcrete_nw_endpoint_flow startWithHandler:] + 2612
 5   libnetwork.dylib                    0x000000010c028d11 nw_endpoint_handler_path_change + 1261
 6   libnetwork.dylib                    0x000000010c028740 nw_endpoint_handler_start + 570
 7   libnetwork.dylib                    0x000000010c040003 nw_endpoint_resolver_start_next_child + 2240
 8   libdispatch.dylib                   0x000000
 
 解决方案：
 1. 到 Edit Scheme (快捷键 command + shift + <)
 
 2.选择 Arguments 选项
 
 3.选择 environment variables 添加变量 OS_ACTIVITY_MODE = disable
 
 */

