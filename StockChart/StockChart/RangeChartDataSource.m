//
//  RangeChartDataSource.m
//  ShinobiControls
//
//  Created by  on 17/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "RangeChartDataSource.h"

/*
 Data source for the range chart, which displays a single line series mapping dates to close
 values from a FinancialChartData instance
 */
@implementation RangeChartDataSource

- (id)init {
  self = [super init];
  if (self) {
    self.chartData = [StockChartData getInstance];
  }
  return self;
}

#pragma mark - Datasource Protocol Functions

- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
  return [self.chartData numberOfDataPoints];
}

- (SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index {
  SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
  lineSeries.baseline = [NSNumber numberWithInt:0];
  lineSeries.crosshairEnabled = YES;
  return lineSeries;
}

- (int)numberOfSeriesInSChart:(ShinobiChart *)chart {
  return 1;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex {
  SChartDataPoint *datapoint = [[SChartDataPoint alloc] init];
  datapoint.xValue = self.chartData.dates[dataIndex];
  datapoint.yValue = self.chartData.seriesClose[dataIndex];
  return datapoint;
}

- (NSArray *)sChart:(ShinobiChart *)chart dataPointsForSeriesAtIndex:(int)seriesIndex {
  NSMutableArray *dataPoints = [NSMutableArray array];
  for (int i=0; i<[self.chartData numberOfDataPoints]; i++) {
    SChartDataPoint *datapoint = [[SChartDataPoint alloc] init];
    datapoint.xValue = self.chartData.dates[i];
    datapoint.yValue = self.chartData.seriesClose[i];
    [dataPoints addObject:datapoint];
  }
  // Return an immutable copy of the data
  return  [dataPoints copy];
}

@end
