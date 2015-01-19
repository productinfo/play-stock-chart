//
//  StockChartRangeChartDataSource.m
//  StockChart
//
//  Created by Alison Clarke on 27/08/2014.
//
//  Copyright 2014 Scott Logic
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "StockChartRangeChartDataSource.h"
#import "ShinobiPlayUtils/UIColor+SPUColor.h"

/*
 Data source for the range chart, which displays a single line series mapping dates to close
 values from a StockChartData instance
 */
@implementation StockChartRangeChartDataSource

- (instancetype)init {
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
  lineSeries.style.lineColor = [UIColor shinobiDarkGrayColor];
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
