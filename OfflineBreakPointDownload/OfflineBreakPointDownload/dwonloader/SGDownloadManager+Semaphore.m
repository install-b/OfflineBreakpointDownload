//
//  SGDownloadManager+Semaphore.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/30.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadManager+Semaphore.h"

//@interface SGDownloadManager ()
//{
//    dispatch_semaphore_t _semaphore;
//    NSInteger _maxDownloadNumber;
//}
//@end

static NSInteger _maxDownloadNumber;
static dispatch_semaphore_t _semaphore;

@implementation SGDownloadManager (Semaphore)

- (dispatch_semaphore_t)getSemaphore {
    
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(self.maxDownloadNumber);
    }
    
    return _semaphore;
}
- (NSInteger)maxDownloadNumber {
    if (!_maxDownloadNumber) {
        _maxDownloadNumber = 3; // 默认为3个任务
    }
    return _maxDownloadNumber;
}

- (void)setMaxDownloadNumber:(NSInteger)maxDownloadNumber {
    _maxDownloadNumber = maxDownloadNumber;
}

@end
