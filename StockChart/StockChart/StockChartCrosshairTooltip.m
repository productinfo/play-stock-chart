//
//  StockChartCrosshairTooltip.m
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

#import "StockChartCrosshairTooltip.h"
#import <ShinobiCharts/SChartCanvas.h>

static const CGFloat StockChartTooltipLabelPadding = 7.f;
static const CGFloat StockChartTooltipTopPadding = 50.f;

@interface StockChartCrosshairTooltip ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSNumberFormatter *volumeFormatter;

@property (strong, nonatomic) UILabel *openLabel;
@property (strong, nonatomic) UILabel *highLabel;
@property (strong, nonatomic) UILabel *lowLabel;
@property (strong, nonatomic) UILabel *closeLabel;
@property (strong, nonatomic) UILabel *volumeLabel;

@property (strong, nonatomic) NSArray *allLabels;

@end

@implementation StockChartCrosshairTooltip

- (instancetype)init {
  self = [super init];
  if (self) {
    // Set the style of our tooltip
    SChartCrosshairStyle *newStyle = [[SChartCrosshairStyle alloc] init];
    newStyle.defaultTextColor = [ShinobiCharts theme].xAxisStyle.lineColor;
    [self setTooltipStyle:newStyle];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.volumeFormatter = [[NSNumberFormatter alloc] init];
    [self.volumeFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.openLabel = [self createTooltipLabel];
    [self addSubview:self.openLabel];
    
    self.highLabel = [self createTooltipLabel];
    [self addSubview:self.highLabel];
    
    self.lowLabel = [self createTooltipLabel];
    [self addSubview:self.lowLabel];
    
    self.closeLabel = [self createTooltipLabel];
    [self addSubview:self.closeLabel];
    
    self.volumeLabel = [self createTooltipLabel];
    [self addSubview:self.volumeLabel];
    
    self.allLabels = @[self.label, self.openLabel, self.highLabel, self.lowLabel,
                       self.closeLabel, self.volumeLabel];
  }
  return self;
}


// Method to create a label to add to the tooltip
- (UILabel*)createTooltipLabel {
  UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  newLabel.backgroundColor = [UIColor clearColor];
  newLabel.textColor = style.defaultTextColor;
  return newLabel;
}

- (void)setDataPoint:(id<SChartData>)dataPoint fromSeries:(SChartSeries *)series fromChart:(ShinobiChart *)chart {
  // Get a date string from the data point
  NSString *formattedDateString = [self.dateFormatter stringFromDate:((SChartDataPoint*)dataPoint).xValue];
  
  // Find the index of the data point within our series
  NSInteger dataPointIndex = ((SChartDataPoint*)dataPoint).index;
  
  // Go through each series and contribute the relevant data
  for (SChartSeries *seriesInChart in chart.series)  {
    
    // If we are looking at the Bollinger band series, move onto the next series.  We don't
    // use this series for our tooltip, and it has fewer data points in it than the other series
    if ([seriesInChart isKindOfClass:[SChartBandSeries class]]) {
      continue;
    }
    
    id<SChartData> dataPointInSeries = [seriesInChart.dataSeries.dataPoints objectAtIndex:dataPointIndex];
    
    // OHLC data
    if ([seriesInChart isKindOfClass:[SChartOHLCSeries class]])    {
      SChartMultiYDataPoint *dp = dataPointInSeries;
      
      self.label.text = [NSString stringWithFormat:@"%@", formattedDateString];
      self.label.textAlignment = NSTextAlignmentLeft;
      
      NSNumber *open = [dp.yValues objectForKey:@"Open"];
      self.openLabel.text = [NSString stringWithFormat:@"Open: %.2f", [open floatValue]];
      
      NSNumber *high = [dp.yValues objectForKey:@"High"];
      self.highLabel.text = [NSString stringWithFormat:@"High: %.2f", [high floatValue]];
      
      NSNumber *low = [dp.yValues objectForKey:@"Low"];
      self.lowLabel.text = [NSString stringWithFormat:@"Low: %.2f", [low floatValue]];
      
      NSNumber *close = [dp.yValues objectForKey:@"Close"];
      self.closeLabel.text = [NSString stringWithFormat:@"Close: %.2f", [close floatValue]];
    }
    // Volume data
    else if ([seriesInChart isKindOfClass:[SChartColumnSeries class]]) {
      // Otherwise we are dealing with a line chart series.  This will contain standard data points.
      SChartDataPoint *dp = dataPointInSeries;
      self.volumeLabel.text = [NSString stringWithFormat:@"Volume: %@",
                               [self.volumeFormatter stringFromNumber:dp.yValue]];
    }
  }
}

- (void)setPosition:(struct SChartPoint)pos onCanvas:(SChartCanvas*)canvas {
  [super setPosition:pos onCanvas:canvas];
  
  // Lay out the labels, keeping track of the maximum width
  CGFloat maxLabelWidth = 0;
  CGFloat labelYPosition = StockChartTooltipLabelPadding;
  
  for (UILabel *label in self.allLabels) {
    // Position the label
    label.font = style.defaultFont;
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = StockChartTooltipLabelPadding;
    frame.origin.y = labelYPosition;
    label.frame = frame;
    
    maxLabelWidth = MAX(maxLabelWidth, label.frame.size.width);
    labelYPosition += label.frame.size.height;
  }
  
  CGRect frame = self.frame;
  frame.size.width = maxLabelWidth + (2 * StockChartTooltipLabelPadding);
  frame.size.height = labelYPosition + StockChartTooltipLabelPadding;
  frame.origin.y = canvas.glView.frame.origin.y + StockChartTooltipTopPadding;
  frame.origin.x = pos.x;
  
  self.frame = frame;
}

@end
