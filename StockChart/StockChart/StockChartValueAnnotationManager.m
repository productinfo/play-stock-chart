//
//  ShinobiValueAnnotationManager.m
//  RangeSelector
//
//  Created by Sam Davies on 09/01/2013.
//  Copyright (c) 2013 Shinobi Controls. All rights reserved.
//

#import "StockChartValueAnnotationManager.h"
#import "StockChartAnchoredTextAnnotation.h"
#import "StockChartDashedLineAnnotation.h"
#import <ShinobiCharts/SChartCanvas.h>

@interface StockChartValueAnnotationManager ()

@property (nonatomic, strong) ShinobiChart *chart;
@property (nonatomic, strong) id<StockChartDatasourceLookup> datasource;
@property (nonatomic, assign) NSInteger seriesIndex;
@property (nonatomic, strong) SChartAnnotation *lineAnnotation;
@property (nonatomic, strong) SChartAnnotation *textAnnotation;

@end

@implementation StockChartValueAnnotationManager

- (id)init {
  NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                   reason:@"Please use initWithChart:seriesIndex:" userInfo:nil];
  @throw exception;
}

- (id)initWithChart:(ShinobiChart *)chart datasource:(id<StockChartDatasourceLookup>)datasource
        seriesIndex:(NSInteger)seriesIndex {
  self = [super init];
  if (self) {
    self.chart = chart;
    self.seriesIndex = seriesIndex;
    self.datasource = datasource;
    [self createLine];
    [self createText];
    
    // Make sure the glView which contains the annotations sits on top of the tick marks
    [chart.canvas bringSubviewToFront:chart.canvas.glView];
  }
  return self;
}

- (void)createLine {
  self.lineAnnotation = [[StockChartDashedLineAnnotation alloc] initWithYValue:nil
                                                                         xAxis:self.chart.xAxis
                                                                         yAxis:self.chart.yAxis];
  [self.chart addAnnotation:self.lineAnnotation];
}

- (void)createText {
  // Create the font
  UIFont *labelFont = [UIFont systemFontOfSize:13.f];
  
  // Create our text annotation subclass. We set the text to be the widest of our possible values
  // since we only size the annotation at construction time.
  self.textAnnotation = [[StockChartAnchoredTextAnnotation alloc] initWithText:@"MM.MM"
                                                               andFont:labelFont
                                                             withXAxis:self.chart.xAxis
                                                              andYAxis:self.chart.yAxis
                                                           atXPosition:nil
                                                          andYPosition:nil
                                                         withTextColor:[UIColor whiteColor]
                                                   withBackgroundColor:[UIColor darkGrayColor]];
  [self.chart addAnnotation:self.textAnnotation];
}

#pragma mark - API Methods
- (void)updateValueAnnotationForXAxisRange:(SChartRange *)range {
  
  // Need to find the y-value at the maximum of the given x-value range
  id lastVisibleDPValue = [self.datasource estimateYValueForXValue:range.maximum
                                                  forSeriesAtIndex:self.seriesIndex];
  
  // Update the values on both annotations and redraw the chart
  self.lineAnnotation.yValue = lastVisibleDPValue;
  self.textAnnotation.yValue = lastVisibleDPValue;
  self.textAnnotation.xValue = range.maximum;
  self.textAnnotation.label.text = [NSString stringWithFormat:@"%0.2f", [lastVisibleDPValue doubleValue]];
  
  [self.chart redrawChart];
}

@end
