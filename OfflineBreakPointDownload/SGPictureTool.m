//
//  SGPictureTool.m
//  OfflineBreakPointDownload
//
//  Created by Shangen Zhang on 16/7/22.
//  Copyright © 2016年 Shangen Zhang. All rights reserved.
//

#import "SGPictureTool.h"
#import <Photos/Photos.h>

@implementation SGPictureTool
#pragma mark - 接口方法
+ (void)sg_saveAImage:(UIImage *)image withFolferName:(NSString *)folderName error:(void(^)(NSError *error))error {
    [self saveMedia:image withFolferName:folderName error:error];
}

+ (void)sg_saveAImage:(UIImage *)image  error:(void(^)(NSError *error))error  {
    [self saveMedia:image withFolferName:[NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleIdentifierKey] error:error];
}

+ (void)sg_saveVideo:(NSURL *)fileURL withFolferName:(NSString *)folderName error:(void (^)(NSError *))error {
    [self saveMedia:fileURL withFolferName:folderName error:error];
}

+ (void)sg_saveVideo:(NSURL *)fileURL error:(void (^)(NSError *))error {
    
    [self saveMedia:fileURL withFolferName:[NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleIdentifierKey] error:error];
}
#pragma mark -
/** 保存图片或视频到相册 获取用户设置状态 */
+ (void)sg_saveMedia:(id)media withFolferName:(NSString *)folderName error:(void(^)(NSError *error))error {
    
    PHAuthorizationStatus oldAuthory = [PHPhotoLibrary authorizationStatus];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized :
                [self saveMedia:media withFolferName:folderName error:error];
                return ;
                
            case PHAuthorizationStatusDenied :
                if (oldAuthory == PHAuthorizationStatusNotDetermined) return ;
                if (error) {
                    NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:1 userInfo:@{@"error" : @"请设置允许访问相册"}];
                    error(err);
                }
                return ;
                
            case PHAuthorizationStatusRestricted:
                if (error) {
                    NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:1 userInfo:@{@"error" : @"系统无法访问相册"}];
                    error(err);
                }
                return ;
            default:
                break;
        }
    }];
    
}
#pragma mark -
/** 用户允许访问相册 */
+ (void)saveMedia:(id)media withFolferName:(NSString *)folderName error:(void (^)(NSError *))errorBlock {
    // 将相机胶卷的相片移至新的相册
    // createdAsset 图片  createdCollection相册 都存在时才进行
    PHFetchResult<PHAsset *> *createdAsset = nil;
    
    if ([media isKindOfClass:[UIImage class]]) {
        createdAsset = [self createdCollectionWithImage:media]; // 保存图片到相机胶卷
    }else if ([media isKindOfClass:[NSURL class]]) {
        createdAsset = [self createdCollectionWithVideo:media]; // 保存视频到相机胶卷
    }
    
    if (!folderName) { // 文件名称 不转移图片或视频
        return;
    }
    
    // 创建文件夹
    PHAssetCollection *createdCollection = [self createdCollectionFolderName:folderName];
    if (createdAsset == nil || createdCollection == nil) {
        NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:1 userInfo:@{@"error" : @"保存失败"}];
        !errorBlock ? : errorBlock(err);
        return;
    }
    
    // 将相机胶卷的相片移至新的相册（实际上是引用到自定义相册）
    NSError *error = nil;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        
        [request insertAssets:createdAsset atIndexes:[NSIndexSet indexSetWithIndex:0]];
        
    } error:&error];
    
    if (!errorBlock) {
        return;
    }
    // 回调
    error ? errorBlock(error) : errorBlock(nil);
}

#pragma mark -
/** 创建图片 */
+ ( PHFetchResult<PHAsset *> *)createdCollectionWithImage:(UIImage *)image{
    // 1、将图片保存至相机胶卷
    __block NSString *creatAssetID = nil;
    
    // 保存照片 到胶卷  并获取标示
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        creatAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (creatAssetID == nil) return nil;
    
    // 根据标示获取 刚刚保存到系统胶卷相册的图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[creatAssetID] options:nil];
}

/** 创建视频 */
+ ( PHFetchResult<PHAsset *> *)createdCollectionWithVideo:(NSURL *)fileURL{
    // 1、将视频保存至相机胶卷
    __block NSString *creatAssetID = nil;
    
    // 保存视频 到胶卷  并获取标示
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        creatAssetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (creatAssetID == nil) return nil;
    
    // 根据标示获取 刚刚保存到系统胶卷相册的视频
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[creatAssetID] options:nil];
}

#pragma mark -
/** 创建图片相册 */
+ (PHAssetCollection *)createdCollectionFolderName:(NSString *)folderName {
    
    // 获取colection 数组
    PHFetchResult<PHAssetCollection *> *colections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 遍历 colection 数组
    for (PHAssetCollection *colection in colections) {
        if ([colection.localizedTitle isEqualToString:folderName]) {
            return  colection;
        }
    }
    __block NSString *createdCollectionID = nil;
    
    // 自定义相册名或根据bundle名创建 自定义相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionID  =  [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:folderName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionID == nil) return nil;
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionID] options:nil].firstObject;
    
}

@end
