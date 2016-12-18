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
#import "SGPictureTool.h"
#import "UIImage+ViewImage.h"

@interface ViewController ()

@property(nonatomic,strong) NSArray *dataList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor purpleColor];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 截屏
    UIImage *image = [UIImage imageForView:self.view];
    
    [SGPictureTool sg_saveAImage:image withFolferName:nil error:^(NSError *error) {
        error ? NSLog(@"保存失败\n%@",error) : NSLog(@"保存成功");
    }];
    
}

- (IBAction)clickDownload:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    NSInteger index = sender.tag - 11;
    SGDownloadManager *manager = [SGDownloadManager shareManager];
    
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
   
    [[SGDownloadManager shareManager] downloadWithURL:url progress:^(NSInteger completeSize, NSInteger expectSize) { // 进度监听
                        
        NSLog(@"任务：%zd -- %.2f%%",index,100.0 * completeSize / expectSize);
    
    }complete:^(NSDictionary *respose, NSError *error) {  // 下载完成
                        
        [sender setTitle:@"完成" forState:UIControlStateDisabled];
        sender.selected = NO;
        
        if(error) {
            NSLog(@"任务：%zd 下载错误%@",index,error);
            return ;
        }
        
        NSLog(@"任务：%zd 下载完成%@",index,respose);
        // 保存到相册
        NSURL *url1 = [NSURL fileURLWithPath:respose[filePath]];
        [self saveVideoWithURL:url1];
        sender.enabled = NO;
    }];
}

// 保存图片
- (void)saveVideoWithURL:(NSURL *)URL {
    
    [SGPictureTool sg_saveVideo:URL withFolferName:@"test" error:^(NSError *error) {
        if (error) {
            NSLog(@"保存失败");
        }else {
            NSLog(@"保存成功");
        }
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
