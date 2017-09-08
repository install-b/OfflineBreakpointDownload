//
//  ViewController.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/11/26.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "ViewController.h"
#import "LYDownloadManager.h"
#import "SGCacheManager.h"
#import "LYProgressView.h"


@interface ViewController ()

@property(nonatomic,strong) NSArray *dataList;
@property (weak, nonatomic) IBOutlet LYProgressView *progressView1;

@property (weak, nonatomic) IBOutlet LYProgressView *progressView2;
@property (weak, nonatomic) IBOutlet LYProgressView *progressView3;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor purpleColor];
    
}


- (IBAction)clickDownload:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    NSInteger index = sender.tag - 11;
    SGDownloadManager *manager = [LYDownloadManager shareManager];
    
    if (index >= self.dataList.count || index < 0) { // 越界 校验
        
        if(sender.tag == 0) {
            [manager stopAllDownloads]; // 取消所有下载
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:self.dataList[index]]; // 获取网络请求

    if (sender.selected) {
        [self downlaodWithUrl:url withBtn:sender]; // 开启下载
        
    }else {
        [manager supendDownloadWithUrl:url.absoluteString]; // 暂停下载
    }
}

- (void)downlaodWithUrl:(NSURL *)url withBtn:(UIButton *)sender{
   
    LYProgressView *proressView = nil;
    switch (sender.tag - 10) {
        case 1:
            proressView = self.progressView1;//.progress = 1.0 * completeSize / expectSize;
            break;
        case 2:
            proressView = self.progressView2;//self.progressView2.progress = 1.0 * completeSize / expectSize;
            break;
        case 3:
            proressView = self.progressView3;//self.progressView3.progress = 1.0 * completeSize / expectSize;
            break;
            
        default:
            break;
    }

    [[LYDownloadManager shareManager] downloadWithURL:url progress:^(NSInteger completeSize, NSInteger expectSize) { // 进度监听
        proressView.progress = 1.0 * completeSize / expectSize;
        NSLog(@"任务：%zd -- %.2f%%",index,100.0 * completeSize / expectSize);
        
    }complete:^(NSDictionary *respose, NSError *error) {  // 下载完成
                        
        [sender setTitle:@"完成" forState:UIControlStateDisabled];
        sender.selected = NO;
        
        if(error) {
            NSLog(@"任务：%zd 下载错误%@",index,error);
            
            return ;
        }
        proressView.progress = 1.0;
        NSLog(@"任务：%zd 下载完成%@",index,respose);
       
        sender.enabled = NO;
    }];
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
