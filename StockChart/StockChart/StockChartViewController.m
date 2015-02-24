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
#import "StockChartRangeChartDataSource.h"
#import "StockChartConfigUtilities.h"
#import <ShinobiCharts/SChartCanvas.h>
#import <ShinobiCharts/SChartGLView.h>
#import "StockChartValueAnnotationManager.h"
#import "NSArray+StockChartUtils.h"
#import "StockChartCrosshair.h"
#import "ShinobiPlayUtils/UIColor+SPUColor.h"
#import "ShinobiPlayUtils/UIFont+SPUFont.h"

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
  
  theme.chartTitleStyle.font = [UIFont shinobiFontOfSize:30];
  theme.chartTitleStyle.textColor = [UIColor shinobiDarkGrayColor];
  theme.chartTitleStyle.titleCentresOn = SChartTitleCentresOnChart;
  
  theme.xAxisStyle.lineColor = theme.chartTitleStyle.textColor;
  theme.xAxisStyle.titleStyle.font = [UIFont shinobiFontOfSize:16];
  theme.xAxisStyle.majorTickStyle.lineColor = theme.xAxisStyle.lineColor;
  theme.xAxisStyle.majorTickStyle.labelColor = [UIColor whiteColor];
  theme.xAxisStyle.majorTickStyle.labelFont = [UIFont lightShinobiFontOfSize:14];
  theme.xAxisStyle.majorTickStyle.showTicks = NO;
  theme.xAxisStyle.majorTickStyle.tickGap = @0;
  
  theme.yAxisStyle.lineColor = theme.xAxisStyle.lineColor;
  theme.yAxisStyle.majorTickStyle.lineColor = theme.yAxisStyle.lineColor;
  theme.yAxisStyle.majorTickStyle.labelColor = theme.yAxisStyle.lineColor;
  theme.yAxisStyle.majorTickStyle.labelFont = [UIFont shinobiFontOfSize:14];
  theme.yAxisStyle.majorTickStyle.lineLength = @8;
  theme.yAxisStyle.majorTickStyle.lineWidth = @1;
  
  self.mainDatasource = [StockChartDataSource new];
  
  self.mainChart = [self createChartWithBounds:self.mainView.bounds
                                    dataSource:self.mainDatasource];
  [self.mainChart applyTheme:theme];
  self.mainChart.clipsToBounds = NO;
  self.mainChart.title = @"Stock values and trading volume over time";
  
  // Set double tap in main chart to reset the zoom
  self.mainChart.gestureDoubleTapResetsZoom = YES;
  self.mainChart.gestureDoubleTapEnabled = YES;
  
  // Create a y axis to use with volume data.  We have specified a large enough range so
  // that the volume data is plotted in the lower section of the chart, so as not to get
  // in the way of the OHLC data
  SChartNumberRange *volumeRange = [[SChartNumberRange alloc] initWithMinimum:@0
                                                                   andMaximum:@2500000000.f];
  SChartNumberAxis *volumeYAxis = [[SChartNumberAxis alloc] initWithRange:volumeRange];
  [StockChartConfigUtilities hideAxisMarkings:volumeYAxis];
  [self.mainChart addYAxis:volumeYAxis];
  
  // Add a dummy x axis to frame the chart
  SChartNumberAxis *dummyXAxis = [SChartNumberAxis new];
  [StockChartConfigUtilities hideAxisMarkings:dummyXAxis];
  dummyXAxis.axisPosition = SChartAxisPositionReverse;
  [self.mainChart addXAxis:dummyXAxis];
  
  [self.mainView addSubview:self.mainChart];
  
  // Set the crosshair to our custom one (we can create it now the chart knows how big it is)
  self.mainChart.crosshair = [[StockChartCrosshair alloc] initWithFrame:[self.mainChart getPlotAreaFrame]];
  
  // Set the initial start and end values for the x axis on the main chart
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [NSDateComponents new];
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
  self.rangeDatasource = [StockChartRangeChartDataSource new];
  self.rangeChart = [self createChartWithBounds:self.rangeView.bounds
                                     dataSource:self.rangeDatasource];
  [self.rangeChart applyTheme:theme];
  self.rangeChart.title = @"";
  [StockChartConfigUtilities hideAxisMarkings:self.rangeChart.xAxis];
  [StockChartConfigUtilities hideAxisMarkings:self.rangeChart.yAxis];
  self.rangeChart.delegate = self;
  
  // Add a dummy y-axis to match that of the main chart
  SChartNumberAxis *dummyYAxis = [SChartNumberAxis new];
  [StockChartConfigUtilities hideAxisMarkings:dummyYAxis];
  [self.rangeChart addYAxis:dummyYAxis];
  
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
  
  // We hard-code the range of the y-Axis in to start with
  SChartNumberRange *numberRange = [[SChartNumberRange alloc] initWithMinimum:@100
                                                                   andMaximum:@170];
  self.mainChart.yAxis.defaultRange = numberRange;
  
  // Create the series marker (it's added to the view in viewDidAppear)
  self.valueAnnotationManager = [[StockChartValueAnnotationManager alloc] initWithChart:self.mainChart
                                                                             datasource:self.mainDatasource
                                                                            seriesIndex:1];
  [self.valueAnnotationManager updateValueAnnotationForXAxisRange:self.mainChart.xAxis.defaultRange
                                                       yAxisRange:self.mainChart.yAxis.defaultRange];
}

