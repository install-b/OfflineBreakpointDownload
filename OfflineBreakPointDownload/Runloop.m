//
//  Runloop.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 17/1/14.
//  Copyright © 2017年 Shangen Zhang. All rights reserved.
//

#import "Runloop.h"

@interface Runloop ()
/** 发送线程 */
@property (nonatomic,strong) NSThread * sendThread;

/** 心跳定时器 */
@property (nonatomic,weak) NSTimer * timer;


/** 运行循环 */
@property (nonatomic,weak) NSRunLoop * heatRunLoop;
@end

@implementation Runloop

- (void)sendMessageWithObjct:(id)obj {
    
    
    
    [self performSelector:@selector(sendMessageWithData:) onThread:self.sendThread withObject:obj waitUntilDone:NO];
    
}

- (void)sendMessageWithData:(id)obj {
    
    NSLog(@"%@----%@",[NSThread currentThread].name,obj);
}



- (NSThread *)sendThread {
    
    if (!_sendThread) {
        NSLog(@"thread");
        // 创建线程 开启运行循环
        _sendThread = [[NSThread alloc] initWithTarget:self selector:@selector(createRunloop) object:nil];
        // 线程命名
        _sendThread.name = @"sendMessageThread";
        // 开启线程
        [_sendThread start];
    }
    
    return _sendThread;
}


- (void)createRunloop {
    
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    
    NSTimer * timer = [NSTimer timerWithTimeInterval:60.0 target:self selector:@selector(sendHeat) userInfo:nil repeats:YES];
    
    self.timer = timer;
    
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    
    self.heatRunLoop = runLoop;
    
    NSLog(@"creating");
    
    [runLoop run];
    
    NSLog(@"created");
    
}


- (void)sendHeat {
    NSLog(@"发送心跳");
    
    
}

- (void)invalidateRunLoop {
    [self.timer invalidate];
    [self.sendThread cancel];
    self.sendThread = nil;
}

@end
