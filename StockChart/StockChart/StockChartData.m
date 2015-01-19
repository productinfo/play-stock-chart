//
//  StockChartData.m
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

#import "StockChartData.h"
#import "NSArray+StockChartUtils.h"

static const NSInteger StockChartKTimesStandardDeviation = 3;
static const NSInteger StockChartNoOfSamplesForMaxMin = 20;

@interface StockChartData ()

@property (nonatomic, strong) NSMutableArray *movingAverage;
@property (nonatomic, strong) NSMutableArray *movingStandardDeviation;
@property (nonatomic, strong) NSMutableArray *sampledMin;
@property (nonatomic, strong) NSMutableArray *sampledMax;

@end

@implementation StockChartData

static StockChartData *instance = nil;

#pragma mark - Object management

// We will eagerly initialize the data.
+ (void)initialize {
  [super initialize];
  if (!instance) {
    instance = [StockChartData new];
  }
}

+ (StockChartData*)getInstance {
  @synchronized(self) {
    if (instance == nil)    {
      instance = [StockChartData new];
    }
    return instance;
  }
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSArray *rawData;
    
    // Load the Historic Dow Jones data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"StockChartData" ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
      rawData = [[NSMutableArray alloc] initWithContentsOfFile:path];
      
      // setup OHLC data
      self.seriesOpen = [NSMutableArray new];
      self.seriesHigh = [NSMutableArray new];
      self.seriesLow = [NSMutableArray new];
      self.seriesClose = [NSMutableArray new];
      self.volume = [NSMutableArray new];
      self.movingAverage = [NSMutableArray new];
      self.movingStandardDeviation = [NSMutableArray new];
      self.dates = [NSMutableArray new];
      self.sampledMin = [NSMutableArray new];
      self.sampledMax = [NSMutableArray new];
      
      NSInteger currentDataPoint = 0;
      
      for (NSDictionary *quote in rawData) {
        // Add the date
        [self.dates addObject:quote[@"date"]];
        
        NSNumber *open = quote[@"open"];
        NSNumber *high = quote[@"high"];
        NSNumber *low = quote[@"low"];
        NSNumber *close = quote[@"close"];
        
        close = [self cleanUpCloseIfNeededWithHigh:high low:low close:close];
        
        [self.seriesOpen addObject:open];
        [self.seriesHigh addObject:high];
        [self.seriesLow addObject:low];
        [self.seriesClose addObject:close];
        [self.volume addObject:quote[@"volume"]];
        
        // Update the moving average and the standard deviation
        [self createMovingAverageAndSD:currentDataPoint];
        
        // Update the min/max sampled series
        [self updateMinMaxSamples:currentDataPoint];
        
        // Increment current data point
        currentDataPoint++;
      }
    }
  }
  return self;
}

- (NSNumber *)cleanUpCloseIfNeededWithHigh:(NSNumber*)high low:(NSNumber*)low close:(NSNumber*)originalClose {
  float highValue = [high floatValue];
  float lowValue = [low floatValue];
  float closeValue = [originalClose floatValue];
  
  // If the closing value is outside of the high-low range, move it to midway in the range
  if (closeValue < lowValue || closeValue > highValue) {
    float range = highValue - lowValue;
    closeValue = lowValue + (range / 2);
  }
  return @(closeValue);
}

- (void)createMovingAverageAndSD:(NSInteger)currentDataPoint {
  double runningTotal, runningSquaredTotal, standardDeviation, mean;
  if (currentDataPoint >= StockChartMovingAverageNPeriod - 1) {
    runningTotal = 0;
    runningSquaredTotal = 0;
    for (NSInteger j=(currentDataPoint - StockChartMovingAverageNPeriod + 1); j <= currentDataPoint; j++) {
      runningTotal += [self.seriesClose[j] doubleValue];
      runningSquaredTotal += pow([self.seriesClose[j] doubleValue], 2);
    }
    // Calculate the current mean and standard deviation
    mean = runningTotal / StockChartMovingAverageNPeriod;
    standardDeviation = sqrt((runningSquaredTotal / StockChartMovingAverageNPeriod) - pow(mean,2));
    
    // Save these to the arrays
    [self.movingAverage addObject:@(mean)];
    [self.movingStandardDeviation addObject:@(standardDeviation)];
  }
}

