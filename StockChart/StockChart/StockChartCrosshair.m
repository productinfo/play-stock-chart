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
#import <ShinobiCharts/SChartCanvas.h>

@interface StockChartCrosshair ()

@property (assign, nonatomic) BOOL clippingMaskSet;
@property (assign, nonatomic) CGPoint crosshairCenter;
@end

@implementation StockChartCrosshair

-(id)initWithChart:(ShinobiChart *)parentChart {
  self = [super initWithChart:parentChart];
  if (self)   {
    self.clippingMaskSet = NO;
  }
  
  return self;
}

-(void) drawCrosshairLines {
  SChartCanvas *canvas = self.chart.canvas;
  CGContextRef c = UIGraphicsGetCurrentContext();
  
  CGContextSetStrokeColorWithColor(c, [ShinobiCharts theme].xAxisStyle.lineColor.CGColor);
  
  if(self.style.lineWidth) {
    CGContextSetLineWidth(c, self.style.lineWidth.floatValue);
  }
  
  // draw the lines
  if(self.enableCrosshairLines){
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, self.crosshairCenter.x, canvas.glView.frame.origin.y);
    CGContextAddLineToPoint(c, self.crosshairCenter.x, canvas.glView.frame.origin.y + canvas.glView.bounds.size.height);
    CGContextStrokePath(c);
  }
}

- (void)moveToPosition:(SChartPoint)coords andDisplayDataPoint:(SChartPoint)dataPoint
            fromSeries:(SChartCartesianSeries *)series andSeriesDataPoint:(id<SChartData>)dataseriesPoint {
  // The first time we move the crosshair to a position, we set the clipping mask on the
  // crosshair's layer.  This is a good time to do it, as we know that the chart canvas
  // will have been rendered by this point.
  if (!self.clippingMaskSet)   {
    double clippingAreaWidth = self.chart.canvas.glView.frame.size.width + [self.chart.yAxis.style.lineWidth doubleValue];
    
    CGRect clippingRect = self.chart.canvas.glView.frame;
    clippingRect.size.width = clippingAreaWidth;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:clippingRect];
    
    // Create a shape layer
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.frame;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
    self.clippingMaskSet = YES;
  }
  
  // Save the crosshair center so we can use it to draw the lines
  self.crosshairCenter = CGPointMake(coords.x, coords.y);
  
  [super moveToPosition:coords andDisplayDataPoint:dataPoint fromSeries:series andSeriesDataPoint:dataseriesPoint];
}

@end
