//
//  LYProgressView.h
//  LYPhotoBrowserDemo
//
//  Created by Shangen Zhang on 17/3/19.
//  Copyright © 2017年 HHLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYProgressView : UIView
/**  快速创建一个50 X 50的进度条View */
+ (instancetype)progressView;

/**  快速创建一个width X width的进度条View */
+ (instancetype)progressViewWithWidth:(CGFloat)width;

/** 进度值 */
@property (nonatomic,assign) CGFloat progress;

@end
