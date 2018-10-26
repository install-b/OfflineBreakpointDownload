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
            proressView = self.progressView1;
            break;
        case 2:
            proressView = self.progressView2;
            break;
        case 3:
            proressView = self.progressView3;
            break;
            
        default:
            break;
    }

    [[LYDownloadManager shareManager] downloadWithURL:url progress:^(NSInteger completeSize, NSInteger expectSize) { // 进度监听
        proressView.progress = 1.0 * completeSize / expectSize;
        NSLog(@"任务：%d -- %.2f%%",(int)index,100.0 * completeSize / expectSize);
        
    }complete:^(NSDictionary *respose, NSError *error) {  // 下载完成
        
        [sender setTitle:@"完成" forState:UIControlStateDisabled];
        sender.selected = NO;
        
        if(error) {
            NSLog(@"任务：%d 下载错误%@",(int)index,error);
            
            return ;
        }
        proressView.progress = 1.0;
        NSLog(@"任务：%d 下载完成%@",(int)index,respose);
       
        sender.enabled = NO;
    }];
}


- (NSArray *)dataList {
    if (!_dataList) {
        _dataList = @[
                      @"https://bityou-io.oss-cn-beijing.aliyuncs.com/4106469bc2c5a0a8_4a0280988003426f.mp3",
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1537016004758&di=994420f271c6595be0272a5e3d0e956e&imgtype=0&src=http%3A%2F%2Fs16.sinaimg.cn%2Fmiddle%2F70858d01gc87794e6164f%26690",
                      @"http://120.25.226.186:32812/resources/videos/minion_08.mp4",
                      ];
    }
    return _dataList;
}
@end
