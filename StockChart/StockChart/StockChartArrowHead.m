//
//  StockChartArrowHead.m
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

#import "StockChartArrowHead.h"

@implementation StockChartArrowHead

- (void)setArrowHeadPointYValue:(float)arrowHeadPointYValue {
  if (arrowHeadPointYValue != _arrowHeadPointYValue)  {
    _arrowHeadPointYValue = arrowHeadPointYValue;
    [self setNeedsDisplay];
  }
}

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color {
  self = [super initWithFrame:frame];
  if (self) {
    self.color = color;
    self.backgroundColor = [UIColor clearColor];
    self.arrowHeadPointYValue = frame.size.height / 2;
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, self.color.CGColor);
  
  float frameWidth = self.frame.size.width;
  CGContextBeginPath(context);
  CGContextMoveToPoint(context, frameWidth, 0);
  CGContextAddLineToPoint(context, 0, self.arrowHeadPointYValue);
  CGContextAddLineToPoint(context, frameWidth, self.frame.size.height);
  CGContextAddLineToPoint(context, frameWidth, 0);
  
  CGContextClosePath(context);
  CGContextFillPath(context);
}

@end
