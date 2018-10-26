//
//  NSURLSession+SGDownloadTask.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 2017/12/18.
//  Copyright © 2017年 Shangen Zhang. All rights reserved.
//

#import "NSURLSession+SGDownloadTask.h"

@implementation NSURLSession (SGDownloadTask)
- (NSURLSessionDataTask *)sg_downloadDataTaskWithURLString:(NSString *)urlString
                                                  startSize:(int64_t)startSize {
    // 校验URL
    if (urlString.length == 0) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        return nil;
    }
    
    // 创建请求 设置请求下载的位置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    /*
     bytes=0-100    请求0-100
     bytes=200-1000
     bytes=200-     从200开始直到结尾
     bytes=-100
     */
    NSString *rangeStr = [NSString stringWithFormat:@"bytes=%lld-",startSize];
    
    [request setValue:rangeStr forHTTPHeaderField:@"Range"];
    
    // 创建task
    return [self dataTaskWithRequest:request];
}
@end
