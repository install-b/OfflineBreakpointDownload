//
//  UIImage+ViewImage.m
//  SGCommonCategories
//
//  Created by Shangen Zhang on 16/12/13.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "UIImage+ViewImage.h"

@implementation UIImage (ViewImage)
// 根据传进来的view返回当前view的截屏图片
+ (UIImage *)imageForView:(UIView *)view {
    //把UIView的上的内容生成一张图片
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    // 获取当前上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //把View的内容渲染到上下文当中
    [view.layer renderInContext:ctx];
    
    //从上下文当中生成一张图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    // 返回一张图片
    return newImage;
}
@end
