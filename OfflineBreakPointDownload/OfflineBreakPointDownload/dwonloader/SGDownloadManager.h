//
//  SGDownloadManager.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SGDownloadManager : NSObject

+ (instancetype)shareManager;

- (void)downloadWithURL:(NSURL *)url complete:(void(^)(NSDictionary *respose,NSError *error))complete;


- (void)downloadWithURL:(NSURL *)url progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complete;


- (void)downloadWithURL:(NSURL *)url begin:(void(^)(NSString * filePath))begin progress:(void(^)(NSInteger completeSize,NSInteger expectSize))progress complete:(void(^)(NSDictionary *respose,NSError *error))complete;


- (void)startDownLoadWithUrl:(NSString *)url;

- (void)supendDownloadWithUrl:(NSString *)url;

- (void)cancelDownloadWithUrl:(NSString *)url;

@end
