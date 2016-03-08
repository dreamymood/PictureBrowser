//
//  AssetsGroupBottomView.m
//  PictureBrowser
//
//  Created by admin on 15/12/25.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import "AssetsGroupBottomView.h"
#import "OriginalImageDot.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIColor+Help.h"

@interface AssetsGroupBottomView ()

@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) NSMutableArray *selectedAssets;

@property (nonatomic, strong) OriginalImageDot *originalImageDot;

@end

@implementation AssetsGroupBottomView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
      CALayer *bottomBorder = [CALayer layer];
      float width=self.frame.size.width;
      bottomBorder.frame = CGRectMake(0.0f, 0.0f, width, 1.0f);
      bottomBorder.backgroundColor = [UIColor colorWithHexString:@"#cccccc"].CGColor;
      [self.layer addSublayer:bottomBorder];
        
        self.previewButton.center = CGPointMake(10+CGRectGetWidth(self.previewButton.frame)/2, CGRectGetHeight(self.bounds) / 2);
//        [self addSubview:self.previewButton];
        
        self.finishButton.center = CGPointMake(CGRectGetWidth(self.bounds)-10-CGRectGetWidth(self.finishButton.frame)/2, CGRectGetHeight(self.bounds) /2);
        [self addSubview:self.finishButton];
        
        self.countLabel.center = CGPointMake(CGRectGetMinX(self.finishButton.frame)-5-CGRectGetWidth(self.countLabel.frame)/2, self.finishButton.center.y);
        [self addSubview:self.countLabel];
        
        self.originalImageDot.center = CGPointMake(10+CGRectGetWidth(self.originalImageDot.frame)/2, CGRectGetHeight(self.bounds)/2);
//        [self addSubview:self.originalImageDot];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 44);
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setDisplayMode:(AssetsGroupBottomViewMode)displayMode {
    _displayMode = displayMode;
    
    if (self.previewButton.superview) {
        [self.previewButton removeFromSuperview];
    }
    if (self.originalImageDot.superview) {
        [self.originalImageDot removeFromSuperview];
    }
    
    switch (displayMode) {
        case AssetsGroupBottomViewModeNone: {
            self.previewButton.hidden = YES;
            self.originalImageDot.hidden = YES;
            break;
        }
        case AssetsGroupBottomViewModePreview: {
            self.previewButton.hidden = NO;
            self.originalImageDot.hidden = YES;
            [self insertSubview:self.previewButton belowSubview:self.finishButton];
            break;
        }
        case AssetsGroupBottomViewModeOriginShow: {
            self.previewButton.hidden = YES;
            self.originalImageDot.hidden = NO;
            [self insertSubview:self.originalImageDot belowSubview:self.finishButton];
            break;
        }
        default:
            self.previewButton.hidden = NO;
            self.originalImageDot.hidden = YES;
            [self insertSubview:self.previewButton belowSubview:self.finishButton];
            break;
    }
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [[UIButton alloc] init];
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        [_previewButton setTitle:@"预览" forState:UIControlStateSelected];
        [_previewButton setTitleColor:[UIColor colorWithHexString:@"#333333" alpha:0.2] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateSelected];
      _previewButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [_previewButton sizeToFit];
        [_previewButton addTarget:self action:@selector(pressPreviewButton:) forControlEvents:UIControlEventTouchUpInside];
        _previewButton.hidden = YES;
      _previewButton.enabled = NO;
    }
    return _previewButton;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [[UIButton alloc] init];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_finishButton setTitle:@"完成" forState:UIControlStateSelected];
        [_finishButton setTitleColor:[UIColor colorWithHexString:@"#f9c615" alpha:0.2] forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor colorWithHexString:@"#96a8d0"] forState:UIControlStateSelected];
      _finishButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [_finishButton sizeToFit];
        [_finishButton addTarget:self action:@selector(pressFinishButton:) forControlEvents:UIControlEventTouchUpInside];
      _finishButton.enabled = NO;
    }
    return _finishButton;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.backgroundColor = [UIColor colorWithHexString:@"#96a8d0"];
        _countLabel.layer.cornerRadius = 12;
        _countLabel.layer.masksToBounds = YES;
        _countLabel.hidden = YES;
      _countLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _countLabel;
}

- (NSMutableArray *)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] init];
    }
    return _selectedAssets;
}

