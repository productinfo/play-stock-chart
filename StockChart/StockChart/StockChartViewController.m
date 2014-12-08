//
//  StockChartViewController.m
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

#import "StockChartViewController.h"
#import "StockChartDataSource.h"
#import "StockChartLineChartFactory.h"
#import "StockChartRangeChartDataSource.h"
//#import "CustomCrosshairTooltip.h"
#import "StockChartConfigUtilities.h"
#import <ShinobiCharts/SChartCanvas.h>
#import "StockChartValueAnnotationManager.h"
#import "StockChartCommon.h"
#import "NSArray+StockChartUtils.h"

// Limit the x axis so it has a minimum range of 2 weeks
const float minXAxisRange = 60 * 60 * 24 * 14;

// Limit the y axis so it has a minimum range of 10
const float minYAxisRange = 10.f;

@interface StockChartViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *rangeView;
@property (strong, nonatomic) ShinobiChart *mainChart;
@property (strong, nonatomic) ShinobiChart *rangeChart;
@property (strong, nonatomic) StockChartValueAnnotationManager *valueAnnotationManager;
@property (strong, nonatomic) StockChartRangeAnnotationManager *rangeAnnotationManager;

@property (strong, nonatomic) StockChartDataSource *mainDatasource;
@property (strong, nonatomic) id<SChartDatasource> rangeDatasource;

@property (strong, nonatomic) UIView *xAxisBackground;

@end

