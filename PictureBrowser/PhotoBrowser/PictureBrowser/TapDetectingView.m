//
//  TapDetectingView.m
//  PictureBrowser
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import "TapDetectingView.h"

@implementation TapDetectingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger touchCount = touch.tapCount;
    switch (touchCount) {
        case 1:
            [self handleSingleTap:touch];
            break;
        case 2:
            [self handleDoubleTap:touch];
            break;
        case 3:
            [self handleTripleTap:touch];
            break;
            
        default:
            break;
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
    if (_delegate && [_delegate respondsToSelector:@selector(view:singleTapDetected:)]) {
        [_delegate view:self singleTapDetected:touch];
    }
}

- (void)handleDoubleTap:(UITouch *)touch {
    if (_delegate && [_delegate respondsToSelector:@selector(view:doubleTapDetected:)]) {
        [_delegate view:self doubleTapDetected:touch];
    }
}

- (void)handleTripleTap:(UITouch *)touch {
    if (_delegate && [_delegate respondsToSelector:@selector(view:tripleTapDetected:)]) {
        [_delegate view:self tripleTapDetected:touch];
    }
}

@end