- (OriginalImageDot *)originalImageDot {
    if (!_originalImageDot) {
        _originalImageDot = [[OriginalImageDot alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        [_originalImageDot addTarget:self action:@selector(originalImageDotButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        _originalImageDot.hidden = YES;
    }
    return _originalImageDot;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex >= self.selectedAssets.count) {
        return;
    }
    _currentIndex = currentIndex;
    if (!self.originalImageDot.selected) {
        [self.originalImageDot showActivityView:NO sizeText:@""];
        return;
    }
    
    [self resetSizeText];
}

- (void)pressPreviewButton:(UIButton *)previewButton {
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupBottomView:didTouchPreviewButton:)]) {
        [_delegate assetsGroupBottomView:self didTouchPreviewButton:previewButton];
    }
}

- (void)pressFinishButton:(UIButton *)finishButton {
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupBottomView:didTouchFinishButton:)]) {
        [_delegate assetsGroupBottomView:self didTouchFinishButton:finishButton];
    }
}

- (void)resetAllButtonState {
    if (self.selectedAssets.count > 0) {
        self.finishButton.selected = YES;
        self.previewButton.selected = YES;
      self.previewButton.enabled = YES;
      self.finishButton.enabled = YES;
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0.85];
        scaleAnimation.duration = .15f;
        scaleAnimation.autoreverses = YES;
        scaleAnimation.repeatCount = 1;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.countLabel.layer addAnimation:scaleAnimation forKey:@"photoAssetCell"];
        self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.selectedAssets.count];
        self.countLabel.hidden = NO;
    } else {
        self.countLabel.hidden = YES;
        self.finishButton.selected = NO;
        self.previewButton.selected = NO;
      self.previewButton.enabled = NO;
      self.finishButton.enabled = NO;
    }
}

- (void)resetAllAssetURLs:(NSArray *)allAssetURLs {
    [self.selectedAssets removeAllObjects];
    self.selectedAssets = [NSMutableArray arrayWithArray:allAssetURLs];
    [self resetAllButtonState];
}

- (void)insertAssetURL:(NSString *)newAssetURL {
    for (NSString *assetURL in self.selectedAssets) {
        if ([assetURL isEqualToString:newAssetURL]) {
            return;
        }
    }
    [self.selectedAssets addObject:newAssetURL];
    [self resetAllButtonState];
}

- (void)removeAssetURL:(NSString *)newAssetURL {
    NSString *existAssetURL = nil;
    for (NSString *assetsURL in self.selectedAssets) {
        if ([assetsURL isEqualToString:newAssetURL]) {
            existAssetURL = assetsURL;
        }
    }
    if (existAssetURL) {
        [self.selectedAssets removeObject:existAssetURL];
    }
    [self resetAllButtonState];
}

- (NSArray *)allSelectedAssets {
    return [NSArray arrayWithArray:self.selectedAssets];
}

- (NSInteger)numberOfSelectedAssets {
    return self.selectedAssets.count;
}

- (void)resetSizeText {
    NSString *assetURL = self.selectedAssets[_currentIndex];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [self.originalImageDot showActivityView:YES sizeText:@""];
    [library assetForURL:[NSURL URLWithString:assetURL] resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        BOOL greaterThanMB = rep.size >= 1024.0*1024.0;
        NSString *sizeText = [NSString stringWithFormat:@"%0.2f%@", greaterThanMB ? rep.size / (1024.0*1024.0) : rep.size / (1024.0), greaterThanMB ? @"M": @"K"];
        [self.originalImageDot showActivityView:NO sizeText:sizeText];
    } failureBlock:^(NSError *error) {
        NSLog(@"获取图片失败：%@", error.localizedDescription);
    }];
}

- (void)originalImageDotButtonPress:(OriginalImageDot *)originalImageDot {
    originalImageDot.selected = !originalImageDot.selected;
    if (originalImageDot.selected) {
        [self resetSizeText];
    } else {
        [self.originalImageDot showActivityView:NO sizeText:@""];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(assetsGroupBottomView:didTouchUseOriginalImageButton:selected:)]) {
        [_delegate assetsGroupBottomView:self didTouchUseOriginalImageButton:originalImageDot selected:originalImageDot.selected];
    }
}

- (void)changeOriginalImageButtonState:(BOOL)selected {
    self.originalImageDot.selected = selected;
    if (selected) {
        [self resetSizeText];
    } else {
        [self.originalImageDot showActivityView:NO sizeText:@""];
    }
}

@end
