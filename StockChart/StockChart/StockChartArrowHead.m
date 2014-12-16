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

@interface StockChartArrowHead ()

@property (strong, nonatomic) CAShapeLayer *arrowHead;

@end

@implementation StockChartArrowHead

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color {
  self = [super initWithFrame:frame];
  if (self) {
    self.color = color;
    self.backgroundColor = [UIColor clearColor];
    
    self.arrowHead = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(frame.size.width, 0)];
    [path addLineToPoint:CGPointMake(0, frame.size.height / 2)];
    [path addLineToPoint:CGPointMake(frame.size.width, frame.size.height)];
    [path addLineToPoint:CGPointMake(frame.size.width, 0)];
    self.arrowHead.path = path.CGPath;
    self.arrowHead.lineWidth = 0;
    self.arrowHead.anchorPoint = CGPointMake(0, 0.5);
    self.arrowHead.fillColor = self.color.CGColor;
    
    [self.layer addSublayer:self.arrowHead];
  }
  return self;
}

- (void)setColor:(UIColor *)color {
  _color = color;
  self.arrowHead.fillColor = color.CGColor;
}

@end
