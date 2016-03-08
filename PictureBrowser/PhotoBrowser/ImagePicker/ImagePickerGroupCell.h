//
//  ImagePickerGroupCell.h
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImagePickerGroupCell : UITableViewCell

- (void)updateAssetsGroup:(ALAssetsGroup *)assetsGroup;

@end

@interface ImagePickerThumbnailView : UIView

@property (nonatomic,copy) NSArray *thumbnailImages;

@end