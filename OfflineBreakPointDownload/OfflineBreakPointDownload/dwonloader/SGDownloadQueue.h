//
//  SGDownloadQueue.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SGDownloadQueue : NSObject

- (NSURLSessionDataTask *)dataTaskWithUrl:(NSString *)url Session:(NSURLSession *)sesssion;



@end