- (ShinobiChart*)createChartWithBounds:(CGRect)bounds dataSource:(id<SChartDatasource>)datasource {
  ShinobiChart *chart = [[ShinobiChart alloc] initWithFrame:bounds];
  
  // As the chart is a UIView, set its resizing mask to allow it to automatically resize when screen orientation changes.
  chart.autoresizingMask = ~UIViewAutoresizingNone;
  chart.rotatesOnDeviceRotation = NO;
  
  // Give the chart the data source
  chart.datasource = datasource;
  
  // Create a discontinuous date time axis to use as the x axis.
  SChartDiscontinuousDateTimeAxis *xAxis = [SChartDiscontinuousDateTimeAxis new];
  
  // Get the data so we can calculate excluded periods (weekends)
  StockChartData *data = [StockChartData getInstance];
  
  // Find the first Saturday in the date range and create a repeated time period to exclude weekends
  NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit
                                                     fromDate:data.dates[0]];
  NSDateComponents *componentsToAdd = [NSDateComponents new];
  [componentsToAdd setDay:(7 - [weekdayComponents weekday])];
  NSDate *firstSaturday = [calendar dateByAddingComponents:componentsToAdd
                                                    toDate:data.dates[0]
                                                   options:0];
  [xAxis addExcludedRepeatedTimePeriod:[[SChartRepeatedTimePeriod alloc] initWithStart:firstSaturday
                                                                             andLength:[SChartDateFrequency dateFrequencyWithDay:2]
                                                                          andFrequency:[SChartDateFrequency dateFrequencyWithWeek:1]]];
  
  // Disable panning and zooming on the x-axis.
  xAxis.enableGesturePanning = YES;
  xAxis.enableGestureZooming = YES;
  xAxis.enableMomentumPanning =YES;
  xAxis.enableMomentumZooming = YES;
  
  chart.xAxis = xAxis;
  
  // Create a number axis to use as the y axis.
  SChartNumberAxis *yAxis = [SChartNumberAxis new];
  
  // Enable panning and zooming on Y
  yAxis.enableGesturePanning = YES;
  yAxis.enableGestureZooming = YES;
  yAxis.enableMomentumPanning = YES;
  yAxis.enableMomentumZooming = YES;
  
  // Put the yAxis on the RHS
  yAxis.axisPosition = SChartAxisPositionReverse;
  yAxis.width = @50;
  chart.yAxis = yAxis;
  
  return chart;
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
    NSUInteger lowerIndex;
    @try {
      lowerIndex = [chartData.dates indexOfBiggestObjectSmallerThan:startValue
                                                      inSortedRange:NSMakeRange(0, chartData.dates.count)];
    } @catch (NSException *e) {
      lowerIndex = 0;
    }
    
    NSUInteger upperIndex;
    @try {
      upperIndex = [chartData.dates indexOfSmallestObjectBiggerThan:endValue
                                                      inSortedRange:NSMakeRange(lowerIndex, chartData.dates.count - lowerIndex)];
    } @catch (NSException *e) {
      upperIndex = [chartData.dates count] - 1;
    }
    
    double min = [[chartData sampledMinInRangeFromIndex:lowerIndex toIndex:upperIndex] doubleValue];
    double max = [[chartData sampledMaxInRangeFromIndex:lowerIndex toIndex:upperIndex] doubleValue];
    
    // Add some padding
    double padding = 0.1 * (max - min);
    double minValue = min - padding;
    double maxValue = max + padding;
    [self.mainChart.yAxis setRangeWithMinimum:@(minValue) andMaximum:@(maxValue)];
  }
  
  // Update the location of the annotation line
  [self.valueAnnotationManager updateValueAnnotationForXAxisRange:range
                                                       yAxisRange:self.mainChart.yAxis.axisRange
                                                           redraw:YES];
}

