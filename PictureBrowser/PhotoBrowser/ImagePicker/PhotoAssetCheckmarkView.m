//
//  PhotoAssetCheckmarkView.m
//  ImagePickerNew
//
//  Created by admin on 15/6/1.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "PhotoAssetCheckmarkView.h"

@interface PhotoAssetCheckmarkView ()

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *unselectedImage;

@end

@implementation PhotoAssetCheckmarkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(24.0, 24.0);
}

- (UIImage *)selectedImage {
    if (!_selectedImage) {
        _selectedImage = [UIImage imageNamed:@"img_big_selected"];
    }
    return _selectedImage;
}

- (UIImage *)unselectedImage {
    if (!_unselectedImage) {
        _unselectedImage = [UIImage imageNamed:@"img_big_unselected"];
    }
    return _unselectedImage;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
  
//    CGContextSetRGBFillColor(context, 57.0 / 255.0 , 187.0 / 255.0 , 181.0 / 255.0, 1.0);
//    CGContextFillEllipseInRect(context, CGRectInset(self.bounds, 1.0, 1.0));
//    
//    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
//    CGContextSetLineWidth(context, 1.2);
//    
//    CGContextMoveToPoint(context, 6.0, 12.0);
//    CGContextAddLineToPoint(context, 10.0, 16.0);
//    CGContextAddLineToPoint(context, 18.0, 8.0);
//    
//    CGContextStrokePath(context);
    
    UIImage *icon;
    if (self.selected) {
        icon = self.selectedImage;
    } else {
        icon = self.unselectedImage;
    }
  [icon drawInRect:rect];
//    CGContextDrawImage(context, self.bounds, icon.CGImage);
}

@end
