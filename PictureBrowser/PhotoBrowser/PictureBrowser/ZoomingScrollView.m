//
//  ZoomingScrollView.m
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import "ZoomingScrollView.h"
#import "PhotoBrowser.h"
#import "Photo.h"

@interface PhotoBrowser ()

- (UIImage *)imageForPhoto:(id<PhotoProtocol>)photo;

@end

@interface ZoomingScrollView ()

@property (nonatomic,weak) PhotoBrowser *photoBrowser;
@property (nonatomic,strong) TapDetectingView *tapView;
//@property (nonatomic,strong) DACircularProgressView *progressView;

@end

@implementation ZoomingScrollView

- (instancetype)initWithPhotoBrowser:(PhotoBrowser *)photoBrowser {
    self = [super init];
    if (self) {
        self.photoBrowser = photoBrowser;
        
        _tapView = [[TapDetectingView alloc] initWithFrame:self.bounds];
        _tapView.delegate = self;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tapView];
        
        _photoImageView = [[TapDetectingImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.delegate = self;
        _photoImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_photoImageView];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenBounds.size.width;
        CGFloat screenHeight = screenBounds.size.height;
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            screenWidth = screenBounds.size.height;
            screenHeight = screenBounds.size.width;
        }
        
//        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake((screenWidth - 35.) / 2., (screenHeight - 35.) / 2., 35., 35.)];
//        [_progressView setProgress:0.0f];
//        _progressView.tag = 101;
//        _progressView.thicknessRatio = 0.1;
//        _progressView.roundedCorners = NO;
//        _progressView.trackTintColor = [UIColor colorWithWhite:0.2 alpha:1];
//        _progressView.progressTintColor = [UIColor colorWithWhite:1.0 alpha:1];
//        [self addSubview:_progressView];
        
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
    }
    return self;
}

- (void)setPhoto:(id<PhotoProtocol>)photo {
    _photoImageView.image = nil;
    if (_photo != photo) {
        _photo = photo;
    }
    [self displayImage];
}

- (void)prepareForReuse {
    self.photo = nil;
}

- (void)displayImage {
    if (_photo && self.photoImageView.image == nil) {
        self.maximumZoomScale = 1.0;
        self.minimumZoomScale = 1.0;
        self.zoomScale = 1.0;
        
        self.contentSize = CGSizeMake(0, 0);
        
        UIImage *image = [self.photoBrowser imageForPhoto:_photo];
        if (image) {
            
            _photoImageView.image = image;
            _photoImageView.hidden = NO;
            
            CGRect photoImageViewFrame;
            photoImageViewFrame.origin = CGPointZero;
            photoImageViewFrame.size = image.size;
            
            _photoImageView.frame = photoImageViewFrame;
            self.contentSize = photoImageViewFrame.size;
            
            [self setMaxMinZoomScaleForCurrentBounds];
        } else {
            _photoImageView.hidden = YES;
        }
        [self setNeedsLayout];
    }
}

- (void)displayImageFailure {
    
}

- (void)setMaxMinZoomScaleForCurrentBounds {
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 1.0;
    self.zoomScale = 1.0;
    
    if (_photoImageView.image == nil) {
        return;
    }
    
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.frame.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    if (xScale > 1 && yScale > 1) {
//        minScale = 1.0;
    }
    CGFloat maxScale = 4.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = maxScale;
    self.zoomScale = minScale;
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    _tapView.frame = self.bounds;
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter)) {
        _photoImageView.frame = frameToCenter;
    }
}

#pragma mark -UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
//    [_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [_photoBrowser hideControlsAfterDelay];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark -TapImageViewDelegate
- (void)handleSingleTap:(CGPoint)touchPoint {
//    [_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    [NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
    
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
    
//    [_photoBrowser hideControlsAfterDelay];
}

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}

- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:view]];
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:view]];
}



@end
