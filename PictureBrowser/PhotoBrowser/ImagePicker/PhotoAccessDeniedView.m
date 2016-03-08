//
//  PhotoAccessDeniedView.m
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "PhotoAccessDeniedView.h"

@interface PhotoAccessDeniedView ()

@property (nonatomic,strong)UILabel *stepsView;
@property (nonatomic,strong) UIImageView *lockImageView;
@property (nonatomic,strong) UILabel *descView;

@end

@implementation PhotoAccessDeniedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.lockImageView];
        [self addSubview:self.descView];
        [self addSubview:self.stepsView];
        
        self.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1.0];
    }
    return self;
}

- (UILabel *)stepsView {
    if (!_stepsView) {
        _stepsView = [[UILabel alloc]initWithFrame:CGRectZero];
        _stepsView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
        _stepsView.textAlignment = NSTextAlignmentCenter;
        _stepsView.numberOfLines = 0;
        _stepsView.textColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
        
//        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        _stepsView.text = @"你可以在「隐私设置」中启用存取。";
    }
    return _stepsView;
}

- (UIImageView *)lockImageView {
    if (!_lockImageView) {
        _lockImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AssetsPickerLocked" ofType:@"png"]];
        _lockImageView.image = image;
        _lockImageView.contentMode = UIViewContentModeCenter;
    }
    return _lockImageView;
}

- (UILabel *)descView {
    if (!_descView) {
        _descView = [[UILabel alloc] initWithFrame:CGRectZero];
        _descView.text = @"此应用无法使用您的照片或视频";
        _descView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
        _descView.textAlignment = NSTextAlignmentCenter;
        _descView.numberOfLines = 0;
        _descView.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return _descView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = 0, y = 100, w = 132, h = 169;
    self.lockImageView.frame = CGRectMake(x, y, w, h);
    self.lockImageView.center = CGPointMake(self.center.x, self.lockImageView.center.y);
    
    x = 0, y = y + h + 5 , w = CGRectGetWidth(self.bounds), h = 20;
    self.descView.frame = CGRectMake(x, y, w, h);
    
    x = 0, y = y + h + 5, h = 20;
    self.stepsView.frame = CGRectMake(x, y, w, h);
    
}

@end
