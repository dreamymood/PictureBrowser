//
//  OriginalImageDot.m
//  PictureBrowser
//
//  Created by admin on 16/2/23.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "OriginalImageDot.h"

#define originalText @"原图"

@interface OriginalImageDot ()

@property (nonatomic, strong) UIView *circleBackDot;
@property (nonatomic, strong) UIView *circleDot;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation OriginalImageDot

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.circleBackDot];
        [self.circleBackDot addSubview:self.circleDot];
        [self addSubview:self.textLabel];
        [self addSubview:self.activityIndicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    self.circleBackDot.center = CGPointMake(CGRectGetWidth(self.circleDot.frame)/2+4, center.y);
    self.textLabel.center = CGPointMake(CGRectGetMaxX(self.circleDot.frame)+10+CGRectGetWidth(self.textLabel.frame)/2, center.y);
    self.circleDot.center = CGPointMake(CGRectGetWidth(self.circleBackDot.frame)/2, CGRectGetHeight(self.circleBackDot.frame)/2);
    self.activityIndicatorView.center = CGPointMake(CGRectGetMaxX(self.textLabel.frame)+CGRectGetWidth(self.activityIndicatorView.frame), center.y);
    
    //    CGRect frame = self.frame;
    //    frame.size = CGSizeMake(CGRectGetMaxX(self.textLabel.frame), CGRectGetHeight(frame));
    //    self.frame = frame;
}

- (UIView *)circleDot {
    if (!_circleDot) {
        _circleDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        _circleDot.backgroundColor = [UIColor greenColor];
        _circleDot.layer.cornerRadius = 9;
        _circleDot.clipsToBounds = YES;
//        _circleDot.hidden = YES;
        _circleDot.alpha = 0.0;
    }
    return _circleDot;
}

- (UIView *)circleBackDot {
    if (!_circleBackDot) {
        _circleBackDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _circleBackDot.layer.cornerRadius = 12;
        _circleBackDot.layer.borderWidth = 1;
        _circleBackDot.layer.borderColor = [UIColor grayColor].CGColor;
        _circleBackDot.clipsToBounds = YES;
        
        CGSize size = _circleBackDot.frame.size;
        CAShapeLayer *circle = [CAShapeLayer layer];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, size.width, size.height) cornerRadius:size.width / 2];
        
        circle.fillColor = [UIColor clearColor].CGColor;
        circle.path = circlePath.CGPath;
        circle.frame = CGRectMake((_circleBackDot.layer.bounds.size.width - size.width) / 2, (_circleBackDot.layer.bounds.size.height - size.height) / 2, size.width, size.height);
        [_circleBackDot.layer addSublayer:circle];
    }
    return _circleBackDot;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.text = originalText;
        [_textLabel sizeToFit];
        _textLabel.textColor = [UIColor grayColor];
    }
    return _textLabel;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidden = YES;
    }
    return _activityIndicatorView;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [UIView animateWithDuration:0.2 animations:^{
        self.circleDot.alpha = selected;
    } completion:nil];
    self.circleDot.hidden = !selected;
    if (selected) {
        self.textLabel.textColor = [UIColor blackColor];
    } else {
        self.textLabel.textColor = [UIColor grayColor];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [super hitTest:point withEvent:event];
    return self;
}

- (void)showActivityView:(BOOL)show sizeText:(NSString *)sizeText {
    if (show) {
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
        self.textLabel.text = originalText;
        [self.textLabel sizeToFit];
        [self setNeedsDisplay];
    } else {
        self.activityIndicatorView.hidden = YES;
        [self.activityIndicatorView stopAnimating];
        self.textLabel.text = sizeText && ![sizeText isEqualToString:@""] ? [[[originalText stringByAppendingString:@"("] stringByAppendingString:sizeText] stringByAppendingString:@")"] : originalText;
        [self.textLabel sizeToFit];
        [self setNeedsDisplay];
    }
}

@end
