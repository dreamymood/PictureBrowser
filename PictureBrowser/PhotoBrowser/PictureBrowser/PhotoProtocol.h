//
//  PhotoProtocol.h
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PHOTO_LOADING_DID_END_NOTIFICATION @"PHOTO_LOADING_DID_END_NOTIFICATION"


@protocol PhotoProtocol <NSObject>

@required
- (UIImage *)underlyingImage;
- (void)loadUnderlyingImageAndNotify;
- (void)unloadUnderlyingImage;

@end
