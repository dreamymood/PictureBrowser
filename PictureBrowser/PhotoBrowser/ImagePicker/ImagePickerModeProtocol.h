//
//  ImagePickerModeProtocol.h
//  PictureBrowser
//
//  Created by admin on 16/2/24.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ImagePickerMode) {
    ImagePickerModeNone,
    ImagePickerModeUseOriginalImage,
};

@interface ImagePickerModeProtocol : NSObject

@property (nonatomic, assign) ImagePickerMode imagePickerMode;

+ (instancetype)sharedInstance;

@end
