//
//  UIColor+Help.m
//  beautyCamera
//
//  Created by admin on 15-5-8.
//
//

#import "UIColor+Help.h"

@implementation UIColor (Help)

+ (UIColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hexValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hexValue & 0xFF)) / 255.0 alpha:alpha];
}

+ (UIColor *)colorWithHex:(NSInteger)hexValue {
    return [UIColor colorWithHex:hexValue alpha:1.0];
}

+ (NSString *)hexFromUIColor:(UIColor *)color {
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetNumberOfComponents(color.CGColor);
        color  = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
    }
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"#%x%x%x",(int)(CGColorGetComponents(color.CGColor))[0] * 255.0,(int)(CGColorGetComponents(color.CGColor))[1] * 255.0,(int)(CGColorGetComponents(color.CGColor))[2] * 255.0];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@",substring,substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha,red,blue,green;
    switch ([colorString length]) {
        case 3: //#RGB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: //#ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: //#RRGGBB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            return nil;
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)newAlpha {
  NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
  CGFloat alpha,red,blue,green;
  switch ([colorString length]) {
    case 3: //#RGB
      alpha = 1.0f;
      red = [self colorComponentFrom:colorString start:0 length:1];
      green = [self colorComponentFrom:colorString start:1 length:1];
      blue = [self colorComponentFrom:colorString start:2 length:1];
      break;
    case 4: //#ARGB
      alpha = [self colorComponentFrom:colorString start:0 length:1];
      red = [self colorComponentFrom:colorString start:1 length:1];
      green = [self colorComponentFrom:colorString start:2 length:1];
      blue = [self colorComponentFrom:colorString start:3 length:1];
      break;
    case 6: //#RRGGBB
      alpha = 1.0f;
      red = [self colorComponentFrom:colorString start:0 length:2];
      green = [self colorComponentFrom:colorString start:2 length:2];
      blue = [self colorComponentFrom:colorString start:4 length:2];
      break;
    case 8: // AARRGGBB
      alpha = [self colorComponentFrom:colorString start:0 length:2];
      red = [self colorComponentFrom:colorString start:2 length:2];
      green = [self colorComponentFrom:colorString start:4 length:2];
      blue = [self colorComponentFrom:colorString start:6 length:2];
      break;
    default:
      return nil;
      break;
  }
  return [UIColor colorWithRed:red green:green blue:blue alpha:newAlpha];
}


@end
