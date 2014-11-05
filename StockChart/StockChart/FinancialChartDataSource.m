//
//  FinancialChartDataSource.m
//  ShinobiControls
//
//  Created by Sam Davies on 16/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "FinancialChartDataSource.h"
#import "NSArray+BinarySearch.h"

@implementation FinancialChartDataSource

@synthesize chartData;

- (id)init  {
    self = [super init];
    
    if (self)   {
        self.chartData = [StockChartData getInstance];
    }
    
    return self;
}


#pragma mark -
#pragma mark Datasource Protocol Functions

// Returns the number of points for a specific series in the specified chart
- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    // We have fewer data points for Bollinger bands
    switch (seriesIndex) {
        case 0:
            // Volume
            return [chartData numberOfDataPoints];
            break;
        case 1:
            // Bollinger Band
            return ([chartData numberOfDataPoints] - StockChartMovingAverageNPeriod);
            break;
        case 2:
            // OHLC
            return [chartData numberOfDataPoints];
            break;
        default:
            break;
    }
    return [chartData numberOfDataPoints];
}

// Returns the series at the specified index for a given chart
-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index {
    
    switch (index) {
        case 0:
            // Volume
            return [FinancialChartDataSource createColumnSeries];
            break;
        case 1:
            // Bollinger Band
            return [FinancialChartDataSource createBollingerBandSeries];
            break;
        case 2:
            // OHLC
            return [FinancialChartDataSource createOhlcSeries];
            break;
        default:
            break;
    }
    
    // If we have gotten here, we were unable to return a valid series based on the index.  Throw an exception to the user.
    NSException* exception = [NSException
                                exceptionWithName:@"IllegalArgumentException"
                                reason:[NSString stringWithFormat:@"Invalid series index: %d", index]
                                userInfo:nil];
    @throw exception;
}

- (SChartAxis*)sChart:(ShinobiChart *)chart yAxisForSeriesAtIndex:(int)index    {
    NSArray *allYAxes = [chart allYAxes];
    // The first series in the chart is our volume chart, which uses a different y axis.  The other series use the default y axis
    if (index == 0)  {
        return [allYAxes objectAtIndex:1];
    } else {
        return [allYAxes objectAtIndex:0];
    }
}

+ (SChartBandSeries*)createBollingerBandSeries
{
    // Create a Band series
    SChartBandSeries *bandSeries = [[SChartBandSeries alloc] init];
    
    bandSeries.crosshairEnabled = YES;
    bandSeries.title = @"Bollinger Band";
    bandSeries.crosshairEnabled = NO;
    
    return bandSeries;
}

+ (SChartColumnSeries*)createColumnSeries    {
    SChartColumnSeries *columnSeries = [[SChartColumnSeries alloc] init];
    columnSeries.crosshairEnabled = YES;
    return columnSeries;
}

+ (SChartOHLCSeries*)createOhlcSeries {
    // Create a candlestick series
    SChartCandlestickSeries *ohlcSeries = [[SChartCandlestickSeries alloc] init];
    
    // Define the data field names
    NSMutableArray *keys = [[NSMutableArray alloc] initWithObjects:@"Open",@"High", @"Low", @"Close", nil];
    ohlcSeries.dataSeries.yValueKeys = keys;
    ohlcSeries.crosshairEnabled = YES;
    
    return ohlcSeries;
}

// Returns the number of series in the specified chart
- (int)numberOfSeriesInSChart:(ShinobiChart *)chart {
    return 3;
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex {
    
    switch (seriesIndex) {
        case 0:
            // Volume
            return [self volumeDataPointAtIndex:dataIndex];
            break;
        case 1:
            // Bollinger
            return [self bollingerDataPointAtIndex:dataIndex];
            break;
        case 2:
            // OHLC
            return [self ohlcDataPointAtIndex:dataIndex];
            break;
        default:
            break;
    }
    
    // If we have gotten here, we were unable to return a data point based on the series index.  Throw an exception to the user.
    NSException* exception = [NSException
                              exceptionWithName:@"IllegalArgumentException"
                              reason:[NSString stringWithFormat:@"Invalid series index: %d", seriesIndex]
                              userInfo:nil];
    @throw exception;
}


- (NSArray *)sChart:(ShinobiChart *)chart dataPointsForSeriesAtIndex:(int)seriesIndex
{

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

- (id<SChartData>)bollingerDataPointAtIndex:(NSUInteger)dataIndex
{
    // Construct a data point to return
    SChartMultiYDataPoint *datapoint = [[SChartMultiYDataPoint alloc] init];
    
    // For this example, we simply move one day forward for each dataIndex
    datapoint.xValue = [chartData.dates objectAtIndex:(dataIndex + StockChartMovingAverageNPeriod)];
    
    // Make a dictionary of the different data points
    NSMutableDictionary *bollingerData = [[NSMutableDictionary alloc] init];
    
    // Push the upper and lower values onto this datapoint
    [bollingerData setValue:[chartData upperBollingerValueForIndex:dataIndex] forKey:@"High"];
    [bollingerData setValue:[chartData lowerBollingerValueForIndex:dataIndex] forKey:@"Low"];
    
    // Construct an NSNumber for the yValue of the data point
    datapoint.yValues = bollingerData;
    
    return datapoint;
}

- (id<SChartData>)ohlcDataPointAtIndex:(NSUInteger)dataIndex
{
    // Use a multi y datapoint
    SChartMultiYDataPoint *dp = [[SChartMultiYDataPoint alloc] init];
    
    // Set the xValue (date)
    dp.xValue = [chartData.dates objectAtIndex: dataIndex];
    
    // Get the open, high, low, close values
    NSMutableDictionary *ohlcData = [[NSMutableDictionary alloc] init];
    float openVal  = [[chartData.seriesOpen  objectAtIndex: dataIndex] floatValue];
    float highVal  = [[chartData.seriesHigh  objectAtIndex: dataIndex] floatValue];
    float lowVal   = [[chartData.seriesLow   objectAtIndex: dataIndex] floatValue];
    float closeVal = [[chartData.seriesClose objectAtIndex: dataIndex] floatValue];
    
    // Clamp values
    openVal  = (openVal  < 0.0f ? 0.0f : openVal);
    highVal  = (highVal  < 0.0f ? 0.0f : highVal);
    lowVal   = (lowVal   < 0.0f ? 0.0f : lowVal);
    closeVal = (closeVal < 0.0f ? 0.0f : closeVal);
    
    // Set the OHLC values
    [ohlcData setValue:[NSNumber numberWithFloat:openVal]  forKey:@"Open"];
    [ohlcData setValue:[NSNumber numberWithFloat:highVal]  forKey:@"High"];
    [ohlcData setValue:[NSNumber numberWithFloat:lowVal]   forKey:@"Low"];
    [ohlcData setValue:[NSNumber numberWithFloat:closeVal] forKey:@"Close"];
    
    dp.yValues = ohlcData;
    
    return dp;
}

- (id<SChartData>)volumeDataPointAtIndex: (NSUInteger)dataIndex
{
    SChartDataPoint *dp = [[SChartDataPoint alloc] init];
    
    // Set the xValue (date)
    dp.xValue = [chartData.dates objectAtIndex: dataIndex];
    dp.yValue = [chartData.volume objectAtIndex:dataIndex];
    return dp;
}

#pragma mark - SChartDatasourceLookup methods
- (id)estimateYValueForXValue:(id)xValue forSeriesAtIndex:(NSUInteger)idx
{
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
  }
  return dp.yValue;
}

@end
