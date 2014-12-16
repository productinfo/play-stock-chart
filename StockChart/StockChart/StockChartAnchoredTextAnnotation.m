//
//  StockChartAnchoredTextAnnotation.m
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

#import "StockChartAnchoredTextAnnotation.h"
#import "StockChartArrowHead.h"

@implementation StockChartAnchoredTextAnnotation

- (instancetype)initWithText:(NSString *)text andFont:(UIFont *)font withXAxis:(SChartAxis *)xAxis
                    andYAxis:(SChartAxis *)yAxis atXPosition:(id)xPosition andYPosition:(id)yPosition
               withTextColor:(UIColor *)textColor withBackgroundColor:(UIColor *)bgColor {
  self = [super init];
  if (self) {
    // Set all the required properties
    self.xAxis = xAxis;
    self.yAxis = yAxis;
    self.xValue = xPosition;
    self.yValue = yPosition;
    
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.backgroundColor = bgColor;
    self.label.font = font;
    self.label.textColor = textColor;
    self.label.text = text;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.label sizeToFit];
    
    StockChartArrowHead *arrowHead = [[StockChartArrowHead alloc] initWithFrame:CGRectMake(0,
                                                                                           0,
                                                                                           self.label.bounds.size.height/2,
                                                                                           self.label.bounds.size.height)
                                                                          color:bgColor];
    
    self.label.center = CGPointMake(arrowHead.bounds.size.width + self.label.center.x, self.label.center.y);
    [self addSubview:self.label];
    [self addSubview:arrowHead];
    [self sizeToFit];
  }
  return self;
}

- (void)updateViewWithCanvas:(SChartCanvas *)canvas {
  [super updateViewWithCanvas:canvas];
  // Move us so we are anchored on the middle left
  self.center = CGPointMake(self.center.x + self.bounds.size.width / 2, self.center.y);
}


@end
