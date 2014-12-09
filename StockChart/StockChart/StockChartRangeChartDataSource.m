//
//  RangeChartDataSource.m
//  ShinobiControls
//
//  Created by  on 17/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "StockChartRangeChartDataSource.h"

/*
 Data source for the range chart, which displays a single line series mapping dates to close
 values from a StockChartData instance
 */
@implementation StockChartRangeChartDataSource

- (id)init {
  self = [super init];
  if (self) {
    self.chartData = [StockChartData getInstance];
  }
  return self;
}

#pragma mark - Datasource Protocol Functions

- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
  return [self.chartData numberOfDataPoints];
}

- (SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index {
  SChartLineSeries *lineSeries = [SChartLineSeries new];
  lineSeries.baseline = @0;
  lineSeries.crosshairEnabled = YES;
  return lineSeries;
}

- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart {
  return 1;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex {
  SChartDataPoint *datapoint = [SChartDataPoint new];
  datapoint.xValue = self.chartData.dates[dataIndex];
  datapoint.yValue = self.chartData.seriesClose[dataIndex];
  return datapoint;
}

- (NSArray *)sChart:(ShinobiChart *)chart dataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
  NSMutableArray *dataPoints = [NSMutableArray array];
  for (int i=0; i<[self.chartData numberOfDataPoints]; i++) {
    SChartDataPoint *datapoint = [SChartDataPoint new];
    datapoint.xValue = self.chartData.dates[i];
    datapoint.yValue = self.chartData.seriesClose[i];
    [dataPoints addObject:datapoint];
  }
  // Return an immutable copy of the data
  return  [dataPoints copy];
}

@end