@implementation StockChartViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"Stock values and trading volume over time";
  
  SChartTheme *theme = [SChartiOS7Theme new];
  theme.chartStyle.backgroundColor = [UIColor whiteColor];
  theme.xAxisStyle.majorTickStyle.labelColor = [UIColor whiteColor];
  theme.xAxisStyle.lineColor = [UIColor darkGrayColor];
  theme.xAxisStyle.majorTickStyle.lineLength = @-8;
  theme.xAxisStyle.majorTickStyle.lineColor = [UIColor darkGrayColor];
  theme.xAxisStyle.majorTickStyle.tickGap = @0;  
  theme.yAxisStyle.majorTickStyle.labelColor = [UIColor darkGrayColor];
  theme.yAxisStyle.lineColor = [UIColor darkGrayColor];
  theme.yAxisStyle.majorTickStyle.lineLength = @8;
  theme.yAxisStyle.majorTickStyle.lineColor = [UIColor darkGrayColor];
  theme.yAxisStyle.majorTickStyle.lineWidth = @1;
  [ShinobiCharts setTheme:theme];
  
  self.mainDatasource = [[StockChartDataSource alloc] init];
  
  self.mainChart = [StockChartLineChartFactory createChartWithBounds:self.mainView.bounds
                                                dataSource:self.mainDatasource];
  self.mainChart.clipsToBounds = NO;
  self.mainChart.title = @"Stock values and trading volume over time";
  
  // Set double tap in main chart to reset the zoom
  self.mainChart.gestureDoubleTapResetsZoom = YES;
  self.mainChart.gestureDoubleTapEnabled = YES;
  
  // Create a y axis to use with volume data.  We have specified a large enough range so
  // that the volume data is plotted in the lower section of the chart, so as not to get
  // in the way of the OHLC data
  SChartNumberRange *volumeRange = [[SChartNumberRange alloc] initWithMinimum:[NSNumber numberWithInt:0]
                                                                   andMaximum:[NSNumber numberWithDouble:2500000000.f]];
  SChartNumberAxis *volumeYAxis = [[SChartNumberAxis alloc] initWithRange:volumeRange];
  [StockChartConfigUtilities hideAxisMarkings:volumeYAxis];
  [StockChartConfigUtilities hideAxisLine:volumeYAxis];
  [self.mainChart addYAxis:volumeYAxis];
  
  [self.mainView addSubview:self.mainChart];
  
  // Set the initial start and end values for the x axis on the main chart
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  components.day = 1;
  components.month = 1;
  components.year = 2004;
  
  NSDate *startX = [calendar dateFromComponents:components];
  
  components.year = 2005;
  NSDate *endX = [calendar dateFromComponents:components];
  
  // We have to set the default x-axis range
  self.mainChart.xAxis.defaultRange = [[SChartDateRange alloc] initWithDateMinimum:startX
                                                                    andDateMaximum:endX];
  
  // Allow the plot area to spill out of its bounds so we can have an annotation outside of it
  self.mainChart.canvas.glView.clipsToBounds = FALSE;
  
  // Create the range chart and annotation
  self.rangeDatasource = [[StockChartRangeChartDataSource alloc] init];
  self.rangeChart = [StockChartLineChartFactory createChartWithBounds:self.rangeView.bounds
                                                 dataSource:self.rangeDatasource];
  self.rangeChart.title = @"";
  [StockChartConfigUtilities hideAxisMarkings:self.rangeChart.xAxis];
  [StockChartConfigUtilities hideAxisMarkings:self.rangeChart.yAxis];
  self.rangeChart.delegate = self;
  
  // Add the chart to the correct subview
  [self.rangeView addSubview:self.rangeChart];
  
  self.rangeAnnotationManager = [[StockChartRangeAnnotationManager alloc] initWithChart:self.rangeChart
                                                                            minimumSpan:minXAxisRange];
  self.rangeAnnotationManager.delegate = self;
  [self.rangeAnnotationManager moveRangeSelectorToRange:self.mainChart.xAxis.defaultRange];
  
  // We also want to set the min/max since it's not available from the axis yet
  NSInteger numberPoints = [self.rangeDatasource sChart:self.rangeChart numberOfDataPointsForSeriesAtIndex:0];
  SChartDataPoint *minDP = [self.rangeDatasource sChart:self.rangeChart dataPointAtIndex:0 forSeriesAtIndex:0];
  SChartDataPoint *maxDP = [self.rangeDatasource sChart:self.rangeChart dataPointAtIndex:(numberPoints-1) forSeriesAtIndex:0];
  [self.rangeAnnotationManager setInitialMin:minDP.xValue andMax:maxDP.xValue];
  
  // Add a chart delegate
  self.mainChart.delegate = self;
  
  // Create the series marker (it's added to the view in viewDidAppear)
  self.valueAnnotationManager = [[StockChartValueAnnotationManager alloc] initWithChart:self.mainChart
                                                                datasource:self.mainDatasource
                                                               seriesIndex:2];
  [self.valueAnnotationManager updateValueAnnotationForXAxisRange:self.mainChart.xAxis.defaultRange];
  
  /* HARD-CODED RANGE
   We hard-code the range of the y-Axis in for now. This will need to change
   with different data (duh!). This works well for the year 2004.
   */
  SChartNumberRange *numberRange = [[SChartNumberRange alloc] initWithMinimum:[NSNumber numberWithInt:100]
                                                                   andMaximum:[NSNumber numberWithInt:200]];
  self.mainChart.yAxis.defaultRange = numberRange;
}

#pragma mark - ShinobiRangeSelectorDelegate protocol

- (void)rangeAnnotation:(StockChartRangeAnnotationManager *)annotation didMoveToRange:(SChartRange *)range
         autoscaleYAxis:(BOOL)autoscale {
  [self.mainChart.xAxis setRangeWithMinimum:range.minimum andMaximum:range.maximum];
  
  if (autoscale == YES)  {
    // Auto-scale the y axis to match the visible data
    StockChartData *chartData = self.mainDatasource.chartData;
    
    // We need to convert the start and end of the range to dates (the values we get from
    // the range are numbers)
    NSDate *startValue = [NSDate dateWithTimeIntervalSince1970:[range.minimum doubleValue]];
    NSDate *endValue = [NSDate dateWithTimeIntervalSince1970:[range.maximum doubleValue]];
    
    // Find the index of the dates nearest the start and end values
    NSUInteger lowerIndex = [chartData.dates indexOfBiggestObjectSmallerThan:startValue inSortedRange:NSMakeRange(0, chartData.dates.count)];
    NSUInteger upperIndex = [chartData.dates indexOfSmallestObjectBiggerThan:endValue inSortedRange:NSMakeRange(lowerIndex, chartData.dates.count - lowerIndex)];
    
    double min = [[chartData sampledMinInRangeFromIndex:lowerIndex toIndex:upperIndex] doubleValue];
    double max = [[chartData sampledMaxInRangeFromIndex:lowerIndex toIndex:upperIndex] doubleValue];
    
    // Add some padding
    double padding = 0.1 * (max - min);
    double minValue = min - padding;
    double maxValue = max + padding;
    [self.mainChart.yAxis setRangeWithMinimum:@(minValue) andMaximum:@(maxValue)];
  }
  
  // Update the location of the annotation line
  [self.valueAnnotationManager updateValueAnnotationForXAxisRange:range];
  
  [self.mainChart redrawChart];
}

