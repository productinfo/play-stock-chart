//
//  StockChartDashedLineAnnotation.m
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

#import "StockChartDashedLineAnnotation.h"
#import "ShinobiPlayUtils/UIColor+SPUColor.h"

@implementation StockChartDashedLineAnnotation

- (instancetype)initWithYValue:(id)yValue xAxis:(SChartAxis *)xAxis yAxis:(SChartAxis*)yAxis {
  // Calculate the annotation width based on the xAxis range
  CGFloat width = [xAxis pixelValueForDataValue:xAxis.axisRange.maximum] - [yAxis.width floatValue];
  self = [super initWithFrame:CGRectMake(100, 0, width, 1)];
  if (self) {
    self.xAxis = xAxis;
    self.yAxis = yAxis;
    self.yValue = yValue;
    self.xValue = nil;
    self.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *dashedLinePath = [UIBezierPath bezierPath];
    CGPoint leftPoint = CGPointMake(0.0, 0.0);
    CGPoint rightPoint = CGPointMake(self.frame.size.width, 0.0);
    [dashedLinePath moveToPoint:leftPoint];
    [dashedLinePath addLineToPoint:rightPoint];
    
    CAShapeLayer *dashedLineLayer = [CAShapeLayer layer];
    dashedLineLayer.path = dashedLinePath.CGPath;
    dashedLineLayer.strokeColor = [UIColor shinobiDarkGrayColor].CGColor;
    dashedLineLayer.lineDashPattern = @[@8.0, @6.0];
    dashedLineLayer.lineWidth = 2;
    [self.layer addSublayer:dashedLineLayer];
  }
  return self;
}

@end
