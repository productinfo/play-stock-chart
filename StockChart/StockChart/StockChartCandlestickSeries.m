//
//  StockChart.m
//  StockChart
//
//  Created by Alison Clarke on 20/01/2015.
//
//  Copyright 2015 Scott Logic
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

#import "StockChartCandlestickSeries.h"
#import "ShinobiPlayUtils/UIColor+SPUColor.h"

@implementation StockChartCandlestickSeries

- (SChartCandlestickSeriesStyle*)styleForPoint:(id<SChartData>)point previousPoint:(id<SChartData>)prevPoint {
  SChartCandlestickSeriesStyle *newStyle = [super styleForPoint:point previousPoint:prevPoint];
  
  // We color the candlestick based on this point's open and close values, and the previous
  // point's close value
  float open = [[point sChartYValueForKey: SChartCandlestickKeyOpen] floatValue];
  float close = [[point sChartYValueForKey: SChartCandlestickKeyClose] floatValue];
  float priorClose = [[prevPoint sChartYValueForKey: SChartCandlestickKeyClose] floatValue];
  
  newStyle.outlineWidth = @2.f;
  newStyle.stickWidth = @2.f;
  
  // If today's closing price is higher than yesterday's, the candlestick should be green;
  // otherwise it should be red
  UIColor *candlestickColor = (close > priorClose) ? [UIColor shinobiPlayGreenColor]
                                                   : [UIColor shinobiPlayRedColor];
  newStyle.outlineColor = candlestickColor;
  newStyle.stickColor = candlestickColor;
  
  // If the closing price is higher than the opening price, the candlestick should be hollow;
  // otherwise it should be filled with the outline/stick color
  if (close > open) {
    newStyle.risingColor = [UIColor clearColor];
    newStyle.risingColorGradient = [UIColor clearColor];
  } else {
    newStyle.fallingColor = candlestickColor;
    newStyle.fallingColorGradient = candlestickColor;
  }
  
  return newStyle;
}

@end
