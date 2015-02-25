//
//  StockChartValueView.m
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

#import "StockChartValueView.h"
#import "StockChartArrowHead.h"

@implementation StockChartValueView

- (instancetype)initWithText:(NSString *)text andFont:(UIFont *)font
               withTextColor:(UIColor *)textColor withBackgroundColor:(UIColor *)bgColor {
  self = [super init];
  if (self) {
    // Add the label
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.backgroundColor = bgColor;
    self.label.font = font;
    self.label.textColor = textColor;
    self.label.text = text;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.label sizeToFit];
    
    // Add the arrow
    StockChartArrowHead *arrowHead = [[StockChartArrowHead alloc] initWithFrame:CGRectMake(0,
                                                                                           0,
                                                                                           self.label.bounds.size.height/2,
                                                                                           self.label.bounds.size.height)
                                                                          color:bgColor];
    
    self.label.center = CGPointMake(arrowHead.bounds.size.width + self.label.center.x - 0.5, self.label.center.y);
    [self addSubview:self.label];
    [self addSubview:arrowHead];
    
    // Fit the frame to the contents
    self.frame = CGRectMake(0,
                            0,
                            arrowHead.bounds.size.width + self.label.bounds.size.width,
                            self.label.bounds.size.height);
  }
  return self;
}

- (void)setPosition:(CGPoint)leftMiddlePosition {
  self.center = CGPointMake(leftMiddlePosition.x + self.bounds.size.width / 2,
                            leftMiddlePosition.y);
}


@end
