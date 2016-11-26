//
//  SGCacheManager.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//
#define SG_EXTERN extern
#import <Foundation/Foundation.h>


SG_EXTERN NSString const * filePath;
SG_EXTERN NSString const * fileSize ;
SG_EXTERN NSString const * fileName ;
SG_EXTERN NSString const * fileUrl ;

SG_EXTERN NSString * SGDownloadCompleteNoti;



@interface SGCacheManager : NSObject

+ (instancetype)shareManager;



@end
