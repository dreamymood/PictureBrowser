//
//  AssetsGroupViewController.h
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define DEFAULT_NUMBER_OF_SELECTED_IMAGE 8

@class AssetsGroupViewController,PhotoAssetCheckmarkView;
@protocol AssetsGroupViewControllerDelegate;

@interface AssetsGroupViewController : UICollectionViewController <UIAlertViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)ALAssetsGroup *assetGroup;
@property (nonatomic,strong)ALAssetsLibrary *assetsLibrary;
@property (nonatomic,weak)id <AssetsGroupViewControllerDelegate> delegate;

- (void)selectAsset:(ALAsset *)asset;
- (void)deselectAsset:(ALAsset *)asset;

- (void)selectAssetsHavingURLs:(NSSet *)assetURLs;

@end

@protocol AssetsGroupViewControllerDelegate <NSObject>

@optional
- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didTouchAsset:(ALAsset *)asset;
- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didTouchCheckmark:(PhotoAssetCheckmarkView *)checkmarkView asset:(ALAsset *)asset;

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didSelectAsset:(ALAsset *)asset;
- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didDeselectAsset:(ALAsset *)asset;

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didSwipeLeft:(UISwipeGestureRecognizer *)recognizer;
- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didSwipeRight:(UISwipeGestureRecognizer *)recognizer;

- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didAppear:(ALAssetsGroup *)assetsGroup;
- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didLongTouch:(ALAsset *)asset inView:(UIView *)cell;

- (void)assetsGroupViewControllerDidReloadAssets:(AssetsGroupViewController *)assetsGroupViewController;

//底部栏的响应事件
- (void)assetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController didFinishPickingMedias:(NSArray *)medias useOriginalImage:(BOOL)useOriginalImage;

- (void)didCancelAssetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController;

//允许选中图片数
- (NSInteger)numberOfSelectedImageOfAssetsGroupViewController:(AssetsGroupViewController *)assetsGroupViewController;

@end
