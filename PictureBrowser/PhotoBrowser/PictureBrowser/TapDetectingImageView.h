//
//  TapDetectingImageView.h
//  ImagePickerNew
//
//  Created by Daniel on 15/6/2.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapDetectingImageViewDelegate;

@interface TapDetectingImageView : UIImageView

@property (nonatomic,assign) id <TapDetectingImageViewDelegate> delegate;

@end


@protocol TapDetectingImageViewDelegate <NSObject>

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end