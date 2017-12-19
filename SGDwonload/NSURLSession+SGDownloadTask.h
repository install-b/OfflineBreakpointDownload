//
//  NSURLSession+SGDownloadTask.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 2017/12/18.
//  Copyright © 2017年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (SGDownloadTask)

/**
 构造一个从特定位置开始下载的任务

 @param urlString 资源路径的URLstring
 @param startSize 开始的位置
 @return 下载任务
 */
- (NSURLSessionDataTask *)sg_downloadDataTaskWithURLString:(NSString *)urlString
                                                  startSize:(int64_t)startSize;
@end
