//
//  ImagePickerController.h
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoAssetCell.h"
#import "AssetsGroupViewController.h"

@class ImagePickerController;

typedef NS_ENUM(NSUInteger, ImagePickerControllerFilterType) {
    ImagePickerControllerFilterTypeNone,
    ImagePickerControllerFilterTypePhotos,
    ImagePickerControllerFilterTypeVideos
};

@protocol ImagePickerControllerDelegate;

@interface ImagePickerController : UIViewController

@property (nonatomic,strong,readonly)NSSet *selectedAssetURLs;
@property (nonatomic,strong)NSString *photoPermissionMessage;
@property (nonatomic,assign)ImagePickerControllerFilterType filterType;
@property (nonatomic,weak)id <ImagePickerControllerDelegate> delegate;
@property (nonatomic,strong)AssetsGroupViewController *assetsGroupViewController;
@property (nonatomic,assign) BOOL flag;

//是否直接进入到选图界面 默认是NO
- (instancetype)initWithFlag:(BOOL)flag;

//+ (BOOL)isAuthorized;

- (void)selectAsset:(ALAsset *)asset;
- (void)deselectAsset:(ALAsset *)asset;

@end


@protocol ImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerController:(ImagePickerController *)imagePickerController didTouchAsset:(ALAsset *)asset;

- (void)imagePickerController:(ImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset;
- (void)imagePickerController:(ImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset;

- (void)imagePickerController:(ImagePickerController *)imagePickerController didLongTouch:(ALAsset *)asset inView:(UIView *)view;
- (UIView *)imagePickerController:(ImagePickerController *)imagePickerController viewForCameraRollAccesResuingView:(UIView *)view;

- (void)didCancelImagePickerController:(ImagePickerController *)imagePickerController ;

- (void)imagePickerController:(ImagePickerController *)imagePickerController didFinishPickingMedias:(NSArray *)medias useOriginalImage:(BOOL)useOriginalImage;

//选中图片数
- (NSInteger)numberOfSelectedImageOfImagePickerController:(ImagePickerController *)imagePickerController;

@end