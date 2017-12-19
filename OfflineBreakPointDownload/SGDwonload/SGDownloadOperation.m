//
//  SGDownloadOperation.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadOperation.h"
#import "NSString+SGHashString.h"
#import "NSURLSession+SGDownloadTask.h"

NSString * const SGDownloadCompleteNoti = @"SGDownloadCompleteNoti";

@interface SGDownloadOperation ()
{
    SGReceiveResponseOperation  _didReceiveResponseCallBack;
    SGReceivDataOperation       _didReceivDataCallBack;
    SGCompleteOperation         _didCompleteCallBack;
}
/** 文件句柄 可以记录文件的下载的位置 */
@property (nonatomic,strong) NSFileHandle *handle;

/** 下载的文件总大小 */
@property (nonatomic,assign) NSInteger totalSize;

/** 当前下载了多少 */
@property (nonatomic,assign) NSInteger currentSize;

/** 当前下载文件名称 */
@property (nonatomic,copy) NSString *fileName;

/** 当前下载文件沙盒全路径 */
@property (nonatomic,copy) NSString *fullPath;

@end

@implementation SGDownloadOperation

- (instancetype)initWith:(NSString *)url session:(NSURLSession *)session {
    
    if (self = [super init]) {
        _url = url;
        // 初始化下载信息
        _currentSize = [self getFileSizeWithURL:url];
        
        // 偏好设置里面存储总数据
        _totalSize = [SGCacheManager totalSizeWith:url];
        
        // 校验
        if (self.currentSize == self.totalSize && self.totalSize != 0) {
            return nil;
        }
        
        _dataTask = [session sg_downloadDataTaskWithURLString:url startSize:_currentSize];
    }
    return _dataTask ? self : nil;
}

#pragma mark - setups
- (NSInteger)getFileSizeWithURL:(NSString *)url {
    // md5文件名加密
    NSString *md5FielName = [url sg_md5HashString];
    // 获取后缀名
    NSArray *subString = [[url lastPathComponent] componentsSeparatedByString:@"."];
    // 拼接后缀名
    self.fileName = [NSString stringWithFormat:@"%@.%@",md5FielName,subString.lastObject];
    
    // 创建文件储存路径
    if (![[NSFileManager defaultManager] fileExistsAtPath:KFullDirector]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:KFullDirector withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // 设置下载路径
    self.fullPath = [KFullDirector stringByAppendingString:self.fileName];
    
    // 获取下载进度
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:self.fullPath error:nil];
    // 获取已下载的长度
    return  [fileInfo[NSFileSize] integerValue];
}

#pragma mark - SGDownloadOperationProtocol
// 接收到相应时
- (void)operateWithResponse:(NSURLResponse *)response {
    // 总的size
    self.totalSize = self.currentSize + response.expectedContentLength;
    
    // 创建空的文件夹
    if (self.currentSize == 0) {
        // 创建空的文件
        [[NSFileManager defaultManager]  createFileAtPath:self.fullPath contents:nil attributes:nil];
    }
    
    // 创建文件句柄
    self.handle = [NSFileHandle fileHandleForWritingAtPath:self.fullPath];
    
    // 文件句柄移动到文件末尾 位置 // 返回值是 unsign long long
    [self.handle seekToEndOfFile];
    
    // 开始下载记录文件下载信息
    [SGCacheManager saveFileInfoWithDict:[self downLoadInfoWithFinished:NO]];
    
    // 回调给外界
    if (_didReceiveResponseCallBack) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _didReceiveResponseCallBack(self.fullPath);
        });
        
    }
}

- (void)operateWithReceivingData:(NSData *)data {
    // 获得已经下载的文件大小
    self.currentSize += data.length;
    
    // 写入文件
    [self.handle writeData:data];
    
    // 下载状态 通知代理
    if (_didReceivDataCallBack) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _didReceivDataCallBack(self.currentSize,self.totalSize);
        });
    }
}

- (void)operateWithComplete:(NSError *)error {
    // 关闭文件句柄
    [self.handle closeFile];
    // 释放文件句柄
    self.handle = nil;
    
    // 完成下载 通知 block
    if (error) {
        [self completFailueWithError:error];
    } else {
        [self completCusesseWithCode:1];
    }
}

- (void)configCallBacksWithDidReceiveResponse:(SGReceiveResponseOperation)didReceiveResponse
                                didReceivData:(SGReceivDataOperation)didReceivData
                                  didComplete:(SGCompleteOperation)didComplete {
    _didReceiveResponseCallBack  = didReceiveResponse;
    _didReceivDataCallBack       = didReceivData;
    _didCompleteCallBack         = didComplete;
    
}

#pragma mark - operations
/** 成功回调 1代表下载后成功回调 2代表直接从磁盘中获取了 */
- (void)completCusesseWithCode:(NSInteger)code {
    // 获取下载信息
    NSDictionary *dict = [self downLoadInfoWithFinished:YES];
    
    
    // 通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SGDownloadCompleteNoti object:self userInfo:dict];
    
    if (code == 1) {
        // 存储 文件下载信息
        [SGCacheManager saveFileInfoWithDict:dict];
    }
    
    // 回到主线程 回调
    if (_didCompleteCallBack) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _didCompleteCallBack(dict,nil);
        });
    }
}

/** 失败回调 */
- (void)completFailueWithError:(NSError *)error {
    
    // 发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SGDownloadCompleteNoti object:self userInfo:@{@"error":error}];
    // 存储
    [SGCacheManager saveFileInfoWithDict:[self downLoadInfoWithFinished:NO]];
    
    // 回调
    if (_didCompleteCallBack) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _didCompleteCallBack(nil,error);
        });
    }
}

#pragma mark - get download info
// 构造回调信息
- (NSDictionary *)downLoadInfoWithFinished:(BOOL)finished {
    return  @{
                fileUrl    : self.url,
                fileName   : self.fileName,
                filePath   : self.fullPath,
                fileSize   : @(self.currentSize),
                totalSize  : @(self.totalSize),
                isFinished : @(finished)
            };
}
@end
