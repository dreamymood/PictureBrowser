//
//  PhotoAssetCell.m
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "PhotoAssetCell.h"
#import "PhotoAssetCheckmarkView.h"

@interface PhotoAssetCell ()

//缩略图
@property (nonatomic,strong)UIImageView *thumbnailImageView;
//选择时的边框
@property (nonatomic,strong)PhotoAssetCheckmarkView *checkmarkView;

@end

@implementation PhotoAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.thumbnailImageView];
        [self addSubview:self.checkmarkView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *tapCheckmarkGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCheckmark:)];
        tapCheckmarkGesture.numberOfTapsRequired = 1;
        tapCheckmarkGesture.numberOfTouchesRequired = 1;
        [self.checkmarkView addGestureRecognizer:tapCheckmarkGesture];
    }
    return self;
}

- (UIImageView *)thumbnailImageView {
    if (!_thumbnailImageView) {
        _thumbnailImageView = [[UIImageView alloc]init];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _thumbnailImageView.clipsToBounds = YES;
    }
    return _thumbnailImageView;
}

- (PhotoAssetCheckmarkView *)checkmarkView {
    if (!_checkmarkView) {
        _checkmarkView = [[PhotoAssetCheckmarkView alloc]init];
        _checkmarkView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _checkmarkView.hidden = NO;
    }
    return _checkmarkView;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
//    if (selected) {
//        [self showCheckmarkView];
//        self.layer.borderWidth = 2.0f;
//        self.layer.borderColor = [UIColor colorWithRed:57.0 / 255.0f  green:187.0 / 255.0f blue:181.0 / 255.0 alpha:1.0].CGColor;
//    } else {
//        [self hideCheckmarkView];
//        self.layer.borderWidth = 0.0f;
//        self.layer.borderColor = [UIColor clearColor].CGColor;
//    }
    
    self.checkmarkView.selected = selected;
}

- (void)showCheckmarkView {
    self.checkmarkView.hidden = NO;
}

- (void)hideCheckmarkView {
    self.checkmarkView.hidden =YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.thumbnailImageView.frame = self.bounds;
//    CGFloat w = 24 ,h = w;
//    CGFloat x = CGRectGetWidth(self.bounds) - w - 3;
//    CGFloat y = CGRectGetHeight(self.bounds) - h - 3;
//    self.checkmarkView.frame = CGRectMake(x, y, w, h);
    
    CGFloat w = 30 ,h = w;
    CGFloat x = CGRectGetWidth(self.bounds) - w - 3;
    CGFloat y = 3;
    self.checkmarkView.frame = CGRectMake(x, y, w, h);
}

- (void)updateWithAsset:(ALAsset *)asset {
    self.thumbnailImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

- (void)tapCell:(UITapGestureRecognizer *)tapGesture {
//    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//    scaleAnimation.toValue = [NSNumber numberWithFloat:0.85];
//    scaleAnimation.duration = .15f;
//    scaleAnimation.autoreverses = YES;
//    scaleAnimation.repeatCount = 1;
//    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [self.layer addAnimation:scaleAnimation forKey:@"photoAssetCell"];
    
    if (_delegate && [_delegate respondsToSelector:@selector(photoAssetCell:)]) {
        [_delegate photoAssetCell:self];
    }
}

- (void)tapCheckmark:(UITapGestureRecognizer *)tapGesture {
    if (_delegate && [_delegate respondsToSelector:@selector(photoAssetCell:didTouchCheckmark:)]) {
        [_delegate photoAssetCell:self didTouchCheckmark:self.checkmarkView];
    }
}

@end
