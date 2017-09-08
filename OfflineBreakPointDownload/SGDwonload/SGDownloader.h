//
//  SGDownloader.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGDownloadManager.h"

@interface SGDownloader : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier;
- (NSURLSession *)backgroundURLSession;
- (void)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(URLSessionCompleteHandler)completionHandler;
// 接口回调
- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString *))begin progress:(void(^)(NSInteger,NSInteger))progress complete:(void(^)(NSDictionary *,NSError *))complet;


- (void)startDownLoadWithUrl:(NSString *)url;

- (void)supendDownloadWithUrl:(NSString *)url;

- (void)cancelDownloadWithUrl:(NSString *)url;

- (void)cancelAllDownloads;
@end
