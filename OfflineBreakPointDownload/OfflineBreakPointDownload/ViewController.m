//
//  ViewController.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "ViewController.h"
#import "SGDownloadManager.h"
#import "SGCacheManager.h"

@interface ViewController ()

@property(nonatomic,strong) NSArray *dataList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (IBAction)clickDownload:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    NSInteger index = sender.tag - 11;
    SGDownloadManager *manager = [SGDownloadManager shareManager];
    // 越界 校验
    if (index >= self.dataList.count || index < 0) {
        
        if(sender.tag == 0) {
            [manager stopAllDownloads];
        }
        
        return;
    }
    
    NSURL *url = [NSURL URLWithString:self.dataList[index]];
    
    
    
    if (sender.selected) {
        
        [manager downloadWithURL:url
         
                        progress:^(NSInteger completeSize, NSInteger expectSize) {
            
                                NSLog(@"任务：%zd -- %.2f%%",index,100.0 * completeSize / expectSize);
            
                        }
         
                        complete:^(NSDictionary *respose, NSError *error) {
            
                                [sender setTitle:@"完成" forState:UIControlStateDisabled];
                                sender.selected = NO;
            
            
                                if(error) {
                                    NSLog(@"任务：%zd 下载错误%@",index,error);
                                    return ;
                                }
                            NSLog(@"任务：%zd 下载完成%@",index,respose);
                            
                            sender.enabled = NO;
            
        }];
    }else {
        [manager supendDownloadWithUrl:url.absoluteString];
    }
}


- (NSArray *)dataList {
    if (!_dataList) {
        _dataList = @[
                      @"http://120.25.226.186:32812/resources/videos/minion_01.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_07.mp4",
                      @"http://120.25.226.186:32812/resources/videos/minion_08.mp4",
                      ];
    }
    
    return _dataList;
}

@end
