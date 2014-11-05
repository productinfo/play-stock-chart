//
//  ArrowHeadView.m
//  ShinobiControls
//
//  Created by  on 21/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
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
