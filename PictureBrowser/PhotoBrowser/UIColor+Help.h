//
//  UIColor+Help.h
//  beautyCamera
//
//  Created by admin on 15-5-8.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (Help)

+ (UIColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(NSInteger)hexValue ;
+ (NSString *)hexFromUIColor:(UIColor *)color;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;


@end
