//
//  ChartConfigUtilities.h
//  ShinobiControls
//
//  Created by  on 01/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiCharts.h>

@interface StockChartConfigUtilities : NSObject

+ (void)hideAxisMarkings:(SChartAxis*)axis;

+ (void)hideAxisLine:(SChartAxis*)axis;

@end
