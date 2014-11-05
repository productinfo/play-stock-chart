//
//  ShinobiColourUtilities.m
//  ShinobiControls
//
//  Created by  on 08/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "ShinobiColourUtilities.h"
#import "UIColor+Hex.h"

@implementation ShinobiColourUtilities

+ (UIColor*)getShinobiMidnightColour  {
    return [UIColor colorWithRed:26.f/255.f green:25.5/255.f blue:25.f/255.f alpha:1.f];
}

+ (UIColor*)getShinobiDarkGrey   {
    return [UIColor colorWithRed:35.f/255.f green:31.f/255.f blue:32.f/255.f alpha:1.f];
}

+ (UIColor*)getShinobiLightGrey {
    return [UIColor colorWithRed:70.f/255.f green:62.f/255.f blue:64.f/255.f alpha:1.f];
}

+ (UIColor*)getShinobiGrey {
    return [UIColor colorWithRed:133.f/255.f green:133.f/255.f blue:133.f/255.f alpha:1.f];
}

+ (UIColor *)getShinobiBrown
{
    return [UIColor colorWithRed:64/255.f green:51/255.f blue:39/255.f alpha:1.f];
}

+ (UIColor *)getEssentialsColour
{
    return [UIColor colourWithHexString:@"#015184" andAlpha:1.0f];
}

+ (UIColor*)getChartsColour {
    return [UIColor colorWithRed:159.f/255.f green:20.f/255.f blue:93.f/255.f alpha:1.f];
}

+ (UIColor*)getShinobiResourcesColour {
    return [UIColor colorWithRed:92.f/255.f green:160.f/255.f blue:56.f/255.f alpha:1.f];
}

+ (UIColor *)getGridsColour {
    return [UIColor colorWithRed:221.f/255.f green:107.f/255.f blue:29.f/255.f alpha:1.f];
}

+ (UIColor *)getDashboardColour {
    return [UIColor colorWithRed:48.f/255.f green:146.f/255.f blue:182.f/255.f alpha:1.f];
}

+ (UIColor *)getOverlayBGColour {
    return [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
}

+ (UIColor *)getShinobiRedColour {
    return [UIColor colorWithRed:180/255.0 green:18/255.0 blue:18/255.0 alpha:1.0];
}

+ (UIColor *)getShinobiGreenColour {
    return [UIColor colourWithHexString:@"497F3B" andAlpha:1.f];
}

+ (UIColor *)getShinobiLightGreenColour
{
    return [UIColor colorWithRed:177/255.0 green:211/255.0 blue:85/255.0 alpha:1.0];
}

+ (UIColor *)getShinobiLightBlue
{
    return [UIColor colorWithRed:64/255.f green:150/255.f blue:238/255.f alpha:1.f];
}


+ (CGFloat)getAlphaComponentOfColour:(UIColor *)colour
{
    CGFloat alpha = 1.f;
    // We will test 2 colour spaces
    if(CGColorSpaceGetModel(CGColorGetColorSpace(colour.CGColor)) == kCGColorSpaceModelRGB) {
        const CGFloat *components = CGColorGetComponents(colour.CGColor);
        // Determine whether we have an alpha channel
        if(CGColorGetNumberOfComponents(colour.CGColor) == 4) {
            alpha = components[3];
        }
    } else if(CGColorSpaceGetModel(CGColorGetColorSpace(colour.CGColor)) == kCGColorSpaceModelMonochrome) {
        const CGFloat *components = CGColorGetComponents(colour.CGColor);
        if(CGColorGetNumberOfComponents(colour.CGColor) == 2) {
            alpha = components[1];
        }
    }
    return alpha;
}
@end
