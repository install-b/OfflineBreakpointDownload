//
//  SGDownloadManager+Semaphore.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/30.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGDownloadManager.h"

@interface SGDownloadManager (Semaphore)
/** 获取信号量（设置最大下载数，当取消一个任务即发生回调后需要释放（增加）一个信号量，当开启一个下载需要获取（减少）一个信号量） */
- (dispatch_semaphore_t)getSemaphore;

@property NSInteger maxDownloadNumber;

@end
