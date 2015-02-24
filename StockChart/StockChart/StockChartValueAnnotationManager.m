//
//  StockChartValueAnnotationManager.m
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

#import "StockChartValueAnnotationManager.h"
#import "StockChartValueView.h"
#import "StockChartDashedLineAnnotation.h"
#import <ShinobiCharts/SChartCanvas.h>
#import <ShinobiCharts/SChartGLView.h>
#import "ShinobiPlayUtils/UIFont+SPUFont.h"
#import "ShinobiPlayUtils/UIColor+SPUColor.h"

@interface StockChartValueAnnotationManager ()

@property (nonatomic, strong) ShinobiChart *chart;
@property (nonatomic, strong) id<StockChartDatasourceLookup> datasource;
@property (nonatomic, assign) NSInteger seriesIndex;
@property (nonatomic, strong) SChartAnnotation *lineAnnotation;
@property (nonatomic, strong) StockChartValueView *valueView;

@end

@implementation StockChartValueAnnotationManager

- (instancetype)init {
  NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                   reason:@"Please use initWithChart:seriesIndex:" userInfo:nil];
  @throw exception;
}

- (instancetype)initWithChart:(ShinobiChart *)chart datasource:(id<StockChartDatasourceLookup>)datasource
                  seriesIndex:(NSInteger)seriesIndex {
  self = [super init];
  if (self) {
    self.chart = chart;
    self.seriesIndex = seriesIndex;
    self.datasource = datasource;
    [self createLine];
    [self createText];
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
  UIFont *labelFont = [UIFont boldShinobiFontOfSize:13.f];
  
  // Create our text annotation subclass. We set the text to be the widest of our possible values
  // since we only size the annotation at construction time.
  self.valueView = [[StockChartValueView alloc] initWithText:@"MM.MM"
                                                     andFont:labelFont
                                               withTextColor:[UIColor whiteColor]
                                         withBackgroundColor:[UIColor shinobiDarkGrayColor]];
  [self.chart addSubview:self.valueView];
}

#pragma mark - API Methods
- (void)updateValueAnnotationForXAxisRange:(SChartRange *)xRange yAxisRange:(SChartRange *)yRange
                                    redraw:(BOOL)redraw {
  // Need to find the y-value at the maximum of the given x-value range
  id lastVisibleDPValue = [self.datasource estimateYValueForXValue:xRange.maximum
                                                  forSeriesAtIndex:self.seriesIndex];
  CGFloat lastVisibleDPValueDouble = [lastVisibleDPValue doubleValue];
  
  if ([lastVisibleDPValue compare:yRange.minimum] == NSOrderedAscending ||
      [lastVisibleDPValue compare:yRange.maximum] == NSOrderedDescending) {
    self.lineAnnotation.alpha = 0;
    self.valueView.alpha = 0;
  } else {
    // Update the value on line annotation
    self.lineAnnotation.yValue = lastVisibleDPValue;
    [self.lineAnnotation updateViewWithCanvas:self.chart.canvas];
    
    // Update position and text of value view
    CGPoint pointInPlotArea = CGPointMake(CGRectGetMaxX([self.chart getPlotAreaFrame]),
                                          [self.chart.yAxis pixelValueForDataValue:lastVisibleDPValue]);
    CGPoint pointInChart = [self.chart convertPoint:pointInPlotArea
                                           fromView:self.chart.canvas.glView];
    [self.valueView setPosition:pointInChart];
    self.valueView.label.text = [NSString stringWithFormat:@"%0.2f", lastVisibleDPValueDouble];
    
    // Make sure they're both visible
    self.lineAnnotation.alpha = 1;
    self.valueView.alpha = 1;
  }
  
  if (redraw) {
    [self.chart redrawChart];
  }
}

- (void)updateValueAnnotationForXAxisRange:(SChartRange *)xRange yAxisRange:(SChartRange *)yRange {
  [self updateValueAnnotationForXAxisRange:xRange yAxisRange:yRange redraw:YES];
}

@end
