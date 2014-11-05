//
//  UIColor+Hex.h
//  ShinobiControls
//
//  Created by Sam Davies on 06/12/2012.
//  Copyright (c) 2012 ScottLogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor*)colourWithHexValue:(uint)hexValue andAlpha:(float)alpha;
+ (UIColor*)colourWithHexString:(NSString*)hexString andAlpha:(CGFloat)alpha;
- (NSString*)hexString;

@end