#pragma mark - SChartDelegate
-(void)sChartIsPanning:(ShinobiChart *)chart withChartMovementInformation:(const SChartMovementInformation *)information {
  [self.rangeAnnotationManager moveRangeSelectorToRange:chart.xAxis.axisRange];
  [self.valueAnnotationManager updateValueAnnotationForXAxisRange:chart.xAxis.axisRange
                                                       yAxisRange:self.mainChart.yAxis.axisRange];
}

-(void)sChartIsZooming:(ShinobiChart *)chart withChartMovementInformation:(const SChartMovementInformation *)information {
  [self.rangeAnnotationManager moveRangeSelectorToRange:chart.xAxis.axisRange];
  [self.valueAnnotationManager updateValueAnnotationForXAxisRange:chart.xAxis.axisRange
                                                       yAxisRange:self.mainChart.yAxis.axisRange];
}

- (void)sChartRenderFinished:(ShinobiChart *)chart {
  // It is the main chart which has finished rendering
  if (chart == self.mainChart) {
    
    // Update the yAxis width on the range chart to match that in the mainChart
    self.rangeChart.yAxis.width = @([self.mainChart.yAxis spaceRequiredToDrawWithTitle:YES]);
    [self.rangeChart redrawChart];
    
    // Add a background view for the x-axis
    // Need to draw a nice grey box
    double boxWidth = [self.mainChart getPlotAreaFrame].size.width;
    double xPos = [self.mainChart getPlotAreaFrame].origin.x;
    
    for (SChartAxis *axis in self.mainChart.allYAxes) {
      if (axis.axisPosition == SChartAxisPositionNormal) {
        xPos -= [axis.style.lineWidth doubleValue];
      }
      boxWidth += [axis.style.lineWidth doubleValue];
    }
    
    CGRect xAxisBackgroundFrame = CGRectMake(xPos,
                                             [self.mainChart getPlotAreaFrame].size.height,
                                             boxWidth,
                                             34);
    if (!self.xAxisBackground) {
      self.xAxisBackground = [[UIView alloc] initWithFrame:xAxisBackgroundFrame];
      self.xAxisBackground.backgroundColor = [UIColor shinobiDarkGrayColor];
      [self.mainChart.canvas addSubview:self.xAxisBackground];
      [self.mainChart.canvas sendSubviewToBack:self.xAxisBackground];
    } else {
      // Just need to update the size
      self.xAxisBackground.frame = xAxisBackgroundFrame;
    }
    
    // Update the value annotation without triggering another redraw
    [self.valueAnnotationManager updateValueAnnotationForXAxisRange:chart.xAxis.axisRange
                                                         yAxisRange:self.mainChart.yAxis.axisRange
                                                             redraw:NO];
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
    
    NSNumber *newMin = @(center - (minXAxisRange / 2));
    NSNumber *newMax = @(center + (minXAxisRange / 2));
    
    [chart.xAxis setRangeWithMinimum:newMin andMaximum:newMax];
    [chart redrawChart];
  }
  
  NSNumber *yAxisSpan = chart.yAxis.axisRange.span;
  if ([yAxisSpan floatValue] < minYAxisRange) {
    NSNumber *min = chart.yAxis.axisRange.minimum;
    float center = [min floatValue] + ([yAxisSpan floatValue] / 2);
    
    NSNumber *newMin = @(center - (minYAxisRange / 2));
    NSNumber *newMax = @(center + (minYAxisRange / 2));
    
    [chart.yAxis setRangeWithMinimum:newMin andMaximum:newMax];
    [chart redrawChart];
  }
}

@end
