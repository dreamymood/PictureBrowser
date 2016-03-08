//
//  TapDetectingView.h
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapDetectingViewDelegate ;

@interface TapDetectingView : UIView

@property (nonatomic,assign) id <TapDetectingViewDelegate> delegate;

@end

@protocol TapDetectingViewDelegate <NSObject>

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end
