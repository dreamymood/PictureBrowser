//
//  ImagePickerNavViewController.h
//  ImagePickerNew
//
//  Created by admin on 15/6/3.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImagePickerModeProtocol.h"

@protocol ImagePickerNavViewControllerDelegate ;

@interface ImagePickerNavViewController : UINavigationController

@property (nonatomic,assign) id <ImagePickerNavViewControllerDelegate> pickerDelegate;
@property (nonatomic, assign, readonly) ImagePickerMode imagePickerMode;

- (instancetype)initWithImagePickerMode:(ImagePickerMode)mode;

@end

@protocol ImagePickerNavViewControllerDelegate <NSObject>

- (void)imagePickerNavViewControllerDelegate:(ImagePickerNavViewController *)imagePickerController didTouchAsset:(ALAsset *)asset;

- (void)imagePickerNavViewControllerDelegate:(ImagePickerNavViewController *)imagePickerController didFinishPickingMedias:(NSArray *)medias useOriginalImage:(BOOL)useOriginalImage;

- (NSInteger)numberOfSelectedImageOfImagePickerNavViewControllerDelegate:(ImagePickerNavViewController *)imagePickerController;

@end