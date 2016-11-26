//
//  SGCacheManager.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGCacheManager.h"
#import <CommonCrypto/CommonCrypto.h>



static SGCacheManager *_instance;


NSString const * filePath = @"filePath";
NSString const * fileSize = @"fileSize";
NSString const * fileName = @"fileName";
NSString const * fileUrl  = @"fileUrl";

NSString const * SGDownloadCompleteNoti = @"SGDownloadCompleteNoti";

@implementation SGCacheManager


+(instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}


+ (instancetype)shareManager {
    return [[self alloc] init];
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
