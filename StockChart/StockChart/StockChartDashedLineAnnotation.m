//
//  DashedLineAnnotation.m
//  ShinobiControls
//
//  Created by Sam Davies on 29/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "StockChartDashedLineAnnotation.h"

@implementation StockChartDashedLineAnnotation

@synthesize dashedLine;

- (id)initWithYValue:(id)yValue xAxis:(SChartAxis *)xAxis yAxis:(SChartAxis*)yAxis {
  // Calculate the annotation width based on the xAxis range
  CGFloat width = [xAxis pixelValueForDataValue:xAxis.axisRange.maximum] - [yAxis.width floatValue];
  self = [super initWithFrame:CGRectMake(100, 0, width, 1)];
  if (self) {
    self.xAxis = xAxis;
    self.yAxis = yAxis;
    self.yValue = yValue;
    self.xValue = nil;
    self.backgroundColor = [UIColor clearColor];
    
    [self createDashedLine];
  }
  return self;
}

- (void)createDashedLine {
  self.dashedLine = [UIBezierPath bezierPath];
  CGPoint leftPoint = CGPointMake(0.0, 0.0);
  CGPoint rightPoint = CGPointMake(self.frame.size.width, 0.0);
  [self.dashedLine moveToPoint:leftPoint];
  [self.dashedLine addLineToPoint:rightPoint];
  [self.dashedLine setLineWidth:2.0f];
  CGFloat lineDash[2] = {8.0, 6.0};
  [self.dashedLine setLineDash:lineDash count:2 phase:0.0];
}

- (void)drawRect:(CGRect)rect {
  [self createDashedLine];
  [[ShinobiCharts theme].xAxisStyle.lineColor setStroke];
  [self.dashedLine stroke];
}


@end
