//
//  StockChartRangeSelectionAnnotation.m
//  StockChart
//
//  Created by Sam Davies on 30/12/2012.
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

#import "StockChartRangeSelectionAnnotation.h"

@implementation StockChartRangeSelectionAnnotation

- (instancetype)initWithFrame:(CGRect)frame xValue:(id)xValue xValueMax:(id)xValueMax
                        xAxis:(SChartAxis *)xAxis yAxis:(SChartAxis *)yAxis {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.xAxis = xAxis;
    self.yAxis = yAxis;
    self.yValue = nil;
    self.yValueMax = nil;
    self.xValue = xValue;
    self.xValueMax = xValueMax;
    self.backgroundColor = [UIColor clearColor];
    self.stretchToBoundsOnY = YES;
  }
  return self;
}

- (void)setTransform:(CGAffineTransform)transform {
  // Zooming annotations usually use an affine transform to set their shape.
  //  We're going to change the frame of the annotation so that we have a
  //  suitable area in which to recognise dragging gestures.
  CGRect bds = self.bounds;
  if (transform.a > 0) {
    bds.size.width *= transform.a;
  }
  if (transform.d > 0) {
    bds.size.height *= transform.d;
  }
  self.bounds = bds;
}

@end
