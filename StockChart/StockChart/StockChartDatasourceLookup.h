//
//  StockChartDatasourceLookup.h
//  StockChart
//
//  Created by Sam Davies on 10/03/2013.
//  Copyright (c) 2013 Shinobi Controls. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocol to allow lookups of a y value for a given x value and series
@protocol StockChartDatasourceLookup <NSObject>

@required
- (id)estimateYValueForXValue:(id)xValue forSeriesAtIndex:(NSUInteger)idx;

@end
