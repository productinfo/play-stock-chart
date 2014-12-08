//
//  FinancialChartData.m
//  ShinobiControls
//
//  Created by  on 17/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "StockChartData.h"
#import "NSArray+StockChartUtils.h"

//static const NSInteger NUM_DATA_FIELDS = 7;
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

/**
 We will eagerly initialize the data.
 */
+ (void)initialize {
  [super initialize];
  if (!instance) {
    instance = [[StockChartData alloc] init];
  }
}

+ (StockChartData*)getInstance {
  @synchronized(self) {
    if (instance == nil)    {
      instance = [[StockChartData alloc] init];
    }
    return instance;
  }
}

- (id)init {
  self = [super init];
  if (self) {
    NSArray *rawData;
    
    // Load the Historic Dow Jones data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"StockChartData" ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
      rawData = [[NSMutableArray alloc] initWithContentsOfFile:path];
      
      // setup OHLC data
      self.seriesOpen = [[NSMutableArray alloc] init];
      self.seriesHigh = [[NSMutableArray alloc] init];
      self.seriesLow = [[NSMutableArray alloc] init];
      self.seriesClose = [[NSMutableArray alloc] init];
      self.volume = [[NSMutableArray alloc] init];
      self.movingAverage = [[NSMutableArray alloc] init];
      self.movingStandardDeviation = [[NSMutableArray alloc] init];
      self.dates = [[NSMutableArray alloc] init];
      self.sampledMin = [[NSMutableArray alloc] init];
      self.sampledMax = [[NSMutableArray alloc] init];
      
      NSInteger currentDataPoint = 0;
      
      /* DATA FILTERING
       For the purposes of this we reduce the data import slightly because
       there is some strange behaviour at the end. Stopping at the point
       used below stops at the end of July 2010
       */
      
      // We want to edit the date such that today is the last day
      // This gives us todays date (at midnight)
      NSDate *dateToday = [[NSDate alloc] init];
      NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
      NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
      dateToday = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:dateToday]];
      // We now want to find the difference between the last date in the data and todays date
      NSDate *finalDate = [[rawData lastObject] objectForKey:@"date"];
      NSTimeInterval timeBetweenDates = [dateToday timeIntervalSinceDate:finalDate];
      
      for (NSDictionary *quote in rawData) {
        // Add the date, but increase it so the data finished on today
        NSDate *date = [quote objectForKey:@"date"];
        [self.dates addObject:[date dateByAddingTimeInterval:timeBetweenDates]];
        
        NSNumber *open = [quote objectForKey:@"open"];
        NSNumber *high = [quote objectForKey:@"high"];
        NSNumber *low = [quote objectForKey:@"low"];
        NSNumber *close = [quote objectForKey:@"close"];
        
        close = [self cleanUpCloseIfNeededWithHigh:high low:low close:close];
        
        [self.seriesOpen addObject:open];
        [self.seriesHigh addObject:high];
        [self.seriesLow addObject:low];
        [self.seriesClose addObject:close];
        [self.volume addObject:[quote objectForKey:@"volume"]];
        
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

- (NSNumber*)cleanUpCloseIfNeededWithHigh:(NSNumber*)high low:(NSNumber*)low close:(NSNumber*)originalClose {
  float highValue = [high floatValue];
  float lowValue = [low floatValue];
  float closeValue = [originalClose floatValue];
  
  // If the closing value is outside of the high-low range, move it to midway in the range
  if (closeValue < lowValue || closeValue > highValue) {
    float range = highValue - lowValue;
    closeValue = lowValue + (range / 2);
  }
  return [NSNumber numberWithFloat:closeValue];
}

- (void)createMovingAverageAndSD:(NSInteger)currentDataPoint {
  double runningTotal, runningSquaredTotal, standardDeviation, mean;
  if(currentDataPoint >= StockChartMovingAverageNPeriod - 1) {
    runningTotal = 0;
    runningSquaredTotal = 0;
    for (NSInteger j=(currentDataPoint - StockChartMovingAverageNPeriod + 1); j <= currentDataPoint; j++) {
      runningTotal += [[self.seriesClose objectAtIndex:j] doubleValue];
      runningSquaredTotal += pow([[self.seriesClose objectAtIndex:j] doubleValue], 2);
    }
    // Calculate the current mean and standard deviation
    mean = runningTotal / StockChartMovingAverageNPeriod;
    standardDeviation = sqrt((runningSquaredTotal / StockChartMovingAverageNPeriod) - pow(mean,2));
    
    // Save these to the arrays
    [self.movingAverage addObject:[NSNumber numberWithDouble:mean]];
    [self.movingStandardDeviation addObject:[NSNumber numberWithDouble:standardDeviation]];
  }
}

- (void)updateMinMaxSamples:(NSInteger)currentDataPoint {
  // Only add a new sample at regular intervals
  if(currentDataPoint % StockChartNoOfSamplesForMaxMin == 0 && currentDataPoint > 0) {
    if(currentDataPoint < StockChartNoOfSamplesForMaxMin + StockChartMovingAverageNPeriod) {
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
      [self.sampledMax addObject:[NSNumber numberWithDouble:(maxMA + StockChartKTimesStandardDeviation * maxSD)]];
      [self.sampledMin addObject:[NSNumber numberWithDouble:(minMA - StockChartKTimesStandardDeviation * maxSD)]];
    }
  }
}

- (NSNumber *)movingAverageValueForIndex:(NSUInteger)index {
  return [self.movingAverage objectAtIndex:index];
}

- (NSNumber *)lowerBollingerValueForIndex:(NSUInteger)index {
  double ma = [[self.movingAverage objectAtIndex:index] doubleValue];
  double sd = [[self.movingStandardDeviation objectAtIndex:index] doubleValue];
  return [NSNumber numberWithDouble:(ma - StockChartKTimesStandardDeviation * sd)];
}

- (NSNumber *)upperBollingerValueForIndex:(NSUInteger)index {
  double ma = [[self.movingAverage objectAtIndex:index] doubleValue];
  double sd = [[self.movingStandardDeviation objectAtIndex:index] doubleValue];
  return [NSNumber numberWithDouble:(ma + StockChartKTimesStandardDeviation * sd)];
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
