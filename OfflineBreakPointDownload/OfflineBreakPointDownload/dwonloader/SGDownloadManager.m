//
//  SGDownloadManager.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadManager.h"
#import "SGDownloader.h"

static SGDownloadManager *_instance;

@interface SGDownloadManager ()

@property(nonatomic,strong) SGDownloader *downloader;

@end


@implementation SGDownloadManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self allocWithZone:zone] init];
    });
    return _instance;
}

+ (instancetype)shareManager {
    return [[self alloc] init];
}


- (void)downloadWithURL:(NSURL *)url complete:(void(^)())complete failue:(void(^)())failue{
    
    
}

- (void)downloadWithURL:(NSURL *)url progress:(void(^)())progress complete:(void(^)())complete failue:(void(^)())failue {


    
}


@end
