//
//  FinancialChartDataSource.m
//  ShinobiControls
//
//  Created by Sam Davies on 16/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "StockChartDataSource.h"
#import "NSArray+StockChartUtils.h"

@implementation StockChartDataSource

@synthesize chartData;

- (id)init {
  self = [super init];
  
  if (self) {
    self.chartData = [StockChartData getInstance];
  }
  
  return self;
}


#pragma mark Datasource Protocol Functions

// Returns the number of series in the specified chart
- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart {
  return 3;
}

// Returns the series at the specified index for a given chart
- (SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index {
  switch (index) {
    case 0:
      // Volume
      return [StockChartDataSource createColumnSeries];
    case 1:
      // Bollinger Band
      return [StockChartDataSource createBollingerBandSeries];
    case 2:
      // OHLC
      return [StockChartDataSource createOhlcSeries];
    default:
      return nil;
  }
}

// Returns the number of points for a specific series in the specified chart
- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
  // We have fewer data points for Bollinger bands
  if (seriesIndex == 1) {
    return [chartData numberOfDataPoints] - StockChartMovingAverageNPeriod;
  } else {
    return [chartData numberOfDataPoints];
  }
}

- (SChartAxis*)sChart:(ShinobiChart *)chart yAxisForSeriesAtIndex:(NSInteger)index {
  NSArray *allYAxes = [chart allYAxes];
  // The first series in the chart is our volume chart, which uses a different y axis.  The other series use the default y axis
  if (index == 0) {
    return [allYAxes objectAtIndex:1];
  } else {
    return [allYAxes objectAtIndex:0];
  }
}

+ (SChartBandSeries*)createBollingerBandSeries {
  // Create a Band series
  SChartBandSeries *bandSeries = [[SChartBandSeries alloc] init];
  
  bandSeries.crosshairEnabled = YES;
  bandSeries.title = @"Bollinger Band";
  bandSeries.crosshairEnabled = NO;
  
  return bandSeries;
}

+ (SChartColumnSeries*)createColumnSeries {
  SChartColumnSeries *columnSeries = [[SChartColumnSeries alloc] init];
  columnSeries.crosshairEnabled = YES;
  return columnSeries;
}

+ (SChartOHLCSeries*)createOhlcSeries {
  // Create a candlestick series
  SChartCandlestickSeries *ohlcSeries = [[SChartCandlestickSeries alloc] init];
  
  // Define the data field names
  NSArray *keys = @[@"Open",@"High", @"Low", @"Close"];
  ohlcSeries.dataSeries.yValueKeys = keys;
  ohlcSeries.crosshairEnabled = YES;
  
  return ohlcSeries;
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex
        forSeriesAtIndex:(NSInteger)seriesIndex {
  switch (seriesIndex) {
    case 0:
      // Volume
      return [self volumeDataPointAtIndex:dataIndex];
    case 1:
      // Bollinger
      return [self bollingerDataPointAtIndex:dataIndex];
    case 2:
      // OHLC
      return [self ohlcDataPointAtIndex:dataIndex];
    default:
      return nil;
  }
}

- (NSArray *)sChart:(ShinobiChart *)chart dataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
  NSMutableArray *datapoints = [NSMutableArray array];
  NSUInteger noPoints = [self sChart:chart numberOfDataPointsForSeriesAtIndex:seriesIndex];
  
  switch (seriesIndex) {
    case 0:
      // Volume
      for (int i=0; i<noPoints; i++) {
        [datapoints addObject:[self volumeDataPointAtIndex:i]];
      }
      break;
    case 1:
      // Bollinger
      for (int i=0; i<noPoints; i++) {
        [datapoints addObject:[self bollingerDataPointAtIndex:i]];
      }
      break;
    case 2:
      // OHLC
      for (int i=0; i<noPoints; i++) {
        [datapoints addObject:[self ohlcDataPointAtIndex:i]];
      }
      break;
    default:
      break;
  }
  
  if(datapoints.count == 0) {
    datapoints = nil;
  }
  
  return datapoints;
}

- (id<SChartData>)bollingerDataPointAtIndex:(NSUInteger)dataIndex {
  // Construct a data point to return
  SChartMultiYDataPoint *datapoint = [[SChartMultiYDataPoint alloc] init];
  
  // We don't have bollinger data for the first StockChartMovingAverageNPeriod points of
  // the chartData, so we start at the StockChartMovingAverageNPeriod'th date
  datapoint.xValue = chartData.dates[dataIndex + StockChartMovingAverageNPeriod];
  
  // Make a dictionary of the different data points
  NSDictionary *bollingerData = @{ @"High": [chartData upperBollingerValueForIndex:dataIndex],
                                   @"Low": [chartData lowerBollingerValueForIndex:dataIndex] };
  datapoint.yValues = [bollingerData mutableCopy];
  return datapoint;
}

- (id<SChartData>)ohlcDataPointAtIndex:(NSUInteger)dataIndex {
  // Use a multi y datapoint
  SChartMultiYDataPoint *dp = [[SChartMultiYDataPoint alloc] init];
  
  // Set the xValue (date)
  dp.xValue = chartData.dates[dataIndex];
  
  // Get the open, high, low, close values
  float openVal  = [chartData.seriesOpen[dataIndex] floatValue];
  float highVal  = [chartData.seriesHigh[dataIndex] floatValue];
  float lowVal   = [chartData.seriesLow[dataIndex] floatValue];
  float closeVal = [chartData.seriesClose[dataIndex] floatValue];
  
  // Make sure all values are > 0
  openVal  = MAX(openVal, 0);
  highVal  = MAX(highVal, 0);
  lowVal   = MAX(lowVal, 0);
  closeVal = MAX(closeVal, 0);
  
  // Set the OHLC values
  NSDictionary *ohlcData = @{@"Open": @(openVal),
                             @"High": @(highVal),
                             @"Low": @(lowVal),
                             @"Close": @(closeVal)};
  dp.yValues = [ohlcData mutableCopy];
  
  return dp;
}

- (id<SChartData>)volumeDataPointAtIndex: (NSUInteger)dataIndex {
  SChartDataPoint *dp = [[SChartDataPoint alloc] init];
  dp.xValue = chartData.dates[dataIndex];
  dp.yValue = chartData.volume[dataIndex];
  return dp;
}

#pragma mark - StockChartDatasourceLookup methods
- (id)estimateYValueForXValue:(id)xValue forSeriesAtIndex:(NSUInteger)idx {
  if([xValue isKindOfClass:[NSNumber class]]) {
    // Need it to be a date since we are comparing timestamp
    xValue = [NSDate dateWithTimeIntervalSince1970:[xValue doubleValue]];
  }
  NSUInteger index;
  @try {
    index = [self.chartData.dates indexOfBiggestObjectSmallerThan:xValue
                                                    inSortedRange:NSMakeRange(0, self.chartData.dates.count)];
  }
  @catch (NSException *exception) {
    index = 0;
  }
  
  SChartDataPoint *dp = [self sChart:nil dataPointAtIndex:index forSeriesAtIndex:idx];
  if ([dp isKindOfClass:[SChartMultiYDataPoint class]]) {
    NSDictionary *yValues = ((SChartMultiYDataPoint*)dp).yValues;
    if (yValues[@"Close"]) {
      return yValues[@"Close"];
    } else {
      return yValues[@"High"];
    }
  } else {
    return dp.yValue;
  }
}

@end
