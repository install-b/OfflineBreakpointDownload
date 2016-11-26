//
//  SGDownloadOperation.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadOperation.h"
#import <CommonCrypto/CommonCrypto.h>
#import "SGCacheManager.h"

#define KFullPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

#define KFullDirector [NSString stringWithFormat:@"%@/downloads/",KFullPath]

//static NSString * const totalSize = @"totalSize";

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
        [self setUrl:url];
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
    //!self.didReceiveResponse ? : self.didReceiveResponse(self.fullPath);
    
    if (self.didReceiveResponse) {
        self.didReceiveResponse(self.fullPath);
    }
    
    // 创建文件句柄
    self.handle = [NSFileHandle fileHandleForWritingAtPath:self.fullPath];
    // 文件句柄移动到文件末尾 位置 // 返回值是 unsign long long
    [self.handle seekToEndOfFile];
    
    // 偏好设置记录文件总大小
    [[NSUserDefaults standardUserDefaults] setInteger:self.totalSize forKey:self.fileName];
    
    NSLog(@"%@\n%@",self.fileName,self.fullPath);
    
}

- (void)sg_didReceivData:(NSData *)data {
    // 获得已经下载的文件大小
    self.currentSize += data.length;
    
    // 下载状态 通知代理
    //!self.didReceivData ? : self.didReceivData(self.currentSize,self.totalSize);
    
    if (self.didReceivData) {
        self.didReceivData(self.currentSize,self.totalSize);
    }
    
    //NSLog(@"++++++%.2f+++++",1.0 * self.currentSize / self.totalSize);
    
    // 写入文件
    [self.handle writeData:data];

}

- (void)sg_didComplete:(NSError *)error {
    [self.handle closeFile];
    self.handle = nil;
    
    NSLog(@"complete:---%@",self.fullPath);
    
    // 完成下载 通知代理 block
    //error ? self.didComplete(nil,error) : [self completCucesse];
    
    if (error) {
        !self.didComplete? : self.didComplete(nil,error);
        // 发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:SGDownloadCompleteNoti object:@(0) userInfo:@{@"error":error}];
    } else {
        [self completCucesse];
    }
}

- (void)completCucesse {
    
    NSDictionary *dict = @{
                           fileUrl  : self.url,
                           fileName : self.fileName,
                           filePath : self.fullPath,
                           fileSize : @(self.currentSize)
                           };
    
    !self.didComplete ? : self.didComplete(dict,nil);
    if (self.didComplete) {
        self.didComplete(dict,nil);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:SGDownloadCompleteNoti object:@(1) userInfo:dict];
}

#pragma mark - setter

- (void)setUrl:(NSString *)url {
    
    _url = url;
    
    // 设置文件路径
    [self setFilePath];
  
    // 获取文件信息
    [self setFileInfo];
}


- (void)setSession:(NSURLSession *)session {
    
    if (self.currentSize == self.totalSize && self.totalSize != 0) {
        [self completCucesse];
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

- (void)setFilePath {
    // md5 文件名加密
    NSString *md5FielName = [self md5StringWitUrl:self.url];
    NSString *originFileName = [self.url lastPathComponent];
    NSArray *subString = [originFileName componentsSeparatedByString:@"."];
    self.fileName = [NSString stringWithFormat:@"%@.%@",md5FielName,subString.lastObject];
    
    // 创建文件储存路径
    if (![[NSFileManager defaultManager] fileExistsAtPath:KFullDirector]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:KFullDirector withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 设置路径
    self.fullPath = [KFullDirector stringByAppendingString:self.fileName];
}

- (void)setFileInfo {
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:self.fullPath error:nil];
    
    self.currentSize = [fileInfo[NSFileSize] integerValue];
    
    // 偏好设置里面存储总数据
    self.totalSize = [[NSUserDefaults standardUserDefaults] integerForKey:self.fileName];
}


#pragma mark - MD5加密
- (NSString *)md5StringWitUrl:(NSString *)url {
    const char *str = url.UTF8String;
    
    uint8_t buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(str, (CC_LONG)strlen(str), buffer);
    
    return [self stringFromBytes:buffer length:CC_MD5_DIGEST_LENGTH];

}

/**
 *  返回二进制 Bytes 流的字符串表示形式
 *
 *  @param bytes  二进制 Bytes 数组
 *  @param length 数组长度
 *
 *  @return 字符串表示形式
 */
- (NSString *)stringFromBytes:(uint8_t *)bytes length:(int)length {
    NSMutableString *strM = [NSMutableString string];
    
    for (int i = 0; i < length; i++) {
        [strM appendFormat:@"%02x", bytes[i]];
    }
    
    return [strM copy];
}


@end
