//
//  ShinobiColourUtilities.h
//  ShinobiControls
//
//  Created by  on 08/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShinobiColourUtilities : NSObject

+ (UIColor*)getShinobiMidnightColour;

+ (UIColor*)getShinobiDarkGrey;
+ (UIColor*)getShinobiLightGrey;
+ (UIColor*)getShinobiGrey;
+ (UIColor*)getShinobiBrown;

+ (UIColor*)getChartsColour;
+ (UIColor*)getGridsColour;
+ (UIColor*)getEssentialsColour;
+ (UIColor*)getShinobiResourcesColour;
+ (UIColor*)getDashboardColour;
+ (UIColor*)getOverlayBGColour;
+ (UIColor*)getShinobiGreenColour;
+ (UIColor*)getShinobiLightGreenColour;
+ (UIColor*)getShinobiRedColour;
+ (UIColor*)getShinobiLightBlue;


+ (CGFloat)getAlphaComponentOfColour:(UIColor*)colour;

@end
