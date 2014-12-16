//
//  StockChartRangeHandleAnnotation.m
//  StockChart
//
//  Created by Sam Davies on 29/12/2012.
//
//  Copyright 2013 Scott Logic
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

#import "StockChartRangeHandleAnnotation.h"
#import <QuartzCore/QuartzCore.h>

@implementation StockChartRangeHandleAnnotation

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color xValue:(id)xValue
                        xAxis:(SChartAxis *)xAxis yAxis:(SChartAxis *)yAxis {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.xAxis = xAxis;
    self.yAxis = yAxis;
    self.xValue = xValue;
    // Setting this to nil will ensure that the handle appears in the centre
    self.yValue = nil;
    
    [self drawHandleWithColor:color];
  }
  return self;
}

- (void)drawHandleWithColor:(UIColor *)color {
  CAShapeLayer *circle = [CAShapeLayer layer];
  UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.frame];
  circle.path = path.CGPath;
  circle.fillColor = color.CGColor;
  [self.layer addSublayer:circle];
}

@end