#pragma mark - SChartDelegate
-(void)sChartIsPanning:(ShinobiChart *)chart withChartMovementInformation:(const SChartMovementInformation *)information {
  [self.rangeAnnotationManager moveRangeSelectorToRange:chart.xAxis.axisRange];
  [self.valueAnnotationManager updateValueAnnotationForXAxisRange:chart.xAxis.axisRange];
}

-(void)sChartIsZooming:(ShinobiChart *)chart withChartMovementInformation:(const SChartMovementInformation *)information {
  [self.rangeAnnotationManager moveRangeSelectorToRange:chart.xAxis.axisRange];
  [self.valueAnnotationManager updateValueAnnotationForXAxisRange:chart.xAxis.axisRange];
}

- (void)sChartRenderFinished:(ShinobiChart *)chart {
  // It is the main chart which has finished rendering
  if (chart == self.mainChart) {
    
    // Update the yAxis width on the range chart to match that in the mainChart
    self.rangeChart.yAxis.width = [NSNumber numberWithDouble:[self.mainChart.yAxis spaceRequiredToDrawWithTitle:YES]];
    [self.rangeChart redrawChart];
    
    // Add a background view for the x-axis
    // Need to draw a nice grey box
    double boxWidth = self.mainChart.canvas.glView.frame.size.width + [self.mainChart.yAxis.style.lineWidth doubleValue];
    CGRect xAxisBackgroundFrame = CGRectMake(self.mainChart.canvas.glView.frame.origin.x,
                                             self.mainChart.canvas.glView.frame.size.height,
                                             boxWidth, 32);
    if(!self.xAxisBackground) {
      self.xAxisBackground = [[UIView alloc] initWithFrame:xAxisBackgroundFrame];
      self.xAxisBackground.backgroundColor = [UIColor darkGrayColor];
      [self.mainChart.canvas addSubview:self.xAxisBackground];
      [self.mainChart.canvas sendSubviewToBack:self.xAxisBackground];
    } else {
      // Just need to update the size
      self.xAxisBackground.frame = xAxisBackgroundFrame;
    }
  }
}

/**
 Listen for zooming notifications.  If the user has zoomed below the specified limits for 
 either axis, reset the range of the axis to the minimum limit.
 */
- (void)sChartIsZooming:(ShinobiChart *)chart {
  NSNumber *xAxisSpan = chart.xAxis.axisRange.span;
  if ([xAxisSpan intValue] < minXAxisRange)   {
    NSNumber *min = chart.xAxis.axisRange.minimum;
    int center = [min intValue] + ([xAxisSpan intValue] / 2);
    
    NSNumber *newMin = [NSNumber numberWithInt:center - (minXAxisRange / 2)];
    NSNumber *newMax = [NSNumber numberWithInt:center + (minXAxisRange / 2)];
    
    [chart.xAxis setRangeWithMinimum:newMin andMaximum:newMax];
    [chart redrawChart];
  }
  
  NSNumber *yAxisSpan = chart.yAxis.axisRange.span;
  if ([yAxisSpan floatValue] < minYAxisRange) {
    NSNumber *min = chart.yAxis.axisRange.minimum;
    float center = [min floatValue] + ([yAxisSpan floatValue] / 2);
    
    NSNumber *newMin = [NSNumber numberWithFloat:center - (minYAxisRange / 2)];
    NSNumber *newMax = [NSNumber numberWithFloat:center + (minYAxisRange / 2)];
    
    [chart.yAxis setRangeWithMinimum:newMin andMaximum:newMax];
    [chart redrawChart];
  }
}

@end
