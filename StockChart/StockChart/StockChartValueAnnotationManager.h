//
//  ShinobiValueAnnotationManager.h
//  RangeSelector
//
//  Created by Sam Davies on 09/01/2013.
//  Copyright (c) 2013 Shinobi Controls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiChart.h>
#import "StockChartDatasourceLookup.h"

@interface StockChartValueAnnotationManager : NSObject

- (id)initWithChart:(ShinobiChart *)chart datasource:(id<StockChartDatasourceLookup>)datasource
        seriesIndex:(NSInteger)seriesIndex;

- (void)updateValueAnnotationForXAxisRange:(SChartRange *)range;

@end
