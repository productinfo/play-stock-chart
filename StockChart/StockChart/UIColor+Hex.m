//
//  UIColor+Hex.m
//  ShinobiControls
//
//  Created by Sam Davies on 06/12/2012.
//  Copyright (c) 2012 ScottLogic. All rights reserved.
//
// Found this on http://www.pixeldock.com/blog/uicolorcolorwithhex-a-category-to-get-an-uicolor-from-a-hex-value-or-a-hex-string/
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor*)colourWithHexValue:(uint)hexValue andAlpha:(CGFloat)alpha {
    return [UIColor
            colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
            green:((float)((hexValue & 0xFF00) >> 8))/255.0
            blue:((float)(hexValue & 0xFF))/255.0
            alpha:alpha];
}

+ (UIColor *)colourWithHexString:(NSString *)hexString andAlpha:(CGFloat)alpha
{
    UIColor *col;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#"
                                                     withString:@"0x"];
    uint hexValue;
    if ([[NSScanner scannerWithString:hexString] scanHexInt:&hexValue]) {
        col = [self colourWithHexValue:hexValue andAlpha:alpha];
    } else {
        // invalid hex string
        col = [self blackColor];
    }
    return col;
}

- (NSString *)hexString {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    // iOS>5
    if ( [self respondsToSelector: @selector(getRed:green:blue:alpha:)] ) {
        [self getRed: &red green: &green blue: &blue alpha: &alpha];
    }
    else {
        const CGFloat *components = CGColorGetComponents( [self CGColor] );
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }
    return [NSString stringWithFormat: @"#%02X%02X%02X",
            (int) roundf( red * 255.0 ),
            (int) roundf( green * 255.0 ),
            (int) roundf( blue * 255.0 )];
}

@end
