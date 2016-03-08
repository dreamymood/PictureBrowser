//
//  PhotoAssetCell.h
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class PhotoAssetCell ,PhotoAssetCheckmarkView;

@protocol PhotoAssetCellDelegate <NSObject>

- (void)photoAssetCell:(PhotoAssetCell *)photoAssetCell;
- (void)photoAssetCell:(PhotoAssetCell *)photoAssetCell didTouchCheckmark:(PhotoAssetCheckmarkView *)checkmarkView;

@end

@interface PhotoAssetCell : UICollectionViewCell

@property (nonatomic,assign) id <PhotoAssetCellDelegate> delegate;

- (void)updateWithAsset:(ALAsset *)asset;

@end
