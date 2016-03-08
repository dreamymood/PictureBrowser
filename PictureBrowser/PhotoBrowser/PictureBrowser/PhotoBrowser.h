//
//  PhotoBrowser.h
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Photo.h"
#import "PhotoProtocol.h"

@class PhotoBrowser,ALAssetsGroup;

@protocol PhotoBrowserDelegate <NSObject>

- (void)photoBrowser:(PhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(PhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(PhotoBrowser *)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex;

- (void)photoBrowser:(PhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSInteger)index withSelectedPhotoURLs:(NSArray *)selectedPhotoURLs;

- (void)photoBrowser:(PhotoBrowser *)photoBrowser didFinishWithSelectedPhotoURLs:(NSArray *)selectedPhotoURLs useOriginalImage:(BOOL)useOriginalImage;


@end

@interface PhotoBrowser : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate>

@property (nonatomic,assign) id <PhotoBrowserDelegate> delegate;

@property (nonatomic,strong) UIImage *leftArrowImage, *leftArrowSelectedImage;
@property (nonatomic,strong) UIImage *rightArrowImage, *rightArrowSelectedImage;

@property (nonatomic,strong) NSString *backButtonTitle;

//view
@property (nonatomic) BOOL useWhiteBackgroundColor;

@property (nonatomic) BOOL arrowButtonsChangePhotosAnimated;

@property (nonatomic) float animationDuration;

@property (nonatomic) ALAssetsGroup *assetsGroup;

//最大相片数
@property (nonatomic, assign) NSInteger maxNumberOfImages;
@property (nonatomic, assign) BOOL useOriginalImage;

- (instancetype)initWithPhotos:(NSArray *)photos;
- (instancetype)initWithPhotos:(NSArray *)photos animatedFromView:(UIView *)view;

- (instancetype)initWithURLs:(NSArray *)urls;
- (instancetype)initWithURLs:(NSArray *)urls animaedFromView:(UIView *)view;

- (void)reloadData;
- (void)setInitialPageIndex:(NSUInteger)index;
- (id<PhotoProtocol>)photoAtIndex:(NSUInteger)index;

//选中的图片
- (void)insertSelectedPhotos:(NSArray *)selectedPhotos;

@end
