//
//  NSString+SGHashString.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/27.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KFullPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

#define KFullDirector [NSString stringWithFormat:@"%@/downloads/",KFullPath]


@interface NSString (SGHashString)

/** 获取MD5加密哈希散列值字符串 */
- (NSString *)sg_md5HashString;

@end
