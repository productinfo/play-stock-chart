//
//  ChartConfigUtilities.m
//  ShinobiControls
//
//  Created by  on 01/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "StockChartConfigUtilities.h"

@implementation StockChartConfigUtilities

+ (void)hideAxisMarkings: (SChartAxis*)axis {
  axis.style.majorTickStyle.showTicks = NO;
  axis.style.majorTickStyle.showLabels = NO;
  axis.style.minorTickStyle.showTicks = NO;
  axis.style.minorTickStyle.showLabels = NO;
}

+ (void)hideAxisLine: (SChartAxis*)axis {
  axis.style.lineWidth = @0;
}

@end
