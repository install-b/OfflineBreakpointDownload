//
//  UIImage+ViewImage.h
//  SGCommonCategories
//
//  Created by Shangen Zhang on 16/12/13.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ViewImage)
/** 根据传进来的view返回当前view的截屏图片 */
+ (UIImage *)imageForView:(UIView *)view;
@end
