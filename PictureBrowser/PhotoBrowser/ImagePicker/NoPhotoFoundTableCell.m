//
//  NoPhotoFoundTableCell.m
//  PictureBrowser
//
//  Created by admin on 15/6/11.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import "NoPhotoFoundTableCell.h"

@interface NoPhotoFoundTableCell ()

@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) UILabel *detailsLabel;

@end

@implementation NoPhotoFoundTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1.0];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:137.0 / 255.0 green:153.0 / 255.0 blue:167.0 / 255.0 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [_titleLabel.font fontWithSize:22];
        _titleLabel.text = @"无图片";
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailsLabel {
    if (!_detailsLabel) {
        _detailsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _detailsLabel.backgroundColor = [UIColor clearColor];
        _detailsLabel.textColor = [UIColor colorWithRed:137.0 / 255.0 green:153.0 / 255.0 blue:167.0 / 255.0 alpha:1.0];
        _detailsLabel.textAlignment = NSTextAlignmentCenter;
        _detailsLabel.font = [_detailsLabel.font fontWithSize:16];
        _detailsLabel.text = @"你可以休息下";
        _detailsLabel.numberOfLines = 0;
        [self.contentView addSubview:_detailsLabel];
    }
    return _detailsLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat x = 0, w = CGRectGetWidth(self.bounds), h = 22;
    //    CGFloat y = (CGRectGetHeight(self.contentView.bounds) / 2) - 70;
    CGFloat y = self.center.y - h;
    
    self.titleLabel.frame = CGRectMake(x, y, w, h);
    
    y += h + 10;
    h = 40;
    self.detailsLabel.frame = CGRectMake(x, y, w, h);
}

@end