- (void)updateMinMaxSamples:(NSInteger)currentDataPoint {
  // Only add a new sample at regular intervals
  if (currentDataPoint % StockChartNoOfSamplesForMaxMin == 0 && currentDataPoint > 0) {
    if (currentDataPoint < StockChartNoOfSamplesForMaxMin + StockChartMovingAverageNPeriod) {
      // We use high/low values until we have some moving average values
      [self.sampledMax addObject:[self.seriesHigh maxInRangeFromIndex:(currentDataPoint - StockChartNoOfSamplesForMaxMin)
                                                         toIndex:(currentDataPoint - 1)]];
      [self.sampledMin addObject:[self.seriesLow minInRangeFromIndex:(currentDataPoint - StockChartNoOfSamplesForMaxMin)
                                                        toIndex:(currentDataPoint - 1)]];
      
    } else {
      // __Approximate__ Min and max for Bollinger bands
      double minMA = [[self.movingAverage minInRangeFromIndex:(currentDataPoint - StockChartNoOfSamplesForMaxMin - StockChartMovingAverageNPeriod)
                                                      toIndex:(currentDataPoint - StockChartMovingAverageNPeriod - 1)] doubleValue];
      double maxMA = [[self.movingAverage maxInRangeFromIndex:(currentDataPoint - StockChartNoOfSamplesForMaxMin - StockChartMovingAverageNPeriod)
                                                      toIndex:(currentDataPoint - StockChartMovingAverageNPeriod - 1)] doubleValue];
      double maxSD = [[self.movingStandardDeviation maxInRangeFromIndex:(currentDataPoint - StockChartNoOfSamplesForMaxMin - StockChartMovingAverageNPeriod)
                                                                toIndex:(currentDataPoint - StockChartMovingAverageNPeriod - 1)] doubleValue];
      [self.sampledMax addObject:@(maxMA + StockChartKTimesStandardDeviation * maxSD)];
      [self.sampledMin addObject:@(minMA - StockChartKTimesStandardDeviation * maxSD)];
    }
  }
}

- (NSNumber *)movingAverageValueForIndex:(NSUInteger)index {
  return self.movingAverage[index];
}

- (NSNumber *)lowerBollingerValueForIndex:(NSUInteger)index {
  double ma = [self.movingAverage[index] doubleValue];
  double sd = [self.movingStandardDeviation[index] doubleValue];
  return @(ma - StockChartKTimesStandardDeviation * sd);
}

- (NSNumber *)upperBollingerValueForIndex:(NSUInteger)index {
  double ma = [self.movingAverage[index] doubleValue];
  double sd = [self.movingStandardDeviation[index] doubleValue];
  return @(ma + StockChartKTimesStandardDeviation * sd);
}

- (NSUInteger)numberOfDataPoints {
  return self.dates.count;
}

- (NSNumber *)sampledMaxInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx {
  // Translate indices to those of the sampled max array
  NSUInteger translatedStartIdx = startIdx / StockChartNoOfSamplesForMaxMin;
  NSUInteger translatedEndIdx = endIdx / StockChartNoOfSamplesForMaxMin + 1;
  
  // Return the max value
  return [self.sampledMax maxInRangeFromIndex:translatedStartIdx toIndex:translatedEndIdx];
}

- (NSNumber *)sampledMinInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx {
  // Translate indices to those of the sampled max array
  NSUInteger translatedStartIdx = startIdx / StockChartNoOfSamplesForMaxMin;
  NSUInteger translatedEndIdx = endIdx / StockChartNoOfSamplesForMaxMin + 1;
  
  // Return the max value
  return [self.sampledMin minInRangeFromIndex:translatedStartIdx toIndex:translatedEndIdx];
}

@end
