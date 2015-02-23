//
//  StockChartCrosshair.m
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

#import "StockChartCrosshair.h"
#import "StockChartCrosshairTooltip.h"
#import "StockChartDataSource.h"
#import <ShinobiCharts/SChartCanvas.h>
#import <ShinobiCharts/SChartCanvasOverlay.h>
#import <ShinobiCharts/SChartPixelToPointMapper.h>
#import <ShinobiCharts/SChartPixelToPointMapping.h>
#import "ShinobiPlayUtils/UIColor+SPUColor.h"

@interface StockChartCrosshair ()

@property (assign, nonatomic) BOOL clippingMaskSet;
@property (assign, nonatomic) CGPoint crosshairCenter;
@property (strong, nonatomic) CAShapeLayer *line;
@property (strong, nonatomic) StockChartCrosshairTooltip *crosshairTooltip;

@end

@implementation StockChartCrosshair

// Synthesise protocol properties to avoid warning
@synthesize tooltip;
@synthesize style;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.clipsToBounds = YES;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, frame.origin.y)];
    [path addLineToPoint:CGPointMake(0, frame.origin.y + frame.size.height)];
    self.line = [CAShapeLayer layer];
    self.line.path = path.CGPath;
    self.line.strokeColor = [UIColor shinobiDarkGrayColor].CGColor;
    self.line.lineWidth = 2;
    [self.layer addSublayer:self.line];
    
    self.crosshairTooltip = [StockChartCrosshairTooltip new];
    [self addSubview:self.crosshairTooltip];
  }
  
  return self;
}

- (void)showAtPoint:(CGPoint)pointInChart inChart:(ShinobiChart *)chart {
  self.frame = [chart getPlotAreaFrame];
  [self moveToPoint:pointInChart inChart:chart];
  [self showInChart:chart];
}

- (void)showInChart:(ShinobiChart *)chart {
  [chart.canvas.overlay addSubview:self];
}

- (void)moveToPoint:(CGPoint)pointInChart inChart:(ShinobiChart *)chart {
  CGFloat xValue = pointInChart.x;
  NSDictionary *dataValues;
  
  // Get the nearest data point to pointInChart so we know where to move the crosshair to.
  // Find the SChartOHLCSeries to get the data values as it contains most data points
  for (SChartSeries *seriesInChart in chart.series) {
    if ([seriesInChart isKindOfClass:[SChartOHLCSeries class]]) {
      
      SChartPixelToPointMapper *mapper = [SChartPixelToPointMapper new];
      SChartPixelToPointMapping *mapping = [mapper mappingForPoint:pointInChart
                                                          onSeries:(SChartMappedSeries *)seriesInChart
                                                           onChart:chart];
      NSInteger dataPointIndex = [mapping.dataPoint sChartDataPointIndex];
      dataValues = [((StockChartDataSource *)chart.datasource) getValuesForIndex:dataPointIndex];
      xValue = [chart.xAxis pixelValueForDataValue:dataValues[@"Date"]];
      break;
    }
  }
  
  // Hide crosshair if out of range of chart (leaving some leeway for gestures)
  if (xValue > self.frame.size.width + 10 || xValue < -10) {
    [self hide];
  } else {
    if (!self.superview) {
      [self showInChart:chart];
    }
    [self.crosshairTooltip setXPosition:xValue andData:dataValues inChart:chart];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationDuration:0];
    self.line.position = CGPointMake(xValue, self.line.position.y);
    [CATransaction commit];
  }
}

- (void)hide {
  [self removeFromSuperview];
}

@end
