//
//  SGPictureTool.h
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/7/22.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGPictureTool : NSObject
/**
 *  保存一张图片到相册 并创建一自定义名称的文件夹
 *
 *  @param folderName 相册名称 （nil值时不会创建问价夹只会保存到相机胶卷中）
 *  @param image 要保存的图片
 */
+ (void)sg_saveAImage:(UIImage *)image withFolferName:(NSString *)folderName error:(void(^)(NSError *error))errorBlock;

/**
 *  保存一张图片到相册 并创建一个应用名称的文件夹
 *
 *  @param image 要保存的图片
 */

+ (void)sg_saveAImage:(UIImage *)image  error:(void(^)(NSError *error))errorBlock;

/**
 *  保存一个视频到自定义相册
 *
 *  @param folderName 相册夹名（nil值时不会创建问价夹只会保存到相机胶卷中）
 *  @param fileURL 文件路径
 */
+ (void)sg_saveVideo:(NSURL *)fileURL withFolferName:(NSString *)folderName error:(void (^)(NSError *error))errorBlock;

/**
 *  保存一个视频到自定义（名称为bundleID）相册
 *
 *  @param fileURL 文件路径
 */
+ (void)sg_saveVideo:(NSURL *)fileURL error:(void (^)(NSError *error))errorBlock;

@end
