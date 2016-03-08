//
//  ImagePickerGroupCell.m
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "ImagePickerGroupCell.h"

@interface ImagePickerGroupCell ()

@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *countLabel;
//@property (nonatomic,strong) UIImageView *thumbnailImageView;
@property (nonatomic,strong) ImagePickerThumbnailView *thumbnailView;

@end

@implementation ImagePickerGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1.0];
    }
    return self;
}

- (ImagePickerThumbnailView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[ImagePickerThumbnailView alloc] initWithFrame:CGRectZero];
        _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_thumbnailView];
    }
    return _thumbnailView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorWithRed:137.0 / 255.0 green:153.0 / 255.0 blue:167.0 / 255.0 alpha:1.0];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [_nameLabel.font fontWithSize:18];
        _nameLabel.numberOfLines = 0;
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor colorWithRed:137.0 / 255.0 green:153.0 / 255.0 blue:167.0 / 255.0 alpha:1.0];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.font = [_countLabel.font fontWithSize:16];
        _countLabel.numberOfLines = 0;
        _countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_countLabel];
    }
    return _countLabel;
}

- (void)updateAssetsGroup:(ALAssetsGroup *)assetsGroup {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(assetsGroup.numberOfAssets - MIN(3, assetsGroup.numberOfAssets), MIN(3, assetsGroup.numberOfAssets))];
    NSMutableArray *thumbnailImages = [[NSMutableArray alloc] init];
    [assetsGroup enumerateAssetsAtIndexes:indexSet options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            UIImage *thumbnailImage = [UIImage imageWithCGImage:result.thumbnail];
            [thumbnailImages addObject:thumbnailImage];
        }
    }];
    self.thumbnailView.thumbnailImages = [[[thumbnailImages reverseObjectEnumerator] allObjects] copy];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@\n",[assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    self.countLabel.text = [NSString stringWithFormat:@"\n%ld",(long)assetsGroup.numberOfAssets];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGFloat x = 10, y = 5, h = CGRectGetHeight(self.bounds) - 10, w = h;
//    self.thumbnailImageView.frame = CGRectMake(x, y, w, h);
//    
//    x = x + w + 15 , y = 0 , w = CGRectGetWidth(self.bounds) - (2 * x) , h = CGRectGetHeight(self.bounds);
//    self.nameLabel.frame = CGRectMake(x, y, w, h);
//    
////    w = 50;
////    x = CGRectGetWidth(self.bounds) - (w) - 20;
////    self.countLabel.frame = CGRectMake(x, y, w, h);
//    
//    self.countLabel.frame = self.nameLabel.frame;
    self.thumbnailView.frame = CGRectMake(8, 4, 70, 74);
    self.nameLabel.frame = CGRectMake(8 + 70 + 18, 0, 180, CGRectGetHeight(self.bounds));
    self.countLabel.frame = CGRectMake(8 + 70 + 18 , 0, 180, CGRectGetHeight(self.bounds));
    
}

@end


@implementation ImagePickerThumbnailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setThumbnailImages:(NSArray *)thumbnailImages {
    _thumbnailImages = thumbnailImages;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    
    if (_thumbnailImages.count == 3) {
        UIImage *thumbnailImage = _thumbnailImages[2];
        CGRect thumbnailImageRect = CGRectMake(4.0, 0, 62.0, 62.0);
        CGContextFillRect(context, thumbnailImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
    if (_thumbnailImages.count >= 2) {
        UIImage *thumbnailImage = _thumbnailImages[1];
        CGRect thumbnialImageRect = CGRectMake(2.0, 2.0, 66.0, 66.0);
        CGContextFillRect(context, thumbnialImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnialImageRect, 0.5, 0.5)];
    }
    UIImage *thumbnialImage = _thumbnailImages[0];
    CGRect thumbnailImageRect = CGRectMake(0, 4.0, 70.0, 70.0);
    CGContextFillRect(context, thumbnailImageRect);
    [thumbnialImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    
}

@end
