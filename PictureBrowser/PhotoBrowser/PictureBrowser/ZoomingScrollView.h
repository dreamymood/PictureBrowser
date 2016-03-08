//
//  ZoomingScrollView.h
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"
#import "TapDetectingView.h"
#import "PhotoProtocol.h"

@class PhotoBrowser,Photo;

@interface ZoomingScrollView : UIScrollView <UIScrollViewDelegate,TapDetectingImageViewDelegate,TapDetectingViewDelegate>

@property (nonatomic,strong) TapDetectingImageView *photoImageView;
@property (nonatomic,strong) id <PhotoProtocol> photo;

- (instancetype)initWithPhotoBrowser:(PhotoBrowser *)photoBrowser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScaleForCurrentBounds;
- (void)prepareForReuse;


@end
