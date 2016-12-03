//
//  NSString+SGHashString.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/27.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "NSString+SGHashString.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (SGHashString)
#pragma mark - MD5加密
- (NSString *)sg_md5HashString {
    const char *str = self.UTF8String;
    
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
