//
//  SGDownloadOperation.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadOperation.h"
#import "NSString+SGHashString.h"

NSString  * SGDownloadCompleteNoti = @"SGDownloadCompleteNoti";

@interface SGDownloadOperation ()

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
        self.url = url;
        // 初始化下载信息
        [self initFilePath];
        // 根据session创建task
        [self setSession:session];
    }
    return self;
}

#pragma mark - operations
// 接收到相应时
- (void)sg_didReceiveResponse:(NSURLResponse *)response {
    self.totalSize = self.currentSize + response.expectedContentLength;
    
    // 创建空的文件夹
    if (self.currentSize == 0) {
        [[NSFileManager defaultManager]  createFileAtPath:self.fullPath contents:nil attributes:nil];
    }
    
    // 回调给外界
    !self.didReceiveResponse ? : self.didReceiveResponse(self.fullPath);
    
    // 创建文件句柄
    self.handle = [NSFileHandle fileHandleForWritingAtPath:self.fullPath];
    
    // 文件句柄移动到文件末尾 位置 // 返回值是 unsign long long
    [self.handle seekToEndOfFile];
    
    // 开始下载记录文件下载信息
    [SGCacheManager saveFileInfoWithDict:[self downLoadInfoWithFinished:NO]];
}

- (void)sg_didReceivData:(NSData *)data {
    // 获得已经下载的文件大小
    self.currentSize += data.length;
    
    // 下载状态 通知代理
    !self.didReceivData ? : self.didReceivData(self.currentSize,self.totalSize);
    
    // 写入文件
    [self.handle writeData:data];

}

- (void)sg_didComplete:(NSError *)error {
    [self.handle closeFile];
    self.handle = nil;
    
    // 完成下载 通知 block
    if (error) {
        [self completFailueWithError:error];
    } else {
        [self completCusesseWithCode:1];
    }
}

/** 成功回调 1代表下载后成功回调 2代表直接从磁盘中获取了 */
- (void)completCusesseWithCode:(NSInteger)code {
    // 获取下载信息
    NSDictionary *dict = [self downLoadInfoWithFinished:YES];
    // 回调
    !self.didComplete ? : self.didComplete(dict,nil);
    
    // 通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SGDownloadCompleteNoti object:self userInfo:dict];
    
    if (code == 2) {
        return;
    }
    // 存储
    [SGCacheManager saveFileInfoWithDict:dict];
}

/** 失败回调 */
- (void)completFailueWithError:(NSError *)error {
    // 回调
    !self.didComplete ? : self.didComplete(nil,error);
    // 发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SGDownloadCompleteNoti object:self userInfo:@{@"error":error}];
    // 存储
    [SGCacheManager saveFileInfoWithDict:[self downLoadInfoWithFinished:NO]];
    
}


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


#pragma mark - 创建任务
- (void)setSession:(NSURLSession *)session {
    
    if (self.currentSize == self.totalSize && self.totalSize != 0) {
        [self completCusesseWithCode:2];
        return;
    }
    
    // 创建请求 设置请求下载的位置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    
    /*
     bytes=0-100    请求0-100
     bytes=200-1000
     bytes=200-     从200开始直到结尾
     bytes=-100
     */
    NSString *rangeStr = [NSString stringWithFormat:@"bytes=%zd-",self.currentSize];
    
    [request setValue:rangeStr forHTTPHeaderField:@"Range"];
    
    // 创建task
    _dataTask = [session dataTaskWithRequest:request];
    

}

#pragma mark - 初始化下载信息
- (void)initFilePath {
    // md5文件名加密
    NSString *md5FielName = [self.url sg_md5HashString];
    // 获取后缀名
    NSArray *subString = [[self.url lastPathComponent] componentsSeparatedByString:@"."];
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
    self.currentSize = [fileInfo[NSFileSize] integerValue];
    
    // 偏好设置里面存储总数据
    self.totalSize = [SGCacheManager totalSizeWith:self.url];
}


@end
